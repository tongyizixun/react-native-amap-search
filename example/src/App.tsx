/*
 * @Author: 刘利军
 * @Date: 2023-05-20 17:53:20
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-05-20 21:10:52
 * @Description:
 * @PageName:
 */
import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import { initSDK, AMapReGeocodeSearch } from '@unif/react-native-amap-search';

export default function App() {
  return (
    <View style={styles.container}>
      <Button
        title="as"
        onPress={async () => {
          await initSDK();

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
            console.log('AMapReGeocodeSearch regeocode', res);
          } catch (error) {
            console.log(error);
          }
        }}
      >
        <Text>按钮</Text>
      </Button>
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
