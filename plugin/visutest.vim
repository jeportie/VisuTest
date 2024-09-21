" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 15:05:24 by jeportie          #+#    #+#              "
"    Updated: 2024/09/21 17:12:42 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Ensure we only load the plugin once
if exists("g:loaded_visutest")
  finish
endif
let g:loaded_visutest = 1

" Function to open an empty vertical window
function! VisuTestOpenWindow()
  " Split the window vertically to 1/4 of the total width
  let l:current_width = winwidth(0)
  let l:split_width = float2nr(l:current_width * 0.25)

  " Open a new vertical window on the right
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

  " Set the filetype for identification
  setlocal filetype=visutest

  " Prevent buffer from being listed
  setlocal nobuflisted            " Hide buffer from buffer list

  " Display placeholder text (can be changed later)
  normal! iVisuTest - Test Suite Overview
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

" Commands to open, close, and toggle the VisuTest window
command! VisuTest :call VisuTestOpenWindow()
command! VisuTestClose :call VisuTestCloseWindow()
command! VisuTestToggle :call VisuTestToggleWindow()
