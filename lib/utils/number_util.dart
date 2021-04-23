bool isChinaPhoneLegal(String str) {
  return new RegExp('^((1[3456789]))\\d{9}\$').hasMatch(str);
}
