// Mechanic Incoming Call screen — mechanic receives a call from a user.
// Accept and Decline buttons.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/navigation/route_names.dart';
import '../../../shared/widget/app_avatar.dart';
import '../../../shared/widget/system_ui_style.dart';

class MechanicIncomingCallScreen extends StatefulWidget {
  const MechanicIncomingCallScreen({super.key});

  @override
  State<MechanicIncomingCallScreen> createState() =>
      _MechanicIncomingCallScreenState();
}

class _MechanicIncomingCallScreenState
    extends State<MechanicIncomingCallScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;
  late final Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    SystemUiStyle.applyDark();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _ringAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, AppSpacing.md,
                  AppSpacing.pageHorizontal, 0),
              child: Text('Incoming Call',
                  style: AppTypography.heading3,
                  overflow: TextOverflow.ellipsis, maxLines: 1),
            ),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pulsing ring around avatar
                  ScaleTransition(
                    scale: _ringAnimation,
                    child: Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primaryBorder, width: 2),
                      ),
                      child: Center(
                        child: AppAvatar(name: 'John Doe', size: 96),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('John Doe',
                      style: AppTypography.heading1,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                  const SizedBox(height: 8),
                  Text('StanDiag Call · Incoming',
                      style: AppTypography.body,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ],
              ),
            ),

            // Accept / Decline buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, 0, AppSpacing.xxl, 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  GestureDetector(
                    onTap: () => context.go(RouteNames.mechanicHome),
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0x12FFFFFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.call_end_rounded,
                              color: AppColors.textMuted, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text('Decline',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                  // Accept
                  GestureDetector(
                    onTap: () => context.go(RouteNames.mechanicActiveCall),
                    child: Column(
                      children: [
                        Container(
                          width: 64, height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x664CAF50),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.call_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text('Accept',
                            style: AppTypography.caption,
                            overflow: TextOverflow.ellipsis, maxLines: 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}