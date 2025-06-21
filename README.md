# Cambridge API

A Python REST API backend with automatic interface generation from OpenAPI specifications.

## Project Structure

```
cambridge/
├── backend/                 # Python FastAPI backend
│   ├── main.py             # Main application with auto-generation
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile         # Backend container
│   └── generated/         # Auto-generated models (created at runtime)
├── interface/              # API specifications
│   └── api.yml            # OpenAPI 3.0 specification
├── frontend/              # Future frontend (not implemented yet)
├── docker-compose.yml     # Container orchestration
└── README.md             # This file
```

## Features

- **FastAPI Backend**: Modern, fast Python web framework
- **Automatic Interface Generation**: Python models are automatically generated from `interface/api.yml`
- **File Watching**: Changes to the API spec automatically trigger model regeneration
- **Docker Support**: Complete containerization with docker-compose
- **Health Checks**: Built-in health monitoring
- **CORS Support**: Cross-origin resource sharing enabled
- **API Documentation**: Auto-generated docs at `/docs` and `/redoc`

## Quick Start

### Using Docker (Recommended)

1. **Start the backend**:
   ```bash
   docker-compose up --build
   ```

2. **Access the API**:
   - API: http://localhost:8000
   - Documentation: http://localhost:8000/docs
   - Alternative docs: http://localhost:8000/redoc

3. **Test the endpoints**:
   ```bash
   # Health check
   curl http://localhost:8000/health
   
   # Get items
   curl http://localhost:8000/api/v1/items
   
   # Get items with pagination
   curl "http://localhost:8000/api/v1/items?limit=2&offset=1"
   ```

### Development Mode

1. **Install dependencies**:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Run the server**:
   ```bash
   python main.py
   ```

## API Endpoints

### Health Check
- **GET** `/health`
- Returns API health status

### Items
- **GET** `/api/v1/items`
- Query parameters:
  - `limit` (optional): Number of items to return (1-100, default: 10)
  - `offset` (optional): Number of items to skip (default: 0)

## Modifying the API

### Adding New Endpoints

1. **Update the OpenAPI spec** (`interface/api.yml`):
   ```yaml
   paths:
     /api/v1/new-endpoint:
       get:
         summary: New endpoint
         operationId: getNewEndpoint
         responses:
           '200':
             description: Success
             content:
               application/json:
                 schema:
                   type: object
                   properties:
                     data:
                       type: string
   ```

2. **The Python models will be automatically regenerated** when you save the file

3. **Add the endpoint implementation** in `backend/main.py`:
   ```python
   @app.get("/api/v1/new-endpoint")
   async def get_new_endpoint():
       return {"data": "Hello from new endpoint"}
   ```

### Adding New Models

1. **Define the model in the OpenAPI spec** (`interface/api.yml`):
   ```yaml
   components:
     schemas:
       NewModel:
         type: object
         properties:
           id:
             type: integer
           name:
             type: string
   ```

2. **The model will be automatically generated** and available for import

## Docker Commands

```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# Rebuild and start
docker-compose up --build

# Stop services
docker-compose down

# View logs
docker-compose logs -f backend

# Execute commands in container
docker-compose exec backend python -c "print('Hello from container')"
```

## Development Workflow

1. **Edit the API spec** in `interface/api.yml`
2. **Models are automatically regenerated** by the file watcher
3. **Implement endpoints** in `backend/main.py`
4. **Test changes** via the API or documentation

## Future Enhancements

- [ ] Frontend application
- [ ] Database integration
- [ ] Authentication & authorization
- [ ] More comprehensive model generation
- [ ] API versioning
- [ ] Rate limiting
- [ ] Logging and monitoring

## Troubleshooting

### Common Issues

1. **Port already in use**:
   ```bash
   # Find process using port 8000
   lsof -i :8000
   # Kill the process
   kill -9 <PID>
   ```

2. **Docker build fails**:
   ```bash
   # Clean up Docker cache
   docker system prune -a
   # Rebuild
   docker-compose up --build
   ```

3. **Models not regenerating**:
   - Check file permissions on `interface/api.yml`
   - Restart the container: `docker-compose restart backend`

### Logs

View detailed logs:
```bash
docker-compose logs -f backend
```

## Contributing

1. Edit the OpenAPI spec in `interface/api.yml`
2. Implement endpoints in `backend/main.py`
3. Test your changes
4. Submit a pull request

## License

MIT License 