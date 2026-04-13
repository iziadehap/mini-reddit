String formatProfileCount(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toString();
}

String accountAgeLabel(DateTime? createdAt) {
  if (createdAt == null) return 'N/A';
  final diff = DateTime.now().difference(createdAt);
  if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y';
  if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
  return '${diff.inDays}d';
}
