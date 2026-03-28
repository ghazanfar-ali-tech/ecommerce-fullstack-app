import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


Color _base(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A2540)
        : Colors.grey[300]!;

Color _highlight(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2E3D5C)
        : Colors.grey[100]!;

Color _baseSmall(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1A2540)
        : Colors.grey[200]!;

Color _hlSmall(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF3B4F70)
        : Colors.white;

Color _card(BuildContext context) => AppColors.cardBackground(context);

Widget _block(
  BuildContext context, {
  required double height,
  double? width,
  double radius = 6,
  bool small = false,
}) =>
    Shimmer.fromColors(
      baseColor: small ? _baseSmall(context) : _base(context),
      highlightColor: small ? _hlSmall(context) : _highlight(context),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );


Widget buildProductGridShimmer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    color: isDark ? const Color(0xFF090E1A) : Colors.grey[50],
    padding: const EdgeInsets.all(16),
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.68,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _card(context),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
         
              Shimmer.fromColors(
                baseColor: _base(context),
                highlightColor: _highlight(context),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: _card(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    _block(context, height: 13, radius: 6),
                    const SizedBox(height: 7),
                  
                    _block(context, height: 13, width: 90, radius: 6),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    
                        _block(context, height: 16, width: 52,
                            radius: 6, small: true),
                      
                        _block(context, height: 32, width: 32,
                            radius: 9, small: true),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}


Widget buildFeaturedBrandsShimmer(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Row(
          children: [

            Shimmer.fromColors(
              baseColor: _base(context),
              highlightColor: _highlight(context),
              child: Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: _card(context),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
   
            _block(context, height: 16, width: 140, radius: 6),
          ],
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(4, (_) => _shimmerBrandCard(context)),
        ),
        const SizedBox(height: 16),
      ],
    ),
  );
}

Widget _shimmerBrandCard(BuildContext context) {
  return Container(
    width: 150,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _card(context),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border(context)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Shimmer.fromColors(
          baseColor: _base(context),
          highlightColor: _highlight(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _card(context),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
  
            _block(context, height: 12, width: 60, radius: 5),
            const SizedBox(height: 5),
 
            _block(context, height: 10, width: 48, radius: 5, small: true),
          ],
        ),
      ],
    ),
  );
}


Widget buildShimmerTab(BuildContext context) {
  return Container(
    height: 44,
    color: AppColors.cardBackground(context),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: Row(
      children: List.generate(4, (i) {
     
        final widths = [68.0, 80.0, 60.0, 74.0];
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
         
              Shimmer.fromColors(
                baseColor: _base(context),
                highlightColor: _highlight(context),
                child: Container(
                  height: 13,
                  width: widths[i],
                  decoration: BoxDecoration(
                    color: _card(context),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 6),
           
              Shimmer.fromColors(
                baseColor: _baseSmall(context),
                highlightColor: _hlSmall(context),
                child: Container(
                  height: 2,
                  width: widths[i] * 0.6,
                  decoration: BoxDecoration(
                    color: _card(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}



Widget buildImageShimmer(double height) {
  return Builder(
    builder: (context) => Shimmer.fromColors(
      baseColor: _base(context),
      highlightColor: _highlight(context),
      child: Container(
        height: height,
        width: double.infinity,
        color: _card(context),
      ),
    ),
  );
}