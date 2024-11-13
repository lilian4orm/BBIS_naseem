import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:z_time_ago/z_time_ago.dart';

String toDateOnly(int millis) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('dd-MM-yyyy').format(dt);
}

String toDateTime(String datetime) {
  DateTime dateTime = DateTime.parse(datetime).toLocal();
  String formattedDateTime = DateFormat("dd-MM-yyyy  hh:mm a").format(dateTime);

  return formattedDateTime;
}

String toDateAndTime(int millis, int format) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);
  if (format == 12) {
    /// 12 Hour format:
    return DateFormat('dd-MM-yyyy, hh:mm a').format(dt);
  } else {
    /// 24 Hour format:
    return DateFormat('dd-MM-yyyy, HH:mm').format(dt);
  }
}

String getChatDate(int millis, int format) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);

  if (format == 12) {
    /// 12 Hour format:
    return DateFormat('dd-MM, hh:mm a').format(dt);
  } else {
    /// 24 Hour format:
    return DateFormat('dd-MM, HH:mm').format(dt);
  }
}

String toTimeOnly(int millis, int format) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);

  if (format == 12) {
    /// 12 Hour format:
    return DateFormat('hh:mm a').format(dt);
  } else {
    /// 24 Hour format:
    return DateFormat('HH:mm').format(dt);
  }
}

String secondToTime(int second) {
  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
  final d3 = Duration(seconds: second);
  return format(d3);
}

String fromISOToDate(String date) {
  DateTime now = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").parse(date);
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  return formattedDate;
}

String toDayOnly(int millis) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('dd').format(dt);
}

String toDayOfWeek(int millis) {
  initializeDateFormatting('en_us', null);
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('EEEE').format(dt);
}

String stringToDayOfWeek(String date) {
  initializeDateFormatting('ar_IQ', null);
  DateTime now = DateFormat("yyyy-MM-dd").parse(date);
  return DateFormat('EEEE').format(now);
}

String toMonthOnlyAR(int millis) {
  //final box = GetStorage();
  initializeDateFormatting('ar_IQ', null);
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('MMM').format(dt);
  // box.read('language') == 'ar'
  //     ? DateFormat('MMM', "ar_IQ").format(dt)
  //     : DateFormat('MMM').format(dt);
}

String toYearOnly(int millis) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return DateFormat('yyyy').format(dt);
}

String lastSeenTime(int? millis) {
  // final box = GetStorage();
  if (millis != null) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String date = ZTimeAgo().getTimeAgo(
      //'2022-01-28 11:46:54.897839'
      date: DateFormat('yyyy-MM-dd HH:mm:ss').format(dt),
      language: Language.english,
      //  box.read('language') == 'en' ? Language.english : Language.arabic,
    );
    return date;
  } else {
    return 'sinceWhile'.tr;
  }
}

DateTime toDateAndTimeDateTime(int millis, int format) {
  var dt = DateTime.fromMillisecondsSinceEpoch(millis);

  if (format == 12) {
    /// 12 Hour format:
    String timeString = DateFormat('dd-MM-yyyy, hh:mm a').format(dt);
    return DateFormat("dd-MM-yyyy, hh:mm a").parse(timeString);
  } else {
    /// 24 Hour format:

    String timeString = DateFormat('dd-MM-yyyy, HH:mm').format(dt);
    return DateFormat("dd-MM-yyyy, HH:mm").parse(timeString);
  }
}
