import sqlite3
import json
from datetime import date
from typing import Optional, Dict, Any
import os

class CaseStorage:
    def __init__(self):
        db_path = os.path.join(os.path.dirname(__file__), 'cases.db')
        self.conn = sqlite3.connect(db_path)
        self.create_tables()
    
    def create_tables(self):
        """Create the necessary tables if they don't exist."""
        cursor = self.conn.cursor()
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS case_responses (
            case_id TEXT PRIMARY KEY,
            response_data TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        ''')
        self.conn.commit()

    def _serialize_date(self, obj: Any) -> Any:
        """Helper method to serialize date objects to ISO format."""
        if isinstance(obj, date):
            return obj.isoformat()
        return obj

    def store_response(self, case_id: str, response_data: Dict) -> None:
        """Store a case response in the database."""
        cursor = self.conn.cursor()
        # Convert response data to JSON string, handling date serialization
        json_data = json.dumps(response_data, default=self._serialize_date)
        cursor.execute(
            'INSERT OR REPLACE INTO case_responses (case_id, response_data) VALUES (?, ?)',
            (case_id, json_data)
        )
        self.conn.commit()

    def get_response(self, case_id: str) -> Optional[Dict]:
        """Retrieve a case response from the database."""
        cursor = self.conn.cursor()
        cursor.execute('SELECT response_data FROM case_responses WHERE case_id = ?', (case_id,))
        result = cursor.fetchone()
        
        if result is None:
            return None
            
        return json.loads(result[0])

    def __del__(self):
        """Ensure the database connection is closed when the object is destroyed."""
        self.conn.close() 