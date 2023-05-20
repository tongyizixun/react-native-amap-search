//
//  Utils.m
//  ReactNativeAmapSearch
//
//  Created by 刘利军 on 2023/5/20.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utils.h"

@implementation Utils

/// 转换经纬度格式
- (NSDictionary *)geoPointFormatData:(AMapGeoPoint *)data
{
  return @{
    @"latitude": @(data.latitude), // 纬度（垂直方向）
    @"longitude": @(data.longitude) // 经度（水平方向）
  };
}

/// 转换成poi数据格式
- (NSArray<AMapPOI *> *)poiFormatData:(NSArray<AMapPOI *> *)data
{
  NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:data.count];
  if(data.count>0){
    [data enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [resultList addObject:@{
                                @"uid": obj.uid, // uid
                                @"name": obj.name, // 名称
                                @"type": obj.type, //兴趣点类型
                                @"typecode": obj.typecode, // 类型编码
                                @"location": [self geoPointFormatData:obj.location],
                                @"address": obj.address, // 地址
                                @"tel": obj.tel, // 电话
                                @"distance": @(obj.distance), //距中心点的距离，单位米
                                @"parkingType":obj.parkingType, //停车场类型，地上、地下
                                @"shopID":obj.shopID, // 商铺id
                                @"postcode":obj.postcode, //邮编
                                @"website":obj.website, // 网址
                                @"email":obj.email, //电子邮件
                                @"province":obj.province, //省
                                @"pcode" : obj.pcode, //省编码
                                @"city": obj.city, //市
                                @"citycode":obj.citycode, //城市编码
                                @"district":obj.district, //区域名称
                                @"adcode":obj.adcode, // 区域编码
                                }];
        
    }];
  }
  return resultList;
}

/// 转换成aoi数据格式
- (NSArray<AMapAOI *> *)aoiFormatData:(NSArray<AMapAOI *> *)data
{
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:data.count];
    if (data.count > 0)
    {
        [data enumerateObjectsUsingBlock:^(AMapAOI *obj, NSUInteger idx, BOOL *stop) {
          [resultList addObject:@{
            @"uid": obj.uid, // uid
            @"name": obj.name, // 名称
            @"adcode": obj.adcode, // 所在区域编码
            @"location": [self geoPointFormatData:obj.location], // 中心点经纬度
            @"area": @(obj.area) // 面积，单位平方米
          }];
        }];
      }
    return resultList;
}


///商圈列表 AMapBusinessArea 数组转换
- (NSArray<AMapBusinessArea *> *)businessFormatData:(NSArray<AMapBusinessArea *> *)data
{
    NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:data.count];
    if(data.count > 0){
      [data enumerateObjectsUsingBlock:^(AMapBusinessArea *obj, NSUInteger idx, BOOL *stop){
        [resultList addObject:@{
          @"name": obj.name,
          @"location": [self geoPointFormatData:obj.location]
        }];
      }];
    }
  
    return resultList;
}

///道路信息 AMapRoad 数组
- (NSArray<AMapRoad *> *)roadsFormatData:(NSArray<AMapRoad *> *)data
{
  NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:data.count];
  if(data.count > 0){
    [data enumerateObjectsUsingBlock:^(AMapRoad *obj, NSUInteger idx, BOOL *stop){
      [resultList addObject:@{
        @"uid": obj.uid,
        @"name": obj.name,
        @"distance": @(obj.distance),
        @"direction": obj.direction,
        @"location": @{
          @"latitude": @(obj.location.latitude),
          @"longitude": @(obj.location.longitude)
        },
  
      }];
    }];
  }

  return resultList;
}

///道路路口信息 AMapRoadInter 数组
- (NSArray<AMapRoadInter *> *)roadsInterFormatData:(NSArray<AMapRoadInter *> *)data
{
  NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:data.count];
  if(data.count > 0){
    [data enumerateObjectsUsingBlock:^(AMapRoadInter *obj, NSUInteger idx, BOOL *stop){
      [resultList addObject:@{
        ///距离（单位：米）
        @"distance": @(obj.distance),
        ///方向
        @"direction": obj.direction,
        ///经纬度
        @"location": [self geoPointFormatData: obj.location],
        ///第一条道路ID
        @"firstId": obj.firstId,
        ///第一条道路名称
        @"firstName": obj.firstName,
        ///第二条道路ID
        @"secondId": obj.secondId,
        ///第二条道路名称
        @"secondName": obj.secondName
      }];
    }];
  }

  return resultList;
}



// poi搜索回调数据转换
- (NSArray<AMapPOI *> *)poiSearchResponseFormatData:(AMapPOISearchResponse *)response
{
    return  [self poiFormatData: response.pois];
}

@end
