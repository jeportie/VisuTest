" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_ui.vim                                    :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:02:33 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 22:54:38 by jeportie         ###   ########.fr        "
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
  " Bind Enter to trigger the popup if the cursor is on a test suite title
  nnoremap <buffer> <silent> <CR> :call visutest_ui#ShowTestSuitePopup()<CR>
  " Key mapping to close the window when 'q' is pressed
  nnoremap <buffer> q :call VisuTestCloseWindow()<CR>
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

" Function to handle popup closure
function! visutest_ui#ClosePopup(popup_id)
  echo "Closing popup: " . a:popup_id
  call popup_close(a:popup_id)
endfunction

" Initialize a global list to store active popup IDs
if !exists('g:visutest_popups')
  let g:visutest_popups = []
endif

" Function to show the test suite popup
ffunction! visutest_ui#ShowTestSuitePopup()
  " Define the content of the popup as a single string with newlines
  let l:popup_content = '----------------------------------------------------------
1/1 Testing: ft_split_test
1/1 Test: ft_split_test
Command: "/home/user/test/test_ft_split"
Directory: /home/user/test
"ft_split_test" start time: Sep 20 15:05 CEST
Output:
----------------------------------------------------------
Running suite(s): ft_split
100%: Checks: 5, Failures: 0, Errors: 0
🟢  All tests passed
<end of output>
Test time =   0.00 sec
----------------------------------------------------------

Press <Enter>, "q", or <Esc> to close this popup.'

  " Debugging: Check the type and content of l:popup_content
  echo "Type of popup_content: " . type(l:popup_content)
  echo "Content of popup_content: " . string(l:popup_content)

  " Verify that popup_content is a string or list
  if type(l:popup_content) != type('') && type(l:popup_content) != type([])
    echoerr "Error: popup_content must be a string or a list."
    return
  endif

  " Calculate center of the screen for popup positioning
  let l:winheight = float2nr(&lines / 2 - len(split(l:popup_content, "\n")) / 2)
  let l:winwidth = float2nr(&columns / 2) - 25

  " Define popup options
  let l:popup_options = {
        \ 'line': l:winheight,
        \ 'col': l:winwidth,
        \ 'minwidth': 50,
        \ 'minheight': 10,
        \ 'border': [],
        \ 'padding': [0,1,0,1],
        \ 'zindex': 10,
        \ 'mousemappings': 0,
        \ 'mapping': 1,
        \ 'focusable': 1,
        \ 'wrap': 1,
        \ 'title': ' Test Suite Results ',
        \ 'title_pos': 'center',
        \ 'highlight': 'Normal',
        \ 'borderhighlight': 'Normal',
        \ 'close_on_escape': 1,
        \ 'scrollbar': v:false,
        \ 'keymappings': {
        \   '<CR>': 'close',
        \   'q': 'close',
        \   '<Esc>': 'close'
        \ },
        \ }

  " Debugging: Check the type and content of l:popup_options
  echo "Type of popup_options: " . type(l:popup_options)
  echo "Content of popup_options: " . string(l:popup_options)

  " Verify that popup_options is a dictionary
  if type(l:popup_options) != type({})
    echoerr "Error: popup_options must be a dictionary."
    return
  endif

  " Create the popup
  let l:popup_id = popup_create(l:popup_content, l:popup_options)

  " Debugging: Check the popup ID returned
  echo "Popup ID: " . l:popup_id

  " Check if popup creation was successful
  if l:popup_id == -1
    echoerr "Failed to create popup."
    return
  endif

  " Store the popup ID in the global list
  call add(g:visutest_popups, l:popup_id)

  " Optionally, set buffer-local variable to track the popup
  let b:visutest_popup = l:popup_id

  " Debugging: Confirm popup creation
  echo "Popup created with ID: " . l:popup_id
endfunction

" Function to close the test suite popup
function! visutest_ui#CloseTestSuitePopup()
  " Close the most recent popup
  if !empty(g:visutest_popups)
    let l:popup_id = remove(g:visutest_popups, -1)
    call popup_close(l:popup_id)
    echo "Popup closed: " . l:popup_id
  endif

  " Optionally, unset buffer-local variables if used
  if exists('b:visutest_popup')
    unlet b:visutest_popup
  endif
endfunction

