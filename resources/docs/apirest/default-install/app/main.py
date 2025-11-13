from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pathlib import Path
import platform
import asyncpg  # type: ignore
import sys
import warnings

PATH = Path(__file__).resolve().parent
app = FastAPI()

# Candidate locations where your static files might live
candidates = [
    PATH / "static",            # ./app/static
    PATH.parent / "static",     # ./static (project root)
    PATH / ".." / "static",     # more permissive parent check
]

# Pick the first existing directory
static_dir = None
for p in candidates:
    p = p.resolve()
    if p.exists() and p.is_dir():
        static_dir = p
        break

# Serve static files from the local "static" directory at the "/static" URL path.
# Only mount if the directory actually exists to avoid RuntimeError at import time.
static_dir = PATH / "static"
if static_dir.exists() and static_dir.is_dir():
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")
else:
    warnings.warn(f"Static directory not found: {static_dir} — /static will not be mounted")

# Set up templates (resolved relative to this file)
templates_dir = PATH / "templates"
if not templates_dir.exists() or not templates_dir.is_dir():
    warnings.warn(f"Templates directory not found: {templates_dir} — template rendering will fail until it exists")
templates = Jinja2Templates(directory=str(templates_dir))

# PostgreSQL connection config
DB_CONFIG = {
    "host": "192.168.1.41",
    "port": 7500,
    "database": "myproj_local",
    "user": "myproj",
    "password": "J4YPuJaieJ35gNAOSQQor87s82q2eUS1",
    "timeout": 3,
}

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
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
            "dbstatus_message": dbstatus_message,
            "static_dir": static_dir
        }
    )

@app.get("/_debug_paths")
async def _debug_paths():
    from pathlib import Path
    return {
        "file": str(__file__),
        "cwd": str(Path.cwd()),
        "PATH_resolved_parent": str(Path(__file__).resolve().parent),
        "static_dir": str(static_dir),
        "static_exists": static_dir.exists(),
        "static_is_dir": static_dir.is_dir(),
        "routes": [r.path for r in app.routes],
    }