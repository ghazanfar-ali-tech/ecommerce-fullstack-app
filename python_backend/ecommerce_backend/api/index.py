import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ecommerce_backend.settings')

try:
    from ecommerce_backend.wsgi import application
    app = application
except Exception as e:
    def app(environ, start_response):
        status = '500 Internal Server Error'
        headers = [('Content-type', 'text/plain')]
        start_response(status, headers)
        return [f'Error: {str(e)}'.encode()]