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

"""""""""" Callback for client data """""""""""""""""""""

function! visutest_client#OnData(job, data)
  echom "Client data callback triggered."
  let l:log_file = '/tmp/visutest.log'  " Change to a path we know is writable
  
  for l:line in a:data
    if l:line == ''
      continue
    endif
    " Log received data
    call writefile([strftime("%Y-%m-%d %H:%M:%S") . " Client received: " . l:line], l:log_file, 'a')
    echom "Client received: " . l:line

    " Check for RUNNING, PASSED, or FAILED signals
    if l:line =~ '^RUNNING:'
      let l:test_name = matchstr(l:line, 'RUNNING:\s*\zs.*')
      let l:test_name = substitute(l:test_name, '^test_', '', '')
      let g:visutest_current_test = l:test_name
      call writefile([strftime("%Y-%m-%d %H:%M:%S") . " Test is running: " . l:test_name], l:log_file, 'a')
      echom "Test is running: " . l:test_name
      call visutest_ui#UpdateTestStatus(l:test_name, 'running')
    elseif l:line ==# 'PASSED'
      call writefile([strftime("%Y-%m-%d %H:%M:%S") . " Test passed: " . g:visutest_current_test], l:log_file, 'a')
      echom "Test passed: " . g:visutest_current_test
      call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'passed')
    elseif l:line ==# 'FAILED'
      call writefile([strftime("%Y-%m-%d %H:%M:%S") . " Test failed: " . g:visutest_current_test], l:log_file, 'a')
      echom "Test failed: " . g:visutest_current_test
      call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'failed')
    else
      " Accumulate test logs
      if !has_key(g:visutest_test_logs, g:visutest_current_test)
        let g:visutest_test_logs[g:visutest_current_test] = []
      endif
      call add(g:visutest_test_logs[g:visutest_current_test], l:line)
      call writefile([strftime("%Y-%m-%d %H:%M:%S") . " Log line added for test: " . g:visutest_current_test . " -> " . l:line], l:log_file, 'a')
    endif
  endfor
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
