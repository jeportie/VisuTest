" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_core.vim                                  :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/28 14:12:40 by jeportie          #+#    #+#              "
"    Updated: 2024/09/28 20:28:44 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Function to start the server
function! visutest_core#StartServer()
  " Define the path to the server script
  let l:script_path = expand('<sfile>:p:h')
  let l:plugin_root = fnamemodify(l:script_path, ':h')
  let l:server_script = l:plugin_root . '/server/server.py'
  
  " Check if the server is already running
  if exists('g:visutest_server_job') && job_status(g:visutest_server_job) ==# 'run'
    " Server is already running
    return
  endif

  " Start the server using jobstart()
  let l:cmd = ['python3', l:server_script]
  let l:opts = {
        \ 'rpc': v:false,
        \ 'detach': v:true,
        \ 'stdout_buffered': v:false,
        \ 'stderr_buffered': v:false,
        \ }

  let g:visutest_server_job = job_start(l:cmd, l:opts)

  if g:visutest_server_job <= 0
    echoerr "Failed to start the VisuTest server."
  else
    echom "VisuTest server started."
  endif
endfunction


function! visutest_core#StartTests()
  " Ensure the server is running
  call visutest_core#StartServer()

  if exists('g:visutest_client_job') && job_status(g:visutest_client_job) ==# 'run'
    echo "Tests are already running."
    return
  endif

  " Define the path to the client script
  let l:script_path = expand('<sfile>:p:h')
  let l:plugin_root = fnamemodify(l:script_path, ':h')
  let l:client_script = l:plugin_root . '/server/client.py'

  " Initialize a dictionary to store test logs
  if !exists('g:visutest_test_logs')
    let g:visutest_test_logs = {}
  endif

  " Use jobstart() to run the client script
  let l:cmd = ['python3', l:client_script]
  let l:opts = {
        \ 'on_stdout': 'visutest_core#OnData',
        \ 'on_stderr': 'visutest_core#OnError',
        \ 'on_exit': 'visutest_core#OnExit',
        \ 'stdout_buffered': v:false,
        \ 'stderr_buffered': v:false,
        \ }

  let g:visutest_client_job = job_start(l:cmd, l:opts)

  if g:visutest_client_job <= 0
    echoerr "Failed to start the VisuTest client."
  else
    echom "VisuTest client started."
  endif
endfunction

function! visutest_core#OnData(job_id, data, event)
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

function! visutest_core#OnError(job_id, data, event)
  for l:line in a:data
    if l:line != ''
      echoerr "VisuTest client error: " . l:line
    endif
  endfor
endfunction

function! visutest_core#OnExit(job_id, exit_code, event)
  echom "VisuTest client exited with code " . a:exit_code
endfunction

" Function to stop the server
function! visutest_core#StopServer()
  if exists('g:visutest_server_job') && job_status(g:visutest_server_job) ==# 'run'
    call jobstop(g:visutest_server_job)
    unlet g:visutest_server_job
    echom "VisuTest server stopped."
  endif
endfunction
