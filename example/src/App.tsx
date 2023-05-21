/*
 * @Author: 刘利军
 * @Date: 2023-05-20 17:53:20
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-05-21 16:24:12
 * @Description:
 * @PageName:
 */
import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import { initSDK, AMapReGeocodeSearch } from '@unif/react-native-amap-search';

const AMAP_KEY_ANDROID = '9f57d2a0f1cb421d24448d29cd8fd866';
const AMAP_KEY_IOS = '8706d4669781e887864f9198c9e394d1';
export default function App() {
  React.useEffect(() => {
    initSDK({ android: AMAP_KEY_ANDROID, ios: AMAP_KEY_IOS });
  }, []);

  return (
    <View style={styles.container}>
      <Button
        title="按钮"
        onPress={async () => {
          const locations = {
            latitude: 31.23048312717014,
            longitude: 121.35320936414934,
          };
          // await AMapSearchManager.aMapPOIKeywordsSearch('上海', '', '')
          //   .then((res) => console.log('res', res))
          //   .catch((err) => console.log('err', err));
          try {
            const res = await AMapReGeocodeSearch({
              ...locations,
              output: 'JSON',
              extensions: 'all',
              batch: false,
              roadlevel: 0,
            });
            console.log('AMapReGeocodeSearch regeocode', JSON.stringify(res));
          } catch (error) {
            console.log('error', error);
          }
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
