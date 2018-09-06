/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 09-01-2018 15:30
 * Licence: GPLv3 - General Public Licence version 3
 */
#ifndef OS_DEVELOPMENT_VA_LIST_H
#define OS_DEVELOPMENT_VA_LIST_H

#ifdef __cplusplus // If using C++, tell the compiler to use C linking.
extern "C"
{
#endif

// Variable length parameter list.
typedef unsigned char *va_list;

#ifdef __cplusplus // If using C++, close the C linking block.
}
#endif

#endif //OS_DEVELOPMENT_VA_LIST_H
