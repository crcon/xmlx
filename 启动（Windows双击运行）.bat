@echo off
chcp 65001 >nul 2>&1
title 储能项目上会材料生成系统 — 本地启动
cd /d "%~dp0"

echo ==================================================
echo   储能项目上会材料生成系统
echo ==================================================
echo.

:: 确定 HTML 文件
set "TARGET=index.html"
if not exist "index.html" (
  set "TARGET=上会材料生成系统.html"
)
if not exist "%TARGET%" (
  echo [错误] 找不到 HTML 文件！
  echo 请确保此脚本与 HTML 文件在同一目录。
  pause
  exit /b 1
)

set PORT=7788

:: 检查端口是否被占用，尝试备用端口
netstat -ano | findstr ":7788 " >nul 2>&1
if %errorlevel% equ 0 (
  set PORT=7789
  netstat -ano | findstr ":7789 " >nul 2>&1
  if %errorlevel% equ 0 set PORT=7790
)

set URL=http://localhost:%PORT%/%TARGET%

:: ── 优先尝试 Python 3 ──
where python >nul 2>&1
if %errorlevel% equ 0 (
  python -c "import sys;exit(0 if sys.version_info.major==3 else 1)" >nul 2>&1
  if %errorlevel% equ 0 (
    echo [OK] 检测到 Python 3，正在启动本地服务器（端口 %PORT%）...
    start /b python server.py %PORT% 2>nul
    goto :open_browser
  )
)

:: ── 尝试 py 命令（Windows Python Launcher）──
where py >nul 2>&1
if %errorlevel% equ 0 (
  echo [OK] 检测到 Python Launcher，正在启动本地服务器（端口 %PORT%）...
  start /b py -3 server.py %PORT% 2>nul
  goto :open_browser
)

:: ── 尝试 python3 命令 ──
where python3 >nul 2>&1
if %errorlevel% equ 0 (
  echo [OK] 检测到 Python 3，正在启动本地服务器（端口 %PORT%）...
  start /b python3 server.py %PORT% 2>nul
  goto :open_browser
)

:: ── 尝试 Node.js ──
where node >nul 2>&1
if %errorlevel% equ 0 (
  echo [OK] 检测到 Node.js，正在启动本地服务器（端口 %PORT%）...
  start /b node -e "const h=require('http'),f=require('fs'),p=require('path');h.createServer((q,r)=>{let fp=p.join('%CD%',decodeURIComponent(q.url.split('?')[0]));if(fp.endsWith(p.sep))fp+=p.join('index.html');try{const d=f.readFileSync(fp);r.writeHead(200);r.end(d);}catch(e){r.writeHead(404);r.end();}}).listen(%PORT%);" 2>nul
  goto :open_browser
)

:: ── 无服务器，直接打开文件 ──
echo [提示] 未检测到 Python 或 Node.js
echo        直接在浏览器中打开文件（数据仍会正常保存）...
echo.
start "" "%~dp0%TARGET%"
echo [OK] 已在浏览器中打开：%TARGET%
echo.
echo 如需通过本地服务器运行，请安装 Python：
echo https://www.python.org/downloads/
echo.
pause
exit /b

:open_browser
:: 等待服务器就绪
timeout /t 2 /nobreak >nul

echo [OK] 服务器已启动：%URL%
echo.
start "" "%URL%"

echo ✅ 系统已在浏览器中打开
echo.
echo 📌 请保持此窗口开启（关闭窗口 = 停止服务）
echo --------------------------------------------------
pause
