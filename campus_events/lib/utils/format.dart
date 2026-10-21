// Date formatting without packages: "18 Oct", "10:00", "18 Oct, 10:00".

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 10:00 — hours and minutes padded, so 9:05 is "09:05", not "9:5".
String formatClock(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

String formatTime(DateTime d) => formatClock(d.hour, d.minute);

/// 18 Oct, 10:00
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

/// 2 d 3 h · 3 h 05 min · 12 min
String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours > 0) return '${d.inHours} h ${_two(d.inMinutes % 60)} min';
  return '${d.inMinutes} min';
}
