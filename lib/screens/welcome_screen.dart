import 'package:flutter/material.dart';
import '../utils/app_constants.dart';
import 'main_navigation.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // NỘI DUNG GIỮA
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO VÍ TIỀN MINH HỌA
                    const WalletIllustration(),

                    const SizedBox(height: 32),

                    // TIÊU ĐỀ
                    const Text(
                      'Expense Manager',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // PHỤ ĐỀ
                    const Text(
                      'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),

              // NÚT BẮT ĐẦU Ở ĐÁY
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigationScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletIllustration extends StatelessWidget {
  const WalletIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tiền giấy xanh lá thò ra phía sau
          Positioned(
            top: 6,
            left: 28,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 72,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF48BB78),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 26,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 68,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF68D391),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          // Thân ví màu xanh dương
          Positioned(
            bottom: 10,
            child: Container(
              width: 116,
              height: 74,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),

          // Nắp ví / Khóa cài
          Positioned(
            bottom: 30,
            right: 12,
            child: Container(
              width: 44,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF1D4ED8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
