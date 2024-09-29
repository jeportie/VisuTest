" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_ui.vim                                    :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:02:33 by jeportie          #+#    #+#              "
"    Updated: 2024/09/29 13:25:53 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Setup UI for the VisuTest window
function! visutest_ui#SetupWindowUI()
  " Set a fixed width for the vertical window (1/5 of the total width)
 let l:split_width = max([float2nr(&columns * 0.15), 30])

  " Open a new vertical window on the right with fixed width
  botright vertical new
  execute "vertical resize " . l:split_width

  " Set buffer settings for this window
  setlocal buftype=nofile         " Buffer has no associated file
  setlocal bufhidden=hide         " Hide buffer when abandoned
  setlocal noswapfile             " Do not use swapfile
  setlocal nowrap                 " Do not wrap text
  setlocal nonumber               " Disable line numbers
  setlocal norelativenumber       " Disable relative line numbers
  setlocal signcolumn=no          " Disable the sign column
  setlocal winfixwidth            " Lock the window width
  setlocal modifiable             " Temporarily make the buffer modifiable
  setlocal filetype=visutest      " Set filetype for identification
  setlocal nobuflisted            " Prevent buffer from being listed

  " Call function to display test suites
  call visutest_tests#DisplayTestSuites()
  " Disable buffer switching commands like bnext/bprev in this buffer
  nnoremap <buffer> <silent> :bnext <NOP>
  nnoremap <buffer> <silent> :bprev <NOP>
  " Bind Enter to trigger the popup if the cursor is on a test suite title
  nnoremap <buffer> <silent> <CR> :call visutest_ui#ShowTestSuitePopup()<CR>
  " Key mapping to close the window when 'q' is pressed
  nnoremap <buffer> q :call VisuTestCloseWindow()<CR>
  " Key mapping to close the popup when 'p' is pressed
  nnoremap <buffer> <Esc> :call visutest_ui#ClosePopup()<CR>
  " Key mapping to run tests when 'r' is pressed
  nnoremap <buffer> r :VisuTestRun<CR>


   " Set the buffer back to read-only
  setlocal nomodifiable
endfunction

" Function to setup syntax highlighting and icons
function! visutest_ui#SetupHighlighting()
  " Highlight the title in red
  highlight VisuTestTitle ctermfg=1 guifg=red
  syntax match VisuTestTitle "VisuTest"
  call matchadd('VisuTestTitle', 'VisuTest')

  " Highlight the test suites header in pink
  highlight TestSuitesHeader ctermfg=13 guifg=lightpink
  syntax match TestSuitesHeader "Test Suits"
  call matchadd('TestSuitesHeader', 'Test Suits')

  " Highlight the arrow in orange
  highlight ArrowIcon ctermfg=214 guifg=orange
  execute 'syntax match ArrowIcon "➔"'
  call matchadd('ArrowIcon', '➔')

  " Highlight the Nerd Font icon in white
  highlight NerdFontIcon ctermfg=15 guifg=white
  execute 'syntax match NerdFontIcon "󰏦"'
  call matchadd('NerdFontIcon', '󰏦')

  " Highlight the test suite names in light blue
  highlight TestSuiteName ctermfg=81 guifg=#add8e6
  syntax match TestSuiteName "\v\w+"
  call matchadd('TestSuiteName', '\w+')

  " Highlight no-test units found in red with special icon
  highlight NoTestArrow ctermfg=214 guifg=orange
  execute 'syntax match NoTestArrow "➔"'
  call matchadd('NoTestArrow', '➔')

  highlight NoTestIcon ctermfg=1 guifg=red
  execute 'syntax match NoTestIcon "󰗖"'
  call matchadd('NoTestIcon', '󰗖')

  highlight NoTestText ctermfg=1 guifg=red
  syntax match NoTestText "No test units found"
  call matchadd('NoTestText', 'No test units found')
endfunction

" Initialize a global list to store active popup IDs
if !exists('g:visutest_popups')
  let g:visutest_popups = []
endif

" Function to show the test suite popup with the actual test log
function! visutest_ui#ShowTestSuitePopup()
  let l:line = getline(".")
  let l:test_name = matchstr(l:line, '\zs\w\+$')
  let l:test_name = substitute(l:test_name, '^test_', '', '')
  let l:test_name = substitute(l:test_name, '^\s*', '', '')

  " Retrieve the log for the selected test, ensure it's treated as a string
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
        \ 'minwidth': 50,
        \ 'minheight': 10,
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

" Function to handle popup closure
function! visutest_ui#ClosePopup()
  call popup_clear(1)
endfunction

" Function to update the test status in the UI
function! visutest_ui#UpdateTestStatus(test_name, status)
  " Ensure test_name has no 'test_' prefix
  let l:test_name = substitute(a:test_name, '^test_', '', '')
  " Find the line number where the test is displayed
  let l:bufnr = bufnr('%')
  let l:lines = getline(1, '$')
  let l:line_num = 0
  let l:updated_line = ''

  for idx in range(len(l:lines))
    let l:line = l:lines[idx]
    if l:line =~ '➔ 󰏦 ' . l:test_name
      let l:line_num = idx + 1  " Line numbers start from 1
      " Update the icon based on status
      if a:status ==# 'running'
        let l:icon = '🟡'  " Yellow circle for running
      elseif a:status ==# 'passed'
        let l:icon = '🟢'  " Green circle for passed
      elseif a:status ==# 'failed'
        let l:icon = '🔴'  " Red circle for failed
      else
        let l:icon = '⚪'  " White circle for unknown
      endif

      " Construct the updated line
      let l:updated_line = substitute(l:line, '^.\zs.', l:icon, '')
      " Update the line in the buffer
      call setline(l:line_num, l:updated_line)
      break
    endif
  endfor

  " Refresh the display
  redraw
endfunction

