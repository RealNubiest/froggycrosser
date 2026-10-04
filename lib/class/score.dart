class Score {
  String user;
  int point;
  int frogs; // jumlah katak yang berhasil diseberangkan
  Score({
    required this.user,
    required this.point,
    required this.frogs,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'point': point,
      'frogs': frogs,
    };
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      user: json['user'] ?? '-',
      point: json['point'] ?? 0,
      frogs: json['frogs'] ?? 0,
    );
  }
}
