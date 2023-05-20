/*
 * @Author: 刘利军
 * @Date: 2023-05-20 21:04:42
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-05-20 21:05:18
 * @Description: 
 * @PageName: 
 */
//
//  Utils.h
//  ReactNativeAmapSearch
//
//  Created by 刘利军 on 2023/5/20.
//  Copyright © 2023 Facebook. All rights reserved.
//

#ifndef Utils_h
#define Utils_h


#import <AMapSearchKit/AMapSearchKit.h>
#import <Foundation/Foundation.h>

@interface Utils : NSObject

- (NSArray<AMapPOI *> *)poiFormatData:(NSArray <AMapPOI *> *)data;

- (NSArray<AMapAOI *> *)aoiFormatData:(NSArray<AMapAOI *> *)data;

- (NSArray *)poiSearchResponseFormatData:(AMapPOISearchResponse *)data;

///商圈列表 AMapBusinessArea 数组转换
- (NSArray<AMapBusinessArea *> *)businessFormatData:(NSArray<AMapBusinessArea *> *)data;

///道路信息 AMapRoad 数组
- (NSArray<AMapRoad *> *)roadsFormatData:(NSArray<AMapRoad *> *)data;

///道路路口信息 AMapRoadInter 数组
- (NSArray<AMapRoadInter *> *)roadsInterFormatData:(NSArray<AMapRoadInter *> *)data;

@end

#endif /* Utils_h */
