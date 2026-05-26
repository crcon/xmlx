#!/bin/bash
# ============================================================
#  储能项目上会材料生成系统 — Mac 一键本地启动
#  使用方法：在 Finder 中双击此文件即可
#  首次使用需在终端执行：chmod +x "启动（Mac双击运行）.command"
# ============================================================

DIR="$(cd "$(dirname "$0")" && pwd)"
PORT=7788

# 确定 HTML 文件
if   [ -f "$DIR/index.html" ];          then TARGET="index.html"
elif [ -f "$DIR/上会材料生成系统.html" ]; then TARGET="上会材料生成系统.html"
else
  osascript -e 'display dialog "找不到 HTML 文件！\n请确保启动脚本与 HTML 文件在同一目录。" buttons {"确定"} default button 1 with icon stop' 2>/dev/null
  echo "❌ 找不到 HTML 文件，请检查目录：$DIR"; exit 1
fi

# 如果端口已被占用则自动换端口
while lsof -i ":$PORT" &>/dev/null 2>&1; do
  PORT=$((PORT + 1))
done

URL="http://localhost:$PORT/$TARGET"

echo "=================================================="
echo "  储能项目上会材料生成系统"
echo "=================================================="
echo ""

# 尝试启动 HTTP 服务器
STARTED=false
if command -v python3 &>/dev/null; then
  echo "▶ 使用 Python 3 启动本地服务器（端口 $PORT）..."
  cd "$DIR" && python3 -m http.server "$PORT" &>/dev/null &
  SERVER_PID=$!
  STARTED=true
elif command -v python &>/dev/null; then
  PY_VER=$(python -c "import sys;print(sys.version_info.major)" 2>/dev/null)
  if [ "$PY_VER" = "3" ]; then
    echo "▶ 使用 Python 3 启动本地服务器（端口 $PORT）..."
    cd "$DIR" && python -m http.server "$PORT" &>/dev/null &
  else
    echo "▶ 使用 Python 2 启动本地服务器（端口 $PORT）..."
    cd "$DIR" && python -m SimpleHTTPServer "$PORT" &>/dev/null &
  fi
  SERVER_PID=$!
  STARTED=true
elif command -v node &>/dev/null; then
  echo "▶ 使用 Node.js 启动本地服务器（端口 $PORT）..."
  node -e "
    const http=require('http'),fs=require('fs'),path=require('path');
    http.createServer((req,res)=>{
      let f=path.join('$DIR',decodeURIComponent(req.url.split('?')[0]));
      if(f.endsWith('/'))f+='index.html';
      try{
        const d=fs.readFileSync(f);
        const ext=path.extname(f);
        const ct={'html':'text/html','js':'application/javascript','css':'text/css','json':'application/json'}[ext.slice(1)]||'application/octet-stream';
        res.writeHead(200,{'Content-Type':ct+';charset=utf-8'});res.end(d);
      }catch(e){res.writeHead(404);res.end('Not Found');}
    }).listen($PORT);
  " &
  SERVER_PID=$!
  STARTED=true
fi

if [ "$STARTED" = true ]; then
  sleep 1  # 等待服务器就绪
  echo "✅ 服务器已启动：$URL"
  echo ""
  # 打开浏览器
  open "$URL" 2>/dev/null
  echo "📌 保持此窗口开启以维持服务，关闭窗口将停止服务。"
  echo ""
  echo "  按 Ctrl+C 可手动停止服务"
  echo "--------------------------------------------------"
  wait $SERVER_PID
else
  # 没有可用的服务器，直接用 file:// 打开（localStorage 仍可用）
  echo "⚠ 未检测到 Python / Node.js，直接在浏览器中打开文件..."
  echo "  注意：此模式下数据同样会正常保存。"
  echo ""
  open "$DIR/$TARGET"
  echo "✅ 已用浏览器打开：$DIR/$TARGET"
  echo ""
  read -n 1 -s -r -p "按任意键关闭此窗口..."
fi
