" autoload/visutest_core.vim

" Function to toggle the test suite popup
function! visutest_core#TogglePopup()
  " Check if any popups are active
  if !empty(g:visutest_popups)
    call visutest_ui#CloseTestSuitePopup()
  else
    call visutest_ui#ShowTestSuitePopup()
  endif
endfunction
