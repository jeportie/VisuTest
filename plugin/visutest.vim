" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 15:05:24 by jeportie          #+#    #+#              "
"    Updated: 2024/09/21 20:04:01 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Ensure we only load the plugin once
if exists("g:loaded_visutest")
  finish
endif
let g:loaded_visutest = 1

" Function to open an empty vertical window and keep it stable
function! VisuTestOpenWindow()
  " Set a fixed width for the vertical window (1/5 of the total width)
  let l:split_width = float2nr(&columns * 0.20)

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

  " Set the filetype for identification
  setlocal filetype=visutest

  " Prevent buffer from being listed
  setlocal nobuflisted            " Hide buffer from buffer list

  " Call the function to display test suites
  call VisuTestDisplayTestSuites()

  " Fix the window size
  execute "vertical resize " . l:split_width

  " Set the buffer back to read-only
  setlocal nomodifiable
endfunction

" Function to parse test_src/ folder and extract test suite names
function! VisuTestGetTestSuites()
  let l:test_suites = []

  " Use the current directory and assume test_src/ is at the same level
  let l:test_src_dir = getcwd() . '/test_src/'

  " Get all .c files from test_src/ directory and its subdirectories
  let l:files = globpath(l:test_src_dir, '**/test_*.c', 0, 1)

  " Loop through each file and extract the test suite name
  for l:file in l:files
    " Remove the directory path and prefix "test_" to get the suite name
    let l:filename = fnamemodify(l:file, ':t')
    let l:test_suite = substitute(l:filename, '^test_', '', '')
    let l:test_suite = substitute(l:test_suite, '\.c$', '', '')
    call add(l:test_suites, l:test_suite)
  endfor

  return l:test_suites
endfunction

" Function to display the test suites in the window with normal title and ASCII art separators
function! VisuTestDisplayTestSuites()
  " Temporarily make the buffer modifiable
  setlocal modifiable

  " Clear the current buffer content
  execute '%delete _'

  " Add VisuTest title in red and surround it with an ASCII box
  call append(line('$'), '╔══════════════════════════╗')
  call append(line('$'), '║        VisuTest          ║')
  call append(line('$'), '╚══════════════════════════╝')
  " Color the title in red
  highlight VisuTestTitle ctermfg=1 guifg=red
  syntax match VisuTestTitle "VisuTest"
  call matchadd('VisuTestTitle', 'VisuTest')

  call append(line('$'), '')

  " Add the test suites header in pink
  call append(line('$'), '------------------------Test Suits------------------------')
  " Color the test suites header in pink
  highlight TestSuitesHeader ctermfg=13 guifg=lightpink
  syntax match TestSuitesHeader "Test Suits"
  call matchadd('TestSuitesHeader', 'Test Suits')

  call append(line('$'), '')

  " Get the list of test suites
  let l:test_suites = VisuTestGetTestSuites()

  " Check if any test suites were found
  if empty(l:test_suites)
    call append(line('$'), "No test suites found.")
  else
    " Display each test suite with the arrow icon (➔) and the Nerd Font eba5 icon
    for l:suite in l:test_suites
      let l:display_line = "➔ \uEBA5 " . l:suite
      call append(line('$'), l:display_line)
      " Color the Nerd Font icon (eba5) in white
      highlight NerdFontIcon ctermfg=15 guifg=white
      execute 'syntax match NerdFontIcon "➔ \uEBA5"'
      call matchadd('NerdFontIcon', '➔ \uEBA5')

      " Color the test suite names in light blue
      highlight TestSuiteName ctermfg=12 guifg=lightblue
      let l:escaped_suite = escape(l:suite, '\')
      " Build the match command for the test suite name
      execute 'syntax match TestSuiteName "' . l:escaped_suite . '"'
      call matchadd('TestSuiteName', l:suite)
    endfor
  endif

  " Set the buffer back to unmodifiable
  setlocal nomodifiable
endfunction

" Function to close the VisuTest window
function! VisuTestCloseWindow()
  " Check if there is a window with the filetype 'visutest'
  for win in range(1, winnr('$'))
    if getbufvar(winbufnr(win), '&filetype') ==# 'visutest'
      execute win . 'wincmd c'
      return
    endif
  endfor
endfunction

" Toggle between opening and closing the window
function! VisuTestToggleWindow()
  " Check if the VisuTest window is already open
  for win in range(1, winnr('$'))
    if getbufvar(winbufnr(win), '&filetype') ==# 'visutest'
      call VisuTestCloseWindow()
      return
    endif
  endfor

  " If not open, open the window
  call VisuTestOpenWindow()

  " Ensure window remains 1/5 size
  let l:split_width = float2nr(&columns * 0.20)
  execute "vertical resize " . l:split_width
endfunction

" Commands to open, close, and toggle the VisuTest window
command! VisuTest :call VisuTestOpenWindow()
command! VisuTestClose :call VisuTestCloseWindow()
command! VisuTestToggle :call VisuTestToggleWindow()

