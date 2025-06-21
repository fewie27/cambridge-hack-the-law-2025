import os
import sys
import json
import yaml
import asyncio
from datetime import datetime
from pathlib import Path
from typing import List, Optional
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# --- Model Generator ---
class OpenAPIGenerator:
    """Handles automatic generation of Python models from OpenAPI spec"""
    def __init__(self, spec_path: str, output_dir: str):
        self.spec_path = Path(spec_path)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    def generate_models(self):
        try:
            with open(self.spec_path, 'r') as f:
                spec = yaml.safe_load(f)
            self._generate_models_py(spec)
            print(f"✅ Generated models from {self.spec_path}")
        except Exception as e:
            print(f"❌ Error generating models: {e}")
    def _generate_model_class(self, schema_name: str, schema: dict) -> List[str]:
        lines = [f"class {schema_name}(BaseModel):"]
        if 'properties' in schema:
            for prop_name, prop_schema in schema['properties'].items():
                prop_type = self._get_python_type(prop_schema)
                lines.append(f"    {prop_name}: {prop_type}")
        else:
            lines.append("    pass")
        return lines
    def _get_python_type(self, schema: dict) -> str:
        schema_type = schema.get('type', 'string')
        if schema_type == 'integer':
            return 'int'
        elif schema_type == 'number':
            return 'float'
        elif schema_type == 'boolean':
            return 'bool'
        elif schema_type == 'array':
            items_schema = schema.get('items', {})
            if '$ref' in items_schema:
                ref_name = items_schema['$ref'].split('/')[-1]
                return f'List[{ref_name}]'
            else:
                item_type = self._get_python_type(items_schema)
                return f'List[{item_type}]'
        else:
            return 'str'
    def _generate_models_py(self, spec: dict):
        models_content = [
            "from datetime import datetime",
            "from typing import List, Optional",
            "from pydantic import BaseModel, Field",
            "",
            "# Auto-generated models from OpenAPI spec",
            ""
        ]
        schemas = spec.get('components', {}).get('schemas', {})
        for name in ['RelatedCase', 'Argument', 'AnalysisResponse', 'AddCaseRequest']:
            if name in schemas:
                models_content.extend(self._generate_model_class(name, schemas[name]))
                models_content.append("")
        for path, path_item in spec.get('paths', {}).items():
            for method, operation in path_item.items():
                if method.lower() == 'get':
                    operation_id = operation.get('operationId', '')
                    if operation_id == 'getHealth':
                        models_content.extend([
                            "class HealthResponse(BaseModel):",
                            "    status: str",
                            "    timestamp: datetime", 
                            "    version: str",
                            ""
                        ])
        models_file = self.output_dir / "models.py"
        with open(models_file, 'w') as f:
            f.write('\n'.join(models_content))

# --- Generate models before importing them ---
if __name__ == "__main__" or os.environ.get("GENERATE_MODELS_ONLY") == "1":
    # Always generate models before anything else
    spec_path = Path("/app/interface/api.yml")
    output_dir = Path("/app/generated")
    generator = OpenAPIGenerator(str(spec_path), str(output_dir))
    generator.generate_models()
    if os.environ.get("GENERATE_MODELS_ONLY") == "1":
        exit(0)

# Add the generated models to the path
sys.path.append(str(Path("/app/generated")))

# Import generated models (now guaranteed to exist)
from models import HealthResponse, Argument, RelatedCase, AnalysisResponse, AddCaseRequest

# Import endpoint routers
from health import health_router
from endpoints import api_router

# Create FastAPI app
app = FastAPI(
    title="Cambridge API",
    description="A REST API for Cambridge application",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health_router)
app.include_router(api_router)

# --- File Watcher for live reload (optional, not blocking startup) ---
class OpenAPIWatcher(FileSystemEventHandler):
    def __init__(self, generator: OpenAPIGenerator):
        self.generator = generator
    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith('api.yml'):
            print(f"🔄 OpenAPI spec changed: {event.src_path}")
            self.generator.generate_models()
            print("🔄 Models regenerated successfully!")

def setup_openapi_watcher():
    spec_path = Path("/app/interface/api.yml")
    output_dir = Path("/app/generated")
    generator = OpenAPIGenerator(str(spec_path), str(output_dir))
    event_handler = OpenAPIWatcher(generator)
    observer = Observer()
    observer.schedule(event_handler, str(spec_path.parent), recursive=False)
    observer.start()
    return observer

if __name__ == "__main__":
    observer = setup_openapi_watcher()
    try:
        uvicorn.run(
            "main:app",
            host="0.0.0.0",
            port=8000,
            reload=True,
            reload_dirs=["."]
        )
    finally:
        observer.stop()
        observer.join() 