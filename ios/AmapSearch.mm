//
//  AmapSearch.m
//  pecportal
//
//  Created by 刘利军 on 2023/7/18.
//

#import "AmapSearch.h"

#import <React/RCTLog.h>
#import <React/RCTConvert.h>

#import <AMapFoundationKit/AMapFoundationKit.h>

#import "AMapUtils.h"


@implementation AmapSearch{
  AMapSearchAPI *search;
  RCTPromiseResolveBlock districtJsResolve;
  RCTPromiseResolveBlock poiJsResolve;
  RCTPromiseResolveBlock GeocodeJsResolve;
  RCTPromiseRejectBlock jsReject;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initSDK:(NSString *)key
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
   dispatch_async(dispatch_get_main_queue(), ^{
    [AMapServices sharedServices].apiKey = key;
    [AMapSearchAPI updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
    [AMapSearchAPI updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
    if (!(self->search)) {
      self->search = [[AMapSearchAPI alloc] init];
      self->search.delegate = self;
    }
    resolve(nil);
  });

};

// 获取行政区划数据
RCT_EXPORT_METHOD(aMapDistrictSearch:(NSString *)keywords
                  currentPage:(NSInteger)currentPage
                  pageSize:(NSInteger)pageSize
                  subdistrict:(NSInteger)subdistrict
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  AMapDistrictSearchRequest *request = [[AMapDistrictSearchRequest alloc] init];

  request.keywords            = keywords;
  // request.requireExtension    = YES;
  request.page                = currentPage;
  request.offset              = pageSize;
  request.subdistrict         = subdistrict;
  self->districtJsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapDistrictSearch:request];
};



// 根据关键字检索POI
RCT_EXPORT_METHOD(aMapPOIKeywordsSearch:(NSString *)keywords
                  types:(NSString *)types
                  city:(NSString *)city
                  currentPage:(NSInteger)currentPage
                  pageSize:(NSInteger)pageSize
                  cityLimit:(BOOL *)cityLimit
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
      
  request.keywords            = keywords;
  request.city                = city;
  request.types               = types;
  // request.requireExtension    = YES;
      
  //    搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。
  request.cityLimit           = cityLimit ? YES : NO;
  // request.requireSubPOIs      = YES;

  //   设置分页页数
  request.page = currentPage;
  //   设置分页
  request.offset = pageSize;

  self->poiJsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapPOIKeywordsSearch:request];
};

// 检索周边POI
RCT_EXPORT_METHOD(aMapPOIAroundSearch:(NSString *)keywords
                  types:(NSString *)types
                  city:(NSString *)city
                  latitude:(nonnull NSNumber *)latitude
                  longitude:(nonnull NSNumber *)longitude
                  currentPage:(NSInteger)currentPage
                  pageSize:(NSInteger)pageSize
                  radius:(NSInteger)radius
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
      
  request.keywords            = keywords;
  request.city                = city;
  request.radius              = radius;
  request.types               = types;
  // request.requireExtension    = YES;
  request.location            = [AMapGeoPoint locationWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
      
  /* 按照距离排序. */
  request.sortrule            = 0;
  /* 设置分页页数 */
  request.page = currentPage;
  /* 设置分页 */
  request.offset = pageSize;

  self->poiJsResolve = resolve;
  self->jsReject = reject;
  
  [self->search AMapPOIAroundSearch:request];
};

// 检索多边形POI
RCT_EXPORT_METHOD(aMapPOIPolygonSearch:(NSString *)keywords
                  types:(NSString *)types
                  city:(NSString *)city
                  points:(NSArray *)points
                  currentPage:(NSInteger)currentPage
                  pageSize:(NSInteger)pageSize
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSMutableArray<AMapGeoPoint *> *polygonPoints= [[NSMutableArray alloc] init];
   if(points != nil && [points count] >= 2) {
       for (NSInteger i = 0; i < [points count]; i++) {
           NSDictionary* dict = [points objectAtIndex:i];
           CGFloat latitude = [[dict objectForKey:@"latitude"] floatValue];
           CGFloat longitude = [[dict objectForKey:@"longitude"] floatValue];
           [polygonPoints addObject:[AMapGeoPoint locationWithLatitude:latitude longitude:longitude]];
       }
   }
  
  AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:polygonPoints];
  AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];
      
  request.keywords            = keywords;
  request.polygon             = polygon;
  request.types               = types;
