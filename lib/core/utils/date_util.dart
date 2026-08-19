extension DateUtil on DateTime? {
  String get toFormattedDate {
    if (this == null) return 'Unknown date';

    final date = this!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      if (difference.inDays >= 1) {
        return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours >= 1) {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else {
        return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'min' : 'mins'} ago';
      }
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[date.month - 1];
      final day = date.day;
      return '$month $day, ${date.year}';
    }
  }
}
extension DateStringUtil on String? {
  String get toFormattedDate {
    if (this == null || this!.isEmpty) return 'Unknown date';

    final date = DateTime.tryParse(this!);
    return date.toFormattedDate;
  }
}
