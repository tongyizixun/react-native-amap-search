# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.2] - 2026-05-18

### Fixed
- **同步 0.2.x 侧分支上丢失的运行时防护**（0.2.3 → 0.2.19 那条分支上加过的 try-catch / nil-guard 一直没合并到主线 0.4.x，本次补回）。

#### Android (`AmapSearchModule.java`)
- `onPoiSearched` / `onPoiItemSearched` / `onGetInputtips` / `onRoutePoiSearched` 四个回调恢复 `result / poiItem / tipList / poiItems` 的 null 防护，避免 SDK 偶发空响应时 NPE 把 Promise 卡死。
- `aMapPOIKeywordsSearch` / `aMapPOIAroundSearch` / `aMapPOIPolygonSearch` 把 `query.setShowFields(ShowFields.ALL)` 调用挪到 try 块内，避免 AMap SDK 版本不匹配时崩在 catch 之外。
- 8 处 `catch (AMapException e)` 收紧为 `catch (Throwable e)`，覆盖 `RuntimeException` / `NoClassDefFoundError` 等运行时异常；Business / Photos 内层的 `catch (Exception e)` 同步改 `Throwable`。
- `formatDataLatLonPoint` / `formatDataStreetNumber` 加入 null guard，新 SDK 返回 null 子对象时不再 NPE。

#### iOS (`AmapSearch.mm` / `AMapUtils.m`)
- `onPOISearchDone` 恢复 `response.pois.count == 0` 的空结果分支，返回空 list 而非依赖 formatter 兜底。
- `onReGeocodeSearchDone` 恢复 `response.regeocode != nil` 防护，nil 时返回 `@{}`。
- `AMapUtils.m` 中 8 个 format 方法（`poiFormatData` / `aoiFormatData` / `businessFormatData` / `roadsFormatData` / `roadsInterFormatData` / `regeocodeFormatData` 的 streetNumber 段 / `geocodeFormatData` / `districtFormatData`）外层加 `@try / @catch (NSException *exception)`，并在 `enumerateObjectsUsingBlock` 中加 `if (obj)` 过滤。
- `poiFormatData` 额外在单条 POI 构造外加内层 `@try / @catch`，单条解析失败不影响整页其他 POI。

## [0.4.1] - 2026-04-29

### Fixed
- **iOS 编译失败修复**：0.4.0 在新版 AMapSearch（9.4.0+）下 fallback 分支编译不通过
  - 移除 `AMapPOI` 顶层 `opentime` / `rating` 引用——这两个属性自 AMapSearch 9.4.0 起已迁至 `AMapBusinessData`，新 SDK 上已无定义
  - `AMapPOIExtension.rating` / `.cost` 是 `CGFloat`（assign），不是 NSString；将原有 `isKindOfClass:[NSString class]` 检查改为数值判断 + `@()` 装箱
- **podspec 钉最低 SDK 版本**：`AMapSearch >= 9.4.0`，避免装到老 SDK 时 `businessData` 分支拿不到数据

### Added
- **完整的 POI 扩展信息支持** 🎉
  - Android: 使用 `Business` 对象获取所有扩展字段
  - Android: 自动设置 `ShowFields.ALL` 以请求完整数据
  - iOS: 使用 `AMapBusinessData` 对象获取所有扩展字段（Since 9.4.0）
  - iOS: 设置 `showFieldsType = AMapPOISearchShowFieldsTypeAll` 请求完整数据
  - **两端功能完全对等！** 均支持以下字段（均在 `business` 对象中）：
    - `businessArea` - 商圈名称
    - `location` - 商圈中心点 (iOS 独有)
    - `openTime` - 营业时间（周）
    - `openTimeToday` - 今日营业时间
    - `rating` - 评分
    - `cost` - 人均消费
    - `tel` - 电话号码
    - `tag` - 特色内容标签
    - `parkingType` - 停车场类型
    - `alias` - POI 别名
  - `poiExtension` 对象包含：
    - `photos` - 图片列表

### Changed
- **⚠️ BREAKING CHANGE: 数据结构调整**
  - 所有 `Business`/`AMapBusinessData` 字段统一放在 `business` 对象中
  - 从 POI 顶层移除：`tel`, `tag`, `parkingType`, `alias`
  - 从 `poiExtension` 移除：`openTime`, `openTimeToday`, `rating`, `cost`
  - 以上字段现在都在 `business` 对象中
  - `poiExtension` 现在只包含 `photos` 数组
  - **数据结构示例**：
    ```typescript
    {
      uid: "xxx",
      name: "xxx",
      // ... 其他基础字段
      business: {
        businessArea: "xxx",
        openTime: "xxx",
        openTimeToday: "xxx",
        rating: "xxx",
        cost: "xxx",
        tel: "xxx",
        tag: "xxx",
        parkingType: "xxx",
        alias: "xxx"
      },
      poiExtension: {
        photos: [{ title: "xxx", url: "xxx" }]
      }
    }
    ```
- **TypeScript 类型定义更新**
  - `AMapBusinessType` 包含所有 Business 字段
  - `AMapPoiExtensionType` 只包含 `photos`
  - `AMapPOISearchListItem` 移除顶层的扩展字段

### Fixed
- 修复 Android 端扩展信息始终为空的问题（需要设置 ShowFields）
- 修复 iOS 端扩展信息始终为空的问题（需要设置 showFieldsType）
- 修复 Business 对象字段未正确获取的问题

### Technical Details
- **Android SDK v9.7.0**
  - 使用 `PoiItemV2.getBusiness()` 获取 `Business` 对象
  - 使用 `query.setShowFields(new PoiSearchV2.ShowFields(PoiSearchV2.ShowFields.ALL))` 请求完整数据
  - Business 类包含所有扩展字段
- **iOS SDK 9.4.0+**
  - 使用 `AMapPOI.businessData` 获取 `AMapBusinessData` 对象
  - 使用 `request.showFieldsType = AMapPOISearchShowFieldsTypeAll` 请求完整数据
  - AMapBusinessData 类包含所有扩展字段（与Android Business完全对应）
  - 兜底机制：businessData → extensionInfo → 直接属性

### Data Structure
```typescript
// POI 搜索结果的数据结构
{
  uid, name, type, typeCode, latLonPoint, address,
  province, provinceCode, city, cityCode, district, adCode,

  business: {  // 所有 Business 对象的字段都在这里
    businessArea?: string;
    location?: LatLon;  // iOS 独有
    openTime?: string;
    openTimeToday?: string;
    rating?: string;
    cost?: string;
    tel?: string;
    tag?: string;
    parkingType?: string;
    alias?: string;
  },

  poiExtension: {  // 只包含 photos
    photos?: Array<{title: string; url: string}>;
  }
}
```

**所有扩展字段两端均完全支持！**

### Documentation
- 新增 `API_VERIFICATION_REPORT_FINAL.md` - 完整的 API 验证报告
- 新增 `POI_TESTING_GUIDE.md` - POI 数据测试指南
- 更新 `CLAUDE.md` - 开发指南

## [0.2.2] - Previous Release

（之前的版本历史...）
