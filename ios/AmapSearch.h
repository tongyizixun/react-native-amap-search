/*
 * @Author: 刘利军
 * @Date: 2023-07-17 15:25:24
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-17 17:24:11
 * @Description: 
 * @PageName: 
 */

#import <Foundation/Foundation.h>

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

@interface AmapSearch : NSObject <RCTBridgeModule>

@end
