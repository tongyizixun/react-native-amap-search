import type {
  AMapDistrictSearchResult,
  AMapGeocodeSearchResult,
  AMapLatLonType,
  AMapPOISearchResult,
  AMapReGeocodeSearchExtensions,
  AMapReGeocodeSearchLatLonType,
  AMapReGeocodeSearchMode,
  AMapReGeocodeSearchResult,
} from './poi';

export type ReactNativeAmapSearchType = {
  initSDK: () => void;
  aMapPOIKeywordsSearch: (
    keyword: string,
    type: string,
    city: string,
    currentPage: number,
    pageSize: number,
    cityLimit: boolean
  ) => Promise<AMapPOISearchResult>;
  aMapRoutePOISearch: (
    fromPoint: AMapLatLonType,
    toPoint: AMapLatLonType,
    mode: number,
    type: number,
    range: number
  ) => Promise<AMapPOISearchResult>;
  aMapPOIPolygonSearch: (
    keyword: string,
    type: string,
    city: string,
    points: AMapLatLonType[],
    currentPage: number,
    pageSize: number
  ) => Promise<AMapPOISearchResult>;
  aMapPOIAroundSearch: (
    keyword: string,
    type: string,
    city: string,
    latitude: number,
    longitude: number,
    radius: number,
    currentPage: number,
    pageSize: number
  ) => Promise<AMapPOISearchResult>;
  aMapPOIInputTipsSearch: (
    keyword: string,
    city: string,
    type: string,
    latitude: number,
    longitude: number
  ) => Promise<AMapPOISearchResult>;
  aMapPOIIDSearch: (id: string) => promise<AMapPOISearchResult>;

  AMapReGeocodeSearch: (
    latitude: number,
    longitude: number,
    radius: number,
    latLonType: AMapReGeocodeSearchLatLonType,
    extensions: AMapReGeocodeSearchExtensions,
    poiType: string,
    mode: AMapReGeocodeSearchMode
  ) => Promise<AMapReGeocodeSearchResult>;
  AMapGeocodeSearch: (
    name: string,
    city: string,
    country: string
  ) => Promise<AMapGeocodeSearchResult>;

  aMapDistrictSearch: (
    keyword: string,
    currentPage: number,
    pageSize: number,
    subdistrict: number
  ) => Promise<AMapDistrictSearchResult>;
};
