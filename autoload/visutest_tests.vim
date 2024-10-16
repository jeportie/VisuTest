" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_tests.vim                                 :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:37:27 by jeportie          #+#    #+#              "
"    Updated: 2024/10/16 15:52:04 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "


"""""""""" Initialize Global Variables """""""""""""""""""""""""""""
if !exists('g:visutest_test_statuses')
  let g:visutest_test_statuses = {}
  echom "Initialized g:visutest_test_statuses"
endif
if !exists('g:visutest_all_subtests')
  let g:visutest_all_subtests = {}
  echom "Initialized g:visutest_all_subtests"
endif

" Global state variable to track whether to show or hide test units
let g:visutest_tests_show_units = 1

"""""""""" Function to toggle display of test units under test suites """"""""""
function! visutest_tests#ToggleUnits()
  if g:visutest_tests_show_units
    let g:visutest_tests_show_units = 0
    call visutest_tests#HideUnits()
    echom "Toggled off sub-test display."
  else
    let g:visutest_tests_show_units = 1
    call visutest_tests#DisplayTestSuites()
    echom "Toggled on sub-test display."
  endif
endfunction

"""""""""" Function to hide the test units and reset UI layout """""""""""""""
function! visutest_tests#HideUnits()
  setlocal modifiable
  execute '%delete _'

  " Add header for VisuTest
  call append(line('$'), '╔══════════════════════════╗')
  call append(line('$'), '║        VisuTest          ║')
  call append(line('$'), '╚══════════════════════════╝')
  call append(line('$'), '')

  " Setup highlighting for icons, colors, etc.
  call visutest_ui#SetupHighlighting()

  " Add a section for test suites
  call append(line('$'), '-------- Test Suites --------')
  call append(line('$'), '')

  let l:test_suites = visutest_tests#GetTestSuites()
  if empty(l:test_suites)
    call append(line('$'), ['No test suites found.'])
  else
    for l:suite_file in l:test_suites
      let l:suite_name = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
      let l:suite_name = substitute(l:suite_name, '\.c$', '', '')
      let l:status = get(g:visutest_test_statuses, l:suite_name, 'waiting')
      let l:icon = l:status ==# 'passed' ? '🟢' :
            \ l:status ==# 'failed' ? '🔴' : '⚪'
      let l:display_line = "➔ " . l:icon . " " . l:suite_name
      call append(line('$'), [l:display_line])
    endfor
  endif

  setlocal nomodifiable
  echom "Displayed test suites without sub-tests."
endfunction

"""""""""" Function to get test units from a test suite file """""""""""""""""
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
  echom "Extracted " . len(l:test_units) . " sub-tests from " . a:suite_file
  return l:test_units
endfunction

"""""""""" Function to get all test suite files in the test_src folder """""""""
function! visutest_tests#GetTestSuites()
  let l:test_suites = []
  let l:test_src_dir = getcwd() . '/test_src/'
  let l:files = globpath(l:test_src_dir, '**/test_*.c', 0, 1)
  for l:file in l:files
    call add(l:test_suites, l:file)
    echom "Found test suite file: " . l:file
  endfor
  return l:test_suites
endfunction

