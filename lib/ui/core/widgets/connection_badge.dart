import 'package:flutter/material.dart';

import '../../features/shell/view_models/service_status_view_model.dart';

class ConnectionBadge extends StatelessWidget {
  const ConnectionBadge({super.key, required this.status});
  final ServiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ServiceStatus.checking => ('连接中', const Color(0xFF829087)),
      ServiceStatus.online => ('已连接', const Color(0xFF4E8766)),
      ServiceStatus.offline => ('离线演示', const Color(0xFFA77C4E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5EBE4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
