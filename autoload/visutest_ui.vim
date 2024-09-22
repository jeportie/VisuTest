" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_ui.vim                                    :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:02:33 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 17:22:30 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Setup UI for the VisuTest window
function! visutest_ui#SetupWindowUI()
  " Set a fixed width for the vertical window (1/5 of the total width)
  let l:split_width = float2nr(&columns * 0.15)

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
   " Enable mouse support
  setlocal mouse=a
  " Key mapping to close the window when 'q' is pressed
  nnoremap <buffer> q :call VisuTestCloseWindow()<CR>
  " Mouse click mapping to open the popup window
  nnoremap <buffer> <silent> <LeftMouse> :call visutest_ui#ShowTestSuitePopup()<CR>
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

function! visutest_ui#ShowTestSuitePopup()
  " The mock data for the test log
  let l:popup_content = [
        \ '----------------------------------------------------------',
        \ '1/1 Testing: ft_split_test',
        \ '1/1 Test: ft_split_test',
        \ 'Command: "/home/user/test/test_ft_split"',
        \ 'Directory: /home/user/test',
        \ '"ft_split_test" start time: Sep 20 15:05 CEST',
        \ 'Output:',
        \ '----------------------------------------------------------',
        \ 'Running suite(s): ft_split',
        \ '100%: Checks: 5, Failures: 0, Errors: 0',
        \ '🟢  All tests passed',
        \ '<end of output>',
        \ 'Test time =   0.00 sec',
        \ '----------------------------------------------------------'
        \ ]

  " Create a popup window with the test log
  call popup_create(l:popup_content, {
        \ 'line': 'cursor+1',      " Open near the cursor
        \ 'col': 'cursor+1',
        \ 'minwidth': 50,          " Minimum width of the popup
        \ 'minheight': 10,         " Minimum height of the popup
        \ 'border': [],            " No border for the popup
        \ 'padding': [0,1,0,1],    " Padding for the text inside the popup
        \ 'zindex': 10,            " Ensure the popup is on top
        \ 'mapping': 0,            " Disable key mappings inside the popup
        \ 'close': 'click'         " Close the popup when clicked
        \ })
endfunction
