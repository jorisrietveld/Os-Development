/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 09-01-2018 15:34
 * Licence: GPLv3 - General Public Licence version 3
 *
 * Description:
 * This header contains macros for variable length arguments list.
 */
#ifndef OS_DEVELOPMENT_STDARG_H
#define OS_DEVELOPMENT_STDARG_H
#include <va_list.h>

#ifdef __cplusplus // If using C++, tell the compiler to use C linking.
extern "C"
{
#endif

/**
 * Define an constant that holds the width of an argument. C++ uses the stack to
 * pass arguments to an function.
 */
#define	STACKITEM int

/**
 * Define an macro that gets the size of an parameter of an certain size. The fist part
 * ((sizeof(TYPE) + sizeof(STACKITEM) - 1) makes sure you get the size of 0 for size 0 objects.
 */
#define	VA_SIZE(TYPE)\
    ((sizeof(TYPE) + sizeof(STACKITEM) - 1) & ~(sizeof(STACKITEM) - 1))

/**
 * &(LASTARG) will point to the left most argument of the function call.
 * function( someArg ...) then it points to someArg
 */
#define	va_start(AP, LASTARG)\
    (AP=((va_list)&(LASTARG) + VA_SIZE(LASTARG)))

/**
 * The end of the variable length argument list.
 */
#define va_end(AP)

/**
 * Combine everything
 */
#define va_arg(AP, TYPE)\
	(AP += VA_SIZE(TYPE), *((TYPE *)(AP - VA_SIZE(TYPE))))

#ifdef __cplusplus // If using C++, close the C linking block.
}
#endif

#endif //OS_DEVELOPMENT_STDARG_H
