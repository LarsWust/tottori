String ago(DateTime date) {
  Duration diff = DateTime.now().difference(date);
  if (diff.inSeconds <= 60) {
    return "${diff.inSeconds}s";
  } else if (diff.inMinutes <= 60) {
    return "${diff.inMinutes}m";
  } else if (diff.inHours <= 24) {
    return "${diff.inHours}h";
  } else /*if (diff.inDays <= 30)*/ {
    return "${diff.inDays}d";
  }
}
