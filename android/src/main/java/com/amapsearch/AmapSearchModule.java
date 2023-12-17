package com.amapsearch;

import androidx.annotation.NonNull;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.geocoder.AoiItem;
import com.amap.api.services.geocoder.BusinessArea;
import com.amap.api.services.geocoder.RegeocodeRoad;
import com.amap.api.services.geocoder.StreetNumber;
import com.amap.api.services.road.Crossroad;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.module.annotations.ReactModule;


import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// 高德

import com.amap.api.services.core.AMapException;
import com.amap.api.services.core.PoiItemV2;
import com.amap.api.services.core.ServiceSettings;


import com.amap.api.services.poisearch.PoiResultV2;
import com.amap.api.services.poisearch.PoiSearchV2;
import com.amap.api.services.poisearch.PoiSearchV2.OnPoiSearchListener;
import com.amap.api.services.poisearch.PoiSearchV2.SearchBound;

import com.amap.api.services.geocoder.GeocodeAddress;
import com.amap.api.services.geocoder.GeocodeQuery;
import com.amap.api.services.geocoder.GeocodeResult;
import com.amap.api.services.geocoder.GeocodeSearch;
import com.amap.api.services.geocoder.GeocodeSearch.OnGeocodeSearchListener;
import com.amap.api.services.geocoder.RegeocodeQuery;
import com.amap.api.services.geocoder.RegeocodeResult;
import com.amap.api.services.core.LatLonPoint;

import com.amap.api.services.help.Inputtips;
import com.amap.api.services.help.Inputtips.InputtipsListener;
import com.amap.api.services.help.InputtipsQuery;
import com.amap.api.services.help.Tip;

import com.amap.api.services.routepoisearch.RoutePOIItem;
import com.amap.api.services.routepoisearch.RoutePOISearch;
import com.amap.api.services.routepoisearch.RoutePOISearch.OnRoutePOISearchListener;
import com.amap.api.services.routepoisearch.RoutePOISearchQuery;
import com.amap.api.services.routepoisearch.RoutePOISearchResult;

import com.amap.api.services.district.DistrictItem;
import com.amap.api.services.district.DistrictResult;
import com.amap.api.services.district.DistrictSearch;
import com.amap.api.services.district.DistrictSearch.OnDistrictSearchListener;
import com.amap.api.services.district.DistrictSearchQuery;


@ReactModule(name = AmapSearchModule.NAME)
public class AmapSearchModule extends ReactContextBaseJavaModule implements OnPoiSearchListener, OnGeocodeSearchListener, OnRoutePOISearchListener, InputtipsListener, OnDistrictSearchListener {
  public static final String NAME = "AmapSearch";

  private static ReactApplicationContext context;
  private Promise jsPromise;
  private PoiSearchV2.Query query; // Poi查询条件类
  private PoiSearchV2 poiSearch;   // POI搜索
	private GeocodeSearch geocoderSearch;


  public AmapSearchModule(ReactApplicationContext reactContext) {
    super(reactContext);
    context = reactContext;
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void initSDK(String key) {
    ServiceSettings.getInstance().setApiKey(key);
    ServiceSettings.updatePrivacyShow(context, true, true);
    ServiceSettings.updatePrivacyAgree(context, true);
  }

  //  经纬度数据转换
  public WritableMap formatDataLatLonPoint(LatLonPoint latlonPoint) {
    WritableMap item = Arguments.createMap();
    item.putDouble("latitude", latlonPoint.getLatitude());
    item.putDouble("longitude",latlonPoint.getLongitude());
    return  item;
  }

  // POI V2类型数据转换
  public WritableMap formatDataPoiV2(PoiItemV2 poiItem) {
      WritableMap item = Arguments.createMap();
      item.putString("uid", poiItem.getPoiId());         // id
      item.putString("name", poiItem.getTitle());        // 名称
      item.putString("type", poiItem.getTypeDes());      // 兴趣点类型
      item.putString("typeCode", poiItem.getTypeCode()); // 类型编码
      item.putMap("latLonPoint", formatDataLatLonPoint(poiItem.getLatLonPoint())); // 经纬度
      item.putString("address", poiItem.getSnippet());         // 地址
      item.putString("province", poiItem.getProvinceName());   // 省
      item.putString("provinceCode", poiItem.getProvinceCode());      // 省编码
      item.putString("city", poiItem.getCityName());           // 市
      item.putString("cityCode", poiItem.getCityCode());       // 城市编码
      item.putString("district", poiItem.getAdName());         // 区域名称
      item.putString("adCode", poiItem.getAdCode());           // 区域编码
      item.putString("businessArea", poiItem.getBusiness().getBusinessArea());  // 获取商圈名称

      return item;
  }

  // POIS V2类型数据转换
  public WritableArray formatDataPoisV2(ArrayList<PoiItemV2> poiItems) {
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < poiItems.size(); i++) {
      array.pushMap(formatDataPoiV2(poiItems.get(i)));
    }
    return array;
  }

