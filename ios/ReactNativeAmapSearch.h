
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNReactNativeAmapSearchSpec.h"

@interface ReactNativeAmapSearch : NSObject <NativeReactNativeAmapSearchSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ReactNativeAmapSearch : NSObject <RCTBridgeModule>
#endif

@end
