#!/usr/bin/env python3
import yaml
from pathlib import Path
from typing import List

class SimpleOpenAPIGenerator:
    """Simple generator for Python models from OpenAPI spec"""
    
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
        schema_format = schema.get('format', '')
        nullable = schema.get('nullable', False)
        
        if schema_type == 'integer':
            base_type = 'int'
        elif schema_type == 'number':
            base_type = 'float'
        elif schema_type == 'boolean':
            base_type = 'bool'
        elif schema_type == 'string' and schema_format == 'date':
            base_type = 'date'
        elif schema_type == 'string' and schema_format == 'date-time':
            base_type = 'datetime'
        elif schema_type == 'array':
            items_schema = schema.get('items', {})
            if '$ref' in items_schema:
                ref_name = items_schema['$ref'].split('/')[-1]
                base_type = f'List[{ref_name}]'
            else:
                item_type = self._get_python_type(items_schema)
                base_type = f'List[{item_type}]'
        else:
            base_type = 'str'
        
        return f'Optional[{base_type}]' if nullable else base_type
    
    def _generate_models_py(self, spec: dict):
        models_content = [
            "from datetime import datetime, date",
            "from typing import List, Optional",
            "from pydantic import BaseModel",
            "",
            "# Auto-generated models from OpenAPI spec",
            ""
        ]
        schemas = spec.get('components', {}).get('schemas', {})
        
        # Generate all schema models in the correct order
        schema_order = ['CaseReference', 'Argument', 'AnalysisResponse', 'AddCaseRequest', 'HealthResponse']
        for name in schema_order:
            if name in schemas:
                models_content.extend(self._generate_model_class(name, schemas[name]))
                models_content.append("")
        
        # Handle any remaining schemas not in the order list
        for name, schema in schemas.items():
            if name not in schema_order:
                models_content.extend(self._generate_model_class(name, schema))
                models_content.append("")
        
        models_file = self.output_dir / "models.py"
        with open(models_file, 'w') as f:
            f.write('\n'.join(models_content))

if __name__ == "__main__":
    spec_path = "../interface/api.yml"
    output_dir = "generated"
    generator = SimpleOpenAPIGenerator(spec_path, output_dir)
    generator.generate_models() 