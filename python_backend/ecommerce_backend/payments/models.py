from django.db import models

class Order(models.Model):
    """
    Order model to track user orders and payment status
    """
    user_id = models.CharField(max_length=100)
    amount = models.IntegerField()  # in PKR
    payment_status = models.CharField(max_length=20, default="pending")  # pending / paid / failed
    order_status = models.CharField(max_length=20, default="pending")    # optional future use
    created_at = models.DateTimeField(auto_now_add=True)
