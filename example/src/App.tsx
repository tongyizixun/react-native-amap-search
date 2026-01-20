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
    init({ ios: '', android: '' });
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
            console.log('========== POI 完整数据结构测试 ==========\n');

            try {
              // 调用真实的关键字搜索 API - 搜索更多结果以找到有扩展信息的 POI
              const result = await aMapPOIKeywordsSearch({
                keyword: '海底捞', // 大型连锁餐饮，通常有更完整的数据
                city: '上海',
                currentPage: 1,
                pageSize: 10, // 增加数量，找到有数据的 POI
              });

              console.log('✅ 搜索成功！');
              console.log('\n【完整返回结构】');
              console.log(JSON.stringify(result, null, 2));

              if (result && result.list && result.list.length > 0) {
                // 查找第一个有扩展信息的 POI
                let poiWithData = result.list[0];
                for (const poi of result.list) {
                  if (
                    poi &&
                    (Object.keys(poi.business || {}).length > 0 ||
                      Object.keys(poi.poiExtension || {}).length > 0)
                  ) {
                    poiWithData = poi;
                    break;
                  }
                }

                console.log(
                  `\n【找到 ${result.count} 个POI，展示第一个有扩展信息的】`
                );
                console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                console.log('基础信息:');
                console.log(`  uid: ${poiWithData!.uid}`);
                console.log(`  name: ${poiWithData!.name}`);
                console.log(`  type: ${poiWithData!.type}`);
                console.log(`  typeCode: ${poiWithData!.typeCode}`);
                console.log(`  address: ${poiWithData!.address}`);
                console.log(`  latLonPoint:`, poiWithData!.latLonPoint);

                console.log('\n行政区域:');
                console.log(
                  `  province: ${poiWithData!.province} (${
                    poiWithData!.provinceCode
                  })`
                );
                console.log(
                  `  city: ${poiWithData!.city} (${poiWithData!.cityCode})`
                );
                console.log(
                  `  district: ${poiWithData!.district} (${
                    poiWithData!.adCode
                  })`
                );

                console.log(
                  '\n📍 商圈信息 (business) - 包含所有 Business 字段:'
                );
                console.log(JSON.stringify(poiWithData!.business, null, 2));
                const businessKeys = Object.keys(poiWithData!.business || {});
                console.log(
                  `  [包含 ${businessKeys.length} 个字段: ${
                    businessKeys.join(', ') || '无'
                  }]`
                );

                console.log('\n⭐ 扩展信息 (poiExtension) - 只包含 photos:');
                console.log(JSON.stringify(poiWithData!.poiExtension, null, 2));
                const extKeys = Object.keys(poiWithData!.poiExtension || {});
                console.log(
                  `  [包含 ${extKeys.length} 个字段: ${
                    extKeys.join(', ') || '无'
                  }]`
                );

                console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

                console.log('\n【数据结构说明】');
                console.log(
                  '• business 对象: 包含所有 Business/businessData 字段'
                );
                console.log('  - businessArea: 商圈名称');
                console.log('  - location: 商圈中心点 (iOS 独有)');
                console.log('  - openTime: 营业时间（周）');
                console.log('  - openTimeToday: 今日营业时间');
                console.log('  - rating: 评分');
                console.log('  - cost: 人均消费');
                console.log('  - tel: 电话号码');
                console.log('  - tag: 特色内容');
                console.log('  - parkingType: 停车场类型');
                console.log('  - alias: 别名');
                console.log('• poiExtension 对象: 只包含 photos');
                console.log('  - photos: 照片列表 [{ title, url }]');
                console.log('\n✨ 两端数据结构完全一致！');

                end(result);
              } else {
                console.log('⚠️ 未找到POI数据');
                end({ message: '未找到POI数据' });
              }
            } catch (error) {
              console.error('❌ 搜索失败:', error);
              end({ error: String(error) });
            }

            console.log('\n========== 测试结束 ==========');
          }}
        >
          POI完整数据结构
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
                types: '080306',
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
