/*
 * @Author: 刘利军
 * @Date: 2023-05-20 20:53:05
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-17 14:16:02
 * @Description: 
 * @PageName: 
 */

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNReactNativeAmapSearchSpec.h"

@interface ReactNativeAmapSearch : NSObject <NativeReactNativeAmapSearchSpec>
#else
#import "RCTBridgeModule.h"
#import <AMapSearchKit/AMapSearchKit.h>

@interface ReactNativeAmapSearch : NSObject <RCTBridgeModule, AMapSearchDelegate>
#endif

@end
