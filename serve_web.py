"""Serves the built web version of Rescue One on http://127.0.0.1:8080
(or the next free port if 8080 is busy) and opens it in the default browser.

Build it first (run_app.bat option [5], or):
    cd smart_emergency_360 && flutter build web --release -o ../app
"""
import http.server
import os
import socket
import socketserver
import sys
import webbrowser

PORT = 8080  # first port tried; the next free one is used if it's busy
DIRECTORY = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'app')


class Handler(http.server.SimpleHTTPRequestHandler):
    extensions_map = {
        **http.server.SimpleHTTPRequestHandler.extensions_map,
        '.js': 'application/javascript',
        '.mjs': 'application/javascript',
        '.wasm': 'application/wasm',
        '.json': 'application/json',
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def end_headers(self):
        # Always serve the latest build (no stale cached app after a rebuild).
        self.send_header('Cache-Control', 'no-store')
        super().end_headers()


def port_busy(port):
    """True if anything already answers on localhost:port (IPv4 or IPv6) -
    e.g. an old server still running from a previous session."""
    for family, host in ((socket.AF_INET, '127.0.0.1'), (socket.AF_INET6, '::1')):
        try:
            with socket.socket(family, socket.SOCK_STREAM) as s:
                s.settimeout(0.3)
                if s.connect_ex((host, port)) == 0:
                    return True
        except OSError:
            pass
    return False


def run():
    if not os.path.isfile(os.path.join(DIRECTORY, 'index.html')):
        print('The web build was not found:', DIRECTORY)
        print('Build it first:  cd smart_emergency_360 && flutter build web --release -o ../app')
        sys.exit(1)
    port = PORT
    while port_busy(port) and port < PORT + 20:
        print(f'Port {port} is already in use, trying {port + 1}...')
        port += 1
    with socketserver.TCPServer(('127.0.0.1', port), Handler) as httpd:
        url = f'http://127.0.0.1:{port}'
        print('==================================================')
        print(' Rescue One - web version')
        print(f' Serving at: {url}')
        print(' Allow location access when the browser asks.')
        print(' Press Ctrl+C to stop the server.')
        print('==================================================')
        if '--no-browser' not in sys.argv:
            webbrowser.open(url)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print('\nServer stopped.')


if __name__ == '__main__':
    run()
