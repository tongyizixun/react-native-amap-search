# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **完整的 POI 扩展信息支持** 🎉
  - Android: 使用 `Business` 对象获取所有扩展字段（营业时间、评分、人均消费等）
  - Android: 自动设置 `ShowFields.ALL` 以请求完整数据
  - iOS: 使用 `AMapBusinessData` 对象获取所有扩展字段（Since 9.4.0）
  - **两端功能完全对等！** 均支持以下字段：
    - `tel` - 电话号码
    - `tag` - 特色内容标签
    - `parkingType` - 停车场类型
    - `alias` - POI 别名
    - `cost` - 人均消费
    - `rating` - 评分
    - `openTime` - 营业时间（周）
    - `openTimeToday` - 今日营业时间
    - `photos` - 图片列表

### Changed
- **TypeScript 类型定义增强**
  - `AMapPoiExtensionType` 新增 `openTimeToday`、`cost` 字段
  - `AMapPOISearchListItem` 新增 `tel`、`tag`、`parkingType`、`alias` 字段
  - 所有扩展字段均为可选类型（`?`），保持跨平台兼容性

### Fixed
- 修复 Android 端扩展信息始终为空的问题（需要设置 ShowFields）
- 修复 iOS 端扩展信息始终为空的问题（需要设置 showFieldsType）
- 修复 Business 对象字段未正确获取的问题

### Important Notes
- **Android SDK**: 需要设置 `ShowFields.ALL` 来获取完整扩展信息
- **iOS SDK**: 需要设置 `showFieldsType = AMapPOISearchShowFieldsTypeAll` 来获取完整扩展信息
- 两端配置方式不同，但功能完全对等

### Technical Details
- **Android SDK v9.7.0**
  - 使用 `PoiItemV2.getBusiness()` 获取 `Business` 对象
  - 使用 `query.setShowFields(new PoiSearchV2.ShowFields(PoiSearchV2.ShowFields.ALL))` 请求完整数据
  - Business 类包含所有扩展字段
- **iOS SDK 9.4.0+**
  - 使用 `AMapPOI.businessData` 获取 `AMapBusinessData` 对象
  - 使用 `request.showFieldsType = AMapPOISearchShowFieldsTypeAll` 请求完整数据（关键！）
  - AMapBusinessData 类包含所有扩展字段（与Android Business完全对应）
  - 兜底机制：businessData → extensionInfo → 直接属性

### Platform Support
| 字段 | Android | iOS | 说明 |
|------|---------|-----|------|
| `tel` | ✅ | ✅ | 电话号码 |
| `tag` | ✅ | ✅ | 特色内容标签 |
| `parkingType` | ✅ | ✅ | 停车场类型 |
| `alias` | ✅ | ✅ | POI 别名 |
| `cost` | ✅ | ✅ | 人均消费 |
| `rating` | ✅ | ✅ | 评分 |
| `openTime` | ✅ | ✅ | 营业时间（周） |
| `openTimeToday` | ✅ | ✅ | 今日营业时间 |
| `photos` | ✅ | ✅ | 图片列表 |

**所有扩展字段两端均完全支持！**

### Documentation
- 新增 `API_VERIFICATION_REPORT_FINAL.md` - 完整的 API 验证报告
- 新增 `POI_TESTING_GUIDE.md` - POI 数据测试指南
- 更新 `CLAUDE.md` - 开发指南

## [0.2.2] - Previous Release

（之前的版本历史...）
