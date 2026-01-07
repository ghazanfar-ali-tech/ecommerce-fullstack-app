from django.urls import path
from . import views

urlpatterns = [
    path('create-payment/', views.create_payment, name='create_payment'),
    path('verify-payment/', views.verify_payment, name='verify_payment'),
]
