" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_commands.vim                              :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:15:51 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 12:36:52 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Commands to open, close, and toggle the VisuTest window
command! VisuTest :call visutest#SetupWindowUI() | call VisuTestResizeWindow()

command! VisuTestClose :call VisuTestCloseWindow()
command! VisuTestToggle :call VisuTestToggleWindow() | call VisuTestResizeWindow()
command! VisuTestShowUnits :call visutest#ShowUnits()