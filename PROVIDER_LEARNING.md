# Provider State Management Learning

Proyek Flutter sederhana untuk belajar state management menggunakan Provider pattern.

## 📋 Overview

Proyek ini mendemonstrasikan implementasi Provider pattern untuk state management di Flutter dengan contoh counter sederhana yang mudah dipahami.

## 🏗️ Struktur File

```
lib/
├── main.dart                           # Entry point dengan provider setup
├── providers/
│   └── counter_provider.dart          # Provider class untuk counter state
├── screens/
│   └── home_screen.dart               # UI screen untuk counter
└── ... (existing files)
```

## 🔧 Dependencies Baru

Tambahan dependency di `pubspec.yaml`:
```yaml
dependencies:
  provider: ^6.1.2  # State management dengan Provider pattern
```

## 📱 Fitur Counter App

### 1. Counter Provider (`counter_provider.dart`)
- **State Management**: Mengelola state counter dengan ChangeNotifier
- **Methods**: 
  - `increment()` - Menambah counter
  - `decrement()` - Mengurangi counter  
  - `reset()` - Reset ke 0
- **notifyListeners()**: Memberitahu UI untuk rebuild otomatis

### 2. Home Screen (`home_screen.dart`)
- **Consumer Widget**: Mendengarkan perubahan state dari provider
- **Provider.of**: Mengakses methods provider tanpa rebuild
- **UI Components**: 
  - Display counter dengan desain menarik
  - Tombol Increment, Decrement, Reset
  - Penjelasan teknis untuk pembelajaran

### 3. Main App Integration (`main.dart`)
- **ChangeNotifierProvider**: Wrapper untuk menyediakan provider ke seluruh app
- **Routing**: Tambahan route `/provider-learning` 
- **Quick Access**: Floating action button di splash screen

## 🎓 Konsep Pembelajaran

### Provider Pattern Basics
1. **ChangeNotifier**: Base class untuk provider yang bisa memberitahu perubahan
2. **Consumer**: Widget yang rebuild otomatis saat state berubah
3. **Provider.of**: Cara mengakses provider untuk memanggil methods
4. **notifyListeners()**: Trigger untuk update UI

### Best Practices
- Pisahkan logic bisnis (Provider) dari UI (Widget)
- Gunakan `listen: false` saat hanya butuh akses method
- Provider di level atas aplikasi untuk global state
- Consumer hanya di widget yang perlu rebuild

## 🚀 Cara Menggunakan

1. **Akses Learning Screen**:
   - Dari splash screen: Tap tombol "Provider Learning"
   - Atau langsung navigate ke `/provider-learning`

2. **Interaksi**:
   - Tap tombol "+" untuk increment
   - Tap tombol "-" untuk decrement  
   - Tap tombol "↻" untuk reset
   - Lihat counter update otomatis

3. **Pembelajaran**:
   - Perhatikan bagaimana UI update tanpa setState
   - Consumer rebuild otomatis saat state berubah
   - Provider.of mengakses methods tanpa rebuild

## 💡 Konsep Penting

### State Management Flow
```
User Action → Provider Method → notifyListeners() → Consumer Rebuild → UI Update
```

### Code Examples

**Provider Setup:**
```dart
ChangeNotifierProvider(
  create: (context) => CounterProvider(),
  child: MaterialApp(...)
)
```

**Listening to Changes:**
```dart
Consumer<CounterProvider>(
  builder: (context, counterProvider, child) {
    return Text('${counterProvider.counter}');
  },
)
```

**Calling Methods:**
```dart
Provider.of<CounterProvider>(context, listen: false).increment();
```

## 🎯 Tujuan Pembelajaran

Setelah menggunakan contoh ini, Anda akan memahami:
- Cara kerja Provider pattern di Flutter
- Perbedaan antara Consumer dan Provider.of
- Kapan menggunakan `listen: false`
- Best practices untuk state management
- Separation of concerns dalam aplikasi Flutter

## 🔗 Integration dengan Existing App

Implementasi ini terintegrasi dengan aplikasi SiKasir yang sudah ada:
- Tidak mengubah fungsionalitas existing
- Tambahan route untuk pembelajaran
- Quick access dari splash screen
- Menggunakan theme dan styling yang konsisten

---

**Catatan**: Ini adalah contoh pembelajaran. Untuk aplikasi production, pertimbangkan menggunakan state management yang lebih kompleks seperti Riverpod atau Bloc jika dibutuhkan.