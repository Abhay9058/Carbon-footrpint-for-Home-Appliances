from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import user_routes, appliance_routes, usage_routes, analytics_routes

app = FastAPI(
    title="Eco Warrior API",
    description="Carbon Footprint Tracker Backend API",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(user_routes.router)
app.include_router(appliance_routes.router)
app.include_router(usage_routes.router)
app.include_router(analytics_routes.router)


@app.get("/")
async def root():
    return {
        "message": "Eco Warrior API",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
