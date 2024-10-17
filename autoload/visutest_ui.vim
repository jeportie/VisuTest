" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_ui.vim                                    :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:36:45 by jeportie          #+#    #+#              "
"    Updated: 2024/10/17 09:01:24 by jeportie         ###   ########.fr        "
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

  " Display test suites
  call visutest_tests#DisplayTestSuites()

  " Key mappings
  nnoremap <buffer> <silent> :bnext <NOP>
  nnoremap <buffer> <silent> :bprev <NOP>
  nnoremap <buffer> <silent> <CR> :call visutest_ui#ShowTestSuitePopup()<CR>
  nnoremap <buffer> q :call VisuTestCloseWindow()<CR>
  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
  nnoremap <buffer> r :VisuTestRun<CR>

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

  for idx in range(len(l:lines))
    let l:line = l:lines[idx]

    " Find the line that matches the test name
    if l:line =~ '^\s*➔ [🟢🔴⚪] ' . l:test_name . '$'
      let l:line_num = idx + 1

      " Determine the appropriate icon based on the status
      let l:icon = a:status ==# 'passed' ? '🟢' :
            \ a:status ==# 'failed' ? '🔴' : '⚪'

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
