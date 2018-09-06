/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 07-01-2018 01:51
 * Licence: GPLv3 - General Public Licence version 3
 *
 * Description:
 * This header file defines the standard size types for C and C++.
 */
#ifndef OS_DEVELOPMENT_SIZE_T_H
#define OS_DEVELOPMENT_SIZE_T_H

#ifdef __cplusplus // If using C++, tell the compiler to use C linking.
extern "C"
{
#endif
typedef unsigned size_t;

#ifdef __cplusplus // If using C++, close the C linking block.
}
#endif

#endif //OS_DEVELOPMENT_SIZE_T_H
