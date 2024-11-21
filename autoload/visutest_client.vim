" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_client.vim                                :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:50:44 by jeportie          #+#    #+#              "
"    Updated: 2024/11/21 16:48:45 by jeportie         ###   ########.fr        "
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
  " Log the raw data received

  if empty(a:data)
    return
  endif

  " Ensure a:data is a list
  if type(a:data) == v:t_string
    let l:data_list = [a:data]
  elseif type(a:data) == v:t_list
    let l:data_list = a:data
  else
    echoerr "Unexpected data type: " . string(type(a:data))
    return
  endif

  " Process each line in the data
  for l:line in l:data_list
    " Remove any non-printable characters
    let l:line = substitute(l:line, '[\x00-\x1F\x7F]', '', 'g')
    if l:line == ''
      continue
    endif


    " Check for build errors
    if l:line =~ 'CMAKE_ERROR:' || l:line =~ 'MAKE_ERROR:'
      let g:visutest_build_error = substitute(l:line, '<br>', "\n", 'g')
      call visutest_ui#ShowBuildErrorPopup()
      return
    endif

    " Check for test start
    if l:line =~ 'RUNNING:'
      let l:test_name = matchstr(l:line, 'RUNNING:\s*\zs.*')
      let g:visutest_current_test = l:test_name
      let g:visutest_test_logs[l:test_name] = []
      let g:visutest_subtest_statuses[l:test_name] = {}
      call visutest_ui#UpdateTestStatus(l:test_name, 'running')
      continue
    endif

    " Check for test result
    if l:line =~? 'Test Passed\.'
      let l:test_name = g:visutest_current_test
      call visutest_ui#UpdateTestStatus(l:test_name, 'passed')
      call visutest_client#ParseSubTestResults(l:test_name, g:visutest_test_logs[l:test_name])
      continue
    elseif l:line =~? 'Test Failed\.'
      let l:test_name = g:visutest_current_test
      call visutest_ui#UpdateTestStatus(l:test_name, 'failed')
      call visutest_client#ParseSubTestResults(l:test_name, g:visutest_test_logs[l:test_name])
      continue
    endif

    " Accumulate log lines for subtest processing
    if exists("g:visutest_current_test") && !empty(g:visutest_current_test)
      call add(g:visutest_test_logs[g:visutest_current_test], l:line)
    endif
  endfor
endfunction

" Function to parse subtest results
function! visutest_client#ParseSubTestResults(test_name, log)
  " Initialize subtest statuses
  let l:subtest_statuses = {}
  
  " Log the parsing action
  
  " Flags to track if we're in the output section
  let l:in_output = 0
  let l:collect_failures = 0
  let l:failures_detected = 0
  let l:failed_subtests = []
  
  for l:line in a:log
    " Check for Output section start
    if l:line =~ '^Output:$'
      let l:in_output = 1
      continue
    endif
    
    " Check for Output section end
    if l:line =~ '^<end of output>$'
      let l:in_output = 0
      continue
    endif
    
    if l:in_output
      " Log lines within Output section
      
      " Check for summary line
      if l:line =~ '\vChecks:\s*\d+,\s*Failures:\s*\d+,\s*Errors:\s*\d+'
        let l:failures = matchstr(l:line, 'Failures:\s*\zs\d\+')
        let l:errors = matchstr(l:line, 'Errors:\s*\zs\d\+')
        if str2nr(l:failures) > 0 || str2nr(l:errors) > 0
          let l:failures_detected = 1
        endif
        continue
      endif
      
      " Collect failed subtests between the summary line and '<end of output>'
      if l:failures_detected
        " Attempt to extract the subtest name from the line
        let l:fields = split(l:line, ':')
        if len(l:fields) >= 5
          let l:subtest_name = l:fields[4]
          " Ensure the subtest name starts with 'test_'
          if l:subtest_name =~ '^test_'
            let l:subtest_statuses[l:subtest_name] = 'failed'
          endif
        endif
      endif
    endif
  endfor
  
  " Default all unlisted subtests to 'passed'
  if has_key(g:visutest_all_subtests, a:test_name)
    for l:subtest in g:visutest_all_subtests[a:test_name]
      if !has_key(l:subtest_statuses, l:subtest)
        let l:subtest_statuses[l:subtest] = 'passed'
      endif
    endfor
  endif
  
  " Update global subtest statuses and UI
  let g:visutest_subtest_statuses[a:test_name] = l:subtest_statuses
  call visutest_ui#UpdateSubTestStatuses(a:test_name, l:subtest_statuses)
endfunction

" Callback for client errors
function! visutest_client#OnError(job, data)
  if empty(a:data)
    echoerr "VisuTest client error: No data received."
    return
  endif
  for l:line in a:data
    if type(l:line) == v:t_string && l:line != ''
      echoerr "VisuTest client error: " . l:line
    endif
  endfor
endfunction

" Callback for client exit
function! visutest_client#OnExit(job, exit_status)
endfunction

