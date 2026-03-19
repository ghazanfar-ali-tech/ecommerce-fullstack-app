import 'dart:math' as math;
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/address_view_model.dart';
import 'package:ecommerceapp/view_model/order_view_model.dart';
import 'package:ecommerceapp/view_model/profile_view_model.dart';
import 'package:ecommerceapp/view_model/setting_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/profile_screen/address_screen/address_screen.dart';
import 'package:ecommerceapp/views/profile_screen/edit_profile_screen.dart';
import 'package:ecommerceapp/views/profile_screen/my_orders/order_history_screen.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/components/auroraPainter.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/components/blobPainter.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/components/dot_grid_painter.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/components/onetimeSweepPainter.dart';
import 'package:ecommerceapp/views/profile_screen/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  late AnimationController _listCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _avatarCtrl;
  late AnimationController _shineCtrl;   
  late Animation<double>   _avatarScale;

  late AnimationController _auroraCtrl;
late Animation<double> _aurora;

  @override
  void initState() {
    super.initState();
_auroraCtrl = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 2000),
);
_aurora = CurvedAnimation(parent: _auroraCtrl, curve: Curves.easeInOut);
    _listCtrl   = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900));
    _floatCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _avatarCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 600));
    _shineCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 2400))..repeat();

    _avatarScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auroraCtrl.forward();
      Provider.of<SettingViewModel>(context, listen: false).fetchUserProfile();
      Provider.of<OrderViewModel>(context, listen: false).fetchOrders();
      _avatarCtrl.forward();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _listCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _auroraCtrl.dispose();
    _listCtrl.dispose();
    _floatCtrl.dispose();
    _avatarCtrl.dispose();
    _shineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);

    return Consumer<SettingViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: vm.isLoading
              ? _buildShimmer(context)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [

                   
                    SliverAppBar(
                      pinned: true,
                      expandedHeight: 0,
                      backgroundColor: AppColors.background(context),
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      title: Text('Profile',
                          style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      actions: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                              context, _slideRoute(const SettingsScreen())),
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.border(context), width: 0.5),
                            ),
                            child: Icon(Icons.settings_rounded,
                                color: AppColors.textPrimary(context), size: 18),
                          ),
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                        child: _buildProfileCard(context, vm, profileVM)),
                    SliverToBoxAdapter(child: _buildStatsRow(context)),

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _buildSection(context, 0, 'My Account', [
                              _tile(context, 0,
                                  icon: Icons.shopping_bag_outlined,
                                  iconColor:  const Color(0xFF0284C7),
                                  title: 'My Orders',
                                  subtitle: 'Track and manage orders',
                                  onTap: () => Navigator.push(context,
                                      _slideRoute(OrderHistoryScreen()))),
                              _divider(context),
                              _tile(context, 1,
                                  icon: Icons.location_on_outlined,
                                  iconColor: const Color(0xFF0284C7),
                                  title: 'Shipping Address',
                                  subtitle: 'Manage delivery addresses',
                                  onTap: () => Navigator.push(
                                      context, _slideRoute(AddressScreen()))),
                            ]),

                            _buildSection(context, 1, 'Support & Legal', [
                              _tile(context, 2,
                                  icon: Icons.help_outline_rounded,
                                   iconColor: const Color(0xFF0284C7),
                                  title: 'Help Center',
                                  subtitle: 'FAQs and support',
                                  onTap: () {}),
                              _divider(context),
                              _tile(context, 3,
                                  icon: Icons.settings_outlined,
                                  iconColor: const Color(0xFF0284C7),
                                  title: 'Settings',
                                  subtitle: 'Notifications and preferences',
                                  onTap: () => Navigator.push(context,
                                      _slideRoute(const SettingsScreen()))),
                            ]),

                            _buildSection(context, 2, '', [
                              _tile(context, 4,
                                  icon: Icons.logout_rounded,
                                  iconColor: AppColors.error,
                                  title: 'Log Out',
                                  subtitle: 'Sign out of your account',
                                  isDestructive: true,
                                  onTap: () async {
                                    context
                                        .read<SettingViewModel>()
                                        .clearProfile();
                                    await profileVM.logout(context);
                                  }),
                            ]),

                            const SizedBox(height: 100),
                          ],
                          addAutomaticKeepAlives: false,
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildProfileCard(BuildContext context, SettingViewModel vm,
      ProfileViewModel profileVM) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.primaryShadow,
        ),
        child: Stack(
          children: [
            Positioned(right: -8, top: -8,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => CustomPaint(
                  painter: BlobPainter(progress: _floatCtrl.value),
                  size: const Size(100, 100),
                ),
              ),
            ),
            Positioned(left: 0, bottom: 0,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => Opacity(
                  opacity: 0.1 + _floatCtrl.value * 0.08,
                  child: CustomPaint(
                    painter: DotGridPainter(),
                    size: const Size(80, 50),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                ScaleTransition(
                  scale: _avatarScale,
                  child: Stack(
                    children: [
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.6), width: 2.5),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: ClipOval(
                          child: vm.profilePhotoUrl != null
                              ? Image.network(vm.profilePhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _fallback())
                              : _fallback(),
                        ),
                      ),
                      Positioned(bottom: 2, right: 2,
                        child: Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vm.username ?? '—',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2)),
                      const SizedBox(height: 3),
                      Text(vm.userGamil ?? '',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                          _slideRoute(ChangeNotifierProvider.value(
                            value: vm, child: EditProfileScreen()))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 5),
                              Text('Edit Profile',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: Colors.white.withOpacity(0.15),
        child: const Icon(Icons.person_rounded, color: Colors.white, size: 36));

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Consumer<OrderViewModel>(
            builder: (_, vm, __) =>
                _statChip(context, 0, '${vm.orders.length}', 'Orders')),
          const SizedBox(width: 10),
          Consumer<AddressViewModel>(
            builder: (_, vm, __) =>
                _statChip(context, 1, '${vm.addresses.length}', 'Addresses')),
          const SizedBox(width: 10),
          Consumer<StoreViewModel>(
            builder: (_, vm, __) =>
                _statChip(context, 2, '${vm.favList.length}', 'Wishlist')),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, int index, String value, String label) {
    final delay = index * 0.15;
    return Expanded(
      child: AnimatedBuilder(
        animation: _listCtrl,
        builder: (_, child) {
          final raw      = (_listCtrl.value - delay) / (1.0 - delay);
          final progress = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
          return Opacity(
            opacity: progress,
            child: Transform.translate(
                offset: Offset(0, 16 * (1 - progress)), child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context), width: 0.5),
            boxShadow: [BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (b) =>
                    AppColors.primaryGradient.createShader(b),
                child: Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: AppColors.textSecondary(context), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildSection(BuildContext context, int index,
    String title, List<Widget> items) {
  final delay = 0.1 + index * 0.18;

  return AnimatedBuilder(
    animation: _listCtrl,
    builder: (context, child) {
      final raw      = (_listCtrl.value - delay) / (1.0 - delay);
      final progress = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
      return Opacity(
        opacity: progress,
        child: Transform.translate(
            offset: Offset(0, 24 * (1 - progress)), child: child),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title,
                style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6)),
          ),

        AnimatedBuilder(
          animation: _aurora,
          builder: (_, child) => ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                child!,
             
                Positioned.fill(
                  child: CustomPaint(
                    painter: AuroraPainter(
                      progress: _aurora.value,
                      sectionIndex: index,
                    ),
                  ),
                ),
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.border(context), width: 0.5),
              boxShadow: [BoxShadow(
                  color: AppColors.shadow(context),
                  blurRadius: 10,
                  offset: const Offset(0, 2))],
            ),
            child: Column(children: items),
          ),
        ),
      ],
    ),
  );
}

  Widget _tile(BuildContext context, int index, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [

AnimatedBuilder(
  animation: _aurora,
  builder: (_, __) {
    final phase   = (index * 0.12);
    final t       = ((_aurora.value - phase) / (1.0 - phase)).clamp(0.0, 1.0);
    final color   = isDestructive ? AppColors.error : iconColor;

    return Stack(
      children: [
    Container(
  width: 40, height: 40,
  decoration: BoxDecoration(

    color: isDestructive
        ? AppColors.error
        : color.withAlpha(220),
    borderRadius: BorderRadius.circular(11),
    border: Border.all(
      color: Colors.white.withOpacity(0.18),
      width: 0.8,
    ),
    boxShadow: [
   
      BoxShadow(
        color: color.withOpacity(0.45),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    
      BoxShadow(
        color: Colors.white.withOpacity(0.2),
        blurRadius: 4,
        spreadRadius: -2,
        offset: const Offset(0, -2),
      ),
    ],
  ),
  child: Icon(
    icon,
    color: Colors.white, 
    size: 19,
  ),
),


        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(
            width: 40, height: 40,
            child: CustomPaint(
              painter: OneTimeSweepPainter(
                progress: t,
                iconColor: color,
              ),
            ),
          ),
        ),
      ],
    );
  },
),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: isDestructive
                                ? AppColors.error
                                : AppColors.textPrimary(context),
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

          
              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                      2 * math.sin(
                          (_floatCtrl.value + index * 0.15) * math.pi), 0),
                  child: child,
                ),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: isDestructive
                        ? AppColors.error.withOpacity(0.5)
                        : AppColors.textHint(context),
                    size: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) => Divider(
      height: 1, indent: 68, endIndent: 0,
      color: AppColors.border(context), thickness: 0.5);

  PageRouteBuilder _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(
                  parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );

  Widget _buildShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E1E26) : Colors.grey[300]!,
      highlightColor: isDark ? const Color(0xFF2A2A35) : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 130,
                decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20))),
            const SizedBox(height: 12),
            Row(children: List.generate(3, (i) => Expanded(
              child: Container(
                height: 70,
                margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                decoration: BoxDecoration(color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(14)),
              ),
            ))),
            const SizedBox(height: 20),
            ...List.generate(2, (si) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 80, height: 10,
                    margin: const EdgeInsets.only(bottom: 8, left: 4),
                    decoration: BoxDecoration(color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5))),
                Container(height: 120,
                    decoration: BoxDecoration(color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(16))),
                const SizedBox(height: 20),
              ],
            )),
          ],
        ),
      ),
    );
  }
}












