import requests
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.conf import settings
from .models import Order
from .serializers import OrderSerializer

# Safepay sandbox keys (from environment variables)
SAFEPAY_PUBLIC = settings.SAFEPAY_PUBLIC  # Public key → safe to use in frontend
SAFEPAY_SECRET = settings.SAFEPAY_SECRET  # Secret key → must stay on backend

@api_view(['POST'])
def create_payment(request):
    """
    1️⃣ Create an order in the database
    2️⃣ Get Safepay auth token using secret key
    3️⃣ Create payment session using Safepay public key + auth token
    4️⃣ Return tracker token and auth token to Flutter
    """
    amount = request.data.get('amount')
    user_id = request.data.get('user_id')

    # Step 1: Save order with pending status
    order = Order.objects.create(user_id=user_id, amount=amount)

    try:
        # Step 2: Request Safepay auth token (using secret key)
        auth_res = requests.post(
            "https://sandbox.api.getsafepay.com/order/v1/init",
            headers={"Authorization": f"Bearer {SAFEPAY_SECRET}"}
        )
        auth_token = auth_res.json()['token']

        # Step 3: Create Safepay payment session
        session_res = requests.post(
            "https://sandbox.api.getsafepay.com/payment/v1/session",
            json={
                "merchant_api_key": SAFEPAY_PUBLIC,
                "amount": amount,
                "currency": "PKR",
            },
            headers={
                "Authorization": f"Bearer {auth_token}",
                "Content-Type": "application/json"
            }
        )

        # Step 4: Get tracker token to send to Flutter
        tracker = session_res.json()['tracker']['token']

        # Return tracker & auth token to Flutter
        return Response({
            "tracker": tracker,
            "token": auth_token,
            "order_id": order.id
        })

    except Exception as e:
        # If any step fails, return error to Flutter
        return Response({"error": str(e)})


@api_view(['POST'])
def verify_payment(request):
    """
    1️⃣ Receive tracker & order_id from Flutter
    2️⃣ Verify payment status with Safepay sandbox API
    3️⃣ Update order in DB (paid / failed)
    4️⃣ Return payment status to Flutter
    """
    tracker = request.data.get('tracker')
    order_id = request.data.get('order_id')

    try:
        # Step 2: Verify tracker with Safepay
        verify_res = requests.get(
            f"https://sandbox.api.getsafepay.com/payment/v1/verify/{tracker}",
            headers={"Authorization": f"Bearer {SAFEPAY_SECRET}"}
        )
        result = verify_res.json()

        # Step 3: Update order status
        order = Order.objects.get(id=order_id)
        if result['status'] == "paid":
            order.payment_status = "paid"
        else:
            order.payment_status = "failed"
        order.save()

        # Step 4: Return payment status
        return Response({"status": order.payment_status})

    except Exception as e:
        return Response({"error": str(e)})
