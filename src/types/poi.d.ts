export type AMapPageType = {
  currentPage?: number;
  pageSize?: number;
};

export type AMapLatLonType = {
  latitude?: number;
  longitude?: number;
};

export type AMapLatLonMustType = {
  latitude: number;
  longitude: number;
};

export type AMapPOICommonSearchType = {
  keyword?: string;
  types?: string;
  city?: string;
};

export type AMapRoutePOISearchType = {
  fromPoint: AMapLatLonType;
  toPoint: AMapLatLonType;
  mode: number;
  type: number;
  range: number;
};

// 关键字搜索
export type AMapPOIKeywordsSearchType = AMapPOICommonSearchType &
  AMapPageType & {
    cityLimit?: boolean;
  };

// 搜索提示
export type AMapInputTipsSearchType = AMapPOICommonSearchType & AMapLatLonType;

// 多边形搜素
export type AMapPOIPolygonSearchType = AMapPOICommonSearchType &
  AMapPageType & {
    points: AMapLatLonType[];
  };

//   周边搜索
export type AMapPOIAroundSearchType = AMapPOICommonSearchType &
  AMapLatLonMustType &
  AMapPageType & { radius?: number; keyword?: string };

// poi 搜索 list
export type AMapPOISearchListItem = {
  uid: string; // uid
  name: string; // 名称
  type: string; //兴趣点类型
  typeCode: string; // 类型编码
  latLonPoint: AMapLatLonMustType; // 经纬度
  address: string; // 地址
  province: string; // 省
  provinceCode: string; // 省编码
  city: string; // 市
  cityCode: string; // 城市编码
  district: string; // 区域名称
  adCode: string; // 区域编码
};

// poi搜索回调
export type AMapPOISearchResult = {
  count: number;
  list: AMapPOISearchListItem[];
};

// 逆地理编码
export type AMapReGeocodeSearchLatLonType = 'AMAP' | 'GPS';
export type AMapReGeocodeSearchExtensions = 'all' | 'base';
export type AMapReGeocodeSearchMode = 'distance' | 'score';
export type AMapReGeocodeSearchParams = AMapLatLonMustType & {
  radius?: number;
  latLonType?: AMapReGeocodeSearchLatLonType;
  extensions?: AMapReGeocodeSearchExtensions;
  mode?: AMapReGeocodeSearchMode;
  poiType?: string;
};

export type AMapReGeocodeSearchResult = {
  uid: string; // uid
  name: string; // 名称
  type: string; //兴趣点类型
  typecode: number; // 类型编码
  location: any;
  address: string; // 地址
  tel: number; // 电话
  distance: any; //距中心点的距离，单位米
  parkingType: any; //停车场类型，地上、地下
  shopID: string; // 商铺id
  postcode: number; //邮编
  website: string; // 网址
  email: string; //电子邮件
  province: string; //省
  pcode: number; //省编码
  city: string; //市
  citycode: number; //城市编码
  district: string; //区域名称
  adcode: number; // 区域编码
};

// 地理编码
export type AMapRegeoSearchParams = {
  name: string;
  city?: string;
  country?: string;
};
export type AMapGeocodeSearchResult = Array<{
  postCode: string;
  formatAddress: string;
  latLonPoint: AMapLatLonMustType;
  province: string;
  district: string;
  building: string;
  neighborhood: string;
  level: string;
  city: string;
  adcode: string;
  country: string;
}>;

// 区域获取
export type AMapDistrictSearchParams = {
  keyword: string;
  subdistrict?: number;
} & AMapPageType;

export type AMapDistrictSearchDistrictType = {
  districts: AMapDistrictSearchDistrictsType;
  polylines: string[];
  name: string;
  center: AMapLatLonMustType;
  cityCode: string;
  level: string;
  adCode: string;
};

export type AMapDistrictSearchDistrictsType =
  Array<AMapDistrictSearchDistrictType>;

export type AMapDistrictSearchResult = {
  count: number;
  districts: AMapDistrictSearchDistrictsType;
};
