import 'package:flutter/material.dart';

import '../app_theme.dart';

class RemitAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RemitAppBar({
    super.key,
    required this.onNavigate,
    required this.currentRoute,
    this.showAuthActions = true,
  });

  final void Function(String route) onNavigate;
  final String currentRoute;
  final bool showAuthActions;

  static const _routes = <String, String>{
    '/': 'Home',
    '/send-money': 'Send Money',
    '/marketplace': 'Marketplace',
    '/transactions': 'Transactions',
  };

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isCompact = constraints.maxWidth < 720;

        return AppBar(
          automaticallyImplyLeading: isCompact,
          titleSpacing: isCompact ? 0 : 24,
          title: Row(
            children: [
              _buildLogo(),
              if (!isCompact) const SizedBox(width: 32),
              if (!isCompact) ..._buildNavItems(context),
            ],
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: Gradients.hero),
          ),
          actions: [
            if (isCompact)
              _CompactMenu(currentRoute: currentRoute, onNavigate: onNavigate),
            if (!isCompact && showAuthActions) ...[
              TextButton(
                onPressed: () => onNavigate('/login'),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  gradient: Gradients.button,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => onNavigate('/signup'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Join Now'),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: Gradients.button,
          ),
          child: const Icon(
            Icons.currency_exchange_rounded,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'RemitHub',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNavItems(BuildContext context) {
    return _routes.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _NavigationButton(
              label: entry.value,
              isActive: currentRoute == entry.key,
              onTap: () => onNavigate(entry.key),
            ),
          ),
        )
        .toList();
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: isActive
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(isActive ? 1 : 0.78),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CompactMenu extends StatelessWidget {
  const _CompactMenu({required this.currentRoute, required this.onNavigate});

  final String currentRoute;
  final void Function(String route) onNavigate;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu, color: Colors.white),
      onSelected: onNavigate,
      itemBuilder: (context) {
        return [
          ...RemitAppBar._routes.entries.map(
            (route) => PopupMenuItem<String>(
              value: route.key,
              child: Row(
                children: [
                  if (route.key == currentRoute)
                    const Icon(Icons.check, size: 16)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(route.value),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem<String>(value: '/login', child: const Text('Login')),
          PopupMenuItem<String>(
            value: '/signup',
            child: const Text('Join Now'),
          ),
        ];
      },
    );
  }
}
