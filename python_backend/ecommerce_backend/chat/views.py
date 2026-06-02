
import re
import os
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


import firebase_admin
from firebase_admin import credentials, firestore

if not firebase_admin._apps:
    cred = credentials.Certificate(
        os.path.join(settings.BASE_DIR, 'firebase_credentials.json')
    )
    firebase_admin.initialize_app(cred)

db = firestore.client()


groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))



def get_products_context():
    try:
        products_ref = db.collection('products')
        docs = products_ref.stream()

        product_list = []
        products_data = []

        for doc in docs:
            data = doc.to_dict()

            name        = data.get('productName', 'Unknown')
            price       = data.get('productPrice', 'N/A')
            category    = data.get('categoryName', 'General')
            description = data.get('productDescription', '')
            discount    = data.get('productDiscount', 0)

           
            image_urls_list = data.get('productImageUrls', [])
            image_url = image_urls_list[0] if image_urls_list else ''

            if discount and int(discount) > 0:
                discounted = int(price) - (int(price) * int(discount) / 100)
                price_text = f"Rs {int(discounted)} (was Rs {price}, {discount}% off)"
            else:
                price_text = f"Rs {price}"

            product_list.append(
                f"- {name} | Category: {category} | Price: {price_text} | {description[:60]}..."
            )

            products_data.append({
                'name': name.lower(),
                'image_url': image_url
            })

        if not product_list:
            return "No products currently available.", []

        return "\n".join(product_list), products_data

    except Exception as e:
        print(f"Firebase fetch error: {e}")
        return "Product information temporarily unavailable.", []

def clean_bot_response(text):

    text = re.sub(r'\*\*(.*?)\*\*', r'\1', text)   # **bold** → bold
    text = re.sub(r'\*(.*?)\*', r'\1', text)         # *italic* → italic
    text = re.sub(r'#{1,6}\s*', '', text)            # ## headers
    text = re.sub(r'`(.*?)`', r'\1', text)           # `code`

    
    bad_phrases = [
        "i can't show",
        "i cannot show",
        "i'm unable to display",
        "i am unable to display",
        "text-based platform",
        "can't display images",
        "cannot display images",
        "i can't display",
        "i cannot display",
        "unfortunately, i can't",
        "unfortunately, i cannot",
        "i'm a text-based",
        "i am a text-based",
        "image url",
        "as we are a text",
    ]

    lines = text.split('\n')
    cleaned_lines = []
    for line in lines:
        if not any(phrase in line.lower() for phrase in bad_phrases):
            cleaned_lines.append(line)

    text = '\n'.join(cleaned_lines)

   
    text = re.sub(r'\n{3,}', '\n\n', text)

    return text.strip()

def find_product_images(bot_text, products_data):
    bot_text_lower = bot_text.lower()
    matched_urls = []

    for product in products_data:
        name = product['name']
        image_url = product['image_url']

        if not image_url:
            continue

   
        if name in bot_text_lower:
            matched_urls.append(image_url)
            continue

     
        words = [w for w in name.split() if len(w) > 3]
        if words and all(w in bot_text_lower for w in words):
            matched_urls.append(image_url)

    return matched_urls



def build_system_prompt(products_context):
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
- ALWAYS use the EXACT product name as written in the list above when mentioning any product
- Keep replies short, friendly and helpful
- Always respond in the same language the user writes in
- Ask ONE question at a time if you need more info
- Never say you are an AI language model — you are a shopping assistant
- Never say you cannot display images — just describe the product
- If you truly don't know something, say "Please contact our support team"
"""



class ChatSendAPIView(APIView):
    def post(self, request, *args, **kwargs):
        text       = request.data.get('text')
        session_id = request.data.get('session_id')

        if not text:
            return Response(
                {'error': 'text field is required'},
                status=status.HTTP_400_BAD_REQUEST
            )

      
        if session_id:
            try:
                session = ChatSession.objects.get(id=session_id)
            except ChatSession.DoesNotExist:
                session = ChatSession.objects.create(id=session_id)
        else:
            session = ChatSession.objects.create()

        
        user_message = ChatMessage.objects.create(
            session=session,
            sender='user',
            text=text
        )

      
        products_context, products_data = get_products_context()

        print("PRODUCTS LOADED:", [p['name'] for p in products_data])

   
        previous_messages = ChatMessage.objects.filter(
            session=session
        ).order_by('timestamp')[:6]

        conversation_messages = [
            {"role": "system", "content": build_system_prompt(products_context)}
        ]

        for msg in previous_messages:
            role = "user" if msg.sender == "user" else "assistant"
            conversation_messages.append({
                "role": role,
                "content": msg.text
            })

        conversation_messages.append({
            "role": "user",
            "content": text
        })

      
        try:
            response = groq_client.chat.completions.create(
                model="llama-3.1-8b-instant",
                messages=conversation_messages,
                temperature=0.7,
                max_tokens=300,
            )
            bot_text = response.choices[0].message.content
            bot_text = clean_bot_response(bot_text)

        except Exception as e:
            print(f"Groq API error: {e}")
            bot_text = "AI service is currently unavailable. Please try again later."

        print("BOT TEXT:", bot_text)

       
        matched_urls = find_product_images(bot_text, products_data)
        print("MATCHED IMAGE URLS:", matched_urls)

        if matched_urls:
            bot_text = bot_text.strip() + "\n" + "\n".join(matched_urls)

    
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