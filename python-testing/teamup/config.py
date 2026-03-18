"""
Simple configuration - load environment variables

This module loads database configuration from environment variables.
"""
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Database configuration
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "teamup")
DB_TEST_NAME = os.getenv("DB_TEST_NAME", "teamup_test")
DB_USER = os.getenv("DB_USER", "amund.ersland")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_SCHEMA = "teamup"

# Build connection strings
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
TEST_DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_TEST_NAME}"

# Logging configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "DEBUG")