  // 商圈列表数据转换
  public WritableArray formatDataBusiness(List<BusinessArea> businessArea) {
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < businessArea.size(); i++) {
      WritableMap item = Arguments.createMap();
      item.putString("name", businessArea.get(i).getName());
      item.putMap("latLonPoint", formatDataLatLonPoint(businessArea.get(i).getCenterPoint()));
      array.pushMap(item);
    }
    return array;
  }

  // 道路信息数据转换
  public WritableArray formatDataRoads(List<RegeocodeRoad> roads) {
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < roads.size(); i++) {
      WritableMap item = Arguments.createMap();
      item.putDouble("distance", roads.get(i).getDistance());
      item.putString("direction", roads.get(i).getDirection());
      item.putString("name", roads.get(i).getName());
      item.putString("uid", roads.get(i).getId());
      item.putMap("latLonPoint", formatDataLatLonPoint(roads.get(i).getLatLngPoint()));
      array.pushMap(item);
    }
    return array;
  }

  // 道路信息路口数据转换
  public WritableArray formatDataRoadInters(List<Crossroad> roads) {
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < roads.size(); i++) {
      WritableMap item = Arguments.createMap();
      item.putDouble("distance", roads.get(i).getDistance());
      item.putString("direction", roads.get(i).getDirection());
      item.putString("firstName", roads.get(i).getFirstRoadName());
      item.putString("firstId", roads.get(i).getFirstRoadId());
      item.putString("secondName", roads.get(i).getSecondRoadName());
      item.putString("secondId", roads.get(i).getSecondRoadId());
      item.putMap("latLonPoint", formatDataLatLonPoint(roads.get(i).getCenterPoint()));
      array.pushMap(item);
    }
    return array;
  }

  // 逆地理编码poi格式转换，不能使用PoiItemV2
  public WritableArray formatDataPoi(List<PoiItem> poiItems) {
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < poiItems.size(); i++) {
      WritableMap item = Arguments.createMap();
      PoiItem poiItem = poiItems.get(i);
      item.putString("uid", poiItem.getPoiId());         // id
      item.putString("name", poiItem.getTitle());        // 名称
      item.putString("type", poiItem.getTypeDes());      // 兴趣点类型
      item.putString("typeCode", poiItem.getTypeCode()); // 类型编码
      item.putString("address", poiItem.getSnippet());         // 地址
      item.putString("province", poiItem.getProvinceName());   // 省
      item.putString("provinceCode", poiItem.getProvinceCode());      // 省编码
      item.putString("city", poiItem.getCityName());           // 市
      item.putString("cityCode", poiItem.getCityCode());       // 城市编码
      item.putString("district", poiItem.getAdName());         // 区域名称
      item.putString("adCode", poiItem.getAdCode());           // 区域编码
      item.putString("email", poiItem.getEmail());           // 邮箱
      item.putInt("distance", poiItem.getDistance());           // POI 距离中心点的距离
      item.putMap("latLonPoint", formatDataLatLonPoint(poiItem.getLatLonPoint())); // 经纬度
      array.pushMap(item);
    }
    return array;
  }

  // AOI类型数据转换
  public WritableArray formatDataAoi(List<AoiItem> aoiItems) {
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < aoiItems.size(); i++) {
      WritableMap item = Arguments.createMap();
      AoiItem aoiItem = aoiItems.get(i);
      item.putString("adCode", aoiItem.getAdCode());
      item.putString("name", aoiItem.getAoiName());
      item.putString("uid", aoiItem.getAoiId());
      item.putDouble("area",aoiItem.getAoiArea());
      item.putMap("latLonPoint", formatDataLatLonPoint(aoiItem.getAoiCenterPoint())); // 经纬度
      array.pushMap(item);
    }
    return array;
  }

  // 门牌信息数据转换
  public WritableMap formatDataStreetNumber(StreetNumber streetNumber) {
    WritableMap item= Arguments.createMap();
    item.putString("number", streetNumber.getNumber());
    item.putString("street", streetNumber.getStreet());
    item.putString("direction", streetNumber.getDirection());
    item.putDouble("distance", streetNumber.getDistance());
    item.putMap("latLonPoint", formatDataLatLonPoint(streetNumber.getLatLonPoint())); // 经纬度
    return item;
  }

  // 获取POI数据-文字搜索
  @ReactMethod
  public void aMapPOIKeywordsSearch(String keyword, String types, String city,
                                    Integer currentPage, Integer pageSize,
                                    Boolean cityLimit,
                                    Promise promise) {

    this.jsPromise = promise;
    query = new PoiSearchV2.Query(keyword, types, city);
    // keyWord表示搜索字符串，
    // 第二个参数表示POI搜索类型，二者选填其一，选用POI搜索类型时建议填写类型代码，码表可以参考下方（而非文字）
    // cityCode表示POI搜索区域，可以是城市编码也可以是城市名称，也可以传空字符串，空字符串代表全国在全国范围内进行搜索
    query.setPageSize(pageSize);   // 设置每页最多返回多少条
    query.setPageNum(currentPage); // 设置查询页码
    query.setCityLimit(cityLimit);  // 仅在通过关键字搜索时进行限制严格按照设置城市搜索
    try {
      poiSearch = new PoiSearchV2(context, query);
      poiSearch.setOnPoiSearchListener(this);
      poiSearch.searchPOIAsyn(); // 异步搜索
    } catch (AMapException e) {
      e.printStackTrace();
    }
  }

  // 获取POI数据-周边搜索
  @ReactMethod
  public void aMapPOIAroundSearch(String keyword, String types, String city,
                                  double latitude, double longitude,
                                    Integer currentPage,
                                    Integer pageSize,
                                    Integer radius,
                                    Promise promise) {
    this.jsPromise = promise;
    query = new PoiSearchV2.Query(keyword, types, city);
    query.setPageSize(pageSize);   // 设置每页最多返回多少条
    query.setPageNum(currentPage); // 设置查询页码
    try {
      poiSearch = new PoiSearchV2(context, query);
      poiSearch.setOnPoiSearchListener(this);
      //设置周边搜索的中心点以及半径
      poiSearch.setBound(new SearchBound(new LatLonPoint(latitude,longitude), radius, true));
      poiSearch.searchPOIAsyn();// 异步搜索
    } catch (AMapException e) {
      e.printStackTrace();
    }

  }

  // 获取POI数据-多边型搜索
  @ReactMethod
  public void aMapPOIPolygonSearch(String keyword, String types, String city,
                                   ReadableArray points,
                                   Integer currentPage,
                                    Integer pageSize,
                                    Promise promise) {

    this.jsPromise = promise;
    query = new PoiSearchV2.Query(keyword, types, city);
    query.setPageSize(pageSize);   // 设置每页最多返回多少条
    query.setPageNum(currentPage); // 设置查询页码

    List<LatLonPoint> polygonPoints = new ArrayList<LatLonPoint>();
    for(int i = 0; i < points.size(); i++ ){
      ReadableMap map = points.getMap(i);
      polygonPoints.add(new LatLonPoint(map.getDouble("latitude"), map.getDouble("longitude")));
    }

    try {
      poiSearch = new PoiSearchV2(context, query);
      poiSearch.setOnPoiSearchListener(this);
      //设置多边形区域
      poiSearch.setBound(new SearchBound(polygonPoints));
      poiSearch.searchPOIAsyn();// 异步搜索
    } catch (AMapException e) {
      e.printStackTrace();
    }

  }

  // 获取POI数据-ID搜索
  @ReactMethod
  public void aMapPOIIDSearch(String id, Promise promise) {
    this.jsPromise = promise;
    try {
      query = new PoiSearchV2.Query("", "");
      poiSearch = new PoiSearchV2(context, query);
      poiSearch.setOnPoiSearchListener(this);
      poiSearch.searchPOIIdAsyn(id);// 异步搜索
    } catch (AMapException e) {
      e.printStackTrace();
    }
  }

  // 获取POI数据-输入内容自动提示
  @ReactMethod
  public void aMapPOIInputTipsSearch(String keyword, String city, String type,
                                     double latitude,
                                     double longitude,
                                     Promise promise) {
    this.jsPromise = promise;
    InputtipsQuery query = new InputtipsQuery(keyword, city);
    query.setCityLimit(true);//限制在当前城市
    query.setType(type);
     if(latitude!=0 && longitude!=0){
       query.setLocation(new LatLonPoint(latitude, longitude));
     }
    Inputtips inputTips = new Inputtips(context, query);
    inputTips.setInputtipsListener(this);
    inputTips.requestInputtipsAsyn();
  }

  // 获取POI数据-道路沿途检索
  @ReactMethod
  public void aMapRoutePOISearch(ReadableMap fromPoint, ReadableMap toPoint,Integer mode,
                                  Integer type,
                                  Integer range,
                                  Promise promise) {
    this.jsPromise = promise;
    LatLonPoint mStartPoint = new LatLonPoint(fromPoint.getDouble("latitude"),fromPoint.getDouble("longitude"));
    LatLonPoint mEndPoint = new LatLonPoint(toPoint.getDouble("latitude"),fromPoint.getDouble("longitude"));
    RoutePOISearch.RoutePOISearchType searchType;
    switch (type){
      case  1:
        searchType = RoutePOISearch.RoutePOISearchType.TypeMaintenanceStation;
        break;
      case 2:
        searchType = RoutePOISearch.RoutePOISearchType.TypeATM;
        break;
      case 3:
        searchType = RoutePOISearch.RoutePOISearchType.TypeToilet;
        break;
      case 4:
        searchType = RoutePOISearch.RoutePOISearchType.TypeFillingStation;
        break;
      case 5:
        searchType = RoutePOISearch.RoutePOISearchType.TypeServiceArea;
        break;
      case 6:
        searchType = RoutePOISearch.RoutePOISearchType.TypeChargeStation;
        break;
      case 7:
        searchType = RoutePOISearch.RoutePOISearchType.TypeFood;
        break;
      case 8:
        searchType = RoutePOISearch.RoutePOISearchType.TypeHotel;
        break;
      default:
        searchType = RoutePOISearch.RoutePOISearchType.TypeGasStation;
        break;
    }
    RoutePOISearchQuery query = new RoutePOISearchQuery(mStartPoint,mEndPoint, mode, searchType, range);
    final RoutePOISearch search;
    try {
      search = new RoutePOISearch(context, query);
      search.setPoiSearchListener(this);
      search.searchRoutePOIAsyn();
    } catch (AMapException e) {
      e.printStackTrace();
    }
  }

  // 区域获取
  @ReactMethod
  public void aMapDistrictSearch(String keyword, Integer currentPage, Integer pageSize, Integer subdistrict,
                                    Promise promise) {
    this.jsPromise = promise;
    try {
      DistrictSearch search = new DistrictSearch(context);
      DistrictSearchQuery query = new DistrictSearchQuery();
      query.setKeywords(keyword);//传入关键字
      query.setShowBoundary(true);//是否返回边界值
      query.setSubDistrict(subdistrict);
      search.setQuery(query);
      search.setOnDistrictSearchListener(this);//绑定监听器
      search.searchDistrictAsyn();//开始搜索
    } catch (AMapException e) {
      e.printStackTrace();
    }
  }
  private WritableArray districtBoundaryFormatData(String[] list){
    WritableArray array = Arguments.createArray();
    for (String x : list) {
      array.pushString(x);
    }
    return array;
  }

  private WritableArray districtFormatData(List<DistrictItem> districts){
    WritableArray array = Arguments.createArray();
    for (int i = 0; i < districts.size(); i++) {
      WritableMap item = Arguments.createMap();
      DistrictItem districtItem = districts.get(i);
      item.putString("adCode", districtItem.getAdcode());
      item.putString("cityCode", districtItem.getCitycode());
      item.putString("level", districtItem.getLevel());
      item.putString("name",districtItem.getName());
      if(districtItem.getSubDistrict() != null){
        item.putArray("districts", districtFormatData(districtItem.getSubDistrict()));
      }else{
        item.putArray("districts", Arguments.createArray());
      }
      item.putMap("latLonPoint", formatDataLatLonPoint(districtItem.getCenter())); // 经纬度
      item.putArray("polylines", districtBoundaryFormatData(districtItem.districtBoundary()));
      array.pushMap(item);
    }
    return array;
  }

  @Override
  public void onDistrictSearched(DistrictResult districtResult) {
  //在回调函数中解析districtResult获取行政区划信息
  //在districtResult.getAMapException().getErrorCode()=1000时调用districtResult.getDistrict()方法
  //获取查询行政区的结果，详细信息可以参考DistrictItem类。
    if (districtResult == null || districtResult.getDistrict()==null) {
        this.jsPromise.reject("onDistrictSearched", "no result");
        return;
    }

     if(districtResult.getAMapException().getErrorCode() == AMapException.CODE_AMAP_SUCCESS) {
       WritableMap item = Arguments.createMap();
       item.putInt("count", districtResult.getPageCount());
       item.putArray("districts", districtFormatData(districtResult.getDistrict()));
       this.jsPromise.resolve(item);
     }else{
       this.jsPromise.reject("onDistrictSearched erroeCode",  String.valueOf(districtResult.getAMapException().getErrorCode()));
     }
  }


  // 逆地理编码
  @ReactMethod
  public void AMapReGeocodeSearch(double latitude, double longitude, Float radius, String type, String extensions,
                                  String poiType,String mode, Promise promise) {
    LatLonPoint latLonPoint = new LatLonPoint(latitude, longitude);
    this.jsPromise = promise;
    try {
      geocoderSearch = new GeocodeSearch(context);
      geocoderSearch.setOnGeocodeSearchListener(this);
      RegeocodeQuery query = new RegeocodeQuery(latLonPoint,radius,type);
      query.setExtensions(extensions);
      query.setMode(mode);
      query.setPoiType(poiType);
      geocoderSearch.getFromLocationAsyn(query);
    } catch (AMapException e) {
      e.printStackTrace();
    }
  }

  // 地理编码
  @ReactMethod
  public void AMapGeocodeSearch(String name, String city, String country, Promise promise) {
    this.jsPromise = promise;
    try {
      geocoderSearch = new GeocodeSearch(context);
      geocoderSearch.setOnGeocodeSearchListener(this);
      GeocodeQuery query = new GeocodeQuery(name, city);
      query.setCountry(country);
      geocoderSearch.getFromLocationNameAsyn(query);
    } catch (AMapException e) {
      e.printStackTrace();
    }

  }

  /**
   * 逆地理编码回调
   */
  @Override
  public void onRegeocodeSearched(RegeocodeResult result, int rCode) {
    final String onReGeoCodeSearchedError = "onReGeoCodeSearched Error：";
    //解析result获取坐标信息
    if (this.jsPromise == null) {
      return;
    }
    if (rCode == AMapException.CODE_AMAP_SUCCESS) {
      if (result != null && result.getRegeocodeAddress() != null) {
        WritableMap reGeoCodeAddress = Arguments.createMap();
        reGeoCodeAddress.putString("address", result.getRegeocodeAddress().getFormatAddress());
        reGeoCodeAddress.putString("adCode", result.getRegeocodeAddress().getAdCode());
        reGeoCodeAddress.putString("cityCode", result.getRegeocodeAddress().getCityCode());
        reGeoCodeAddress.putString("city", result.getRegeocodeAddress().getCity());
        reGeoCodeAddress.putString("province", result.getRegeocodeAddress().getProvince());
        reGeoCodeAddress.putString("district", result.getRegeocodeAddress().getDistrict());
        reGeoCodeAddress.putString("country", result.getRegeocodeAddress().getCountry());
        reGeoCodeAddress.putString("countryCode", result.getRegeocodeAddress().getCountryCode());
        reGeoCodeAddress.putString("building", result.getRegeocodeAddress().getBuilding());
        reGeoCodeAddress.putString("neighborhood", result.getRegeocodeAddress().getNeighborhood());
        reGeoCodeAddress.putString("townCode", result.getRegeocodeAddress().getTowncode());
        reGeoCodeAddress.putString("townShip", result.getRegeocodeAddress().getTownship());
        reGeoCodeAddress.putMap("streetNumber", formatDataStreetNumber(result.getRegeocodeAddress().getStreetNumber()));
        reGeoCodeAddress.putArray("businessAreas", formatDataBusiness(result.getRegeocodeAddress().getBusinessAreas()));
        reGeoCodeAddress.putArray("roadInters", formatDataRoadInters(result.getRegeocodeAddress().getCrossroads()));
        reGeoCodeAddress.putArray("roads", formatDataRoads(result.getRegeocodeAddress().getRoads()));
        reGeoCodeAddress.putArray("pois", formatDataPoi(result.getRegeocodeAddress().getPois()));
        reGeoCodeAddress.putArray("aois", formatDataAoi(result.getRegeocodeAddress().getAois()));
        this.jsPromise.resolve(reGeoCodeAddress);
      } else {
        this.jsPromise.reject(onReGeoCodeSearchedError, "no result");
      }
    } else {
      this.jsPromise.reject(onReGeoCodeSearchedError, "rCode error：" + rCode);
    }
    this.jsPromise = null;
  }

    // 地理编码回调
    @Override
    public void onGeocodeSearched(GeocodeResult result, int rCode) {
        //解析result获取坐标信息
        if (this.jsPromise == null) {
          return;
        }
        if (rCode == AMapException.CODE_AMAP_SUCCESS) {
          if (result != null && result.getGeocodeAddressList() != null) {
            WritableArray array = Arguments.createArray();
            for (int i = 0; i < result.getGeocodeAddressList().size(); i++) {
              WritableMap item = Arguments.createMap();
              GeocodeAddress geocodeAddress = result.getGeocodeAddressList().get(i);
              item.putString("city", geocodeAddress.getCity());
              item.putString("formatAddress", geocodeAddress.getFormatAddress());
              item.putString("building", geocodeAddress.getBuilding());
              item.putString("country",geocodeAddress.getCountry());
              item.putString("district",geocodeAddress.getDistrict());
              item.putString("adCode",geocodeAddress.getAdcode());
              item.putString("level",geocodeAddress.getLevel());
              item.putString("neighborhood",geocodeAddress.getNeighborhood());
              item.putString("township",geocodeAddress.getTownship());
              item.putString("postCode",geocodeAddress.getPostcode());
              item.putString("province",geocodeAddress.getProvince());
              item.putMap("latLonPoint", formatDataLatLonPoint(geocodeAddress.getLatLonPoint())); // 经纬度
              array.pushMap(item);
            }
            this.jsPromise.resolve(array);
          }
        } else {
          this.jsPromise.reject("onGeocodeSearched Error: ", String.valueOf(rCode));
        }
        this.jsPromise = null;
    }

    // 解析result获取POI信息
    @Override
    public void onPoiSearched(PoiResultV2 result, int rCode) {
      System.out.println("===>onPoiSearched");
      if (this.jsPromise == null) {
        return;
      }
      if (rCode == AMapException.CODE_AMAP_SUCCESS) {
        WritableMap item = Arguments.createMap();
        item.putInt("count", result.getCount());
        item.putArray("list", formatDataPoisV2(result.getPois()));
        this.jsPromise.resolve(item);
      } else {
        this.jsPromise.reject("onPoiSearched: ", String.valueOf(rCode));
      }
      this.jsPromise = null;
    }

    // 获取POI数据-ID搜索 回调
    @Override
    public void onPoiItemSearched(PoiItemV2 poiItem, int rCode) {
      if (this.jsPromise == null) {
        return;
      }
      if (rCode == AMapException.CODE_AMAP_SUCCESS) {
        WritableArray array = Arguments.createArray();
        array.pushMap(formatDataPoiV2(poiItem));
        WritableMap item = Arguments.createMap();
        item.putInt("count", 1);
        item.putArray("list", array);
        this.jsPromise.resolve(item);
      } else {
        this.jsPromise.reject("onPoiItemSearched: ", String.valueOf(rCode));
      }
      this.jsPromise = null;
    }

    //  获取POI数据-输入内容自动提示回调
    @Override
    public void onGetInputtips(List<Tip> tipList, int rCode) {
      if (this.jsPromise == null) {
        return;
      }
      if (rCode == AMapException.CODE_AMAP_SUCCESS) {
        WritableArray array = Arguments.createArray();
        for (int i = 0; i < tipList.size(); i++) {
          Tip tip = tipList.get(i);
          WritableMap item= Arguments.createMap();
          item.putString("adCode", tip.getAdcode());
          item.putString("district", tip.getDistrict());
          item.putString("typeCode", tip.getTypeCode());
          item.putString("name", tip.getName());
          item.putString("uid", tip.getPoiID());
          item.putString("address", tip.getAddress());
          item.putMap("latLonPoint", formatDataLatLonPoint(tip.getPoint()));
          array.pushMap(item);
        }
        WritableMap resolveItem= Arguments.createMap();
        resolveItem.putInt("count", tipList.size());
        resolveItem.putArray("list", array);
        this.jsPromise.resolve(resolveItem);
      } else {
        this.jsPromise.reject("onGetInputTips: ", String.valueOf(rCode));
      }
      this.jsPromise = null;
    }

    @Override
    public void onRoutePoiSearched(RoutePOISearchResult result, int rCode){
      if (this.jsPromise == null) {
        return;
      }
      if (rCode == AMapException.CODE_AMAP_SUCCESS) {
        WritableArray array = Arguments.createArray();
        List<RoutePOIItem> poiItems = result.getRoutePois();
        for(int i = 0 ; i< poiItems.size(); i++){
          WritableMap item = Arguments.createMap();
          RoutePOIItem poiItem = poiItems.get(i);
          item.putString("uid",poiItem.getID());
          item.putString("name",poiItem.getTitle()); //名称
          item.putMap("latLonPoint",formatDataLatLonPoint(poiItem.getPoint())); // 经纬度
          item.putDouble("distance", poiItem.getDistance());  //距中心点的距离，单位米
          array.pushMap(item);
        }
        WritableMap resolveItem= Arguments.createMap();
        resolveItem.putInt("count", poiItems.size());
        resolveItem.putArray("list", array);
        this.jsPromise.resolve(resolveItem);
      } else {
        this.jsPromise.reject("onGetInputTips: ",  String.valueOf(rCode));
      }

    }



}
