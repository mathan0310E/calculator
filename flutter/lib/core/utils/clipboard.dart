import 'package:flutter/services.dart';

class ClipboardUtil {
  ClipboardUtil._();

  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<String> paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text ?? '';
  }
}
