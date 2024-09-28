" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 15:05:24 by jeportie          #+#    #+#              "
"    Updated: 2024/09/28 14:55:52 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Ensure we only load the plugin once
if exists("g:loaded_visutest")
  finish
endif
let g:loaded_visutest = 1

" Function to ensure window remains 1/5 of the total width
"function! VisuTestResizeWindow()
"  let l:split_width = float2nr(&columns * 0.20)
"  execute "vertical resize " . l:split_width
"endfunction

" Autocommand to resize the VisuTest window when Vim is resized
"autocmd VimResized * call VisuTestResizeWindow()

" Load the core and UI modules
runtime! autoload/visutest_core.vim
runtime! autoload/visutest_ui.vim

" Start the VisuTest server when the plugin is loaded
call visutest_core#StartServer()
" Stop the VisuTest server when Vim exits
autocmd VimLeavePre * call visutest_core#StopServer()

" Function to setup autocommands
function! visutest#SetupAutocmds()
  augroup visutest_popup_management
    autocmd!
    " Close popup when leaving any window
    autocmd WinLeave * call visutest_ui#ClosePopup()
    " Close popup when entering a new buffer
    autocmd BufEnter * call visutest_ui#ClosePopup()
  augroup END
endfunction

" Initialize autocommands
call visutest#SetupAutocmds()
