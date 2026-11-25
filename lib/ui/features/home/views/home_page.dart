import 'package:flutter/material.dart';

import '../../../../data/repositories/market_price_repository.dart';
import '../../../core/widgets/connection_badge.dart';
import '../../market_price/views/market_price_page.dart';
import '../../shell/view_models/service_status_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.status, required this.repository});
  final ServiceStatus status;
  final MarketPriceRepository repository;

  static const _categories = [
    _Category(
      '数码家电',
      '每一次升级，都有迹可循',
      'DIGITAL',
      Icons.devices_rounded,
      Color(0xFFE8EFFA),
      Color(0xFF6889BF),
    ),
    _Category(
      '食品生鲜',
      '一日三餐里的价格故事',
      'GROCERY',
      Icons.shopping_basket_outlined,
      Color(0xFFFAEEE2),
      Color(0xFFBF8D62),
    ),
    _Category(
      '日用百货',
      '关心生活的每一件小事',
      'LIFESTYLE',
      Icons.chair_outlined,
      Color(0xFFE5F0E7),
      Color(0xFF719C7A),
    ),
    _Category(
      '出行能源',
      '看见每一程的成本变化',
      'MOBILITY',
      Icons.electric_bolt_rounded,
      Color(0xFFEEE9F6),
      Color(0xFF9582B6),
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 480;
      final horizontal = constraints.maxWidth < 600 ? 22.0 : 36.0;
      return Padding(
        padding: EdgeInsets.fromLTRB(
          horizontal,
          compact ? 12 : 26,
          horizontal,
          compact ? 12 : 22,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF203D34),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stacked_line_chart_rounded,
                    color: Color(0xFFDCE8CD),
                    size: 23,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '价迹',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                ConnectionBadge(status: status),
              ],
            ),
            SizedBox(height: compact ? 14 : 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '从日常，发现变化。',
                        style: TextStyle(
                          fontSize: compact ? 22 : 29,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 8),
                        const Text(
                          '选一个分类，调研现在的商品价格',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF879087),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (constraints.maxWidth > 600 && !compact)
                  const Text(
                    'EXPLORE YOUR EVERYDAY',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.7,
                      color: Color(0xFF9AA399),
                    ),
                  ),
              ],
            ),
            SizedBox(height: compact ? 16 : 26),
            Expanded(
              child: Column(
                children: [
                  for (var row = 0; row < 2; row++) ...[
                    if (row > 0) SizedBox(height: compact ? 12 : 16),
                    Expanded(
                      child: Row(
                        children: [
                          for (var column = 0; column < 2; column++) ...[
                            if (column > 0) SizedBox(width: compact ? 12 : 16),
                            Expanded(
                              child: _CategoryCard(
                                category: _categories[row * 2 + column],
                                index: row * 2 + column + 1,
                                repository: repository,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _Category {
  const _Category(
    this.title,
    this.subtitle,
    this.label,
    this.icon,
    this.background,
    this.accent,
  );
  final String title;
  final String subtitle;
  final String label;
  final IconData icon;
  final Color background;
  final Color accent;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.index,
    required this.repository,
  });
  final _Category category;
  final int index;
  final MarketPriceRepository repository;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 155;
      final padding = compact ? 14.0 : 20.0;
      return Material(
        color: category.background,
        borderRadius: BorderRadius.circular(26),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('category-${category.title}'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MarketPricePage(
                category: category.title,
                repository: repository,
              ),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: compact ? -30 : -14,
                right: -25,
                child: Container(
                  width: compact ? 115 : 160,
                  height: compact ? 115 : 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: padding,
                left: padding,
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 11,
                    color: category.accent,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Positioned(
                top: compact ? 8 : 28,
                right: compact ? 16 : 25,
                child: Transform.rotate(
                  angle: -0.09,
                  child: Icon(
                    category.icon,
                    color: category.accent.withValues(alpha: 0.8),
                    size: compact ? 32 : 72,
                  ),
                ),
              ),
              Positioned(
                bottom: padding,
                left: padding,
                right: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!compact) ...[
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.7,
                          color: category.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              category.title,
                              style: TextStyle(
                                fontSize: compact ? 18 : 22,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2D3B34),
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_outward_rounded,
                          size: 18,
                          color: category.accent,
                        ),
                      ],
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 7),
                      Text(
                        category.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF818A81),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
