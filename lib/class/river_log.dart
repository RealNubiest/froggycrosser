class RiverLog {
  int lane;
  double x;
  double speed; // piksel per detik, negatif = bergerak ke kiri
  double width;
  double height;
  RiverLog({
    required this.lane,
    required this.x,
    required this.speed,
    required this.width,
    this.height = 38,
  });

  void move(double dt, double arenaWidth) {
    x += speed * dt;
    if (speed > 0 && x > arenaWidth + 50) {
      x = -width - 20;
    }
    if (speed < 0 && x + width < -50) {
      x = arenaWidth + 20;
    }
  }
}
