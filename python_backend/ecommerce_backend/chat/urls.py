from django.urls import path
from .views import ChatSendAPIView, ChatHistoryAPIView

urlpatterns = [
    path('send/', ChatSendAPIView.as_view(), name='chat-send'),
    path('<uuid:session_id>/history/', ChatHistoryAPIView.as_view(), name='chat-history'),
]
