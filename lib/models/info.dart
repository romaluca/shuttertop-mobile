class Info {
  final int minAndroidVersion;
  final String minIosVersion;

  Info.fromMap(Map<String, dynamic> map)
      : minAndroidVersion = int.parse(map['min_android_version']),
      minIosVersion = map['min_ios_version'];
}