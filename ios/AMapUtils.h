//
//  AMapUtils.h
//  AmapSearch
//
//  Created by 刘利军 on 2023/7/21.
//  Copyright © 2023 Facebook. All rights reserved.
//

#ifndef AMapUtils_h
#define AMapUtils_h

#import <AMapSearchKit/AMapSearchKit.h>
#import <Foundation/Foundation.h>

@interface AMapUtils : NSObject
- (NSArray<AMapPOI *> *)poiFormatData:(NSArray <AMapPOI *> *)data;

- (NSArray<AMapAOI *> *)aoiFormatData:(NSArray<AMapAOI *> *)data;

- (NSArray<AMapPOI *> *)poiSearchResponseFormatData:(AMapPOISearchResponse *)data;

///商圈列表 AMapBusinessArea 数组转换
- (NSArray<AMapBusinessArea *> *)businessFormatData:(NSArray<AMapBusinessArea *> *)data;

///道路信息 AMapRoad 数组
- (NSArray<AMapRoad *> *)roadsFormatData:(NSArray<AMapRoad *> *)data;

///道路路口信息 AMapRoadInter 数组
- (NSArray<AMapRoadInter *> *)roadsInterFormatData:(NSArray<AMapRoadInter *> *)data;

///逆地理编码
- (NSDictionary *)regeocodeFormatData:(AMapReGeocodeSearchResponse *)data;

///地理编码
- (NSArray *)geocodeFormatData:(AMapGeocodeSearchResponse *)data;


///行政区划
- (NSArray<AMapDistrict *> *)districtFormatData:(NSArray<AMapDistrict *> *)data;

@end

#endif /* AMapUtils_h */
