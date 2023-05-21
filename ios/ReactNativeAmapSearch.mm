#import "ReactNativeAmapSearch.h"

#import <React/RCTLog.h>
#import <React/RCTConvert.h>

#import <AMapFoundationKit/AMapFoundationKit.h>

#import "Utils.h"


@implementation ReactNativeAmapSearch{
  AMapSearchAPI *search;
  RCTPromiseResolveBlock jsResolve;
  RCTPromiseRejectBlock jsReject;
}

RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios

RCT_EXPORT_METHOD(initSDK:(NSString *)apikey)
{
  [AMapServices sharedServices].apiKey = apikey;
  [AMapSearchAPI updatePrivacyShow:AMapPrivacyShowStatusDidShow privacyInfo:AMapPrivacyInfoStatusDidContain];
  [AMapSearchAPI updatePrivacyAgree:AMapPrivacyAgreeStatusDidAgree];
  self->search = [[AMapSearchAPI alloc] init];
  self->search.delegate = self;
};

//poi搜索
RCT_EXPORT_METHOD(aMapPOIKeywordsSearch:(NSString *)keywords
                  city:(NSString *)city
                  types:(NSString *)types
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

  RCTLogInfo(@"RNLog aMapPOIKeywordsSearch -------- start");

  AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
      
  request.keywords            = keywords;
  request.city                = city;
  request.types               = types;
//  request.requireExtension    = YES;
      
  /*  搜索SDK 3.2.0 中新增加的功能，只搜索本城市的POI。*/
  request.cityLimit           = YES;
//  request.requireSubPOIs      = YES;

  self->jsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapPOIKeywordsSearch:request];
};

// 地址编码
RCT_EXPORT_METHOD(AMapGeocodeSearch:(NSString *)address
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

  RCTLogInfo(@"RNLog AMapGeocodeSearch -------- start");

  AMapGeocodeSearchRequest *request = [[AMapGeocodeSearchRequest alloc] init];
  request.address = address;
      

  self->jsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapGeocodeSearch:request];
};

// 逆地址编码
RCT_EXPORT_METHOD(AMapReGeocodeSearch:(NSDictionary *)coordinate
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{

  RCTLogInfo(@"RNLog AMapReGeocodeSearch -------- start");
  AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];

  CGFloat latitude = [RCTConvert CGFloat:coordinate[@"latitude"]];
  CGFloat longitude = [RCTConvert CGFloat:coordinate[@"longitude"]];
  regeo.location                    = [AMapGeoPoint locationWithLatitude:latitude  longitude:longitude];
  regeo.requireExtension            = YES;
        

  self->jsResolve = resolve;
  self->jsReject = reject;
  [self->search AMapReGoecodeSearch:regeo];
};

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
  RCTLogInfo(@"RNLog onPOISearchDone");
//  NSMutableArray *resultList = [self->aMapUtil poiSearchResponseFormatData:response];
//    if(!self->jsResolve){
//        return;
//    }
//    self->jsResolve(resultList);
//    self->jsResolve= nil;
}

// 地址编码回调
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(!self->jsResolve){
        return;
    }
    self->jsResolve(response);
    self->jsResolve= nil;
}

// 逆地址编码回调
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if(!self->jsResolve){
        return;
    }
 
    NSDictionary *data = @{
        @"formattedAddress": response.regeocode.formattedAddress,
        @"addressComponent": @{
          @"country": response.regeocode.addressComponent.country,
          @"countryCode": response.regeocode.addressComponent.countryCode,
          @"province": response.regeocode.addressComponent.province,
          @"city": response.regeocode.addressComponent.city,
          @"citycode": response.regeocode.addressComponent.citycode,
          @"district": response.regeocode.addressComponent.district,
          @"adcode": response.regeocode.addressComponent.adcode,
          @"township": response.regeocode.addressComponent.township,
          @"towncode": response.regeocode.addressComponent.towncode,
          @"neighborhood": response.regeocode.addressComponent.neighborhood,
          @"building": response.regeocode.addressComponent.building,
          @"streetNumber": @{
            @"street": response.regeocode.addressComponent.streetNumber.street,
            @"number": response.regeocode.addressComponent.streetNumber.number,
            @"location": response.regeocode.addressComponent.streetNumber.location,
            @"distance": @(response.regeocode.addressComponent.streetNumber.distance),
            @"direction": response.regeocode.addressComponent.streetNumber.direction,
          },
          @"businessAreas":  [[Utils alloc] businessFormatData:response.regeocode.addressComponent.businessAreas]
        },
        @"roads": [[Utils alloc] roadsFormatData:response.regeocode.roads],
        @"roadinters":  [[Utils alloc] roadsInterFormatData:response.regeocode.roadinters],
        @"pois": [[Utils alloc] poiFormatData:response.regeocode.pois],
        @"aois": [[Utils alloc] aoiFormatData:response.regeocode.aois],
    };

  self->jsResolve(@{ @"regeocode": data });

  self->jsResolve= nil;
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    RCTLogInfo(@"RNLog didFailWithError");
    self->jsReject(@"amapSearch_failure", @"search request error", error);
    self->jsReject= nil;
}

// Don't compile this code when we build for the old architecture.
#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeReactNativeAmapSearchSpecJSI>(params);
}
#endif

@end
