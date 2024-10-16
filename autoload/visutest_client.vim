" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_client.vim                                :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:50:44 by jeportie          #+#    #+#              "
"    Updated: 2024/10/16 15:50:47 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

"""""""""" Initialize Global Variables """""""""""""""""""""""""""""
if !exists('g:visutest_test_logs')
  let g:visutest_test_logs = {}
  echom "Initialized g:visutest_test_logs"
endif
if !exists('g:visutest_test_statuses')
  let g:visutest_test_statuses = {}
  echom "Initialized g:visutest_test_statuses"
endif
if !exists('g:visutest_subtest_statuses')
  let g:visutest_subtest_statuses = {}
  echom "Initialized g:visutest_subtest_statuses"
endif
if !exists('g:visutest_all_subtests')
  let g:visutest_all_subtests = {}
  echom "Initialized g:visutest_all_subtests"
endif

"""""""""" Function to start the client/tests """""""""""""""""""""
function! visutest_client#StartTests()
  " Define the absolute path to the client script
  let l:client_script = '/root/.vim/plugged/VisuTest/server/client.py'

  " Check if the client script exists and is readable
  if !filereadable(l:client_script)
    echoerr "Client script not found or unreadable: " . l:client_script
    return
  endif

  " Use job_start() to run the client script
  let l:cmd = ['python3', l:client_script]
  let l:opts = {
        \ 'out_cb': function('visutest_client#OnData'),
        \ 'err_cb': function('visutest_client#OnError'),
        \ 'exit_cb': function('visutest_client#OnExit'),
        \ }

  let g:visutest_client_job = job_start(l:cmd, l:opts)

  if type(g:visutest_client_job) == v:t_job
    echom "VisuTest client started."
  else
    echoerr "Failed to start the VisuTest client."
  endif
endfunction

