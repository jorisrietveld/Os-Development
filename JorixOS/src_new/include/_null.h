/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 07-01-2018 01:33
 * Licence: GPLv3 - General Public Licence version 3
 *
 * Description:
 * This header file defines the NULL type for both C and C++.
 */
#ifndef OS_DEVELOPMENT_NULL_H
#define OS_DEVELOPMENT_NULL_H

#ifdef NULL // Un define NULL.
#undef NULL
#endif

#ifdef __cplusplus // If using C++, tell the compiler to use C linking.
extern "C"
{
#endif

// standard NULL declaration
#define	NULL 0

#ifdef __cplusplus // If using C++, end the c linking block.
}
#else // If using C declate the standard NULL type. (Generic pointer to 0)
#define NULL (void*)0
#endif

#endif //OS_DEVELOPMENT_NULL_H
