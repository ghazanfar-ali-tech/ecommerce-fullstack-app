import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductRatingStars extends StatefulWidget {
  final String productId;
  const ProductRatingStars({super.key, required this.productId});

  @override
  State<ProductRatingStars> createState() => _ProductRatingStarsState();
}

class _ProductRatingStarsState extends State<ProductRatingStars> {
  double _avgRating = 0.0;
  int _reviewCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchRating();
  }

  Future<void> _fetchRating() async {
    try {
      final vm = context.read<ProductReviewViewModel>();
      await vm.fetchReviewsForProduct(widget.productId);
      if (!mounted) return;
      final reviews = vm.getReviewsForProduct(widget.productId);
      setState(() {
        _reviewCount = reviews.length;
        _avgRating = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                reviews.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        width: 16, height: 16,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    }

  
    if (_reviewCount == 0) {
       return Row(
        
  children: [
    for (int i = 0; i < 4; i++)...[
       Icon(Icons.star_rounded, size: 14,color: Colors.grey.shade300,),
      
    ],
     Text("(0)",style: TextStyle( fontSize: 10,
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w500,),)
  ],
);
    }

    return Row(
      children: [
        ...List.generate(5, (i) => Icon(
          i < _avgRating.round()
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          size: 14,
          color: i < _avgRating.round()
              ? Colors.amber
              : Colors.grey.shade300,
        )),
        const SizedBox(width: 4),
        Text(
          '(${_reviewCount})',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}