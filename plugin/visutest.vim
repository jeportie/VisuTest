" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 15:05:24 by jeportie          #+#    #+#              "
"    Updated: 2024/09/21 21:38:08 by jeportie         ###   ########.fr        "
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

  " Disable buffer switching commands like bnext/bprev in this buffer
  nnoremap <buffer> <silent> :bnext <NOP>
  nnoremap <buffer> <silent> :bprev <NOP>
endfunction

" Function to parse test units inside each .c file in test_src/
function! VisuTestGetTestUnits(suite_file)
  let l:test_units = []

  " Read the content of the .c file
  let l:file_content = readfile(a:suite_file)

  " Regular expression to match test unit function declarations (e.g., void test_*())
  let l:pattern = 'void\s\+test_\w\+\s*('

  " Scan each line of the file and look for test unit functions
  for l:line in l:file_content
    if match(l:line, l:pattern) != -1
      " Extract the function name (e.g., test_case1_function_name1)
      let l:function_name = matchstr(l:line, '\vtest_\w+')
      call add(l:test_units, l:function_name)
    endif
  endfor

  return l:test_units
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
    call add(l:test_suites, l:file)
  endfor

  return l:test_suites
endfunction

" Function to display the test suites and test units
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

  " Add the test suites header in pink, centered with fewer dashes
  call append(line('$'), '------ Test Suits ------------')
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
    for l:suite_file in l:test_suites
      " Extract the suite name from the file name
      let l:suite_name = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
      let l:suite_name = substitute(l:suite_name, '\.c$', '', '')

      let l:display_line = "➔ \uEBA5 " . l:suite_name
      call append(line('$'), l:display_line)

      " Color the arrow in orange
      highlight ArrowIcon ctermfg=214 guifg=orange
      execute 'syntax match ArrowIcon "➔"'
      call matchadd('ArrowIcon', '➔')

      " Color the Nerd Font icon (eba5) in white
      highlight NerdFontIcon ctermfg=15 guifg=white
      execute 'syntax match NerdFontIcon "\uEBA5"'
      call matchadd('NerdFontIcon', '\uEBA5')

      " Color the test suite names in lighter blue
      highlight TestSuiteName ctermfg=81 guifg=#add8e6
      let l:escaped_suite = escape(l:suite_name, '\')
      execute 'syntax match TestSuiteName "' . l:escaped_suite . '"'
      call matchadd('TestSuiteName', l:suite_name)
    endfor
  endif

  " Set the buffer back to unmodifiable
  setlocal nomodifiable
endfunction

" Function to get the selected test suite name from the current line
function! VisuTestGetSelectedSuite()
  let l:line = getline(".")  " Get the current line
  let l:suite_name = substitute(l:line, '^➔ \uEBA5 ', '', '')  " Remove icons
  return l:suite_name
endfunction

" Function to display test units for the selected test suite
function! VisuTestShowUnits()
  " Get the selected suite name
  let l:suite_name = VisuTestGetSelectedSuite()

  " Get the list of test suites
  let l:test_suites = VisuTestGetTestSuites()

  " Find the suite file corresponding to the selected suite name
  for l:suite_file in l:test_suites
    let l:extracted_suite = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
    let l:extracted_suite = substitute(l:extracted_suite, '\.c$', '', '')

    if l:extracted_suite == l:suite_name
      " Get test units for the suite
      let l:test_units = VisuTestGetTestUnits(l:suite_file)

      " Display test units under the selected suite
      call append(line('$'), '  Test Units for ' . l:extracted_suite . ':')
      if !empty(l:test_units)
        for l:test_unit in l:test_units
          call append(line('$'), '    - ' . l:test_unit)
        endfor
      else
        call append(line('$'), '  No test units found.')
      endif

      break
    endif
  endfor
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

" Command to show the test units for the currently selected test suite
command! VisuTestShowUnits :call VisuTestShowUnits()

