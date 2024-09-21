" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest.vim                                       :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/21 18:24:04 by jeportie          #+#    #+#              "
"    Updated: 2024/09/21 18:34:23 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Syntax for VisuTest plugin
syntax match VisuTestIcon "^\uF111"

" Apply orange color to the icon
highlight VisuTestIcon ctermfg=208 guifg=#FFA500
