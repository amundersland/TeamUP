"""
Tests for database connection and session management

This module tests the database connection utilities and context managers.
"""
import pytest
from sqlalchemy import text
from teamup.database import get_session, test_connection, engine, test_engine


class TestDatabaseConnection:
    """Test database connection functions"""
    
    def test_engine_exists(self):
        """Test that main database engine exists"""
        assert engine is not None
        assert str(engine.url).startswith("postgresql://")
    
    def test_test_engine_exists(self):
        """Test that test database engine exists"""
        assert test_engine is not None
        # Both engines should use PostgreSQL
        assert str(test_engine.url).startswith("postgresql://")
    
    def test_connection_to_main_db(self):
        """Test connection to main database"""
        result = test_connection(use_test_db=False)
        assert result is True


class TestSessionContextManagers:
    """Test session context managers"""
    
    def test_get_session_context_manager(self):
        """Test get_session as context manager"""
        with get_session() as session:
            assert session is not None
            # Execute a simple query to verify session works
            result = session.execute(text("SELECT 1 as num"))
            row = result.first()
            assert row[0] == 1
    
    def test_session_rollback_on_exception(self, clean_db):
        """Test that session rolls back on exception"""
        from teamup.repository import EmployeeRepository
        
        # Track initial count
        with get_session() as session:
            repo = EmployeeRepository(session)
            initial_count = repo.count()
        
        try:
            with get_session() as session:
                repo = EmployeeRepository(session)
                # Create an employee
                emp = repo.create(fullname="Test Employee", age=25)
                emp_id = emp.id
                
                # Force an error before commit
                raise ValueError("Intentional error")
        except ValueError:
            pass
        
        # Verify the employee was rolled back (count should be same)
        with get_session() as session:
            repo = EmployeeRepository(session)
            final_count = repo.count()
            assert final_count == initial_count
    
    def test_session_commits_on_success(self, clean_db):
        """Test that session commits on successful completion"""
        from teamup.repository import EmployeeRepository
        
        emp_id = None
        
        # Create employee in one session
        with get_session() as session:
            repo = EmployeeRepository(session)
            emp = repo.create(fullname="Persistent Employee", age=30)
            emp_id = emp.id
        
        # Verify it persists in a new session
        with get_session() as session:
            repo = EmployeeRepository(session)
            retrieved = repo.get_by_id(emp_id)
            assert retrieved is not None
            assert retrieved.fullname == "Persistent Employee"
            
            # Clean up
            repo.delete(emp_id)


class TestDatabaseConfiguration:
    """Test database configuration"""
    
    def test_database_url_format(self):
        """Test that database URL is properly formatted"""
        import teamup.config as config
        
        assert config.DATABASE_URL.startswith("postgresql://")
        assert config.DB_HOST in config.DATABASE_URL
        assert str(config.DB_PORT) in config.DATABASE_URL
        assert config.DB_NAME in config.DATABASE_URL
    
    def test_test_database_url_format(self):
        """Test that test database URL is properly formatted"""
        import teamup.config as config
        
        assert config.TEST_DATABASE_URL.startswith("postgresql://")
        assert config.DB_TEST_NAME in config.TEST_DATABASE_URL
    
    def test_schema_configuration(self):
        """Test that schema is configured"""
        import teamup.config as config
        
        assert config.DB_SCHEMA is not None
        assert len(config.DB_SCHEMA) > 0
