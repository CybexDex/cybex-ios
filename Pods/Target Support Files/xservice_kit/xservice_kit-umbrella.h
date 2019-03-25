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

#import "FlutterServiceCallDispather.h"
#import "FlutterServiceCallHandler.h"
#import "MessageDispatcher.h"
#import "FlutterChannelManager.h"
#import "FlutterMessageClient.h"
#import "FlutterMessageFactory.h"
#import "MCUtils.h"
#import "MessageClient.h"
#import "MessengerFacede.h"
#import "FlutterNativeService.h"
#import "FlutterServiceTemplate.h"
#import "ServiceGateway.h"
#import "XKCollectionHelper.h"
#import "XserviceKitPlugin.h"

FOUNDATION_EXPORT double xservice_kitVersionNumber;
FOUNDATION_EXPORT const unsigned char xservice_kitVersionString[];

