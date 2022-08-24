class Utils {
  static const String S3host = "https://s3-eu-west-1.amazonaws.com";

  static const String imageBaseUrl = "https://img.shuttertop.com/";

  static String getTimeRemain(DateTime d, [bool short = false]) {
    if (d == null) return "";
    final DateTime currentTime = new DateTime.now();
    final Duration du = d.difference(currentTime);

    if (du.isNegative) {
      return ("terminato " +
              (short
                  ? ""
                  : (du.inDays == 0 ? "oggi" : "${du.inDays * -1} giorni fa")))
          .trim();
    } else if (du.inDays > 0)
      return (short ? "" : "mancano ") + "${du.inDays} giorni";
    final int hours = du.inHours;
    final int minutes = du.inMinutes - (du.inHours * 60);
    final int sec = du.inSeconds - (du.inMinutes * 60);
    return "${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(sec)}";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}

enum UserListItemFormat {
  normal,
  trophies,
  score,
  minimal,
  scoreMonth,
  scoreWeek
}

enum ImageFormat { normal, medium, thumb_small, thumb }

enum ResponseStatus { Ok, Error, Expired }

enum ListOrder { news, top, name }

enum ListUserType {
  score,
  trophies,
  name,
  userFollowers,
  userFollows,
  contestFollowers,
  photoTops
}

const List<String> listOrders = const <String>["news", "top", "name"];

const List<String> listUserType = const <String>[
  "score",
  "trophies",
  "name",
  "followers_user_id",
  "follows_user_id",
  "followers_contest_id",
  "tops_photo_id"
];
