" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_client.vim                                :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/29 19:12:00 by jeportie          #+#    #+#              "
"                                                                              "
" **************************************************************************** "

"""""""""" Function to start the client/tests """""""""""""""""""""

function! visutest_client#StartTests()
  call visutest_server#StartServer()

  " Define the absolute path to the client script
  let l:client_script = '/root/.vim/plugged/VisuTest/server/client.py'

  " Check if the client script exists and is readable
  if !filereadable(l:client_script)
    echoerr "Client script not found or unreadable: " . l:client_script
    return
  endif

  " Initialize a dictionary to store test logs
  if !exists('g:visutest_test_logs')
    let g:visutest_test_logs = {}
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

""""""""""""" Function to print the log for a specific test suite """"""""""""""
function! visutest_client#PrintTestLog(test_name)
  " Ensure the global log dictionary exists
  if !exists('g:visutest_test_logs')
    echoerr "Test logs are not available."
    return
  endif

  " Clean up the test suite name by removing any 'test_' prefix
  let l:test_name = substitute(a:test_name, '^test_', '', '')

  " Check if the test suite exists in the dictionary
  if has_key(g:visutest_test_logs, l:test_name)
    " Get the test log for the suite
    let l:test_log = g:visutest_test_logs[l:test_name]

    " Print the test log line by line
    echom "Log for test suite: " . l:test_name
    for l:line in l:test_log
      echom l:line
    endfor
  else
    " If the test suite is not found in the dictionary
    echoerr "No log found for test suite: " . l:test_name
  endif
endfunction

"""""""""""""""" Function to handle structured data from the client """""""""""""""""
function! visutest_client#OnData(job, data)
  " Ensure global variables are initialized
  if !exists('g:visutest_current_test')
    let g:visutest_current_test = ''
  endif

  if !exists('g:visutest_test_logs')
    let g:visutest_test_logs = {}
  endif

  let l:buffer = ''  " Initialize buffer for the log content
  let l:output_buffer = ''  " Buffer to accumulate client data for final echom

  " Process each line in the data block received from the client
  for l:line in a:data
    " Clean the line: remove null characters and non-printable characters before processing
    let l:clean_line = substitute(l:line, '[^\x20-\x7E]', '', 'g')

    " Skip empty or invalid lines after cleaning
    if l:clean_line == ''
      continue
    endif

    " Accumulate clean data into output buffer for final echom
    let l:output_buffer .= l:clean_line . "\n"

    " Check for RUNNING, PASSED, or FAILED signals
    if l:clean_line =~ '^RUNNING:'
      let l:test_name = matchstr(l:clean_line, 'RUNNING:\s*\zs.*')
      let l:test_name = substitute(l:test_name, '^test_', '', '')

      " Set the current test name
      let g:visutest_current_test = l:test_name

      " Update UI for the running test
      call visutest_ui#UpdateTestStatus(l:test_name, 'running')

    elseif l:clean_line ==# 'PASSED'
      " Update UI for the passed test
      call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'passed')

    elseif l:clean_line ==# 'FAILED'
      " Update UI for the failed test
      call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'failed')

    elseif l:clean_line =~ '^---'  " Detect the start of a test log block
      let l:buffer = l:clean_line  " Start a new buffer for the log

    elseif l:clean_line =~ '^Test Passed.$' || l:clean_line =~ '^Test Failed.$'
      " Finalize and store the test log when a log block is completed
      let l:buffer .= "\n" . l:clean_line
      let g:visutest_test_logs[g:visutest_current_test] = split(l:buffer, "\n")

    else
      " Append to the log buffer if in a log block
      let l:buffer .= "\n" . l:clean_line
    endif
  endfor

  " Display the accumulated client data in one echom
  echom "Client received data:\n" . l:output_buffer
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

