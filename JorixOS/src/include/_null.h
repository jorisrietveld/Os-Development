/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 07-01-2018 01:33
 * Licence: GPLv3 - General Public Licence version 3
 */
#ifndef OS_DEVELOPMENT_NULL_H
#define OS_DEVELOPMENT_NULL_H

#ifdef NULL
// If NULL is defined undefine it.
#undef NULL
#endif

#ifdef __cplusplus  // If we use C++
extern "C"
{
#endif
// Define the standard c++ null type.
#define  NULL 0

#ifdef  __cplusplus
}
#else
// Define the standard C NULL type.
#define NULL (void*)0
#endif

#endif //OS_DEVELOPMENT_NULL_H
