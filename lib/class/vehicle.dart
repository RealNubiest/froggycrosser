class Vehicle {
  String type; // truck, car, race_car
  int lane;
  double x;
  double speed; // piksel per detik, negatif = bergerak ke kiri
  double width;
  double height;
  Vehicle({
    required this.type,
    required this.lane,
    required this.x,
    required this.speed,
    required this.width,
    required this.height,
  });

  String get name {
    if (type == 'truck') {
      return 'Truk';
    } else if (type == 'race_car') {
      return 'Mobil Balap';
    } else {
      return 'Mobil';
    }
  }

  String get image => 'assets/images/$type.png';

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
