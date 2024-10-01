" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_server.vim                                :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/28 14:12:40 by jeportie          #+#    #+#              "
"    Updated: 2024/10/01 12:19:33 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

"""""""""" Function to start the server """"""""""""""""""""""""

function! visutest_server#StartServer()
  " Define the path to the server script
  let l:script_path = expand('<sfile>:p:h')
  let l:plugin_root = fnamemodify(l:script_path, ':h')
  let l:server_script = l:plugin_root . '/server/server.py'

  " Check if the server is already running
  if exists('g:visutest_server_job') && job_status(g:visutest_server_job) ==# 'run'
    return
  endif

  " Start the server using job_start()
  let l:cmd = ['python3', l:server_script]
  let l:opts = {
        \ 'out_cb': function('visutest_server#ServerOutput'),
        \ 'err_cb': function('visutest_server#ServerError'),
        \ 'exit_cb': function('visutest_server#ServerExit'),
        \ }

  let g:visutest_server_job = job_start(l:cmd, l:opts)
  if type(g:visutest_server_job) != v:t_job
    echoerr "Failed to start the VisuTest server."
  endif
 endfunction
"""""""""" Callback for server output """""""""""""""""""""

function! visutest_server#ServerOutput(job, data)
  " Handle server output if needed
  for l:line in a:data
    if l:line != ''
      echom "Server Output: " . l:line
    endif
  endfor
endfunction

"""""""""" Callback for server errors """""""""""""""""""""

function! visutest_server#ServerError(job, data)
  for l:line in a:data
    if l:line != ''
      echoerr "VisuTest server error: " . l:line
    endif
  endfor
endfunction

"""""""""" Callback for server exit """""""""""""""""""""

function! visutest_server#ServerExit(job, exit_status)
  echom "VisuTest server exited with code " . a:exit_status
endfunction

"""""""""" Function to stop the server """""""""""""""""""""

function! visutest_server#StopServer()
  if exists('g:visutest_server_job') && job_status(g:visutest_server_job) ==# 'run'
    call job_stop(g:visutest_server_job)
    unlet g:visutest_server_job
    echom "VisuTest server stopped."
  else
    echo "No running server found."
  endif
endfunction
