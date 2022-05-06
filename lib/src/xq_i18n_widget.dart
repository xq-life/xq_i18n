import 'package:flutter/material.dart';
import 'package:i18n_extension/i18n_widget.dart';

// ignore: must_be_immutable
class XI18nWidget extends StatelessWidget {
  XI18nWidget({required this.child, Key? key}) : super(key: key);
  Widget child;

  @override
  Widget build(BuildContext context) {
    return I18n(initialLocale: const Locale("zh"), child: child);
  }
}
