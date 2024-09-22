" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_tests.vim                                 :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:11:04 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 15:16:55 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Function to get test units inside each .c file in test_src/
function! visutest_tests#GetTestUnits(suite_file)
  let l:test_units = []
  let l:file_content = readfile(a:suite_file)
  let l:suite_pattern = 'Suite\s*\*.*_suite\s*\(.*\)'
  let l:test_case_pattern = 'tcase_add_test\s*\(.*,\s*\zs\w\+\ze\s*\)'

  let l:in_suite_function = 0
  for l:line in l:file_content
    if match(l:line, l:suite_pattern) != -1
      let l:in_suite_function = 1
    endif
    if l:in_suite_function
      let l:test_case = matchstr(l:line, l:test_case_pattern)
      if !empty(l:test_case)
        call add(l:test_units, l:test_case)
      endif
    endif
    if l:in_suite_function && match(l:line, 'return\s') != -1
      let l:in_suite_function = 0
    endif
  endfor
  return l:test_units
endfunction

" Function to get test suites from test_src/ folder
function! visutest_tests#GetTestSuites()
  let l:test_suites = []
  let l:test_src_dir = getcwd() . '/test_src/'
  let l:files = globpath(l:test_src_dir, '**/test_*.c', 0, 1)
  for l:file in l:files
    call add(l:test_suites, l:file)
  endfor
  return l:test_suites
endfunction

" Function to display the test suites and their test units
function! visutest_tests#DisplayTestSuites()
  setlocal modifiable
  execute '%delete _'

  " Add header
  call append(line('$'), '╔══════════════════════════╗')
  call append(line('$'), '║        VisuTest          ║')
  call append(line('$'), '╚══════════════════════════╝')
  call append(line('$'), '')

  " Setup highlighting for icons, colors, etc.
  call visutest_ui#SetupHighlighting()

  call append(line('$'), '-------- Test Suites --------')
  call append(line('$'), '')

  let l:test_suites = visutest_tests#GetTestSuites()
  if empty(l:test_suites)
    call append(line('$'), "No test suites found.")
  else
    for l:suite_file in l:test_suites
      let l:suite_name = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
      let l:suite_name = substitute(l:suite_name, '\.c$', '', '')
      let l:display_line = "➔ 󰏦 " . l:suite_name
      call append(line('$'), l:display_line)

      let l:test_units = visutest_tests#GetTestUnits(l:suite_file)
      if !empty(l:test_units)
        for l:test_unit in l:test_units
          let l:test_unit_display = "➔ 󰏦 " . l:test_unit
          call append(line('$'), '    ' . l:test_unit_display)
        endfor
      else
        let l:no_test_display = "➔ 󰗖 No test units found"
        call append(line('$'), '    ' . l:no_test_display)
      endif
    endfor
  endif

  setlocal nomodifiable
endfunction

" Function to get the selected test suite name from the current line
function! visutest_tests#GetSelectedSuite()
  let l:line = getline(".")  " Get the current line
  let l:suite_name = substitute(l:line, '^➔ 󰏦', '', '')  " Remove icons
  return l:suite_name
endfunction

" Function to display test units for the selected test suite
function! visutest_tests#ShowUnits()
  " Get the selected suite name
  let l:suite_name = visutest_tests#GetSelectedSuite()

  " Get the list of test suites
  let l:test_suites = visutest_tests#GetTestSuites()

  " Find the suite file corresponding to the selected suite name
  for l:suite_file in l:test_suites
    let l:extracted_suite = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
    let l:extracted_suite = substitute(l:extracted_suite, '\.c$', '', '')

    if l:extracted_suite == l:suite_name
      " Get test units for the suite
      let l:test_units = visutest_tests#GetTestUnits(l:suite_file)

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
