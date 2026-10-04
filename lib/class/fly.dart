class Fly {
  int lane;
  double x; // posisi relatif terhadap lebar layar (0.0 - 1.0)
  int seconds; // sisa waktu lalat muncul
  double size;
  Fly({
    required this.lane,
    required this.x,
    this.seconds = 5,
    this.size = 36,
  });
}
