"""
Pytest configuration and fixtures for TeamUP tests

This module provides test fixtures for database setup, test data generation,
and transaction management. Each test runs in isolation with a clean database state.
"""
import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from teamup.models import Base
import teamup.config as config

# Create test engine
test_engine = create_engine(
    config.DATABASE_URL,  # Using main database for now
    echo=False  # Set to True for SQL debugging
)

TestSessionLocal = sessionmaker(bind=test_engine)


@pytest.fixture(scope="session", autouse=True)
def setup_test_database():
    """
    Session-level fixture to create all tables before tests run
    and drop them after all tests complete.
    
    This ensures we have a clean database schema for testing.
    """
    # Create all tables
    Base.metadata.create_all(bind=test_engine)
    
    yield
    
    # Drop all tables after tests
    # Comment out the line below if you want to inspect data after tests
    # Base.metadata.drop_all(bind=test_engine)


@pytest.fixture(scope="function")
def db_session() -> Session:
    """
    Function-level fixture providing a database session with automatic rollback.
    
    Each test gets a fresh session, and all changes are rolled back after the test,
    ensuring test isolation without requiring database recreation.
    
    Usage:
        def test_something(db_session):
            # Your test code using db_session
            pass
    """
    connection = test_engine.connect()
    transaction = connection.begin()
    session = TestSessionLocal(bind=connection)
    
    # Set schema search path
    session.execute(text(f"SET search_path TO {config.DB_SCHEMA}"))
    
    yield session
    
    # Rollback transaction to undo any changes
    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture(scope="function")
def clean_db(db_session):
    """
    Fixture that provides a completely empty database for tests.
    
    This is useful for tests that need to start with no data at all.
    
    Usage:
        def test_with_empty_db(clean_db):
            # Database is empty here
            pass
    """
    from teamup.models import Employee, LearningMaterial, LearningMaterialType
    
    # Delete all data
    db_session.query(LearningMaterial).delete()
    db_session.query(LearningMaterialType).delete()
    db_session.query(Employee).delete()
    db_session.commit()
    
    yield db_session
