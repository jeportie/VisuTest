/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_handle_plus_flag.c                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/12/29 21:19:16 by jeportie          #+#    #+#             */
/*   Updated: 2024/03/21 11:24:21 by jeportie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/libft.h"

void	ft_handle_plus_flag(t_format_spec spec, int content, t_buffer *buf_info)
{
	if (spec.flag_plus)
	{
		if (content >= 0 && spec.type != 'u')
			ft_buffer_add(buf_info, '+');
	}
}
