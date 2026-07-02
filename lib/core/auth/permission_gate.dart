import 'package:flutter/material.dart';
import '../../domain/entities/app_user.dart';

/// Wraps [child] and only renders it when [condition] is true for [user].
/// Shows [fallback] otherwise (defaults to SizedBox.shrink).
class PermissionGate extends StatelessWidget {
  final AppUser user;
  final bool condition;
  final Widget child;
  final Widget fallback;

  const PermissionGate({
    super.key,
    required this.user,
    required this.condition,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) =>
      condition ? child : fallback;
}
