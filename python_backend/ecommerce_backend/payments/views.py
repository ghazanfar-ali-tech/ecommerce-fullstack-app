import requests
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.conf import settings
from .models import Order

SAFEPAY_PUBLIC = settings.SAFEPAY_PUBLIC
SAFEPAY_SECRET = settings.SAFEPAY_SECRET
SAFEPAY_BASE_URL = "https://sandbox.api.getsafepay.com"

@api_view(['POST'])
def create_payment(request):
    amount = request.data.get('amount')
    user_id = request.data.get('user_id')

    print(f"Received request - amount: {amount}, user_id: {user_id}")
    
    if not user_id or not amount:
        return Response({"error": "user_id and amount are required"}, status=400)

    # Step 1: Save order with pending status
    order = Order.objects.create(user_id=user_id, amount=amount)
    print(f"Order created: {order.id}")

    try:
        # Step 2: Create order with Safepay - WITH CARD PAYMENT ENABLED
        init_res = requests.post(
            f"{SAFEPAY_BASE_URL}/order/v1/init",
            headers={
                "Content-Type": "application/json"
            },
            json={
                "client": SAFEPAY_PUBLIC,
                "amount": float(amount),
                "currency": "PKR",
                "environment": "sandbox",
                "intent": "cybersource",
                "mode": "payment"
            },
            timeout=10
        )
        
        print(f"Init response status: {init_res.status_code}")
        print(f"Init response body: {init_res.text}")

        if init_res.status_code != 200:
            return Response({
                "error": "Payment initialization failed",
                "details": init_res.json()
            }, status=400)

        init_data = init_res.json()
        data = init_data.get('data')
        
        if not data:
            return Response({
                "error": "Invalid response structure",
                "details": init_data
            }, status=400)

        # FIX: The token is directly in 'data', not nested in 'tracker'
        tracker = data.get('token')

        if not tracker:
            print(f"Tracker token missing in response: {init_data}")
            return Response({
                "error": "Tracker token not found in response",
                "details": init_data
            }, status=400)

        print(f"Payment order created - tracker: {tracker}")
        
        return Response({
            "tracker": tracker,
            "token": tracker,
            "order_id": order.id
        })

    except requests.exceptions.RequestException as e:
        print(f"Request exception: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({"error": f"Network error: {str(e)}"}, status=500)
    except Exception as e:
        print(f"Exception occurred: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)


@api_view(['POST'])
def verify_payment(request):
    tracker = request.data.get('tracker')
    order_id = request.data.get('order_id')

    print(f"Verifying payment - tracker: {tracker}, order_id: {order_id}")

    if not tracker or not order_id:
        return Response({"error": "tracker and order_id are required"}, status=400)

    try:
        # Verify the payment with Safepay
        verify_res = requests.post(
            f"{SAFEPAY_BASE_URL}/order/v1/track",
            headers={
                "Content-Type": "application/json"
            },
            json={
                "tracker": tracker,
                "secret": SAFEPAY_SECRET
            },
            timeout=10
        )
        
        print(f"Verify response status: {verify_res.status_code}")
        print(f"Verify response body: {verify_res.text}")

        if verify_res.status_code != 200:
            return Response({
                "error": "Payment verification failed",
                "details": verify_res.json()
            }, status=400)

        result = verify_res.json()
        data = result.get('data', {})
        
        # Check the payment state
        state = data.get('state', '').upper()

        # Update order status
        order = Order.objects.get(id=order_id)
        
        if state == "PAID":
            order.payment_status = "paid"
        elif state in ["FAILED", "CANCELLED"]:
            order.payment_status = "failed"
        else:
            order.payment_status = "pending"
            
        order.save()

        print(f"Order {order_id} updated to status: {order.payment_status}")

        return Response({"status": order.payment_status})

    except Order.DoesNotExist:
        return Response({"error": "Order not found"}, status=404)
    except Exception as e:
        print(f"Exception during verification: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response({"error": str(e)}, status=500)