//  request.requireExtension    = YES;
  
  /* 按照距离排序. */
  request.sortrule            = 0;
  /* 设置分页页数 */
  request.page = currentPage;
  /* 设置分页 */
  request.offset = pageSize;

  self->poiJsResolve = resolve;
  self->jsReject = reject;
  
  [self->search AMapPOIPolygonSearch:request];
};

// 根据ID检索
RCT_EXPORT_METHOD(aMapPOIIDSearch:(NSString *)uid
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
 

  AMapPOIIDSearchRequest *request = [[AMapPOIIDSearchRequest alloc] init];
      
  request.uid            = uid;
  // request.requireExtension    = YES;
  self->poiJsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapPOIIDSearch:request];
};

// 输入内容自动提示
RCT_EXPORT_METHOD(aMapPOIInputTipsSearch:(NSString *)keywords
                  city:(NSString *)city
                  type:(NSString *)type
                  latitude:(NSNumber *)latitude
                  longitude:(NSNumber *)longitude
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  AMapInputTipsSearchRequest *request = [[AMapInputTipsSearchRequest alloc] init];
      
  request.keywords              = keywords;
  request.city                  = city;
  request.types                 = type;
 
  if(latitude !=0 &&longitude != 0){
//    request.location              =[NSString initwi]
  }
  request.cityLimit             = YES;
  self->poiJsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapInputTipsSearch:request];
};

// 地址编码
RCT_EXPORT_METHOD(AMapGeocodeSearch:(NSString *)address
                  city:(NSString*)city
                  country:(NSString*)country
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  RCTLogInfo(@"RNLog AMapGeocodeSearch -------- start");

  AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc] init];
  request.address = address;
  request.city = city;
  request.country = country;

  self->GeocodeJsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapGeocodeSearch:request];
};

// 逆地址编码
RCT_EXPORT_METHOD(AMapReGeocodeSearch:(nonnull NSNumber *)latitude
                  longitude:(nonnull NSNumber *)longitude
                  radius:(NSInteger)radius
                  type:(NSString*)type
                  extensions:(NSString *)extensions
                  poiType:(NSString *)poiType
                  mode:(NSString *)mode
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

  RCTLogInfo(@"RNLog AMapReGeocodeSearch -------- start");
  AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
  regeo.poitype = poiType;
  regeo.mode = mode;
  regeo.radius = radius;
  regeo.location                    = [AMapGeoPoint locationWithLatitude:[latitude doubleValue]  longitude:[longitude doubleValue]];
  regeo.requireExtension            = [extensions isEqualToString: @"all" ] ? YES:NO;

  self->GeocodeJsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapReGoecodeSearch:regeo];
};

// poi搜索回调
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    RCTLogInfo(@"RNLog onPOISearchDone %d", (int)response.count);
    if(!self->poiJsResolve){
        return;
    }
    NSArray *resultList = [[AMapUtils alloc] poiSearchResponseFormatData:response];
    self->poiJsResolve(@{ @"count": @(response.count), @"list": resultList});
    self->poiJsResolve= nil;
}

// 地址编码回调
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(!self->GeocodeJsResolve){
        return;
    }
    NSArray *data = [[AMapUtils alloc] geocodeFormatData:response];
    self->GeocodeJsResolve(data);
    self->GeocodeJsResolve= nil;
}

// 逆地址编码回调
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
  if(!self->GeocodeJsResolve){
      return;
  }
  NSDictionary *data = [[AMapUtils alloc] regeocodeFormatData:response];
  self->GeocodeJsResolve(data);
  self->GeocodeJsResolve= nil;
}

// 行政区划回调
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    
    if(!self->districtJsResolve){
        return;
    }
  
    if (response == nil)
    {
        districtJsResolve(response);
        return;
    }
  
  //解析response获取行政区划，具体解析见 Demo
  self->districtJsResolve(@{@"count": @(response.count), @"districts": [[AMapUtils alloc] districtFormatData:response.districts]});
  self->districtJsResolve= nil;
}

// 失败回调
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    RCTLogInfo(@"RNLog didFailWithError");
    self->jsReject(@"amapSearch_failure", @"search request error", error);
    self->jsReject= nil;
}

@end

