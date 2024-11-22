" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_ui.vim                                    :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:36:45 by jeportie          #+#    #+#              "
"    Updated: 2024/11/22 13:21:14 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

"""""""""" Initialize Global Variables """""""""""""""""""""""""""""
if !exists('g:visutest_popups')
  let g:visutest_popups = []
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

function! visutest_ui#HandleLineAction()
  let l:current_line = getline('.')
  if l:current_line =~ '^➔ [🟢🔴⚪] '  " Test suite line
    call visutest_tests#ToggleSuiteUnits()
  elseif l:current_line =~ '^    ➔ [🟢🔴⚪] '  " Subtest line
    call visutest_ui#ShowTestLogPopup()
  else
    " Not a recognizable line, do nothing
  endif
endfunction

"""""""""" Function to set up the VisuTest window UI layout """"""""""""""""""
function! visutest_ui#SetupWindowUI()
  let l:split_width = max([float2nr(&columns * 0.20), 30])

  " Open a vertical window on the right with fixed width
  botright vertical new
  execute "vertical resize " . l:split_width

  " Set buffer settings
  setlocal buftype=nofile bufhidden=hide noswapfile nowrap nonumber
  setlocal norelativenumber signcolumn=no winfixwidth modifiable
  setlocal filetype=visutest nobuflisted

  " Initialize expanded suites dictionary
  let g:visutest_expanded_suites = {}

  " Set the global variable to hide units by default
  let g:visutest_tests_show_units = 0

  " Display test suites
  call visutest_tests#DisplayTestSuites()

  " Key mappings
  nnoremap <buffer> <silent> :bnext <NOP>
  nnoremap <buffer> <silent> :bprev <NOP>
  nnoremap <buffer> q :call VisuTestCloseWindow()<CR>
  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
  nnoremap <buffer> r :VisuTestRun<CR>
  nnoremap <buffer> P :call visutest_ui#ResetUI()<CR>

  " Enable mouse support
  setlocal mouse=a

  " Map double-click and Enter key to handle action based on line type
  nnoremap <buffer> <2-LeftMouse> :call visutest_ui#HandleLineAction()<CR>
  nnoremap <buffer> <CR> :call visutest_ui#HandleLineAction()<CR>

  " Set buffer back to read-only
  setlocal nomodifiable
endfunction

"""""""""" Function to set up syntax highlighting for the UI """"""""""""""""
function! visutest_ui#SetupHighlighting()
  " Highlight the title, test suites header, and icons
  highlight VisuTestTitle ctermfg=1 guifg=red
  syntax match VisuTestTitle "VisuTest"
  call matchadd('VisuTestTitle', 'VisuTest')

  highlight TestSuitesHeader ctermfg=13 guifg=lightpink
  syntax match TestSuitesHeader "Test Suites"
  call matchadd('TestSuitesHeader', 'Test Suites')

  highlight ArrowIcon ctermfg=214 guifg=orange
  execute 'syntax match ArrowIcon "➔"'
  call matchadd('ArrowIcon', '➔')

  highlight NerdFontIcon ctermfg=15 guifg=white
  execute 'syntax match NerdFontIcon "⚪"'
  call matchadd('NerdFontIcon', '⚪')

  highlight TestSuiteName ctermfg=81 guifg=#add8e6
  syntax match TestSuiteName "\v\w+"
  call matchadd('TestSuiteName', '\w+')

  highlight NoTestArrow ctermfg=214 guifg=orange
  execute 'syntax match NoTestArrow "➔"'
  call matchadd('NoTestArrow', '➔')

  highlight NoTestIcon ctermfg=1 guifg=red
  execute 'syntax match NoTestIcon "🔴"'
  call matchadd('NoTestIcon', '🔴')

  highlight NoTestText ctermfg=1 guifg=red
  syntax match NoTestText "No test units found"
  call matchadd('NoTestText', 'No test units found')

  " Highlight sub-test icons
  highlight SubTestIcon ctermfg=6 guifg=cyan
  syntax match SubTestIcon "    ➔"

  " Highlight sub-test passed icon
  highlight SubTestPassedIcon ctermfg=2 guifg=green
  syntax match SubTestPassedIcon "🟢"

  " Highlight sub-test failed icon
  highlight SubTestFailedIcon ctermfg=1 guifg=red
  syntax match SubTestFailedIcon "🔴"

  " Highlight sub-test names
  highlight SubTestName ctermfg=7 guifg=white
  syntax match SubTestName "    ➔ [🟢🔴⚪] \zs.*"
endfunction

"""""""""" Function to display a popup with the test suite log """""""""""""""
function! visutest_ui#ShowTestSuitePopup()
  call visutest_ui#ClosePopup()
  let l:line = getline(".")
  let l:test_name = matchstr(l:line, '\zs\w\+$')
  let l:test_name = substitute(l:test_name, '^test_', '', '')
  let l:test_name = substitute(l:test_name, '^\s*', '', '')

  " Retrieve the log for the selected test
  if has_key(g:visutest_test_logs, l:test_name)
    let l:popup_content = join(g:visutest_test_logs[l:test_name], "\n")
  else
    let l:popup_content = 'No log available for this test suite.'
  endif

  " Calculate popup position
  let l:winheight = float2nr(&lines / 2 - len(split(l:popup_content, "\n")) / 2)
  let l:winwidth = float2nr(&columns / 2) - 25

  let l:popup_options = {
        \ 'line': l:winheight,
        \ 'col': l:winwidth,
        \ 'minwidth': 50,
        \ 'minheight': 10,
        \ 'border': [],
        \ 'title': '💻 Test Suite: ' . l:test_name,
        \ 'wrap': v:false,
        \ }

  " Ensure popup_content is a list
  let l:popup_lines = split(l:popup_content, "\n")

  let l:popup_id = popup_create(l:popup_lines, l:popup_options)

  if l:popup_id == -1
    echoerr "Failed to create popup."
    return
  endif

  call add(g:visutest_popups, l:popup_id)
  let b:visutest_popup = l:popup_id

  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
