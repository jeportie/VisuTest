" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_client.vim                                :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:50:44 by jeportie          #+#    #+#              "
"    Updated: 2024/10/28 14:18:17 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Initialize Global Variables
if !exists('g:visutest_test_logs')
  let g:visutest_test_logs = {}
endif
if !exists('g:visutest_test_statuses')
  let g:visutest_test_statuses = {}
endif
if !exists('g:visutest_subtest_statuses')
  let g:visutest_subtest_statuses = {}
endif
if !exists('g:visutest_all_subtests')
  let g:visutest_all_subtests = {}
endif

" Function to start the client/tests
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
    " Client started successfully
  else
    echoerr "Failed to start the VisuTest client."
  endif
endfunction

" Function to handle structured data from the client
function! visutest_client#OnData(job, data)
  echomsg "Received data: " . a:data

  if type(a:data) == type('')
    let l:data = [a:data]
  elseif type(a:data) == type([])
    let l:data = a:data
  else
    return
  endif

  let l:raw_data = join(l:data, "\n")
  let l:clean_data = substitute(l:raw_data, '[\x00-\x1F\x7F]', '', 'g')
  echomsg "Cleaned data: " . l:clean_data

  if l:clean_data == ''
    return
  endif

  if l:clean_data =~ 'CMAKE_ERROR:' || l:clean_data =~ 'MAKE_ERROR:'
    let g:visutest_build_error = substitute(l:clean_data, '<br>', "\n", 'g')
    echomsg "Build error set for popup: " . g:visutest_build_error
    call visutest_ui#ShowBuildErrorPopup()
    return
  endif

  " Update test suite status and set as current test
  if l:clean_data =~ 'RUNNING:'
    let l:test_name = matchstr(l:clean_data, 'RUNNING:\s*\zs.*')
    let l:test_name = substitute(l:test_name, '^test_', '', '')
    let g:visutest_current_test = l:test_name
    let g:visutest_test_logs[g:visutest_current_test] = []
    let g:visutest_subtest_statuses[g:visutest_current_test] = {}
    echomsg "Test started: " . l:test_name
    call visutest_ui#UpdateTestStatus(l:test_name, 'running')

  elseif l:clean_data =~ 'PASSED'
    echomsg "Test passed: " . g:visutest_current_test
    call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'passed')
    call visutest_client#ParseSubTestResults(g:visutest_current_test)

  elseif l:clean_data =~ 'FAILED'
    echomsg "Test failed: " . g:visutest_current_test
    call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'failed')
    call visutest_client#ParseSubTestResults(g:visutest_current_test)
  endif

  " Accumulate log lines for subtest processing
  if exists("g:visutest_current_test") && !empty(g:visutest_current_test)
    let l:log_lines = split(l:clean_data, "\n")
    for l:line in l:log_lines
      if l:line != ''
        call add(g:visutest_test_logs[g:visutest_current_test], l:line)
      endif
    endfor
  endif
endfunction

" Function to parse sub-test results from test logs
function! visutest_client#ParseSubTestResults(test_name)
  let l:log = g:visutest_test_logs[a:test_name]
  let l:subtest_statuses = {}

  " Parse each log line for sub-test status updates
  for l:line in l:log
    if l:line =~ 'Core:' || l:line =~ 'SubTest'
      " Extract the sub-test name after 'Core:' or 'SubTest'
      let l:subtest_name = matchstr(l:line, '\v(Core|SubTest):\s*(\w+)', 1)
      let l:subtest_status = l:line =~ 'failed' ? 'failed' : 'passed'
      let l:subtest_statuses[l:subtest_name] = l:subtest_status
    endif
  endfor

  " Default all unlisted sub-tests to 'passed'
  if has_key(g:visutest_all_subtests, a:test_name)
    for l:subtest in g:visutest_all_subtests[a:test_name]
      if !has_key(l:subtest_statuses, l:subtest)
        let l:subtest_statuses[l:subtest] = 'passed'
      endif
    endfor
  endif

  " Update global sub-test statuses and UI
  let g:visutest_subtest_statuses[a:test_name] = l:subtest_statuses
  call visutest_ui#UpdateSubTestStatuses(a:test_name, g:visutest_subtest_statuses[a:test_name])
endfunction

" Callback for client errors
function! visutest_client#OnError(job, data)
  if empty(a:data)
    echoerr "VisuTest client error: No data received."
    return
  endif
  for l:line in a:data
    if type(l:line) == type('') && l:line != ''
      echoerr "VisuTest client error: " . l:line
    endif
  endfor
endfunction

" Callback for client exit
function! visutest_client#OnExit(job, exit_status)
  " Client exited
endfunction

