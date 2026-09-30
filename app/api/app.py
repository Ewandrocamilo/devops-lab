import os

import psycopg
from flask import Flask

app = Flask(__name__)


@app.get("/health")
def health():
    try:
        with psycopg.connect(
            host=os.getenv("DB_HOST"),
            port=os.getenv("DB_PORT", "5432"),
            dbname=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
        ):
            database_status = "healthy"

    except Exception as error:
        return {
            "status": "unhealthy",
            "database": "unhealthy",
            "error": str(error),
        }, 503

    return {
        "status": "healthy",
        "database": database_status,
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
