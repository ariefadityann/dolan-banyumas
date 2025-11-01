// lib/widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  // ... (Salin seluruh kode kelas CustomBottomNavBar dari file asli Anda ke sini)
  // Tidak ada perubahan pada isi kelas ini, hanya pemindahan file.
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalMargin = 20.0;
    final double itemWidth = (screenWidth - horizontalMargin * 2) / 5;

    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildBackgroundBase(),
          _buildAnimatedSelector(itemWidth),
          _buildNavigationItems(itemWidth),
        ],
      ),
    );
  }

  Widget _buildBackgroundBase() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSelector(double itemWidth) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutBack,
      left: itemWidth * selectedIndex,
      top: -20,
      child: Container(
        height: 80,
        width: itemWidth,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItems(double itemWidth) {
    return Row(
      children: [
        _buildNavItem(Icons.home_outlined, 'Home', 0, itemWidth),
        _buildNavItem(Icons.confirmation_number_outlined, 'Tickets', 1, itemWidth),
        _buildNavItem(Icons.directions_bus_outlined, 'Transport', 2, itemWidth),
        _buildNavItem(Icons.favorite_border, 'Favorite', 3, itemWidth),
        _buildNavItem(Icons.more_horiz, 'More', 4, itemWidth),
      ],
    );
  }

   Widget _buildNavItem(IconData icon, String label, int index, double itemWidth) {
    final bool isSelected = selectedIndex == index;
    final Color backgroundColor = const Color(0xFFF44336);
    final Color selectedIconColor = backgroundColor;
    final Color unselectedIconColor = Colors.grey[400]!;
    final Color textColor = const Color(0xFFF44336); // TEKS PUTIH

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon dengan animasi yang lebih smooth
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSelected ? 52 : 38,
                height: isSelected ? 52 : 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFFF0F3F0) : Colors.transparent,
                  border: isSelected 
                      ? Border.all(color: backgroundColor, width: 2.5)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? selectedIconColor : unselectedIconColor,
                  size: isSelected ? 26 : 22,
                ),
              ),
              
              // Label dengan teks putih dan animasi yang lebih baik
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isSelected ? 1.0 : 0.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.translationValues(
                    0, 
                    isSelected ? 0 : 10, 
                    0
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textColor, // TEKS PUTIH
                        height: 1.3,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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