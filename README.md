# xq_i18n

Secondary packaging based on "i18n_extension" .

### 插件环境
```
# flutter --version #
Flutter 2.10.3 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 7e9793dee1 (3 weeks ago) • 2022-03-02 11:23:12 -0600
Engine • revision bd539267b4
Tools • Dart 2.16.1 • DevTools 2.9.2
```
### 使用
- 国际化使用
    - 添加国际化组件为跟组件
  ```dart
  // 1、导入包
  import 'package:xq_i18n/xq_i18n.dart';
  
  void main() {
    // 2、添加跟组件
    runApp(XI18nWidget(
        child: MaterialApp(...)
      ));
  }
  ```
    - 设置 Dio 对象
  ```dart
  XI18nUtil().setDio( /* Dio 对象 */ );
  ```
    - 切换中英文
  ```dart
  XI18nUtil().changeLocale(context, 'en', 'US');
  ```
    - 下载国际化
  ```dart
  XI18nUtil().downXi18nJson('path', true);
  ```