"""""""""" Function to display test suites and units in the UI """"""""""""""""
function! visutest_tests#DisplayTestSuites()
  setlocal modifiable
  execute '%delete _'

  " Add header for VisuTest
  call append(line('$'), '╔══════════════════════════╗')
  call append(line('$'), '║        VisuTest          ║')
  call append(line('$'), '╚══════════════════════════╝')
  call append(line('$'), '')

  " Setup highlighting for icons, colors, etc.
  call visutest_ui#SetupHighlighting()

  " Display test suites
  call append(line('$'), '-------- Test Suites --------')
  call append(line('$'), '')

  let l:test_suites = visutest_tests#GetTestSuites()
  if empty(l:test_suites)
    call append(line('$'), ['No test suites found.'])
  else
    for l:suite_file in l:test_suites
      let l:suite_name = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
      let l:suite_name = substitute(l:suite_name, '\.c$', '', '')
      let l:status = get(g:visutest_test_statuses, l:suite_name, 'waiting')
      let l:icon = l:status ==# 'passed' ? '🟢' :
            \ l:status ==# 'failed' ? '🔴' : '⚪'
      let l:display_line = "➔ " . l:icon . " " . l:suite_name
      call append(line('$'), [l:display_line])

      " Populate the list of all sub-tests
      let l:test_units = visutest_tests#GetTestUnits(l:suite_file)
      let g:visutest_all_subtests[l:suite_name] = l:test_units

      echom "Populated g:visutest_all_subtests for suite: " . l:suite_name

      " Initialize subtest statuses if not already done
      if !has_key(g:visutest_subtest_statuses, l:suite_name)
        let g:visutest_subtest_statuses[l:suite_name] = {}
      endif

      " Initialize all subtests as 'waiting'
      for l:subtest in l:test_units
        if !has_key(g:visutest_subtest_statuses[l:suite_name], l:subtest)
          let g:visutest_subtest_statuses[l:suite_name][l:subtest] = 'waiting'
        endif
      endfor

      " Display sub-tests if units are shown
      if !empty(g:visutest_all_subtests[l:suite_name]) && g:visutest_tests_show_units
        for l:test_unit in g:visutest_all_subtests[l:suite_name]
          " Get sub-test status using the helper function
          let l:subtest_status = visutest_helper#GetSubtestStatus(l:suite_name, l:test_unit)
          let l:subtest_icon = l:subtest_status ==# 'passed' ? '🟢' :
                \ l:subtest_status ==# 'failed' ? '🔴' : '⚪'
          let l:test_unit_display = "    ➔ " . l:subtest_icon . " " . l:test_unit
          call append(line('$'), [l:test_unit_display])
        endfor
      else
        let l:no_test_display = "    ➔ 🔴 No test units found"
        call append(line('$'), [l:no_test_display])
      endif
    endfor
  endif

  setlocal nomodifiable
  echom "Displayed test suites with sub-tests."
endfunction

"""""""""" Function to get the name of the selected test suite """""""""""""""
function! visutest_tests#GetSelectedSuite()
  let l:line = getline(".")  " Get the current line
  let l:suite_name = substitute(l:line, '^➔ [🟢🔴⚪] ', '', '')  " Remove icons
  return l:suite_name
endfunction

"""""""""" Function to display the test units for a selected suite """"""""""""
function! visutest_tests#ShowUnits()
  let l:suite_name = visutest_tests#GetSelectedSuite()
  let l:test_suites = visutest_tests#GetTestSuites()

  for l:suite_file in l:test_suites
    let l:extracted_suite = substitute(fnamemodify(l:suite_file, ':t'), '^test_', '', '')
    let l:extracted_suite = substitute(l:extracted_suite, '\.c$', '', '')

    if l:extracted_suite == l:suite_name
      let l:test_units = visutest_tests#GetTestUnits(l:suite_file)

      call append(line('$'), ['  Test Units for ' . l:extracted_suite . ':'])

      if !empty(l:test_units)
        " Populate the list of all sub-tests if not already done
        if !has_key(g:visutest_all_subtests, l:extracted_suite)
          let g:visutest_all_subtests[l:extracted_suite] = l:test_units
        endif

        for l:test_unit in l:test_units
          " Get sub-test status using the helper function
          let l:subtest_status = visutest_helper#GetSubtestStatus(l:extracted_suite, l:test_unit)
          let l:subtest_icon = l:subtest_status ==# 'passed' ? '🟢' :
                \ l:subtest_status ==# 'failed' ? '🔴' : '⚪'
          let l:test_unit_display = "    ➔ " . l:subtest_icon . " " . l:test_unit
          call append(line('$'), [l:test_unit_display])
        endfor
      else
        call append(line('$'), ['    ➔ 🔴 No test units found.'])
      endif
      break
    endif
  endfor
endfunction

""""""""""""" Mapping to toggle units display with 'P' key """""""""""""""""
nnoremap <silent> P :call visutest_tests#ToggleUnits()<CR>
