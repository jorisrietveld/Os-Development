/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 09-01-2018 15:34
 * Licence: GPLv3 - General Public Licence version 3
 */
#ifndef OS_DEVELOPMENT_STDARG_H
#define OS_DEVELOPMENT_STDARG_H
#include <va_list.h>

#ifdef __cplusplus // If using C++, tell the compiler to use C linking.
extern "C"
{
#endif

// width of stack == width of int
#define	STACKITEM int

// Round up the width of objects pushed on the stack.
#define	VA_SIZE(TYPE)\
    ((sizeof(TYPE) + sizeof(STACKITEM) - 1) & ~(sizeof(STACKITEM) - 1))

// &(LASTARG) will point to the left most argument of the function call.
#define	va_start(AP, LASTARG)\
    (AP=((va_list)&(LASTARG) + VA_SIZE(LASTARG)))

// The end of the argument list.
#define va_end(AP)

// Combine everything
#define va_arg(AP, TYPE)\
	(AP += VA_SIZE(TYPE), *((TYPE *)(AP - VA_SIZE(TYPE))))

#ifdef __cplusplus // If using C++, close the C linking block.
}
#endif

#endif //OS_DEVELOPMENT_STDARG_H