endfunction

""""""""""""" Function to close the popup window """"""""""""""""""""
function! visutest_ui#ClosePopup()
  for l:popup_id in g:visutest_popups
    call popup_clear(l:popup_id)
  endfor
  let g:visutest_popups = []
endfunction

"""""""""" Function to update test statuses in the UI display """"""""""""""
function! visutest_ui#UpdateTestStatus(test_name, status)
  let l:test_name = substitute(a:test_name, '^test_', '', '')

  " Update the global test status
  let g:visutest_test_statuses[l:test_name] = a:status

  " Get the current buffer number and all the lines in the buffer
  let l:bufnr = bufnr('%')
  let l:lines = getline(1, '$')
  let l:line_num = 0

  " Temporarily make the buffer modifiable
  setlocal modifiable

  " Determine the appropriate icon based on the test status
  let l:icon = a:status ==# 'passed' ? '🟢' :
        \ a:status ==# 'failed' ? '🔴' : '⚪'

  " Update the icon display for the test suite in the buffer
  for idx in range(len(l:lines))
    let l:line = l:lines[idx]

    " Find the line that matches the test name
    if l:line =~ '^\s*➔ [🟢🔴⚪] ' . l:test_name . '$'
      let l:line_num = idx + 1

      " Construct the updated line with the new icon and test suite name
      let l:updated_line = "➔ " . l:icon . " " . l:test_name

      " Replace the entire line in the buffer
      call setline(l:line_num, l:updated_line)
      break
    endif
  endfor

  " Set the buffer back to non-modifiable
  setlocal nomodifiable

  " Refresh the display to apply changes
  redraw
endfunction

""""""""""""" Function to update sub-test statuses in the UI display """""""""""""""
function! visutest_ui#UpdateSubTestStatuses(suite_name, subtest_statuses)
  let l:suite_name = substitute(a:suite_name, '^test_', '', '')

  " Get the current buffer number and all the lines in the buffer
  let l:bufnr = bufnr('%')
  let l:lines = getline(1, '$')

  " Temporarily make the buffer modifiable
  setlocal modifiable

  let l:found_suite = 0
  for idx in range(len(l:lines))
    let l:line = l:lines[idx]

    " Find the test suite line
    if l:line =~ '^\s*➔ [🟢🔴⚪] ' . l:suite_name . '$'
      let l:found_suite = 1
      continue
    endif

    " If we've found the suite, look for its sub-tests
    if l:found_suite
      " Check if the line is a sub-test line
      if l:line =~ '^\s\+➔ [🟢🔴⚪] .*$'
        " Extract the sub-test name
        let l:subtest_line = l:line
        let l:subtest_name = substitute(l:subtest_line, '^\s\+➔ [🟢🔴⚪] ', '', '')

        " Get the status of the sub-test using the helper function
        let l:status = visutest_helper#GetSubtestStatus(l:suite_name, l:subtest_name)
        let l:icon = l:status ==# 'passed' ? '🟢' :
              \ l:status ==# 'failed' ? '🔴' : '⚪'

        " Construct the updated line
        let l:updated_line = "    ➔ " . l:icon . " " . l:subtest_name

        " Replace the line in the buffer
        call setline(idx + 1, l:updated_line)
      else
        " If we reach a line that is not a sub-test, stop looking
        break
      endif
    endif
  endfor

  " Set the buffer back to non-modifiable
  setlocal nomodifiable

  " Refresh the display to apply changes
  redraw
