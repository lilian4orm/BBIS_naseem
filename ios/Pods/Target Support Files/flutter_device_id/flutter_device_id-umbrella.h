#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif


FOUNDATION_EXPORT double flutter_device_idVersionNumber;
FOUNDATION_EXPORT const unsigned char flutter_device_idVersionString[];

