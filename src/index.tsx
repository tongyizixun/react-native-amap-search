import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package '@unif/react-native-amap-search' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ReactNativeAmapSearch = NativeModules.ReactNativeAmapSearch
  ? NativeModules.ReactNativeAmapSearch
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function initSDK(): Promise<void> {
  return ReactNativeAmapSearch.initSDK();
}

export type AMapReGeocodeSearchOutput = 'JSON';
export type AMapReGeocodeSearchExtensions = 'all';

export type AMapReGeocodeSearchParams = {
  latitude: number;
  longitude: number;
  output: AMapReGeocodeSearchOutput;
  extensions: AMapReGeocodeSearchExtensions;
  batch: boolean;
  roadlevel: number;
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

export function AMapReGeocodeSearch(
  params: AMapReGeocodeSearchParams
): Promise<AMapReGeocodeSearchResult> {
  return ReactNativeAmapSearch.AMapReGeocodeSearch(params);
}

export type AMapRegeoParams = { latitude: number; longitude: number };
export type AMapRegeohResult = any;
export function AMapRegeo(
  params: AMapReGeocodeSearchParams
): Promise<AMapRegeohResult> {
  return ReactNativeAmapSearch.AMapRegeo({ locations: params });
}
