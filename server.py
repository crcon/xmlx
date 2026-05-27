#!/usr/bin/env python3
"""
储能项目上会材料生成系统 — 本地服务器
- 提供静态文件服务
- GET  /api/load  → 读取 yichu_data.json 并返回
- POST /api/save  → 接收 JSON 写入 yichu_data.json
数据文件与本脚本同目录，复制整个文件夹即可迁移所有数据。
"""
import http.server, json, os, sys

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_FILE = os.path.join(BASE_DIR, 'yichu_data.json')


class YichuHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self._cors()
        self.end_headers()

    def do_GET(self):
        if self.path == '/api/load':
            if os.path.exists(DATA_FILE):
                with open(DATA_FILE, 'rb') as f:
                    data = f.read()
                self.send_response(200)
                self.send_header('Content-Type', 'application/json; charset=utf-8')
                self.send_header('Content-Length', str(len(data)))
                self._cors()
                self.end_headers()
                self.wfile.write(data)
            else:
                self.send_response(404)
                self._cors()
                self.end_headers()
        else:
            super().do_GET()

    def do_POST(self):
        if self.path == '/api/save':
            try:
                length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(length)
                json.loads(body)            # validate JSON
                with open(DATA_FILE, 'wb') as f:
                    f.write(body)
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self._cors()
                self.end_headers()
                self.wfile.write(b'{"ok":true}')
            except Exception as e:
                self.send_response(500)
                self._cors()
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def _cors(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')

    def log_message(self, fmt, *args):
        pass  # 静默模式


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 7788
    os.chdir(BASE_DIR)
    server = http.server.HTTPServer(('', port), YichuHandler)
    print(f'✅  服务已启动：http://localhost:{port}/index.html')
    print(f'📁  数据文件：{DATA_FILE}')
    print('    关闭此窗口将停止服务，数据已自动保存到 yichu_data.json')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('\n服务已停止')
