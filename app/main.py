from fastapi import FastAPI

app = FastAPI(title="Python Codespace API")


@app.get("/")
def root() -> dict[str, str]:
    return {"status": "ok", "message": "Hello from Codespace!"}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "healthy"}
