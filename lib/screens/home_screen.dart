import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';

/// Home Screen untuk menampilkan counter dan tombol-tombol kontrol
/// 
/// Screen ini menggunakan Consumer widget untuk mendengarkan perubahan
/// dari CounterProvider dan akan rebuild otomatis saat state berubah
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Provider State Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF133E87),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card container untuk counter display
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF133E87),
                        const Color(0xFF133E87).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Counter Value',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Consumer widget untuk mendengarkan perubahan dari CounterProvider
                      Consumer<CounterProvider>(
                        builder: (context, counterProvider, child) {
                          return Text(
                            '${counterProvider.counter}',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Penjelasan singkat tentang Provider
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'State Management dengan Provider',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Counter ini menggunakan Provider untuk mengelola state. Saat tombol ditekan, provider akan memberitahu UI untuk update otomatis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Row untuk tombol increment dan decrement
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tombol Decrement
                  _buildControlButton(
                    context: context,
                    icon: Icons.remove,
                    label: 'Decrement',
                    color: Colors.red,
                    onPressed: () {
                      // Menggunakan Provider.of untuk mengakses method decrement
                      Provider.of<CounterProvider>(context, listen: false).decrement();
                    },
                  ),
                  
                  // Tombol Reset
                  _buildControlButton(
                    context: context,
                    icon: Icons.refresh,
                    label: 'Reset',
                    color: Colors.orange,
                    onPressed: () {
                      Provider.of<CounterProvider>(context, listen: false).reset();
                    },
                  ),
                  
                  // Tombol Increment
                  _buildControlButton(
                    context: context,
                    icon: Icons.add,
                    label: 'Increment',
                    color: Colors.green,
                    onPressed: () {
                      // Menggunakan Provider.of untuk mengakses method increment
                      Provider.of<CounterProvider>(context, listen: false).increment();
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Informasi teknis
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Teknis Implementation:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Consumer<CounterProvider> - Mendengarkan perubahan state\n'
                      '• Provider.of<CounterProvider> - Mengakses method provider\n'
                      '• notifyListeners() - Memberitahu UI untuk rebuild\n'
                      '• listen: false - Tidak perlu rebuild saat mengakses method',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method untuk membuat tombol kontrol yang konsisten
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 4,
          ),
          child: Icon(icon, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}