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

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import uvicorn

# Add the generated models to the path
sys.path.append(str(Path(__file__).parent / "generated"))

# Import generated models (will be created by the generator)
try:
    from models import HealthResponse, Item, ItemsResponse
except ImportError:
    # Fallback models if generation hasn't happened yet
    class HealthResponse(BaseModel):
        status: str
        timestamp: datetime
        version: str

    class Item(BaseModel):
        id: int
        name: str
        description: str
        created_at: datetime

    class ItemsResponse(BaseModel):
        items: List[Item]
        total: int
        limit: int
        offset: int

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
    allow_origins=["*"],  # In production, specify actual origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mock data for demonstration
MOCK_ITEMS = [
    Item(
        id=1,
        name="Sample Item 1",
        description="This is the first sample item",
        created_at=datetime.now()
    ),
    Item(
        id=2,
        name="Sample Item 2", 
        description="This is the second sample item",
        created_at=datetime.now()
    ),
    Item(
        id=3,
        name="Sample Item 3",
        description="This is the third sample item", 
        created_at=datetime.now()
    )
]

@app.get("/health", response_model=HealthResponse)
async def get_health():
    """Health check endpoint"""
    return HealthResponse(
        status="healthy",
        timestamp=datetime.now(),
        version="1.0.0"
    )

@app.get("/api/v1/items", response_model=ItemsResponse)
async def get_items(
    limit: int = Query(10, ge=1, le=100, description="Maximum number of items to return"),
    offset: int = Query(0, ge=0, description="Number of items to skip")
):
    """Get all items with pagination"""
    if limit < 1 or limit > 100:
        raise HTTPException(status_code=400, detail="Limit must be between 1 and 100")
    
    if offset < 0:
        raise HTTPException(status_code=400, detail="Offset must be non-negative")
    
    # Apply pagination
    start_idx = offset
    end_idx = start_idx + limit
    paginated_items = MOCK_ITEMS[start_idx:end_idx]
    
    return ItemsResponse(
        items=paginated_items,
        total=len(MOCK_ITEMS),
        limit=limit,
        offset=offset
    )

class OpenAPIGenerator:
    """Handles automatic generation of Python models from OpenAPI spec"""
    
    def __init__(self, spec_path: str, output_dir: str):
        self.spec_path = Path(spec_path)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
    
    def generate_models(self):
        """Generate Python models from OpenAPI spec"""
        try:
            # Read the OpenAPI spec
            with open(self.spec_path, 'r') as f:
                spec = yaml.safe_load(f)
            
            # Generate models.py
            self._generate_models_py(spec)
            print(f"✅ Generated models from {self.spec_path}")
            
        except Exception as e:
            print(f"❌ Error generating models: {e}")
    
    def _generate_models_py(self, spec: dict):
        """Generate models.py file from OpenAPI spec"""
        models_content = [
            "from datetime import datetime",
            "from typing import List, Optional",
            "from pydantic import BaseModel, Field",
            "",
            "# Auto-generated models from OpenAPI spec",
            ""
        ]
        
        # Generate models from components/schemas
        if 'components' in spec and 'schemas' in spec['components']:
            for schema_name, schema in spec['components']['schemas'].items():
                if schema_name != 'Error':  # Skip generic Error schema
                    models_content.extend(self._generate_model_class(schema_name, schema))
                    models_content.append("")
        
        # Generate response models from paths
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
                    elif operation_id == 'getItems':
                        models_content.extend([
                            "class Item(BaseModel):",
                            "    id: int",
                            "    name: str",
                            "    description: str", 
                            "    created_at: datetime",
                            "",
                            "class ItemsResponse(BaseModel):",
                            "    items: List[Item]",
                            "    total: int",
                            "    limit: int",
                            "    offset: int",
                            ""
                        ])
        
        # Write models.py
        models_file = self.output_dir / "models.py"
        with open(models_file, 'w') as f:
            f.write('\n'.join(models_content))

class OpenAPIWatcher(FileSystemEventHandler):
    """Watches for changes in the OpenAPI spec and regenerates models"""
    
    def __init__(self, generator: OpenAPIGenerator):
        self.generator = generator
    
    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith('api.yml'):
            print(f"🔄 OpenAPI spec changed: {event.src_path}")
            self.generator.generate_models()
            print("🔄 Models regenerated successfully!")

def setup_openapi_watcher():
    """Setup file watcher for OpenAPI spec changes"""
    # In container, the interface is mounted at /app/interface
    spec_path = Path("/app/interface/api.yml")
    output_dir = Path("/app/generated")
    
    generator = OpenAPIGenerator(str(spec_path), str(output_dir))
    
    # Generate initial models
    generator.generate_models()
    
    # Setup file watcher
    event_handler = OpenAPIWatcher(generator)
    observer = Observer()
    observer.schedule(event_handler, str(spec_path.parent), recursive=False)
    observer.start()
    
    return observer

if __name__ == "__main__":
    # Setup OpenAPI watcher
    observer = setup_openapi_watcher()
    
    try:
        # Run the FastAPI server
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