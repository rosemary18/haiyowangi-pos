import 'dart:math';

import 'package:flutter/material.dart';

export 'network.dart';
export 'loader.dart';
export 'date.dart';
export 'currency.dart';
export 'image.downloader.dart';
export 'path.finder.dart';

String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
String nums = '1234567890';
final _rnd = Random();

String generateRandomString(int length, {bool numsOnly = false}) {
  return String.fromCharCodes(Iterable.generate(length, (_) {
    if (numsOnly) {
      return nums.codeUnitAt(_rnd.nextInt(nums.length));
    }
    return _chars.codeUnitAt(_rnd.nextInt(_chars.length));
  }));
}

String formatDouble(double value) {

  if (value == value.toInt()) {
    return value.toInt().toString();
  } else {
    return value.toString();
  }
}

Map<String, dynamic> convertToStringDynamic(Map<dynamic, dynamic> map) {

  Map<String, dynamic> newMap = {};

  for (var key in map.keys) {
    if (map[key] is Map) {
      newMap[key.toString()] = convertToStringDynamic(map[key]);
      continue;
    } else {
      newMap[key.toString()] = map[key];
    }
  }
  
  return newMap;
}

void debugPrintLongText(String text) {
  const int chunkSize = 800; // Ukuran maksimum per bagian
  int start = 0;
  
  while (start < text.length) {
    int end = (start + chunkSize < text.length) ? start + chunkSize : text.length;
    debugPrint(text.substring(start, end));
    start += chunkSize;
  }
}