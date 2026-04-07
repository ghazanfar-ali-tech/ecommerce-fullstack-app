import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ecommerceapp/models/product_review_model.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/home_view_model.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewDialog extends StatefulWidget {
  final String productId;
  final ProductReview? existingReview; 

  const ReviewDialog({
    super.key,
    required this.productId,
    this.existingReview,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final TextEditingController commentCtrl = TextEditingController();
  int rating = 5;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      rating = widget.existingReview!.rating;
      commentCtrl.text = widget.existingReview!.comment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final homeVM = context.read<HomeViewModel>();
    final reviewVM = context.read<ProductReviewViewModel>();

    if (user == null) {
      return const Center(child: Text("Please login to add a review"));
    }

   return AlertDialog(
  backgroundColor: AppColors.cardBackground(context),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Text(
    widget.existingReview != null ? "Edit Review" : "Add Review",
    style: TextStyle(
      color: AppColors.textPrimary(context),
      fontWeight: FontWeight.bold,
    ),
  ),

  content: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      DropdownButtonHideUnderline(
        child: DropdownButton2<int>(
          value: rating,
          isExpanded: true,

          items: List.generate(
            5,
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Row(
                children: List.generate(
                  i + 1,
                  (index) => Icon(Icons.star,
                      size: 18, color: const Color(0xFFFFD000)),
                ),
              ),
            ),
          ),

          onChanged: (val) {
  if (val != null) {
    setState(() => rating = val);
  }
},

          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border(context)),
            ),
          ),

          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(10),
            ),
            offset: const Offset(0, -5), 
          ),
        ),
      ),

      const SizedBox(height: 16),

  
      TextField(
        controller: commentCtrl,
        maxLines: 3,
        style: TextStyle(color: AppColors.textPrimary(context)),
        decoration: InputDecoration(
          hintText: "Write your review...",
          hintStyle: TextStyle(color: AppColors.textHint(context)),
          filled: true,
          fillColor: AppColors.surfaceVariant(context),
          contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
        ),
      ),
    ],
  ),

  actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

  actions: [

  
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(
        "Cancel",
        style: TextStyle(color: AppColors.textSecondary(context)),
      ),
    ),

   
    Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.primaryShadow,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          final review = ProductReview(
            id: widget.existingReview?.id ?? '',
            productId: widget.productId,
            userId: user.uid,
            userName: homeVM.username ?? "Anonymous",
            rating: rating,
            comment: commentCtrl.text.trim(),
            createdAt: DateTime.now(),
          );

          if (widget.existingReview != null) {
            await reviewVM.editReview(review);
          } else {
            await reviewVM.addReview(review);
          }

         if (mounted) {
  Navigator.pop(context);
}
        },
        child: Text(
          widget.existingReview != null ? "Update" : "Submit",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ],
);
  }
}
