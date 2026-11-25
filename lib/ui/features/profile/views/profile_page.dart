import 'package:flutter/material.dart';

import '../../demo/views/demo_page.dart';
import '../../platform_login/views/platform_login_page.dart';
import '../../shell/view_models/service_status_view_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.status, required this.onRefresh});
  final ServiceStatus status;
  final VoidCallback onRefresh;

  void _openDemo(BuildContext context, String title, IconData icon) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DemoPage(title: title, icon: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('profile-scroll'),
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 22 : 36),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '我的',
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        const Text(
          '把每一次发现，留给自己。',
          style: TextStyle(fontSize: 13, color: Color(0xFF879087)),
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFE5),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF203D34),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFFE4EED9),
                  size: 34,
                ),
              ),
              const SizedBox(width: 17),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '你好，探索者',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '演示账号 · 发现一点新变化',
                      style: TextStyle(fontSize: 12, color: Color(0xFF7E8C7C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            for (final title in ['我的收藏', '浏览记录', '关注分类'])
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () =>
                      _openDemo(context, title, Icons.bookmarks_outlined),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Text(
                          '0',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF90988C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 19),
        Container(
          decoration: _panelDecoration,
          child: Column(
            children: [
              ListTile(
                key: const Key('profile-platform-login'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 9,
                ),
                leading: const Icon(
                  Icons.login_rounded,
                  size: 22,
                  color: Color(0xFF74836F),
                ),
                title: const Text(
                  '平台登录',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    '在官方页面查看商品价格',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9BA292)),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFFABB2A3),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PlatformLoginPage(),
                  ),
                ),
              ),
              const Divider(
                height: 1,
                indent: 65,
                endIndent: 20,
                color: Color(0xFFF0F2EC),
              ),
              _menu(context, '偏好设置', '让探索更合心意', Icons.tune_rounded),
              const Divider(
                height: 1,
                indent: 65,
                endIndent: 20,
                color: Color(0xFFF0F2EC),
              ),
              _menu(context, '关于价迹', '记录日常，看见时间', Icons.info_outline_rounded),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _panelDecoration,
          child: Row(
            children: [
              Icon(
                status == ServiceStatus.online
                    ? Icons.cloud_done_outlined
                    : Icons.cloud_outlined,
                color: const Color(0xFF7B9574),
                size: 24,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      switch (status) {
                        ServiceStatus.online => '服务已连接',
                        ServiceStatus.checking => '正在连接服务',
                        ServiceStatus.offline => '当前为离线演示',
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      status == ServiceStatus.offline
                          ? '页面仍可浏览，点击右侧重试'
                          : '演示服务运行状态',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF929C89),
                      ),
                    ),
                  ],
                ),
              ),
              if (status == ServiceStatus.checking)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  tooltip: '重新连接',
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded, size: 22),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Center(
          child: Text(
            '价迹  /  日常的价格，时间的答案',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFABB2A4),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ),
  );

  static final _panelDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: const Color(0xFFE8EDE5)),
  );

  Widget _menu(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    leading: Icon(icon, size: 22, color: const Color(0xFF74836F)),
    title: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Color(0xFF9BA292)),
      ),
    ),
    trailing: const Icon(
      Icons.chevron_right_rounded,
      size: 20,
      color: Color(0xFFABB2A3),
    ),
    onTap: () => _openDemo(context, title, icon),
  );
}
