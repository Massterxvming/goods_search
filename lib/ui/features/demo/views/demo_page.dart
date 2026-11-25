import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.title,
    this.icon = Icons.explore_outlined,
    this.accent = const Color(0xFF719C7A),
    this.background = const Color(0xFFE5F0E7),
  });
  final String title;
  final IconData icon;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: ValueKey('demo-page-$title'),
    appBar: AppBar(
      leading: IconButton(
        tooltip: '返回',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(icon, color: accent, size: 46),
            ),
            const SizedBox(height: 27),
            const Text(
              '下一次发现，从这里开始。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '这是一个演示页面，更多内容正在路上。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF929A90)),
            ),
            const SizedBox(height: 32),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: const Text('返回上一页'),
            ),
          ],
        ),
      ),
    ),
  );
}
