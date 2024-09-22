" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 15:05:24 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 12:32:22 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Ensure we only load the plugin once
if exists("g:loaded_visutest")
  finish
endif
let g:loaded_visutest = 1

" Function to ensure window remains 1/5 of the total width
function! VisuTestResizeWindow()
  let l:split_width = float2nr(&columns * 0.20)
  execute "vertical resize " . l:split_width
endfunction

" Autocommand to resize the VisuTest window when Vim is resized
autocmd VimResized * call VisuTestResizeWindow()
