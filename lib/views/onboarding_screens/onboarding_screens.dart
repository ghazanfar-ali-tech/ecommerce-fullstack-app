import 'package:ecommerceapp/resources/images.dart';
import 'package:ecommerceapp/views/auth_screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  bool isLastPage = false;
  late AnimationController _animationController;

  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;

  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final box = Hive.box('app');
    await box.put('onboardingDone', true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => isLastPage = index == 2);
              _animationController.forward(from: 0);
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildPage(index);
            },
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color(0xFFFF5722),
                    dotColor: Colors.white,
                    dotHeight: 8,
                    dotWidth: 8,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _finishOnboarding,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLastPage) {
                            _finishOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index) {
    final pages = [
      {
        'image': AppImages.onboarding1,
        'title': 'Join the Community',
        'subtitle':
            'Join our community of fashion enthusiasts. Get inspired, get fashion, and connect with others.Elevate your style with tips and ideas.',
      },
      {
        'image': AppImages.onboarding2,
        'title': 'Welcome to oxShop',
        'subtitle':
            'Discover the best clothing and accessories at your fingertips.Shop the latest trends anytime, anywhere. Upgrade your wardrobe with style and ease.',
      },
      {
        'image': AppImages.onboarding3,
        'title': 'SALE UP TO 50% OFF',
        'subtitle':
            'Get exclusive offers and discounts on your favorite items. Save more while enjoying the latest trends. Unlock rewards and perks just for you.',
      },
    ];

    return _OnboardPage(
      image: pages[index]['image']!,
      title: pages[index]['title']!,
      subtitle: pages[index]['subtitle']!,
      titleSlide: _titleSlide,
      titleFade: _titleFade,
      subtitleSlide: _subtitleSlide,
      subtitleFade: _subtitleFade,
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  final Animation<Offset> titleSlide;
  final Animation<double> titleFade;

  final Animation<Offset> subtitleSlide;
  final Animation<double> subtitleFade;

  const _OnboardPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.titleSlide,
    required this.titleFade,
    required this.subtitleSlide,
    required this.subtitleFade,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(image, fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 5),
                FadeTransition(
                  opacity: titleFade,
                  child: SlideTransition(
                    position: titleSlide,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: subtitleFade,
                  child: SlideTransition(
                    position: subtitleSlide,
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}