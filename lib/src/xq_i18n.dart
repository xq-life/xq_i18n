import 'package:i18n_extension/i18n_extension.dart';
import 'package:i18n_extension/io/import.dart';

import 'xq_i18n_custom.dart';
import 'xq_out_utils.dart';

extension XLocalization on String {
  static var _t = Translations.byLocale("zh") + xqI18nCustom;

  // 添加自定义国际化
  // Example：取 data 数据格式
  // {
  //   "code": 200,
  //   "success": true,
  //   "msg": "操作成功",
  //   "data": {
  //     "save": "保存",
  //     "please_input": "请输入",
  //     "back": "返回",
  //     /* ... */
  //   }
  // }
  Future<bool> add(String language, String source) async {
    if (source.isEmpty || source == 'null') {
      return false;
    }
    try {
      _t += (await JSONImporter().fromString(language, source));
      return true;
    } catch (e) {
      cOut('CI18n add:$e');
      return false;
    }
  }

  String get c => localize(this, _t);

  String fill(List<Object> params) => localizeFill(this, params);

  String plural(int value) => localizePlural(value, this, _t);

  String version(Object modifier) => localizeVersion(modifier, this, _t);
}
