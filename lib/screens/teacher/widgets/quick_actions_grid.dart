import 'package:flutter/material.dart';

class QuickActionItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActionsGrid({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final action = actions[index];
          return _ActionCard(action: action);
        },
        childCount: actions.length,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final QuickActionItem action;

  const _ActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconContainer(),
              const SizedBox(height: 8),
              _buildTitle(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: action.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        action.icon,
        color: action.color,
        size: 28,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      action.title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
