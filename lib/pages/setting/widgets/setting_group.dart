import 'package:flutter/material.dart';
import 'package:parkeer/widgets/section_title.dart';
import 'setting_item.dart';

class SettingMenu {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingMenu({required this.icon, required this.title, required this.onTap});
}

class SettingGroup extends StatelessWidget {
  final String title;
  final List<SettingMenu> items;

  const SettingGroup({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title),

        const SizedBox(height: 8),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  SettingItem(
                    icon: items[index].icon,
                    title: items[index].title,
                    onTap: items[index].onTap,
                  ),
                  if (index != items.length - 1)
                    Divider(height: 1, color: Colors.grey.shade200),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
