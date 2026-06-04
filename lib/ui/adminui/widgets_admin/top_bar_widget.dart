import 'package:flutter/material.dart';
import 'app_colors.dart';

class TopBarWidget extends StatelessWidget {
  final bool isDesktop;

  const TopBarWidget({
    super.key,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _buildDesktopTopBar() : _buildMobileTopBar();
  }

  Widget _buildDesktopTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(bottom: BorderSide(color: AppColors.borderColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'EduAdmin Dashboard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              // Search
              Container(
                width: 200,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm...',
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Notifications
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // Help
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {},
              ),
              const SizedBox(width: 16),
              // Divider
              Container(width: 1, height: 30, color: AppColors.borderColor),
              const SizedBox(width: 16),
              // User Info
              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        'Nguyễn Văn A',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Giảng viên',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.accentBlue,
                    child: const Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTopBar() {
    return Container(
      height: 64,
      color: AppColors.surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'EduAdmin',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          CircleAvatar(
            backgroundColor: AppColors.accentBlue,
            child: const Text('A', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
