import 'package:ecommerceapp/models/product_review_model.dart';
import 'package:ecommerceapp/view_model/home_view_mode.dart';
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
      title: Text(widget.existingReview != null ? "Edit Review" : "Add Review"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: rating,
            items: List.generate(
              5,
              (i) => DropdownMenuItem(
                value: i + 1,
                child: Text("${i + 1} Stars"),
              ),
            ),
            onChanged: (val) => setState(() => rating = val!),
          ),
          TextField(
            controller: commentCtrl,
            decoration: const InputDecoration(
              hintText: "Write your review",
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),


        // Submit / Update button
        ElevatedButton(
          onPressed: () async {
            final review = ProductReview(
              id: widget.existingReview?.id ?? '', // use existing ID if editing
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

            Navigator.pop(context);
          },
          child: Text(widget.existingReview != null ? "Update" : "Submit"),
        ),
      ],
    );
  }
}
