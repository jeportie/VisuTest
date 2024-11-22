" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_tests.vim                                 :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/16 15:37:27 by jeportie          #+#    #+#              "
"    Updated: 2024/11/22 14:13:41 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "


"""""""""" Initialize Global Variables """""""""""""""""""""""""""""
if !exists('g:visutest_test_statuses')
  let g:visutest_test_statuses = {}
endif
if !exists('g:visutest_all_subtests')
  let g:visutest_all_subtests = {}
endif
if !exists('g:visutest_expanded_folders')
  let g:visutest_expanded_folders = {}
endif

" Global state variable to track whether to show or hide test units
let g:visutest_tests_show_units = 1

"""""""""" Function to toggle display of test units under test suites """"""""""
function! visutest_tests#ToggleUnits()
  if g:visutest_tests_show_units
    let g:visutest_tests_show_units = 0
    call visutest_tests#HideUnits()
  else
    let g:visutest_tests_show_units = 1
    call visutest_tests#DisplayTestSuites()
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
  return l:test_units
endfunction

"""""""""" Function to get all test suite files in the test_src folder """""""""
function! visutest_tests#GetTestSuites()
  let l:test_suites = []
  let l:test_src_dir = getcwd() . '/test_src/'
  let l:files = globpath(l:test_src_dir, '**/test_*.c', 0, 1)
  for l:file in l:files
    call add(l:test_suites, l:file)
  endfor
  return l:test_suites
endfunction

"""""""""" Function to display test suites and units in the UI """"""""""""""""
" Function to display test suites and units in the UI
" Function to display test suites and units in the UI
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

  " Display test hierarchy
  call append(line('$'), '-------- Test Suites --------')
  call append(line('$'), '')

  " Get the test hierarchy
  let l:test_hierarchy = visutest_tests#GetTestHierarchy()

  if empty(l:test_hierarchy)
    call append(line('$'), ['No test suites found.'])
  else
    for l:folder_name in sort(keys(l:test_hierarchy))
      " Display the folder name
      let l:is_folder_expanded = get(g:visutest_expanded_folders, l:folder_name, 0)
      let l:folder_icon = l:is_folder_expanded ? '▼' : '▶'
      let l:folder_line = l:folder_icon . ' ' . l:folder_name
      call append(line('$'), [l:folder_line])

      " If folder is expanded, display test suites
      if l:is_folder_expanded
        for l:suite in l:test_hierarchy[l:folder_name]
          let l:suite_name = l:suite.name
          let l:suite_file = l:suite.file
          let l:status = get(g:visutest_test_statuses, l:suite_name, 'waiting')
          let l:icon = l:status ==# 'passed' ? '🟢' :
                \ l:status ==# 'failed' ? '🔴' : '⚪'
          " **Remove indentation before test suite names**
          let l:suite_line = "➔ " . l:icon . " " . l:suite_name
          call append(line('$'), [l:suite_line])

          " Initialize subtest statuses for all suites
          " Populate the list of all sub-tests
          let l:test_units = visutest_tests#GetTestUnits(l:suite_file)
          let g:visutest_all_subtests[l:suite_name] = l:test_units

          " Initialize subtest statuses if not already done
          if !has_key(g:visutest_subtest_statuses, l:suite_name)
            let g:visutest_subtest_statuses[l:suite_name] = {}
          endif

          " Initialize all subtests as 'waiting' if not already set
          for l:subtest in l:test_units
            if !has_key(g:visutest_subtest_statuses[l:suite_name], l:subtest)
              let g:visutest_subtest_statuses[l:suite_name][l:subtest] = 'waiting'
            endif
          endfor

          " Check if test suite is expanded
          let l:is_suite_expanded = get(g:visutest_expanded_suites, l:suite_name, 0)
          if l:is_suite_expanded
            " Display sub-tests
            for l:test_unit in g:visutest_all_subtests[l:suite_name]
              " Get sub-test status
              let l:subtest_status = visutest_helper#GetSubtestStatus(l:suite_name, l:test_unit)
              let l:subtest_icon = l:subtest_status ==# 'passed' ? '🟢' :
                    \ l:subtest_status ==# 'failed' ? '🔴' : '⚪'
              " **Indent subtests under test suites**
              let l:subtest_line = "    ➔ " . l:subtest_icon . " " . l:test_unit
              call append(line('$'), [l:subtest_line])
            endfor
          endif
        endfor
      endif
    endfor
  endif

  setlocal nomodifiable
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

" Function to toggle the expansion of a test suite
function! visutest_tests#ToggleSuiteUnits()
  setlocal modifiable
  let l:current_line_num = line('.')
  let l:line_text = getline('.')

  " Get the suite name from the current line
  let l:suite_name = matchstr(l:line_text, '^➔ [🟢🔴⚪] \zs.*$')

  if l:suite_name == ''
    " Not a test suite line
    setlocal nomodifiable
    return
  endif

  " Toggle the expansion state
  let l:is_expanded = get(g:visutest_expanded_suites, l:suite_name, 0)
  let g:visutest_expanded_suites[l:suite_name] = !l:is_expanded

  " Re-display the test suites
  call visutest_tests#DisplayTestSuites()

  " Move cursor back to the suite line
  call cursor(l:current_line_num, 1)

  setlocal nomodifiable
endfunction

" Function to get all test folders in the test_src directory, excluding 'build'
function! visutest_tests#GetTestFolders()
  let l:test_src_dir = getcwd() . '/test_src/'
  let l:folders = []
  let l:all_entries = globpath(l:test_src_dir, '*', 1, 1)
  for l:entry in l:all_entries
    if isdirectory(l:entry) && fnamemodify(l:entry, ':t') !=# 'build'
      call add(l:folders, l:entry)
    endif
  endfor
  return l:folders
endfunction

" Function to build a hierarchy of folders to test suites
function! visutest_tests#GetTestHierarchy()
  let l:test_hierarchy = {}
  let l:test_folders = visutest_tests#GetTestFolders()
  for l:folder in l:test_folders
    let l:folder_name = fnamemodify(l:folder, ':t')
    " Get all test_*.c files in the folder
    let l:test_files = globpath(l:folder, 'test_*.c', 0, 1)
    if !empty(l:test_files)
      let l:test_hierarchy[l:folder_name] = []
      for l:test_file in l:test_files
        " Get the test suite name
        let l:suite_name = substitute(fnamemodify(l:test_file, ':t'), '^test_', '', '')
        let l:suite_name = substitute(l:suite_name, '\.c$', '', '')
        call add(l:test_hierarchy[l:folder_name], {'file': l:test_file, 'name': l:suite_name})
      endfor
    endif
  endfor
  return l:test_hierarchy
endfunction

" Function to toggle the expansion of a folder
function! visutest_tests#ToggleFolder()
  setlocal modifiable
  let l:current_line_num = line('.')
  let l:line_text = getline('.')

  " Get the folder name from the current line
  let l:folder_name = matchstr(l:line_text, '^[▶▼] \zs.*$')

  if l:folder_name == ''
    " Not a folder line
    setlocal nomodifiable
    return
  endif

  " Toggle the expansion state
  let l:is_expanded = get(g:visutest_expanded_folders, l:folder_name, 0)
  let g:visutest_expanded_folders[l:folder_name] = !l:is_expanded

  " Re-display the test suites
  call visutest_tests#DisplayTestSuites()

  " Move cursor back to the folder line
  call cursor(l:current_line_num, 1)

  setlocal nomodifiable
endfunction