"""""""""" Function to print the log for a specific test suite """"""""""""""
function! visutest_client#PrintTestLog(test_name)
  " Check if the test suite exists in the dictionary
  if has_key(g:visutest_test_logs, a:test_name)
    " Get the test log for the suite
    let l:test_log = g:visutest_test_logs[a:test_name]

    " Print the test log line by line
    echom "Log for test suite: " . a:test_name
    for l:line in l:test_log
      echom l:line
    endfor
  else
    " If the test suite is not found in the dictionary
    echoerr "No log found for test suite: " . a:test_name
  endif
endfunction

"""""""""" Function to handle structured data from the client """""""""""""""""
function! visutest_client#OnData(job, data)
  " Debug: Check the type of a:data
  echom "Type of a:data: " . type(a:data)

  " Ensure a:data is a list
  if type(a:data) != type([])
    echom "Error: a:data is not a list."
    return
  endif

  " Accumulate all incoming data into a single string
  let l:raw_data = join(a:data, "\n")

  " Clean the data by removing control characters and NULL bytes
  let l:clean_data = substitute(l:raw_data, '[\x00-\x1F\x7F]', '', 'g')

  " Skip processing if the cleaned data is empty
  if l:clean_data == ''
    return
  endif

  " Debug: Log the cleaned data
  echom "Received Data: " . l:clean_data

  " Check for specific test statuses or log signals
  if l:clean_data =~ 'RUNNING:'
    let l:test_name = matchstr(l:clean_data, 'RUNNING:\s*\zs.*')
    let l:test_name = substitute(l:test_name, '^test_', '', '')

    " Set the current test name and initialize its log in the dictionary
    let g:visutest_current_test = l:test_name
    let g:visutest_test_logs[g:visutest_current_test] = []  " Initialize an empty log buffer
    let g:visutest_subtest_statuses[g:visutest_current_test] = {}  " Initialize sub-test statuses

    echom "Started test: " . l:test_name

    " Update UI for the running test
    call visutest_ui#UpdateTestStatus(l:test_name, 'running')

  elseif l:clean_data =~ 'PASSED'
    " Update UI for the passed test
    call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'passed')
    let g:visutest_test_statuses[g:visutest_current_test] = 'passed'

    echom "Test passed: " . g:visutest_current_test

  elseif l:clean_data =~ 'FAILED'
    " Update UI for the failed test
    call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'failed')
    let g:visutest_test_statuses[g:visutest_current_test] = 'failed'

    echom "Test failed: " . g:visutest_current_test
  endif

  " Check if we are in a log section by detecting '---'
  if l:clean_data =~ '^---'
    let l:log_lines = split(l:clean_data, "\n")

    " Iterate over each line and add it to the log buffer for the current test
    for l:line in l:log_lines
      if l:line != ''
        call add(g:visutest_test_logs[g:visutest_current_test], l:line)
      endif
    endfor

    " Parse sub-test results from the log
    call visutest_client#ParseSubTestResults(g:visutest_current_test)

  else
    " If not a separator, continue adding all relevant log lines to the buffer
    let l:log_lines = split(l:clean_data, "\n")
    for l:line in l:log_lines
      if l:line != ''
        call add(g:visutest_test_logs[g:visutest_current_test], l:line)
      endif
    endfor
  endif
endfunction

"""""""""" Function to parse sub-test results from test logs """""""""""""""
function! visutest_client#ParseSubTestResults(test_name)
  let l:log = g:visutest_test_logs[a:test_name]
  let l:subtest_statuses = {}

  " Extract failed sub-tests from lines containing 'Core:'
  for l:line in l:log
    if l:line =~ 'Core:'
      " Example line:
      " /root/projects/Minishell/test_src/init_shell/test_ms_init_env.c:72:F:Core:test_ms_init_env_without_envp:0: Assertion 'current->var == "PwD"' failed: current->var == "PWD", "PwD" == "PwD"

      " Extract the sub-test name after 'Core:'
      let l:core_pos = match(l:line, 'Core:')
      if l:core_pos != -1
        let l:substr = strpart(l:line, l:core_pos + len('Core:'))
        " Extract up to the next colon
        let l:subtest_name = matchstr(l:substr, '^\w\+')
        if !empty(l:subtest_name)
          let l:subtest_statuses[l:subtest_name] = 'failed'
          echom "Subtest failed: " . l:subtest_name
        endif
      endif
    endif
  endfor

  " Assume all sub-tests passed initially
  if has_key(g:visutest_all_subtests, a:test_name)
    for l:subtest in g:visutest_all_subtests[a:test_name]
      if has_key(l:subtest_statuses, l:subtest)
        " Sub-test already marked as failed
        continue
      else
        " Mark as passed
        let l:subtest_statuses[l:subtest] = 'passed'
        echom "Subtest passed: " . l:subtest
      endif
    endfor
  else
    echom "No sub-tests found for suite: " . a:test_name
  endif

  " Initialize the subtest_statuses dictionary for the test suite if not already done
  if !has_key(g:visutest_subtest_statuses, a:test_name)
    let g:visutest_subtest_statuses[a:test_name] = {}
  endif

  " Update the global sub-test statuses
  for [l:subtest, l:status] in items(l:subtest_statuses)
    let g:visutest_subtest_statuses[a:test_name][l:subtest] = l:status
  endfor

  " Update the UI for sub-tests
  call visutest_ui#UpdateSubTestStatuses(a:test_name, g:visutest_subtest_statuses[a:test_name])
endfunction

"""""""""" Callback for client errors """""""""""""""""""""
function! visutest_client#OnError(job, data)
  if empty(a:data)
    echoerr "VisuTest client error: No data received."
    return
  endif
  for l:line in a:data
    if type(l:line) == type('') && l:line != ''
      echoerr "VisuTest client error: " . l:line
    else
      echoerr "VisuTest client error: Unexpected data format."
    endif
  endfor
endfunction

"""""""""" Callback for client exit """""""""""""""""""""
function! visutest_client#OnExit(job, exit_status)
  echom "VisuTest client exited with code " . a:exit_status
endfunction

