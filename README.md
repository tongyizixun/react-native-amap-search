<!--
 * @Author: 刘利军
 * @Date: 2023-07-20 17:56:38
 * @LastEditors: 刘利军
 * @LastEditTime: 2023-07-21 19:17:17
 * @Description: 
 * @PageName: 
-->
# @unif/react-native-amap-search

amap search

## 安装

```sh
npm install @unif/react-native-amap-search
or
yarn add @td-design/react-native-amap-search

# ios 项目需要更新 pods
cd ios
pod install

```

## 使用

# 添加高德key
-ios
1. [获取高德key](https://lbs.amap.com/api/ios-sdk/guide/create-project/get-key) 
2. 在AppDelegate.m 引入头文件并设置高德 Key 
```objectivec
#import <AMapFoundationKit/AMapFoundationKit.h>

[AMapServices sharedServices].apiKey = @"你的高德 Key";
```

-android
1. [获取高德key](https://lbs.amap.com/api/android-sdk/guide/create-project/get-key) 
2. AndroidManifest.xml（一般在 android\app\src\main\AndroidManifest.xml），添加如下代码

```java
<application>
  <meta-data android:name="com.amap.api.v2.apikey" android:value="你的高德 Key" />
</application>
```
## 用法

1. 初始化
```js
import { init, aMapPOIAroundSearch, aMapPOIIDSearch, aMapPOIKeywordsSearch } from '@unif/react-native-amap-search';
await = init();
```
2. 调用
```js
// 传入参数
const params =
  {
    type: 'around',
    jsonData: {
      keyword: '星巴克',
      type: '咖啡店',
      city: '上海市',
      latitude: 31.223333,
      longitude: 121.222222,
      currentPage: 1,
      pageSize: 25,
      radius: 500,
    },
  } || null;
 const res = await =  aMapPOIAroundSearch(params);

```

## 文档
[查看](https://eudmtest.upbuy.com.cn/js_control/plugindoc/docs/api/amap#%E8%8E%B7%E5%8F%96%E5%9C%B0%E5%9B%BE%E6%95%B0%E6%8D%AE)

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
