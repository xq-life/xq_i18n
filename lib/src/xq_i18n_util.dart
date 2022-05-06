import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sp_util/sp_util.dart';

import 'xq_i18n.dart';
import 'xq_out_utils.dart';

/*
* 自定义整合国际化工具类
* */
class XI18nUtil {
  XI18nUtil._();

  static final XI18nUtil _instance = XI18nUtil._();

  factory XI18nUtil() => _instance;

  final String _xqI18nAllFileName = 'xqI18n_all';
  final String _xqI18nLocalLanguage = 'XI18nUtilLocalLanguage';

  // 默认语言列表
  List<String> _xLanguageList = [
    'zh', // 简体中文
    'tw', // 繁体中文
    'en', // 英文
    'jp', // 日文
  ];

  Dio? dio;

  String get language => I18n.locale.languageCode;

  List<String> get xLanguageList => _xLanguageList;

  // 设置支持的国际化语言列表
  set xLanguageList(List<String> newXLanguageList) {
    _xLanguageList = newXLanguageList;
    _removeInvalidFile();
  }

  // 添加自定义国际化
  addXI18n(String language, String source, [bool save = false]) async {
    if (await ''.add(language, source) && save) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        bool hasPermission = (await Permission.storage.request()).isGranted;
        if (hasPermission) {
          var xPath = await _getXSavePath();
          var xName = '$language.json';
          File file = File(xPath + xName);
          if (await file.exists()) {
            Map readMap = jsonDecode(await file.readAsString());
            Map sourceMap = jsonDecode(source);
            readMap.addAll(sourceMap);
            file.writeAsString(jsonEncode(readMap));
          } else {
            file.writeAsString(source);
          }
          if (!_xLanguageList.contains(language)) {
            _xLanguageList.add(language);
            getLanguageFile(_xqI18nAllFileName).then((xqI18nAllFile) =>
                xqI18nAllFile.writeAsString(jsonEncode(_xLanguageList)));
          }
        }
      });
    }
  }

  // 下载国际化 File
  void downXi18nFile(String xUrl, {String? xPath, String? xName}) async {
    if (dio == null) {
      cOut('请配置 dio');
      return;
    }
    bool hasPermission = (await Permission.storage.request()).isGranted;
    if (hasPermission) {
      xPath ??= await _getXSavePath();
      try {
        if (xName == null) {
          var split = xUrl.split('/');
          xName ??= split[split.length - 1];
        }
      } catch (e) {
        xName = 'err.json';
      }
      await dio?.download(xUrl, '$xPath$xName',
          onReceiveProgress: (received, total) {
        if (total != -1) {
          cOut('CI18nUtil download $xName to $xPath:' +
              (received / total * 100).toStringAsFixed(0) +
              '%');
        }
      });
    }
  }

  // 下载国际化 JSON
  void downXi18nJson(
      {required String xUrl, required data, bool save = false}) async {
    if (dio == null) {
      cOut('请配置 dio');
      return;
    }
    await dio?.post(xUrl, data: data, queryParameters: data).then((val) {
      try {
        var value = jsonDecode('$val')['data'];
        addXI18n(data['language'], jsonEncode(value), save);
      } catch (e) {
        cOut('CI18nUtil downXi18nJson e:$e');
      }
    });
  }

  // 更改系统语言
  void changeLanguage(BuildContext context, String languageCode,
      [String? countryCode]) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      I18n.of(context).locale = Locale(languageCode, countryCode);
      SpUtil.putString(_xqI18nLocalLanguage, language);
    });
  }

  // 获取存储路径
  Future<String> _getXSavePath() async {
    String path = (await getApplicationSupportDirectory()).path + '/xqI18n/';
    if (!await Directory(path).exists()) {
      Directory(path).create();
    }
    return path;
  }

  // 获取国际化文件
  Future<File> getLanguageFile(String language) async =>
      File(await _getXSavePath() + language + '.json');

  // 加载本地国际化文件
  Future<List> getLocalCList() async {
    File xqI18nAllFile = await getLanguageFile(_xqI18nAllFileName);
    bool xqI18nAllFileExists = xqI18nAllFile.existsSync();
    if (xqI18nAllFileExists) {
      _xLanguageList =
          List<String>.from(jsonDecode(xqI18nAllFile.readAsStringSync()));
    }
    Stream<FileSystemEntity> fileList = Directory(await _getXSavePath()).list();
    await for (FileSystemEntity fileSystemEntity in fileList) {
      if (!fileSystemEntity.path.contains(_xqI18nAllFileName)) {
        List s = fileSystemEntity.path.split('/');
        s = s[s.length - 1].toString().split('.');
        if (_xLanguageList.isEmpty || _xLanguageList.contains(s[0])) {
          Future.delayed(const Duration(milliseconds: 100), () {
            try {
              addXI18n(s[0], File(fileSystemEntity.path).readAsStringSync());
            } catch (e) {
              cOut('CI18nUtil getLocalCList e:$e');
            }
          });
        }
      }
    }
    if (!xqI18nAllFileExists && _xLanguageList.isNotEmpty) {
      xqI18nAllFile.writeAsString(jsonEncode(_xLanguageList));
    }
    return _xLanguageList;
  }

  // 删除无用的国际化文件
  _removeInvalidFile() async {
    Stream<FileSystemEntity> fileList = Directory(await _getXSavePath()).list();
    await for (FileSystemEntity fileSystemEntity in fileList) {
      List s = fileSystemEntity.path.split('/');
      s = s[s.length - 1].toString().split('.');
      if (!_xLanguageList.contains(s[0]) && s[0] != _xqI18nAllFileName) {
        fileSystemEntity.delete();
        getLanguageFile(_xqI18nAllFileName).then((xqI18nAllFile) =>
            xqI18nAllFile.writeAsString(jsonEncode(_xLanguageList)));
      }
    }
  }
}
