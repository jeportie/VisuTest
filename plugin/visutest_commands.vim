" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_commands.vim                              :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/09/22 12:15:51 by jeportie          #+#    #+#              "
"    Updated: 2024/09/22 15:39:40 by jeportie         ###   ########.fr        "
"                                                                              "
" **************************************************************************** "

" Commands to open, close, and toggle the VisuTest window
command! VisuTest :call visutest_ui#SetupWindowUI() 
command! VisuTestClose :call VisuTestCloseWindow()
command! VisuTestToggle :call VisuTestToggleWindow() 
command! VisuTestShowUnits :call visutest_tests#ShowUnits()
