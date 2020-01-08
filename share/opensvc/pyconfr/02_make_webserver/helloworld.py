#!/usr/bin/python3

import os
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
import platform

def mywebsrv(node, port):

    class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(bytes("Hello World! I am %s serving on port %s\n" % (node, port), "utf-8"))
    
    httpd = HTTPServer(('', port), SimpleHTTPRequestHandler)
    httpd.serve_forever()

def main():
    node = platform.node()
    try:
        port = os.environ['PORT']
    except:
        port = 80
    try:
        mywebsrv(node, int(port))
    except KeyboardInterrupt:
        sys.stderr.write("Keybord Interrupt\n")
        return 1

if __name__ == "__main__":
    ret = main()
    sys.exit(ret)
