/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_check_format.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jeportie <jeportie@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2023/12/26 19:02:54 by jeportie          #+#    #+#             */
/*   Updated: 2024/06/27 18:10:06 by jeportie         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/libft.h"

int	ft_check_format(t_format_spec *spec)
{
	if (spec->type == 'c')
	{
		if (spec->width >= 0 && spec->precision == -1)
			return (1);
		spec->error = ERNOFORMAT;
		return (0);
	}
	else if (spec->type == 's')
		return (spec->width >= 0);
	else if (spec->type == 'p')
		return (spec->width >= 0 && spec->precision == -1);
	else if (spec->type == 'd' || spec->type == 'i' || spec->type == 'u')
		return (spec->width >= 0);
	else if (spec->type == 'x' || spec->type == 'X')
		return (spec->width >= 0 && spec->precision >= -1);
	else if (spec->type == '%')
		return (spec->width >= 0 && spec->precision == -1);
	else
	{
		spec->error = ERNOFORMAT;
		return (0);
	}
}
