/**
 * Author: Joris Rietveld <jorisrietveld@gmail.com>
 * Date: 07-01-2018 01:56
 * Licence: GPLv3 - General Public Licence version 3
 */
#ifndef OS_DEVELOPMENT_STDINT_H
#define OS_DEVELOPMENT_STDINT_H

#define __need_wint_t
#define __need_wchar_t

// Defining exact width integer types.
typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

// Defining minimum-width integer types.
typedef signed char int_least8_t;
typedef unsigned char uint_least8_t;
typedef short int_least16_t;
typedef unsigned short uint_least16_t;
typedef int int_least32_t;
typedef unsigned uin_least32_t;
typedef long long int_least64_t;
typedef unsigned long long uint_least64_t;

//
typedef char int_fast8_t;
typedef unsigned char

#endif //OS_DEVELOPMENT_STDINT_H
