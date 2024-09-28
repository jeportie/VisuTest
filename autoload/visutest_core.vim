" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_core.vim                                  :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/28 14:12:40 by jeportie          #+#    #+#              "
"    Updated: 2024/09/28 21:22:12 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Function to start the server
function! visutest_core#StartServer()
  " Define the absolute path to the server script
  let l:server_script = '/root/.vim/plugged/VisuTest/server/server.py'

  " Debugging: Print server script path
  echom "Server Script: " . l:server_script

  " Check if the server script exists and is readable
  if !filereadable(l:server_script)
    echoerr "Server script not found or unreadable: " . l:server_script
    return
  endif

  " Check if the server is already running
  if exists('g:visutest_server_job') && job_status(g:visutest_server_job) ==# 'run'
    " Server is already running
    echom "VisuTest server is already running."
    return
  endif

  " Start the server using job_start()
  let l:cmd = ['python3', l:server_script]
  let l:opts = {
        \ 'out_cb': function('visutest_core#ServerOutput'),
        \ 'err_cb': function('visutest_core#ServerError'),
        \ 'exit_cb': function('visutest_core#ServerExit'),
        \ 'mode': 'line',
        \ }

  let g:visutest_server_job = job_start(l:cmd, l:opts)

  if type(g:visutest_server_job) == v:t_job
    echom "VisuTest server started."
  else
    echoerr "Failed to start the VisuTest server."
  endif
endfunction

" Callback for server output
function! visutest_core#ServerOutput(job, data)
  " Handle server output if needed
  " For debugging, you can echo the output
  " for l:line in a:data
  "   echom "Server Output: " . l:line
  " endfor
endfunction

" Callback for server errors
function! visutest_core#ServerError(job, data)
  for l:line in a:data
    if l:line != ''
      echoerr "VisuTest server error: " . l:line
    endif
  endfor
endfunction

" Callback for server exit
function! visutest_core#ServerExit(job, exit_status)
  echom "VisuTest server exited with code " . a:exit_status
endfunction

" Function to start the client/tests
function! visutest_core#StartTests()
  " Ensure the server is running
  call visutest_core#StartServer()

  " Define the absolute path to the client script
  let l:client_script = '/root/.vim/plugged/VisuTest/server/client.py'

  " Debugging: Print client script path
  echom "Client Script: " . l:client_script

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
        \ 'out_cb': function('visutest_core#OnData'),
        \ 'err_cb': function('visutest_core#OnError'),
        \ 'exit_cb': function('visutest_core#OnExit'),
        \ 'mode': 'line',
        \ }

  let g:visutest_client_job = job_start(l:cmd, l:opts)

  if type(g:visutest_client_job) == v:t_job
    echom "VisuTest client started."
  else
    echoerr "Failed to start the VisuTest client."
  endif
endfunction

" Callback for client data
function! visutest_core#OnData(job, data)
  for l:line in a:data
    if l:line == ''
      continue
    endif
    " Check for RUNNING, PASSED, or FAILED signals
    if l:line =~ '^RUNNING:'
      let l:test_name = matchstr(l:line, 'RUNNING:\s*\zs.*')
      " Remove 'test_' prefix if present
      let l:test_name = substitute(l:test_name, '^test_', '', '')
      let g:visutest_current_test = l:test_name
      call visutest_ui#UpdateTestStatus(l:test_name, 'running')
    elseif l:line ==# 'PASSED'
      call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'passed')
    elseif l:line ==# 'FAILED'
      call visutest_ui#UpdateTestStatus(g:visutest_current_test, 'failed')
    else
      " Accumulate test logs
      if !has_key(g:visutest_test_logs, g:visutest_current_test)
        let g:visutest_test_logs[g:visutest_current_test] = []
      endif
      call add(g:visutest_test_logs[g:visutest_current_test], l:line)
    endif
  endfor
endfunction

" Callback for client errors
function! visutest_core#OnError(job, data)
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

" Callback for client exit
function! visutest_core#OnExit(job, exit_status)
  echom "VisuTest client exited with code " . a:exit_status
endfunction

" Function to stop the server
function! visutest_core#StopServer()
  if exists('g:visutest_server_job') && job_status(g:visutest_server_job) ==# 'run'
    call job_stop(g:visutest_server_job)
    unlet g:visutest_server_job
    echom "VisuTest server stopped."
  endif
endfunction
