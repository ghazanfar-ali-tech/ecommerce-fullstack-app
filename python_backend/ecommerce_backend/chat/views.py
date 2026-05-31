# ============================================================
# chat/views.py — Updated with Grok AI Integration
# ============================================================

import os
import json
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import ChatSession, ChatMessage
from .serializers import ChatMessageSerializer
from groq import Groq
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parent.parent / '.env')


# ── Firebase Setup ───────────────────────────────────────────
import firebase_admin
from firebase_admin import credentials, firestore

if not firebase_admin._apps:
    cred = credentials.Certificate(
        os.path.join(settings.BASE_DIR, 'firebase_credentials.json')
    )
    firebase_admin.initialize_app(cred)

db = firestore.client()

# ── Grok Client ───────────────────────────────────────────────
groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))

# ── Fetch Products from Firestore ─────────────────────────────
def get_products_context():
    try:
        products_ref = db.collection('products')
        docs = products_ref.stream()

        product_list = []
        for doc in docs:
            data = doc.to_dict()

            name        = data.get('productName', 'Unknown')
            price       = data.get('productPrice', 'N/A')
            category    = data.get('categoryName', 'General')
            description = data.get('productDescription', '')
            discount    = data.get('productDiscount', 0)

            if discount and int(discount) > 0:
                discounted = int(price) - (int(price) * int(discount) / 100)
                price_text = f"Rs {int(discounted)} (was Rs {price}, {discount}% off)"
            else:
                price_text = f"Rs {price}"

            product_list.append(
                f"- {name} | Category: {category} | Price: {price_text} | {description[:60]}..."
            )

        if not product_list:
            return "No products currently available."

        return "\n".join(product_list)

    except Exception as e:
        print(f"Firebase fetch error: {e}")
        return "Product information temporarily unavailable."


# ── Build System Prompt ───────────────────────────────────────
def build_system_prompt():
    products_context = get_products_context()

    return f"""You are a helpful customer support assistant for an online ecommerce shopping app in Pakistan.

AVAILABLE PRODUCTS IN OUR STORE:
{products_context}

STORE INFORMATION:
- Currency: PKR (Pakistani Rupees)
- Payment methods: Safepay and Stripe
- USD to PKR rate: approximately 280 PKR per dollar

YOU CAN HELP WITH:
- Product questions (features, price, availability, category)
- Order tracking (ask for order ID if needed)
- Payment issues (Safepay, Stripe)
- Returns and refunds
- General shopping support

RULES:
- Only recommend products from the list above
- Keep replies short, friendly and helpful
- If a product is out of stock, suggest alternatives from the list
- Always respond in the same language the user writes in
- Ask ONE question at a time if you need more info
- Never say you are an AI language model
- If you truly don't know something, say "Please contact our support team"
"""


# ── API Views ─────────────────────────────────────────────────

class ChatSendAPIView(APIView):
    def post(self, request, *args, **kwargs):
        text       = request.data.get('text')
        session_id = request.data.get('session_id')

        if not text:
            return Response(
                {'error': 'text field is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Get or create session
        if session_id:
            try:
                session = ChatSession.objects.get(id=session_id)
            except ChatSession.DoesNotExist:
                session = ChatSession.objects.create(id=session_id)
        else:
            session = ChatSession.objects.create()

        # Save user message
        user_message = ChatMessage.objects.create(
            session=session,
            sender='user',
            text=text
        )

        # Build conversation history (last 6 messages)
        previous_messages = ChatMessage.objects.filter(
            session=session
        ).order_by('timestamp')[:6]

        # Format history for Grok
        conversation_messages = [
            {"role": "system", "content": build_system_prompt()}
        ]

        for msg in previous_messages:
            role = "user" if msg.sender == "user" else "assistant"
            conversation_messages.append({
                "role": role,
                "content": msg.text
            })

        # Add current user message
        conversation_messages.append({
            "role": "user",
            "content": text
        })

        # ── Call Grok ─────────────────────────────────────────
        # ── Call Grok ─────────────────────────────────────────────
        try:
            response = groq_client.chat.completions.create(
                model="llama-3.1-8b-instant",  # ← replace llama3-8b-8192
                messages=conversation_messages,
                temperature=0.7,
                max_tokens=200,
            )
            bot_text = response.choices[0].message.content

        except Exception as e:
            print(f"Groq API error: {e}")  # ← change from "Grok API error"
            bot_text = "AI service is currently unavailable. Please try again later."

        # Save bot message
        bot_message = ChatMessage.objects.create(
            session=session,
            sender='bot',
            text=bot_text.strip()
        )

        return Response({
            'session_id': str(session.id),
            'user_message': ChatMessageSerializer(user_message).data,
            'bot_message':  ChatMessageSerializer(bot_message).data,
        }, status=status.HTTP_200_OK)


class ChatHistoryAPIView(APIView):
    def get(self, request, session_id, *args, **kwargs):
        try:
            session = ChatSession.objects.get(id=session_id)
        except ChatSession.DoesNotExist:
            return Response(
                {'error': 'Session not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        messages   = ChatMessage.objects.filter(session=session).order_by('timestamp')
        serializer = ChatMessageSerializer(messages, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)