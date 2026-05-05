class UserStats {
  final int attended, pending;
  double get rate =>
      attended + pending == 0 ? 0 : attended / (attended + pending);

  UserStats({required this.attended, required this.pending});
  factory UserStats.fromJson(Map<String, dynamic> j) =>
      UserStats(attended: j['attended'] ?? 0, pending: j['pending'] ?? 0);
}
