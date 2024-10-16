" **************************************************************************** "
"                                                                              "
"                                                         :::      ::::::::    "
"    visutest_helper.vim                                 :+:      :+:    :+:    "
"                                                     +:+ +:+         +:+      "
"    By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+         "
"                                                 +#+#+#+#+#+   +#+            "
"    Created: 2024/10/01 12:00:00 by jeportie          #+#    #+#              "
" **************************************************************************** "

"""""""""" Helper Function to Retrieve Subtest Status """"""""""""""""""""""
function! visutest_helper#GetSubtestStatus(suite, subtest)
  return get(get(g:visutest_subtest_statuses, a:suite, {}), a:subtest, 'waiting')
endfunction

