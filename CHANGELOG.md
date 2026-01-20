# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **完整的 POI 扩展信息支持** 🎉
  - Android: 新增获取 Business 对象的所有字段（营业时间、评分、人均消费等）
  - Android: 自动设置 `ShowFields.ALL` 以请求完整数据
  - 新增 `openTimeToday` 字段 - 今日营业时间（Android 独有）
  - 新增 `tel` 字段 - 电话号码
  - 新增 `tag` 字段 - 特色内容标签（Android 独有）
  - 新增 `parkingType` 字段 - 停车场类型
  - 新增 `alias` 字段 - POI 别名（Android 独有）
  - 新增 `cost` 字段 - 人均消费
  - 新增 `photos` 字段 - 图片列表（两端都支持）

### Changed
- **TypeScript 类型定义增强**
  - `AMapPoiExtensionType` 新增 `openTimeToday` 字段
  - `AMapPOISearchListItem` 新增 `tel`、`tag`、`parkingType`、`alias` 字段
  - 所有扩展字段均为可选类型（`?`）

### Fixed
- 修复 Android 端扩展信息始终为空的问题（需要设置 ShowFields）
- 修复 Business 对象字段未正确获取的问题

### Technical Details
- Android SDK v9.7.0 完全支持
  - 使用 `PoiItemV2.getBusiness()` 获取扩展信息
  - 使用 `query.setShowFields(new PoiSearchV2.ShowFields(PoiSearchV2.ShowFields.ALL))` 请求完整数据
- iOS SDK 已有完整支持（无需修改）

### Documentation
- 新增 `API_VERIFICATION_REPORT_FINAL.md` - 完整的 API 验证报告
- 新增 `POI_TESTING_GUIDE.md` - POI 数据测试指南
- 更新 `CLAUDE.md` - 开发指南

## [0.2.2] - Previous Release

（之前的版本历史...）
