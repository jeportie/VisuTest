" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_core.vim                                  :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/28 14:12:40 by jeportie          #+#    #+#              "
"    Updated: 2024/09/28 14:21:27 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Function to start the test and communicate with the server
function! visutest_core#StartTests()
  " Define the server address and port
  let l:server_address = 'localhost'
  let l:server_port = 9999

  " Initialize a dictionary to store test logs
  if !exists('g:visutest_test_logs')
    let g:visutest_test_logs = {}
  endif

  " Use sockconnect() to establish a connection with the server
  let l:sock = sockconnect('tcp', l:server_address . ':' . l:server_port, {'on_data': 'visutest_core#OnData', 'on_close': 'visutest_core#OnClose'})

  " Check if the socket connection was successful
  if type(l:sock) == type(0)
    echoerr "Failed to connect to the test server."
    return
  endif

  " Send the START_TEST command to the server
  call socksend(l:sock, "START_TEST\n")

  " Store the socket in a global variable for later use
  let g:visutest_socket = l:sock
endfunction

" Handler function for incoming data from the server
function! visutest_core#OnData(channel, msg)
  " Split the incoming message into lines
  let l:lines = split(a:msg, "\n")

  for l:line in l:lines
    if l:line == ''
      continue
    endif

    " Check for RUNNING, PASSED, or FAILED signals
    if l:line =~ '^RUNNING:'
      let l:test_name = matchstr(l:line, 'RUNNING:\s*\zs.*')
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

" Handler function for when the socket is closed
function! visutest_core#OnClose(channel)
  echom "Test server connection closed."
endfunction
