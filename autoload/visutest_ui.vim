" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_ui.vim                                    :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:02:33 by jeportie          #+#    #+#              "
"    Updated: 2024/09/29 21:19:16 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

""""""""""" Function to set up the VisuTest window UI layout """"""""""""""""""

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

""""""""""""" Function to set up syntax highlighting for the UI """"""""""""""""

function! visutest_ui#SetupHighlighting()
  " Highlight the title, test suites header, and icons
  highlight VisuTestTitle ctermfg=1 guifg=red
  syntax match VisuTestTitle "VisuTest"
  call matchadd('VisuTestTitle', 'VisuTest')

  highlight TestSuitesHeader ctermfg=13 guifg=lightpink
  syntax match TestSuitesHeader "Test Suits"
  call matchadd('TestSuitesHeader', 'Test Suits')

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
endfunction

" Initialize a global list to store active popup IDs """"""""""""""""""""""""""""
if !exists('g:visutest_popups')
  let g:visutest_popups = []
endif

""""""""""" Function to display a popup with the test suite log """""""""""""""

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

  let l:winheight = float2nr(&lines / 2 - len(split(l:popup_content, "\n")) / 2)
  let l:winwidth = float2nr(&columns / 2) - 25

  let l:popup_options = {
        \ 'line': l:winheight,
        \ 'col': l:winwidth,
        \ 'minwidth': 70,
        \ 'minheight': 20,
        \ 'border': [],
        \ 'title': 'Test Suite: ' . l:test_name,
        \ 'wrap': v:false,
        \ }

  let l:popup_id = popup_create(split(l:popup_content, "\n"), l:popup_options)

  if l:popup_id == -1
    echoerr "Failed to create popup."
    return
  endif

  call add(g:visutest_popups, l:popup_id)
  let b:visutest_popup = l:popup_id

  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
endfunction

""""""""""""""""""""""" Function to close the popup window """"""""""""""""""""

function! visutest_ui#ClosePopup()
  call popup_clear(1)
endfunction

""""""""""""" Function to update test statuses in the UI display """"""""""""""

function! visutest_ui#UpdateTestStatus(test_name, status)
  let l:test_name = substitute(a:test_name, '^test_', '', '')
  echom "UI: Updating status for " . l:test_name . " to " . a:status

  " Get the current buffer number and all the lines in the buffer
  let l:bufnr = bufnr('%')
  let l:lines = getline(1, '$')
  let l:line_num = 0

  " Temporarily make the buffer modifiable
  setlocal modifiable

  for idx in range(len(l:lines))
    let l:line = l:lines[idx]

    " Find the line that matches the test name
    if l:line =~ '➔ ⚪ ' . l:test_name
      let l:line_num = idx + 1

      " Determine the appropriate icon based on the status
      let l:icon = a:status ==# 'passed' ? '🟢' :
            \ a:status ==# 'failed' ? '🔴' : '⚪'

      " Construct the updated line with the new icon and test suite name
      let l:updated_line = "➔ " . l:icon . " " . l:test_name

      " Replace the entire line in the buffer
      call setline(l:line_num, l:updated_line)
      echom "UI: Updated line " . l:line_num . " to " . l:updated_line
      break
    endif
  endfor

  " Set the buffer back to non-modifiable
  setlocal nomodifiable

  " Refresh the display to apply changes
  redraw
endfunction