endfunction

""""""""""""" Function to show Build Error in Popup """""""""""""""
function! visutest_ui#ShowBuildErrorPopup()
  call visutest_ui#ClosePopup()

  " Log the current build error content
  if exists('g:visutest_build_error') && !empty(g:visutest_build_error)
    let l:popup_content = g:visutest_build_error
  else
    let l:popup_content = 'No build error log available.'
  endif

  let l:winheight = float2nr(&lines / 2 - len(split(l:popup_content, "\n")) / 2)
  let l:winwidth = float2nr(&columns / 2) - 25

  let l:popup_options = {
        \ 'line': l:winheight,
        \ 'col': l:winwidth,
        \ 'minwidth': 50,
        \ 'minheight': 10,
        \ 'border': [],
        \ 'title': '🔴 Build Error Log',
        \ 'wrap': v:false,
        \ }

  let l:popup_lines = split(l:popup_content, "\n")
  let l:popup_id = popup_create(l:popup_lines, l:popup_options)

  if l:popup_id == -1
    echoerr "Failed to create build error popup."
  else
    call add(g:visutest_popups, l:popup_id)
    let b:visutest_popup = l:popup_id
  endif
  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
endfunction

function! visutest_ui#ShowTestLogPopup()
  let l:current_line_num = line('.')
  let l:current_line = getline('.')

  " Determine the test suite name
  " We need to look upwards in the buffer to find the test suite line
  let l:suite_line_num = l:current_line_num
  while l:suite_line_num > 0
    let l:line_text = getline(l:suite_line_num)
    if l:line_text =~ '^➔ [🟢🔴⚪] '
      " Found the test suite line
      let l:suite_name = matchstr(l:line_text, '^➔ [🟢🔴⚪] \zs.*$')
      break
    endif
    let l:suite_line_num -= 1
  endwhile

  if !exists('l:suite_name')
    return
  endif

  " Get the test log for the test suite
  let l:test_log = get(g:visutest_test_logs, l:suite_name, [])
  if empty(l:test_log)
    return
  endif

  " Display the test log in a popup window
  call visutest_ui#ShowPopup(join(l:test_log, "\n"), 'Test Log: ' . l:suite_name)
endfunction

function! visutest_ui#ShowPopup(content, title)
  " Close any existing popup
  call visutest_ui#ClosePopup()

  let l:popup_options = {
        \ 'line': 'cursor+1',
        \ 'col': 'cursor+1',
        \ 'pos': 'botleft',
        \ 'minwidth': 50,
        \ 'minheight': 10,
        \ 'border': [],
        \ 'title': a:title,
        \ 'wrap': v:false,
        \ 'padding': [0,1,0,1],
        \ }

  let l:popup_lines = split(a:content, "\n")
  let l:popup_id = popup_create(l:popup_lines, l:popup_options)

  if l:popup_id == -1
    echoerr "Failed to create popup."
  else
    call add(g:visutest_popups, l:popup_id)
    let b:visutest_popup = l:popup_id
  endif

  " Map <Esc> to close the popup
  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
endfunction

function! visutest_ui#ResetUI()

  " Clear all test statuses and logs
  let g:visutest_test_logs = {}
  let g:visutest_test_statuses = {}
  let g:visutest_subtest_statuses = {}
  let g:visutest_all_subtests = {}
  let g:visutest_expanded_suites = {}
  let g:visutest_expanded_folders = {}

  " Re-display the test suites (this will reparse the test folders)
  call visutest_tests#DisplayTestSuites()

endfunction
