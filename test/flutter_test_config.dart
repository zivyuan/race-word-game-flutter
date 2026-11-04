import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// 全局测试配置：为所有测试初始化 sqflite FFI 与 mock SharedPreferences。
/// merge /api/v1/ 对齐后，页面普遍依赖 LocalDatabase 与 token 存储，
/// 缺少这两项会以 "databaseFactory not initialized" / MissingPluginException 失败。
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  await testMain();
}
