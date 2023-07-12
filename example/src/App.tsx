/* eslint-disable react-native/no-inline-styles */
/*
 * @Author: 刘利军
 * @Date: 2023-05-20 17:53:20
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-12 14:46:42
 * @Description:
 * @PageName:
 */
import * as React from 'react';

import { StyleSheet, View, ScrollView, Text, SafeAreaView } from 'react-native';
import {
  AMapDistrictSearch,
  AMapGeocodeSearch,
  AMapReGeocodeSearch,
  aMapPOIAroundSearch,
  aMapPOIIDSearch,
  aMapPOIKeywordsSearch,
  aMapPOIPolygonSearch,
  init,
} from '@unif/react-native-amap-search';

const AroundParams = {
  latitude: 31.219234,
  longitude: 121.360923,
  // location: {
  //   latitude: 31.219234,
  //   longitude: 121.360923,
  // },
  keyword: '星巴克',
  city: '',
  type: '',
  currentPage: 1,
  pageSize: 25,
};

export default function App() {
  React.useEffect(() => {
    init();
  }, []);
  const [data, setData] = React.useState<any>();
  const start = () => {
    setData(JSON.stringify(''));
  };
  // eslint-disable-next-line @typescript-eslint/no-shadow
  const end = (data?: any) => {
    data ? setData(JSON.stringify(data)) : setData('');
  };
  return (
    <SafeAreaView
      style={{
        display: 'flex',
        backgroundColor: '#eee',
        marginBottom: 24,
        flex: 1,
      }}
    >
      <View style={{ display: 'flex', flexDirection: 'row', flexWrap: 'wrap' }}>
        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            try {
              const res = await AMapReGeocodeSearch({
                latitude: 31.230483,
                longitude: 121.353209,
              });
              console.log('res', res);
              end(res);
            } catch (error) {}
          }}
        >
          逆地理编码
        </Text>
        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            const res = await AMapGeocodeSearch({ name: '上海' });
            end(res);
          }}
        >
          地理编码
        </Text>
        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            try {
              const res = await aMapPOIKeywordsSearch(AroundParams);
              end(res);
              return;
            } catch (error) {
              console.log('error', error);
            }
            end();
          }}
        >
          关键字搜索
        </Text>
        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            const res = await aMapPOIAroundSearch(AroundParams);
            end(res);
          }}
        >
          周边搜索
        </Text>
        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            const res = await aMapPOIIDSearch('B0FFHD1L4T');
            end(res);
          }}
        >
          POI ID 搜索
        </Text>
        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            const points = [
              { latitude: 41.060816, longitude: 115.423411 },
              { latitude: 39.442758, longitude: 117.514625 },
            ];

            try {
              const res = await aMapPOIPolygonSearch({
                points,
                keyword: '',
                type: '080306',
              });
              end(res);
            } catch (error) {
              end();
            }
          }}
        >
          多边形搜索
        </Text>

        <Text
          style={{ margin: 8, padding: 8, backgroundColor: '#fff' }}
          onPress={async () => {
            start();
            try {
              const res = await AMapDistrictSearch({
                keyword: '上海',
              });
              end(res);
            } catch (error) {
              end();
            }
          }}
        >
          行政区数据
        </Text>
      </View>
      <ScrollView
        style={{
          display: 'flex',
          flex: 1,
          margin: 8,
          padding: 8,
          backgroundColor: '#fff',
        }}
      >
        <Text>{data}</Text>
      </ScrollView>
    </SafeAreaView>
  );
}
