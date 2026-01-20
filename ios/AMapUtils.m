//
//  AMapUtils.m
//  pecportal
//
//  Created by 刘利军 on 2023/7/18.
//

#import <Foundation/Foundation.h>

#import "AMapUtils.h"

@implementation AMapUtils

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
  NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:0];
  if(data.count>0){
    resultList = [NSMutableArray arrayWithCapacity: data.count];
    [data enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        // 构建商圈对象
        NSMutableDictionary *business = [NSMutableDictionary dictionary];
        // 优先使用 businessData 对象（Since 9.4.0）
        if (obj.businessData && obj.businessData.businessArea) {
          business[@"businessArea"] = obj.businessData.businessArea;
          // iOS POI 对象中商圈可能没有中心点坐标，设置为 POI 位置
          if (obj.location) {
            business[@"location"] = [self geoPointFormatData:obj.location];
          }
        } else if ([obj.businessArea isKindOfClass:[NSString class]] && obj.businessArea.length > 0) {
          // 兜底使用旧版 businessArea 属性
          business[@"businessArea"] = obj.businessArea;
          if (obj.location) {
            business[@"location"] = [self geoPointFormatData:obj.location];
          }
        }

        // 构建扩展信息对象
        NSMutableDictionary *poiExtension = [NSMutableDictionary dictionary];

        // 优先使用 businessData 对象（Since 9.4.0，与Android Business对应）
        if (obj.businessData) {
          if ([obj.businessData.opentimeWeek isKindOfClass:[NSString class]] && obj.businessData.opentimeWeek.length > 0) {
            poiExtension[@"openTime"] = obj.businessData.opentimeWeek;
          }
          if ([obj.businessData.opentimeToday isKindOfClass:[NSString class]] && obj.businessData.opentimeToday.length > 0) {
            poiExtension[@"openTimeToday"] = obj.businessData.opentimeToday;
          }
          if ([obj.businessData.rating isKindOfClass:[NSString class]] && obj.businessData.rating.length > 0) {
            poiExtension[@"rating"] = obj.businessData.rating;
          }
          if ([obj.businessData.cost isKindOfClass:[NSString class]] && obj.businessData.cost.length > 0) {
            poiExtension[@"cost"] = obj.businessData.cost;
          }
        }

        // 兜底：使用 extensionInfo 对象（ID查询时有效）
        if (obj.extensionInfo) {
          if (poiExtension[@"openTime"] == nil &&
              [obj.extensionInfo.openTime isKindOfClass:[NSString class]] && obj.extensionInfo.openTime.length > 0) {
            poiExtension[@"openTime"] = obj.extensionInfo.openTime;
          }
          if (poiExtension[@"rating"] == nil &&
              [obj.extensionInfo.rating isKindOfClass:[NSString class]] && obj.extensionInfo.rating.length > 0) {
            poiExtension[@"rating"] = obj.extensionInfo.rating;
          }
          if (poiExtension[@"cost"] == nil &&
              [obj.extensionInfo.cost isKindOfClass:[NSString class]] && obj.extensionInfo.cost.length > 0) {
            poiExtension[@"cost"] = obj.extensionInfo.cost;
          }
        }

        // 再兜底：使用直接属性（旧版）
        if (poiExtension[@"openTime"] == nil &&
            [obj.opentime isKindOfClass:[NSString class]] && obj.opentime.length > 0) {
          poiExtension[@"openTime"] = obj.opentime;
        }
        if (poiExtension[@"rating"] == nil &&
            [obj.rating isKindOfClass:[NSString class]] && obj.rating.length > 0) {
          poiExtension[@"rating"] = obj.rating;
        }

        // 处理照片列表
        if (obj.images && obj.images.count > 0) {
          NSMutableArray *photos = [NSMutableArray arrayWithCapacity:obj.images.count];
          [obj.images enumerateObjectsUsingBlock:^(AMapImage *image, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *photo = [NSMutableDictionary dictionary];
            if (image.title) {
              photo[@"title"] = image.title;
            }
            if (image.url) {
              photo[@"url"] = image.url;
            }
            [photos addObject:photo];
          }];
          poiExtension[@"photos"] = photos;
        }

        // 构建POI数据对象
        NSMutableDictionary *poiData = [@{
          @"uid": obj.uid, // uid
          @"name": obj.name, // 名称
          @"type": obj.type, // 兴趣点类型
          @"typeCode": obj.typecode, // 类型编码
          @"latLonPoint": [self geoPointFormatData:obj.location],
          @"address": obj.address, // 地址
          @"shopID": obj.shopID, // 商铺id
          @"email": obj.email, // 电子邮件
          @"province": obj.province, // 省
          @"provinceCode": obj.pcode, // 省编码
          @"city": obj.city, // 市
          @"cityCode": obj.citycode, // 城市编码
          @"district": obj.district, // 区域名称
          @"adCode": obj.adcode, // 区域编码
          @"business": business.count > 0 ? business : @{}, // 商圈对象，空字典而不是 null
          @"poiExtension": poiExtension.count > 0 ? poiExtension : @{} // 扩展信息对象，空字典而不是 null
        } mutableCopy];

        // 获取扩展字段 - 与Android保持一致的数据结构
        // 优先使用 businessData 对象（Since 9.4.0，与Android Business对应）
        if (obj.businessData) {
          if ([obj.businessData.tel isKindOfClass:[NSString class]] && obj.businessData.tel.length > 0) {
            poiData[@"tel"] = obj.businessData.tel;
          }
          if ([obj.businessData.tag isKindOfClass:[NSString class]] && obj.businessData.tag.length > 0) {
            poiData[@"tag"] = obj.businessData.tag;
          }
          if ([obj.businessData.parkingType isKindOfClass:[NSString class]] && obj.businessData.parkingType.length > 0) {
            poiData[@"parkingType"] = obj.businessData.parkingType;
          }
          if ([obj.businessData.alias isKindOfClass:[NSString class]] && obj.businessData.alias.length > 0) {
            poiData[@"alias"] = obj.businessData.alias;
          }
        } else {
          // 兜底：使用 POI 直接属性（旧版）
          if ([obj.tel isKindOfClass:[NSString class]] && obj.tel.length > 0) {
            poiData[@"tel"] = obj.tel;
          }
          if ([obj.parkingType isKindOfClass:[NSString class]] && obj.parkingType.length > 0) {
            poiData[@"parkingType"] = obj.parkingType;
          }
        }

        [resultList addObject:poiData];

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
            @"adCode": obj.adcode, // 所在区域编码
            @"latLonPoint": [self geoPointFormatData:obj.location], // 中心点经纬度
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
          @"latLonPoint": [self geoPointFormatData:obj.location]
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
        @"latLonPoint":  [self geoPointFormatData: obj.location]
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
        @"latLonPoint": [self geoPointFormatData: obj.location],
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


// 逆地址编码数据转换
- (NSDictionary *)regeocodeFormatData:(AMapReGeocodeSearchResponse *)response
{
    NSMutableDictionary *streetNumber = [NSMutableDictionary dictionary];
    if([response.regeocode.addressComponent.streetNumber.street isKindOfClass:[NSString class]]){
      NSDictionary *streetNumberData = @{
        @"street": response.regeocode.addressComponent.streetNumber.street,
        @"number": response.regeocode.addressComponent.streetNumber.number,
        @"latLonPoint": [self geoPointFormatData: response.regeocode.addressComponent.streetNumber.location],
        @"distance": @(response.regeocode.addressComponent.streetNumber.distance),
        @"direction": response.regeocode.addressComponent.streetNumber.direction,
      };
      [streetNumber setDictionary:streetNumberData];
    }
    
    NSDictionary *data = @{
        @"address": response.regeocode.formattedAddress,
        @"adCode": response.regeocode.addressComponent.adcode,
        @"cityCode": response.regeocode.addressComponent.citycode,
        @"city": response.regeocode.addressComponent.city,
        @"province": response.regeocode.addressComponent.province,
        @"district": response.regeocode.addressComponent.district,
        @"country": response.regeocode.addressComponent.country,
        @"countryCode": response.regeocode.addressComponent.countryCode,
        @"building": response.regeocode.addressComponent.building,
        @"neighborhood": response.regeocode.addressComponent.neighborhood,
        @"townShip": response.regeocode.addressComponent.township,
        @"townCode": response.regeocode.addressComponent.towncode,
        @"streetNumber": streetNumber,
        @"businessAreas":  [[AMapUtils alloc] businessFormatData:response.regeocode.addressComponent.businessAreas],
        @"roads": [[AMapUtils alloc] roadsFormatData:response.regeocode.roads],
        @"roadInters":  [[AMapUtils alloc] roadsInterFormatData:response.regeocode.roadinters],
        @"pois": [[AMapUtils alloc] poiFormatData:response.regeocode.pois],
        @"aois": [[AMapUtils alloc] aoiFormatData:response.regeocode.aois],
    };
    return  data;
}

// 地理编码数据转换
- (NSArray<AMapPOI *> *)geocodeFormatData:(AMapGeocodeSearchResponse *)response
{
  NSMutableArray *resultList = [NSMutableArray arrayWithCapacity:response.geocodes.count];
  if (response.geocodes.count > 0)
  {
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop){
      [resultList addObject:@{
        ///格式化地址
        @"formatAddress": obj.formattedAddress,
        ///省份
        @"province": obj.province,
        ///城市名称
        @"city": obj.city,
        ///区域名称
        @"district": obj.district,
        ///区域编码
        @"adCode": obj.adcode,
        ///乡镇街道
        @"township": obj.township,
        ///社区
        @"neighborhood": obj.neighborhood,
        ///楼
        @"building": obj.building,
        /// 坐标
        @"latLonPoint": [self geoPointFormatData:obj.location], // 中心点经纬度
        ///匹配的等级
        @"level": obj.level,
        ///国家-仅海外生效
        @"country": obj.country,
        ///国家简码-仅海外生效
        @"postCode": obj.postcode,
      }];
    }];
  }
  return  resultList;
}


// 行政区划数据转换
- (NSArray<AMapDistrict *> *)districtFormatData:(NSArray<AMapDistrict *> *)districts
{
  NSMutableArray *resultList = [NSMutableArray arrayWithCapacity: 0];
  if (districts.count > 0)
  {
    resultList = [NSMutableArray arrayWithCapacity: districts.count];
    [districts enumerateObjectsUsingBlock:^(AMapDistrict *obj, NSUInteger idx, BOOL *stop){
      [resultList addObject:@{
        ///区域编码
        @"adCode": obj.adcode,
        ///城市编码
        @"cityCode": obj.citycode,
        ///行政区名称
        @"name": obj.name,
        ///级别
        @"level": obj.level,
        ///城市中心点
        @"center": [self geoPointFormatData:obj.center],
        ///下级行政区域数组
        @"districts": [self districtFormatData: obj.districts],
        ///行政区边界坐标点, NSString 数组
        @"polylines": obj.polylines ? obj.polylines : @[]
      }];
    }];
  }
  return  resultList;
}



@end
