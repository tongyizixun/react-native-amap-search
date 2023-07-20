/*
 * @Author: 刘利军
 * @Date: 2023-05-20 20:53:05
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-12 14:27:45
 * @Description:
 * @PageName:
 */
import { NativeModules, Platform } from 'react-native';
import type {
  AMapDistrictSearchParams,
  AMapInputTipsSearchType,
  AMapPOIAroundSearchType,
  AMapPOIKeywordsSearchType,
  AMapPOIPolygonSearchType,
  AMapReGeocodeSearchParams,
  AMapRegeoSearchParams,
  AMapRoutePOISearchType,
  ReactNativeAmapSearchType,
} from './types';

const LINKING_ERROR =
  `The package '@unif/react-native-amap-search' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ReactNativeAmapSearch: ReactNativeAmapSearchType =
  NativeModules.ReactNativeAmapSearch
    ? NativeModules.ReactNativeAmapSearch
    : new Proxy(
        {},
        {
          get() {
            throw new Error(LINKING_ERROR);
          },
        }
      );

// 初始化
export const init = () => ReactNativeAmapSearch.initSDK();

// poi搜索
export const aMapPOIKeywordsSearch = async ({
  keyword = '',
  type = '',
  city = '',
  currentPage = 1,
  pageSize = 10,
  cityLimit = false,
}: AMapPOIKeywordsSearchType) => {
  return ReactNativeAmapSearch.aMapPOIKeywordsSearch(
    keyword,
    type,
    city,
    currentPage,
    pageSize,
    cityLimit
  );
};

// 沿途道路搜索
export const aMapRoutePOISearch = async ({
  fromPoint,
  toPoint,
  mode = 0,
  type = 0,
  range = 250,
}: AMapRoutePOISearchType) => {
  return ReactNativeAmapSearch.aMapRoutePOISearch(
    fromPoint,
    toPoint,
    mode,
    type,
    range
  );
};

// 多边形搜索
export const aMapPOIPolygonSearch = async ({
  points,
  keyword = '',
  type = '',
  city = '',
  currentPage = 1,
  pageSize = 10,
}: AMapPOIPolygonSearchType) => {
  return ReactNativeAmapSearch.aMapPOIPolygonSearch(
    keyword,
    type,
    city,
    points,
    currentPage,
    pageSize
  );
};

// 周边搜索
export const aMapPOIAroundSearch = async ({
  latitude,
  longitude,
  keyword = '',
  type = '',
  city = '',
  radius = 10000,
  currentPage = 1,
  pageSize = 10,
}: AMapPOIAroundSearchType) => {
  return ReactNativeAmapSearch.aMapPOIAroundSearch(
    keyword,
    type,
    city,
    latitude,
    longitude,
    currentPage,
    pageSize,
    radius
  );
};

// 搜索提示
export const aMapPOIInputTipsSearch = async ({
  keyword = '',
  city = '',
  type = '',
  latitude = 0,
  longitude = 0,
}: AMapInputTipsSearchType) => {
  return await ReactNativeAmapSearch.aMapPOIInputTipsSearch(
    keyword,
    city,
    type,
    latitude,
    longitude
  );
};

// id搜索
export const aMapPOIIDSearch = async (id: string) => {
  return ReactNativeAmapSearch.aMapPOIIDSearch(id);
};

// 逆地理编码
export const AMapReGeocodeSearch = async ({
  latitude,
  longitude,
  radius = 1000,
  latLonType = 'AMAP',
  extensions = 'all',
  poiType = '',
  mode = 'distance',
}: AMapReGeocodeSearchParams) => {
  return await ReactNativeAmapSearch.AMapReGeocodeSearch(
    latitude,
    longitude,
    radius,
    latLonType,
    extensions,
    poiType,
    mode
  );
};

// 地理编码
export const AMapGeocodeSearch = async ({
  name,
  city = '',
  country = '',
}: AMapRegeoSearchParams) => {
  return ReactNativeAmapSearch.AMapGeocodeSearch(name, city, country);
};

// 城区获取
export const AMapDistrictSearch = async ({
  keyword = '',
  pageSize = 20,
  currentPage = 1,
  subdistrict = 0,
}: AMapDistrictSearchParams) => {
  return await ReactNativeAmapSearch.aMapDistrictSearch(
    keyword,
    currentPage,
    pageSize,
    subdistrict
  );
};
