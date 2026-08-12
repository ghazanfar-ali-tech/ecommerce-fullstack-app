import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/views/auth_screens/forgot_password_screen.dart';
import 'package:ecommerceapp/views/bottom_navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:ecommerceapp/resources/components/custom_field.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isSmall = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height * (isSmall ? 0.38 : 0.42),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * (isSmall ? 0.28 : 0.32),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: size.height * 0.01,
                        child: SizedBox(
                          width: size.width * 0.55,
                          height: size.height * 0.22,
                          child: Lottie.asset(
                            'assets/Animation - 1743764351883.json',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: isSmall ? 4 : 10,
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.055,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sign in to continue shopping',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: size.width * 0.032,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow(context),
                          blurRadius: 24,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: size.width * 0.06,
                        right: size.width * 0.06,
                        top: size.height * 0.025,
                        bottom:
                            MediaQuery.of(context).viewInsets.bottom +
                            padding.bottom +
                            20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.border(context),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.025),

                          Consumer<AuthViewModel>(
                            builder: (context, model, _) {
                              return Container(
                                height: 49,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant(context),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.border(context),
                                    width: 0.8,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedAlign(
                                      duration: const Duration(
                                        milliseconds: 530,
                                      ),
                                      curve: Curves.easeInOut,
                                      alignment: model.isLoginSelected
                                          ? Alignment.centerLeft
                                          : Alignment.centerRight,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.5,
                                        child: Container(
                                          margin: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius: BorderRadius.circular(
                                              11,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.primary
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: model.selectLogin,
                                            behavior: HitTestBehavior.opaque,
                                            child: Center(
                                              child: Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: size.width * 0.038,
                                                  fontWeight: FontWeight.w600,
                                                  color: model.isLoginSelected
                                                      ? Colors.white
                                                      : AppColors.textSecondary(
                                                          context,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: model.selectSignIn,
                                            behavior: HitTestBehavior.opaque,
                                            child: Center(
                                              child: Text(
                                                'Sign Up',
                                                style: TextStyle(
                                                  fontSize: size.width * 0.038,
                                                  fontWeight: FontWeight.w600,
                                                  color: !model.isLoginSelected
                                                      ? Colors.white
                                                      : AppColors.textSecondary(
                                                          context,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(height: size.height * 0.03),

                          Consumer<AuthViewModel>(
                            builder: (context, model, _) {
                              return Form(
                                key: _formkey,
                                child: Column(
                                  children: [
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: model.isLoginSelected
                                          ? const SizedBox.shrink()
                                          : Column(
                                              children: [
                                                customField(
                                                  context: context,
                                                  controller: context
                                                      .read<AuthViewModel>()
                                                      .usernameController,
                                                  hintName: 'Full name',
                                                  icon: Icons.person_outline,
                                                  labelText: 'Name',
                                                  validator: (v) => v!.isEmpty
                                                      ? 'Enter your name'
                                                      : null,
                                                ),
                                                SizedBox(
                                                  height: size.height * 0.016,
                                                ),
                                              ],
                                            ),
                                    ),

                                    customField(
                                      context: context,
                                      controller: context
                                          .read<AuthViewModel>()
                                          .emailController,
                                      hintName: 'Email address',
                                      icon: Icons.email_outlined,
                                      labelText: 'Email',
                                      validator: (v) =>
                                          v!.isEmpty ? 'Enter email' : null,
                                    ),
                                    SizedBox(height: size.height * 0.016),

                                    customField(
                                      obscure: model.obscurePassword,
                                      onToggleObscure:
                                          model.togglePasswordVisibility,
                                      context: context,
                                      controller: context
                                          .read<AuthViewModel>()
                                          .passwordController,
                                      hintName: 'Password',
                                      labelText: 'Password',
                                      icon: Icons.lock_outline_rounded,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Enter password' : null,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ForgotPasswordScreen(),
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 2,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: AppColors.primaryText(context),
                                  fontSize: size.width * 0.033,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 0.018),

                          Consumer<AuthViewModel>(
                            builder: (context, model, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: AppColors.primaryShadow,
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: () {
                                        if (model.isLoginSelected) {
                                          model.login(
                                            context,
                                            context
                                                .read<NotificationViewModel>(),
                                          );
                                        } else {
                                          model.signUp(
                                            context,
                                            context
                                                .read<NotificationViewModel>(),
                                          );
                                        }
                                      },
                                      child: Center(
                                        child: model.loading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                child: Text(
                                                  model.isLoginSelected
                                                      ? 'Login'
                                                      : 'Create Account',
                                                  key: ValueKey(
                                                    model.isLoginSelected,
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize:
                                                        size.width * 0.042,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: size.height * 0.025),

                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: AppColors.border(context),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: size.width * 0.03,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: AppColors.border(context),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.022),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                assetPath: 'assets/google.png',
                                label: 'Google',
                                size: size,
                                context: context,
                                onTap: () async {
                                  final user = await context
                                      .read<AuthViewModel>()
                                      .loginWithGoogle(context);
                                  if (user != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BottomNavigation(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AuthScreen(),
                                      ),
                                    );
                                  }
                                },
                              ),
                              SizedBox(width: size.width * 0.04),

                              _SocialButton(
                                assetPath: 'assets/facebook.png',
                                label: 'Facebook',
                                size: size,
                                context: context,
                                onTap: () async {
                                  // final user = await context
                                  //     .read<AuthViewModel>()
                                  //     .loginWithFacebook(context);
                                  // if (user != null) {
                                  //   Navigator.pushReplacement(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //       builder: (_) => BottomNavigation(),
                                  //     ),
                                  //   );
                                  // }
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.assetPath,
    required this.label,
    required this.size,
    required this.context,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final Size size;
  final BuildContext context;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.38,
        height: 50,
       decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(13),
  border: Border.all(color: AppColors.border(context), width: 0.8),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ],
),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Image.asset(assetPath, width: 22, height: 22, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
