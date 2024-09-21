" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 15:05:24 by jeportie          #+#    #+#              "
"    Updated: 2024/09/21 15:27:39 by jeportie         ###   ########.fr        "
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
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nowrap
  setlocal nonumber
  setlocal norelativenumber
  setlocal signcolumn=no

  " Set a name for the buffer
  setlocal filetype=visutest
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal bufhidden=wipe

  " Display placeholder text (you can leave this empty for now)
  normal! iVisuTest - Test Suite Overview
endfunction

" Command to open the window
command! VisuTest :call VisuTestOpenWindow()
