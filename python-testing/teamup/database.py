"""
Simple database connection management

This module provides database session management with context managers.
All operations automatically commit on success and rollback on error.
"""
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from contextlib import contextmanager
import logging

from teamup.config import DATABASE_URL, TEST_DATABASE_URL, DB_SCHEMA, LOG_LEVEL

# Configure logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create engines
engine = create_engine(DATABASE_URL, echo=False, pool_pre_ping=True)
test_engine = create_engine(TEST_DATABASE_URL, echo=False, pool_pre_ping=True)

# Session factories
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
TestSessionLocal = sessionmaker(bind=test_engine, autoflush=False, autocommit=False)


@contextmanager
def get_session(use_test_db: bool = False):
    """
    Simple context manager for database sessions
    
    Args:
        use_test_db: If True, use test database instead of main database
    
    Yields:
        Session: SQLAlchemy session with automatic commit/rollback
    
    Example:
        with get_session() as session:
            repo = EmployeeRepository(session)
            employee = repo.create(fullname="John Doe")
            # Automatically commits on success
    
    Example with test database:
        with get_session(use_test_db=True) as session:
            repo = EmployeeRepository(session)
            employee = repo.create(fullname="Test User")
    """
    SessionFactory = TestSessionLocal if use_test_db else SessionLocal
    session = SessionFactory()
    
    try:
        # Set search path to teamup schema
        session.execute(text(f"SET search_path TO {DB_SCHEMA}"))
        session.commit()
        
        yield session
        
        # Commit on success
        session.commit()
        logger.debug("Transaction committed successfully")
        
    except Exception as e:
        # Rollback on error
        session.rollback()
        logger.error(f"Transaction rolled back due to error: {e}")
        raise
        
    finally:
        session.close()


def create_all_tables(use_test_db: bool = False):
    """
    Create all tables in the database
    
    Args:
        use_test_db: If True, create tables in test database
    
    Example:
        create_all_tables(use_test_db=True)  # Create test database tables
    """
    from teamup.models import Base
    target_engine = test_engine if use_test_db else engine
    Base.metadata.create_all(target_engine)
    db_name = "test" if use_test_db else "main"
    logger.info(f"Created all tables in {db_name} database")


def drop_all_tables(use_test_db: bool = False):
    """
    Drop all tables in the database
    
    Args:
        use_test_db: If True, drop tables in test database
    
    Warning:
        This will delete all data! Use with caution.
    
    Example:
        drop_all_tables(use_test_db=True)  # Drop test database tables
    """
    from teamup.models import Base
    target_engine = test_engine if use_test_db else engine
    Base.metadata.drop_all(target_engine)
    db_name = "test" if use_test_db else "main"
    logger.info(f"Dropped all tables in {db_name} database")


def test_connection(use_test_db: bool = False):
    """
    Test database connection
    
    Args:
        use_test_db: If True, test connection to test database
    
    Returns:
        bool: True if connection successful, False otherwise
    
    Example:
        if test_connection(use_test_db=True):
            print("Test database connection OK")
    """
    try:
        target_engine = test_engine if use_test_db else engine
        with target_engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_name = "test" if use_test_db else "main"
        logger.info(f"Successfully connected to {db_name} database")
        return True
    except Exception as e:
        logger.error(f"Failed to connect to database: {e}")
        return False
