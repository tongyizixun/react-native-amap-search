/*
 * @Author: 刘利军
 * @Date: 2023-05-20 20:53:05
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-17 14:26:27
 * @Description: 
 * @PageName: 
 */



#ifdef RCT_NEW_ARCH_ENABLED
#import "RNReactNativeAmapSearchSpec.h"

@interface ReactNativeAmapSearch : NSObject <NativeReactNativeAmapSearchSpec>
#else
// #import "RCTBridgeModule.h"
#import <AMapSearchKit/AMapSearchKit.h>

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#elif __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#import "RCTEventEmitter.h"
#elif __has_include("React/RCTBridgeModule.h")
#import "React/RCTBridgeModule.h"
#import "React/RCTEventEmitter.h"
#endif

@interface ReactNativeAmapSearch : NSObject <RCTBridgeModule, AMapSearchDelegate>
#endif

@end
