
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNAmapSearchSpec.h"

@interface AmapSearch : NSObject <NativeAmapSearchSpec>
#else
#import <React/RCTBridgeModule.h>
#import <AMapSearchKit/AMapSearchKit.h>
@interface AmapSearch : NSObject <RCTBridgeModule, AMapSearchDelegate>
#endif

@end
