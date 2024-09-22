" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_core.vim                                  :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 11:58:11 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 15:30:00 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Ensure we only load the plugin once
if exists("g:loaded_visutest_core")
  finish
endif
let g:loaded_visutest_core = 1

" Function to open the VisuTest window
function! VisuTestOpenWindow()
  " Call the autoload function to setup UI
  call visutest_ui#SetupWindowUI()
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
endfunction

" Autocmd to automatically close the VisuTest window when the main buffer is closed
autocmd BufDelete * if bufexists('visutest') | call VisuTestCloseWindow() | endif

