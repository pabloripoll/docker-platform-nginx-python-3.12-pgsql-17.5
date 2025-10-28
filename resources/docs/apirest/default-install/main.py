from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import platform
import asyncpg  # type: ignore
import sys

app = FastAPI()

# Serve static files from the local "public" directory at "/static"
app.mount("/static", StaticFiles(directory="static"), name="static")

# Set up templates
templates = Jinja2Templates(directory="templates")

# PostgreSQL connection config
DB_CONFIG = {
    "host": "192.168.1.41",
    "port": 4500,
    "database": "myproj_local",
    "user": "myproj",
    "password": "J4YPuJaieJ35gNAOSQQor87s82q2eUS1",
    "timeout": 3,
}

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):  # <-- Add request parameter here
    dbstatus = False
    dbstatus_message = ''
    try:
        conn = await asyncpg.connect(**DB_CONFIG)
        await conn.execute("SELECT NOW()")
        await conn.close()
        dbstatus = True
    except Exception as e:
        dbstatus_message = f'{e}'

    python_version = sys.version.split()[0]
    platform_name = platform.system()
    return templates.TemplateResponse(
        "home.html",
        {
            "request": request,
            "python_version": python_version,
            "platform_name": platform_name,
            "dbstatus": dbstatus,
            "dbstatus_message": dbstatus_message
        }
    )