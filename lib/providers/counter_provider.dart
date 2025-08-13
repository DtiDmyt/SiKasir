import 'package:flutter/foundation.dart';

/// Counter Provider untuk mengelola state counter
/// 
/// Class ini menggunakan ChangeNotifier untuk memberitahu widget
/// ketika terjadi perubahan pada state counter
class CounterProvider with ChangeNotifier {
  // Private variable untuk menyimpan nilai counter
  int _counter = 0;

  // Getter untuk mengakses nilai counter
  // Menggunakan getter agar nilai counter tidak bisa diubah langsung dari luar
  int get counter => _counter;

  /// Method untuk menambah nilai counter
  /// 
  /// Setelah nilai counter bertambah, memanggil notifyListeners()
  /// untuk memberitahu semua widget yang mendengarkan provider ini
  void increment() {
    _counter++;
    notifyListeners(); // Penting! Ini memberitahu UI untuk rebuild
  }

  /// Method untuk mengurangi nilai counter
  /// 
  /// Setelah nilai counter berkurang, memanggil notifyListeners()
  /// untuk memberitahu semua widget yang mendengarkan provider ini
  void decrement() {
    _counter--;
    notifyListeners(); // Penting! Ini memberitahu UI untuk rebuild
  }

  /// Method untuk reset counter ke 0
  void reset() {
    _counter = 0;
    notifyListeners();
  }
}