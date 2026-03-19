import 'dart:math' as math;
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/app_version_info.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/view_model/theme_provider.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/privacy_and_policy_screen.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {

  late AnimationController _heroCtrl;
  late AnimationController _listCtrl;
  late AnimationController _floatCtrl;
  late Animation<double>   _heroFade;
  late Animation<Offset>   _heroSlide;

  @override
  void initState() {
    super.initState();
    _heroCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _listCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);

    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _listCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [

       
          SliverToBoxAdapter(child: _buildHero(context)),

        
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(context, 0,     _buildAppearanceItems(context)),
                _buildSection(context, 1, _buildNotificationItems(context)),
                _buildSection(context, 2,        _buildPrivacyItems(context)),
                _buildSection(context, 3,           _buildAboutItems(context)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return SlideTransition(
      position: _heroSlide,
      child: FadeTransition(
        opacity: _heroFade,
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20, right: 20, bottom: 24,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Stack(
            children: [

           
              Positioned(
                right: -10, top: -10,
                child: AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _BlobPainter(progress: _floatCtrl.value),
                    size: const Size(120, 120),
                  ),
                ),
              ),

       
              Positioned(
                left: 0, bottom: 0,
                child: AnimatedBuilder(
                  animation: _floatCtrl,
                  builder: (_, __) => Opacity(
                    opacity: 0.15 + _floatCtrl.value * 0.1,
                    child: CustomPaint(
                      painter: _DotGridPainter(),
                      size: const Size(100, 60),
                    ),
                  ),
                ),
              ),

        
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 0.8),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Settings',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3)),
                        Text('Manage your preferences',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13)),
                      ],
                    ),
                  ),

                 
                  AnimatedBuilder(
                    animation: _floatCtrl,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, -3 * _floatCtrl.value + 1.5),
                      child: child,
                    ),
             
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildSection(BuildContext context, int sectionIndex,
       List<Widget> items) {
    final delay = sectionIndex * 0.18;

    return AnimatedBuilder(
      animation: _listCtrl,
      builder: (context, child) {
        final raw      = (_listCtrl.value - delay) / (1.0 - delay);
        final progress = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - progress)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

     

          const SizedBox(height: 10),

       
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(context), width: 0.5),
              boxShadow: [
                BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 12,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppearanceItems(BuildContext context) {
    return [
      _buildSwitchTile(
        context,
        icon: Icons.dark_mode_rounded,
        iconColor: const Color(0xFF003DB5),
        title: 'Dark Mode',
        subtitle: 'Switch between light and dark',
        value: context.watch<ThemeProvider>().isDark,
        onChanged: (v) => context.read<ThemeProvider>().toggleTheme(v),
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildNotificationItems(BuildContext context) {
    return [
      _buildSwitchTile(
        context,
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFF0284C7),
        title: 'Push Notifications',
        subtitle: 'Orders, offers and updates',
        value: context.watch<NotificationViewModel>().isEnabled,
        onChanged: (v) => context.read<NotificationViewModel>().togglePush(v),
      ),
      _buildDivider(context),
      _buildSwitchTile(
        context,
        icon: Icons.email_rounded,
        iconColor: const Color(0xFF0057E7),
        title: 'Email Notifications',
        subtitle: 'Newsletters and receipts',
        value: context.watch<NotificationViewModel>().isEmailNotification,
        onChanged: (v) => context.read<NotificationViewModel>().setEmailNotification(v),
        isLast: true,
      ),
    ];
  }
  List<Widget> _buildPrivacyItems(BuildContext context) {
    return [
      _buildNavTile(
        context,
        icon: Icons.privacy_tip_rounded,
        iconColor: const Color(0xFF003DB5),
        title: 'Privacy Policy',
        subtitle: 'How we handle your data',
        onTap: () => Navigator.push(context,
            _slideRoute(const PrivacyPolicyScreen())),
      ),
      _buildDivider(context),
      _buildNavTile(
        context,
        icon: Icons.article_rounded,
        iconColor: const Color(0xFF0284C7),
        title: 'Terms of Service',
        subtitle: 'Rules and conditions of use',
        onTap: () => Navigator.push(context,
            _slideRoute(const TermsOfServiceScreen())),
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildAboutItems(BuildContext context) {
    return [
      Consumer<AppVersionInfoViewModel>(
        builder: (context, vm, _) => _buildInfoTile(
          context,
          icon: Icons.rocket_launch_rounded,
          iconColor: const Color(0xFFFF6B35),
          title: 'App Version',
          value: '${vm.packageInfo.version}+${vm.packageInfo.buildNumber}',
          isLast: true,
        ),
      ),
    ];
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12)),
              ],
            ),
          ),
          _GradientSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _iconBadge(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.primaryText(context), size: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _iconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: AppColors.border(context),
      thickness: 0.5,
    );
  }

  PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}

class _GradientSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GradientSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 48,
        height: 27,
        decoration: BoxDecoration(
          gradient: value ? AppColors.primaryGradient : null,
          color: value ? null : AppColors.border(context),
          borderRadius: BorderRadius.circular(14),
          boxShadow: value
              ? AppColors.primaryShadow
              : [],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 21, height: 21,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double progress;
  _BlobPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final path = Path();
    const pts = 8;
    for (int i = 0; i <= pts; i++) {
      final a = (i / pts) * 2 * math.pi;
      final r = 44 +
          14 * math.sin(a * 3 + progress * math.pi * 2) +
          8  * math.cos(a * 2 + progress * math.pi);
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.progress != progress;
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    const cols = 5;
    const rows = 3;
    final gx = size.width  / cols;
    final gy = size.height / rows;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
            Offset(gx * c + gx / 2, gy * r + gy / 2), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => false;
}