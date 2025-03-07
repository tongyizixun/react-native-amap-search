/* eslint-disable react-native/no-inline-styles */
/*
 * @Author: 刘利军
 * @Date: 2023-05-20 17:53:20
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-25 13:28:54
 * @Description:
 * @PageName:
 */
import * as React from 'react';

import { View, ScrollView, Text, SafeAreaView } from 'react-native';
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
  types: '',
  currentPage: 1,
  pageSize: 25,
};

export default function App() {
  React.useEffect(() => {
    init({
      ios: '26ce677d6223c634b24f34f23e76023f',
      android: 'd65e2091b031bfd341e66c9ef9627273',
    });
  }, []);
  const [data, setData] = React.useState<any>();
  const start = () => {
    setData(JSON.stringify('开始'));
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
            try {
              console.log('start');
              const res = await aMapPOIIDSearch('B0FFL179OM');
              console.log('res', res);
              end(res);
            } catch (error) {
              console.log('error', error);
            }
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
                types: '',
              });
              console.log('res', res);
              end(res);
            } catch (error) {
              console.log('error', error);
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
