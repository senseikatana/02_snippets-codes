#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Password Generator Utility & Service
Generates passwords of various types:
  - matricula/license: 4 digits + 3 letters (e.g. 1234BCD)
  - secure: alphanumeric + safe special characters
  - alphanumeric: lowercase + uppercase + digits
  - numeric/pin: digits only
  - memorable/xkcd: random dictionary words joined by hyphens

Modes:
  - CLI: On-demand generation with arguments
  - HTTP Daemon: Runs as a service (e.g. for systemd) to serve passwords over HTTP
"""

import sys
import os
import string
import argparse
import json
import secrets
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse

# Use secrets.SystemRandom for cryptographically secure random number generation
random = secrets.SystemRandom()

# Common words fallback for memorable passwords (Spanish and English)
FALLBACK_WORDS = [
    # Spanish
    "agua", "arbol", "arena", "barco", "brisa", "cielo", "cueva", "disco", "duna", "fuego",
    "gato", "globo", "hoja", "humo", "isla", "lago", "lluvia", "luna", "mapa", "monte",
    "nieve", "nube", "onda", "papel", "piedra", "pino", "pluma", "rayo", "rio", "roca",
    "selva", "sol", "suelo", "tierra", "torre", "viento", "vuelo", "valle", "verde", "vida",
    "azul", "rojo", "claro", "oscuro", "fuerte", "suave", "rapido", "lento", "alto", "bajo",
    # English
    "acid", "apex", "atom", "bark", "beam", "bolt", "brisk", "calm", "clay", "coal",
    "dawn", "deep", "dusk", "echo", "fade", "flow", "flux", "glen", "glow", "halo",
    "haze", "iron", "jade", "lava", "leaf", "lime", "mist", "neon", "nova", "opal",
    "path", "pure", "rain", "reef", "rift", "rust", "sand", "shadow", "silk", "silt",
    "snow", "star", "surf", "tide", "vale", "vast", "wave", "wild", "wind", "zinc"
]

def get_words_list():
    """Tries to load words from system dictionary paths, falls back if not found."""
    words = []
    # Try common dictionary locations in Linux
    for path in ['/usr/share/dict/words', '/etc/dictionaries-common/words', '/usr/dict/words']:
        if os.path.exists(path):
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    for line in f:
                        w = line.strip()
                        # Filter for clean, short alphabetic words (length 4-8)
                        if w.isalpha() and 4 <= len(w) <= 8 and w.islower():
                            words.append(w)
                if words:
                    return words
            except Exception:
                pass
    return FALLBACK_WORDS

def generate_password(pw_type, length=16, qty=1):
    """Generates a password based on type, length, and block quantity."""
    if pw_type == "matricula":
        generated = set()
        results = []
        while len(results) < qty:
            num = "".join(random.choices(string.digits, k=4))
            # Exclude vowels to avoid forming words, keeping it similar to Spanish vehicle plates
            consonants = "BCDFGHJKLMNPQRSTVWXYZ"
            let = "".join(random.choices(consonants, k=3))
            placa = f"{num}{let}"
            if placa not in generated:
                generated.add(placa)
                results.append(placa)
        return "-".join(results)
    
    elif pw_type == "secure":
        # Safe punctuation set to avoid shell escapes / SQL injection issues
        symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        all_chars = string.ascii_letters + string.digits + symbols
        if length < 4:
            return "".join(random.choices(all_chars, k=length))
        
        # Ensure at least one lowercase, one uppercase, one digit, and one symbol
        while True:
            pwd = "".join(random.choices(all_chars, k=length))
            if (any(c in string.ascii_lowercase for c in pwd) and
                any(c in string.ascii_uppercase for c in pwd) and
                any(c in string.digits for c in pwd) and
                any(c in symbols for c in pwd)):
                return pwd

    elif pw_type == "alphanumeric":
        all_chars = string.ascii_letters + string.digits
        if length < 2:
            return "".join(random.choices(all_chars, k=length))
        
        # Ensure at least one lowercase, one uppercase, and one digit
        while True:
            pwd = "".join(random.choices(all_chars, k=length))
            if (any(c in string.ascii_lowercase for c in pwd) and
                any(c in string.ascii_uppercase for c in pwd) and
                any(c in string.digits for c in pwd)):
                return pwd

    elif pw_type == "numeric":
        return "".join(random.choices(string.digits, k=length))

    elif pw_type == "memorable":
        words = get_words_list()
        # Ensure unique words if possible
        if len(words) >= qty:
            selected = random.sample(words, k=qty)
        else:
            selected = random.choices(words, k=qty)
        return "-".join(selected)
    
    else:
        raise ValueError(f"Unknown password type: {pw_type}")

class PasswordRequestHandler(BaseHTTPRequestHandler):
    """HTTP Request Handler for password generator daemon."""
    def log_message(self, format, *args):
        # Override to log to stdout instead of default stderr (keeps journald cleaner)
        sys.stdout.write("%s - - [%s] %s\n" %
                         (self.address_string(),
                          self.log_date_time_string(),
                          format%args))

    def do_GET(self):
        parsed_url = urllib.parse.urlparse(self.path)
        path = parsed_url.path
        
        if path not in ["/", "/generate"]:
            self.send_response(404)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"404 Not Found")
            return
            
        params = urllib.parse.parse_qs(parsed_url.query)
        
        # Read parameters
        pw_type = params.get("type", ["secure"])[0]
        
        # Default defaults depending on type
        default_len = 16
        if pw_type == "numeric":
            default_len = 6
            
        default_qty = 1
        if pw_type == "memorable":
            default_qty = 4
        
        try:
            length = int(params.get("length", [default_len])[0])
            qty = int(params.get("qty", [default_qty])[0])
            count = int(params.get("count", [1])[0])
        except ValueError:
            self.send_response(400)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Bad Request: length, qty, and count must be integers.")
            return

        if pw_type not in ["matricula", "secure", "alphanumeric", "numeric", "memorable"]:
            self.send_response(400)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Bad Request: type must be matricula, secure, alphanumeric, numeric, or memorable.")
            return
            
        if length <= 0 or qty <= 0 or count <= 0:
            self.send_response(400)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Bad Request: parameters must be greater than zero.")
            return

        # Generate passwords
        try:
            passwords = [generate_password(pw_type, length, qty) for _ in range(count)]
        except Exception as e:
            self.send_response(500)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(f"Internal Error: {str(e)}".encode())
            return
        
        # Output format
        fmt = params.get("format", ["text"])[0]
        if fmt == "json":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            response = {
                "status": "success",
                "passwords": passwords,
                "type": pw_type,
                "length": length if pw_type not in ["matricula", "memorable"] else None,
                "qty": qty if pw_type in ["matricula", "memorable"] else None,
                "count": count
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(("\n".join(passwords) + "\n").encode())

def run_server(port, host="127.0.0.1"):
    """Starts the HTTPServer daemon."""
    server_address = (host, port)
    httpd = HTTPServer(server_address, PasswordRequestHandler)
    print(f"🚀 Password Generator Service listening on HTTP {host}:{port}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping service...")
        httpd.server_close()

def main():
    parser = argparse.ArgumentParser(description="Cryptographically Secure Password Generator & Daemon")
    
    parser.add_argument("-t", "--type", choices=["matricula", "secure", "alphanumeric", "numeric", "memorable"],
                        default="secure", help="Password type (default: secure)")
    parser.add_argument("-l", "--length", type=int, default=16,
                        help="Length of password (for secure, alphanumeric, numeric; default: 16)")
    parser.add_argument("-q", "--qty", type=int, default=0,
                        help="Number of blocks/words (for matricula, memorable; default: 1 for matricula, 4 for memorable)")
    parser.add_argument("-c", "--count", type=int, default=1,
                        help="Number of passwords to generate (default: 1)")
    parser.add_argument("--serve", action="store_true",
                        help="Run as an HTTP service daemon instead of CLI")
    parser.add_argument("--port", type=int, default=7777,
                        help="HTTP service port (default: 7777)")
    parser.add_argument("--host", default="127.0.0.1",
                        help="HTTP service listen address (default: 127.0.0.1 for local safety)")

    args = parser.parse_args()

    if args.serve:
        run_server(args.port, args.host)
        return

    # Handle defaults depending on type
    length = args.length
    if args.type == "numeric" and length == 16 and not any(arg in sys.argv for arg in ['-l', '--length']):
        length = 6 # Default PIN size

    qty = args.qty
    if qty == 0:
        qty = 4 if args.type == "memorable" else 1

    try:
        for _ in range(args.count):
            print(generate_password(args.type, length, qty))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()