import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ecommerce_backend.settings')

from ecommerce_backend.wsgi import application

app = application