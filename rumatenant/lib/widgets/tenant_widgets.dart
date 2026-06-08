import 'package:flutter/material.dart';

import '../core/theme.dart';

class RumaBrandLogo extends StatelessWidget {
  const RumaBrandLogo({
    super.key,
    this.height = 24,
    this.alignment = Alignment.centerRight,
  });

  final double height;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Image.asset(
        'assets/RUMA LOGO 1.png',
        height: height,
        color: AppTheme.accent,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'RUMA',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          );
        },
      ),
    );
  }
}

class RumaPageTitle extends StatelessWidget {
  const RumaPageTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class RumaSectionHeader extends StatelessWidget {
  const RumaSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final hasAction = actionLabel != null && onAction != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (hasAction)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textMuted,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class RumaPanel extends StatelessWidget {
  const RumaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppTheme.surface,
    this.borderColor = AppTheme.border,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class RumaInfoRow extends StatelessWidget {
  const RumaInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.icon,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppTheme.textDark),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style:
                  labelStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style:
                  valueStyle ??
                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class RumaStatusChip extends StatelessWidget {
  const RumaStatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class RumaPrimaryButton extends StatelessWidget {
  const RumaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = AppTheme.olive,
    this.foregroundColor = AppTheme.textLight,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class RumaFilterChip extends StatelessWidget {
  const RumaFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.olive : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? Colors.white : AppTheme.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class RumaBottomNav extends StatelessWidget {
  const RumaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = <_NavItem>[
      _NavItem(icon: Icons.home, activeIcon: Icons.home, index: 0),
      _NavItem(
        icon: Icons.credit_card_outlined,
        activeIcon: Icons.credit_card,
        index: 1,
      ),
      _NavItem(
        icon: Icons.notifications_none,
        activeIcon: Icons.notifications,
        index: 2,
      ),
      _NavItem(icon: Icons.history, activeIcon: Icons.history, index: 3),
      _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, index: 4),
    ];

    return Container(
      color: AppTheme.navBackground,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) {
            final isSelected = currentIndex == item.index;
            return GestureDetector(
              onTap: () => onTap(item.index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: isSelected ? 58 : 54,
                height: isSelected ? 58 : 54,
                decoration: BoxDecoration(
                  color: AppTheme.navButton,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: AppTheme.olive,
                  size: isSelected ? 30 : 26,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.index,
  });

  final IconData icon;
  final IconData activeIcon;
  final int index;
}
