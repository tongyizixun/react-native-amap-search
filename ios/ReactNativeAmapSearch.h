
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNReactNativeAmapSearchSpec.h"

@interface ReactNativeAmapSearch : NSObject <NativeReactNativeAmapSearchSpec>
#else
#import <React/RCTBridgeModule.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface ReactNativeAmapSearch : NSObject <RCTBridgeModule, AMapSearchDelegate>
#endif

@end
