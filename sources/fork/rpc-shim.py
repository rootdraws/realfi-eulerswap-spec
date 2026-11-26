#!/usr/bin/env python3
"""Port 8548 in front of the Hardhat fork on 8547. Foundry sends both `input` and `data` in a call, and Hardhat 2
refuses that ("duplicate field data"), so this drops `data` when `input` is there. Everything else passes through."""
import json, urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

UP = "http://127.0.0.1:8547"


def fix(m):
    for p in m.get("params") or []:
        if isinstance(p, dict) and "input" in p and "data" in p:
            p.pop("data")
    return m


class H(BaseHTTPRequestHandler):
    def do_POST(self):
        body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
        body = [fix(m) for m in body] if isinstance(body, list) else fix(body)
        req = urllib.request.Request(UP, json.dumps(body).encode(), {"Content-Type": "application/json"})
        with urllib.request.urlopen(req, timeout=600) as r:
            out = r.read()
        self.send_response(200); self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(out))); self.end_headers(); self.wfile.write(out)

    def log_message(self, *a):
        pass


ThreadingHTTPServer(("127.0.0.1", 8548), H).serve_forever()
