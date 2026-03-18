"""
Tests for Employee model and EmployeeRepository

This module tests all CRUD operations for employees, including:
- Creating employees with various field combinations
- Reading individual and multiple employees
- Updating employee information
- Deleting employees
- Edge cases and validation
"""
import pytest
from teamup.models import Employee
from teamup.repository import EmployeeRepository
from tests.factories import create_fake_employee, create_fake_fullname, create_fake_job_title


class TestEmployeeModel:
    """Tests for Employee model"""
    
    def test_create_employee_with_all_fields(self):
        """Test creating an employee with all fields populated"""
        employee = Employee(
            fullname="John Doe",
            job_title="Software Engineer",
            age=30
        )
        assert employee.fullname == "John Doe"
        assert employee.job_title == "Software Engineer"
        assert employee.age == 30
    
    def test_create_employee_with_required_fields_only(self):
        """Test creating an employee with only required fields"""
        employee = Employee(fullname="Jane Smith")
        assert employee.fullname == "Jane Smith"
        assert employee.job_title is None
        assert employee.age is None
    
    def test_employee_representation(self):
        """Test employee string representation"""
        employee = Employee(fullname="John Doe", job_title="Engineer")
        repr_str = repr(employee)
        assert "Employee" in repr_str
        assert "John Doe" in repr_str


class TestEmployeeRepository:
    """Tests for EmployeeRepository CRUD operations"""
    
    def test_create_employee(self, db_session):
        """Test creating a new employee"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(
            fullname="Alice Johnson",
            job_title="Developer",
            age=28
        )
        
        assert employee.id is not None
        assert employee.fullname == "Alice Johnson"
        assert employee.job_title == "Developer"
        assert employee.age == 28
    
    def test_create_employee_minimal(self, db_session):
        """Test creating employee with only required fields"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(fullname="Bob Smith")
        
        assert employee.id is not None
        assert employee.fullname == "Bob Smith"
        assert employee.job_title is None
        assert employee.age is None
    
    def test_get_by_id_existing(self, db_session):
        """Test retrieving an existing employee by ID"""
        repo = EmployeeRepository(db_session)
        created = repo.create(fullname="Charlie Brown", age=35)
        
        retrieved = repo.get_by_id(created.id)
        assert retrieved is not None
        assert retrieved.id == created.id
        assert retrieved.fullname == "Charlie Brown"
        assert retrieved.age == 35
    
    def test_get_by_id_nonexistent(self, db_session):
        """Test retrieving a non-existent employee returns None"""
        repo = EmployeeRepository(db_session)
        employee = repo.get_by_id(999999)
        assert employee is None
    
    def test_get_all_empty(self, clean_db):
        """Test get_all returns empty list when no employees exist"""
        repo = EmployeeRepository(clean_db)
        employees = repo.get_all()
        assert employees == []
    
    def test_get_all_multiple(self, clean_db):
        """Test get_all returns all employees"""
        repo = EmployeeRepository(clean_db)
        
        # Create multiple employees
        repo.create(fullname="Employee 1")
        repo.create(fullname="Employee 2")
        repo.create(fullname="Employee 3")
        
        employees = repo.get_all()
        assert len(employees) == 3
        names = [e.fullname for e in employees]
        assert "Employee 1" in names
        assert "Employee 2" in names
        assert "Employee 3" in names
    
    def test_update_employee_all_fields(self, db_session):
        """Test updating all fields of an employee"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(fullname="Old Name", job_title="Old Job", age=25)
        
        updated = repo.update(
            employee.id,
            fullname="New Name",
            job_title="New Job",
            age=30
        )
        
        assert updated.fullname == "New Name"
        assert updated.job_title == "New Job"
        assert updated.age == 30
    
    def test_update_employee_partial(self, db_session):
        """Test updating only some fields"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(fullname="John Doe", job_title="Engineer", age=30)
        
        updated = repo.update(employee.id, job_title="Senior Engineer")
        
        assert updated.fullname == "John Doe"  # Unchanged
        assert updated.job_title == "Senior Engineer"  # Changed
        assert updated.age == 30  # Unchanged
    
    def test_update_nonexistent_employee(self, db_session):
        """Test updating a non-existent employee returns None"""
        repo = EmployeeRepository(db_session)
        result = repo.update(999999, fullname="Ghost")
        assert result is None
    
    def test_delete_existing_employee(self, db_session):
        """Test deleting an existing employee"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(fullname="To Be Deleted")
        employee_id = employee.id
        
        result = repo.delete(employee_id)
        assert result is True
        
        # Verify it's gone
        deleted = repo.get_by_id(employee_id)
        assert deleted is None
    
    def test_delete_nonexistent_employee(self, db_session):
        """Test deleting a non-existent employee returns False"""
        repo = EmployeeRepository(db_session)
        result = repo.delete(999999)
        assert result is False
    
    def test_find_by_name_exact(self, clean_db):
        """Test finding employees by exact name match"""
        repo = EmployeeRepository(clean_db)
        repo.create(fullname="Alice Smith")
        repo.create(fullname="Bob Jones")
        repo.create(fullname="Alice Johnson")
        
        results = repo.find_by_name("Alice Smith")
        assert len(results) == 1
        assert results[0].fullname == "Alice Smith"
    
    def test_find_by_name_partial(self, clean_db):
        """Test finding employees by partial name match"""
        repo = EmployeeRepository(clean_db)
        repo.create(fullname="Alice Smith")
        repo.create(fullname="Bob Jones")
        repo.create(fullname="Alice Johnson")
        
        results = repo.find_by_name("Alice")
        assert len(results) == 2
        names = [e.fullname for e in results]
        assert "Alice Smith" in names
        assert "Alice Johnson" in names
    
    def test_find_by_name_case_insensitive(self, clean_db):
        """Test that name search is case-insensitive"""
        repo = EmployeeRepository(clean_db)
        repo.create(fullname="John Doe")
        
        results = repo.find_by_name("john doe")
        assert len(results) == 1
        assert results[0].fullname == "John Doe"
    
    def test_find_by_name_no_matches(self, clean_db):
        """Test finding employees with no matches returns empty list"""
        repo = EmployeeRepository(clean_db)
        repo.create(fullname="Alice Smith")
        
        results = repo.find_by_name("Bob")
        assert results == []
    
    def test_find_by_job_title(self, clean_db):
        """Test finding employees by job title"""
        repo = EmployeeRepository(clean_db)
        repo.create(fullname="Alice", job_title="Engineer")
        repo.create(fullname="Bob", job_title="Manager")
        repo.create(fullname="Charlie", job_title="Engineer")
        
        results = repo.find_by_job_title("Engineer")
        assert len(results) == 2
        names = [e.fullname for e in results]
        assert "Alice" in names
        assert "Charlie" in names
    
    def test_find_by_age_range(self, clean_db):
        """Test finding employees by age range"""
        repo = EmployeeRepository(clean_db)
        repo.create(fullname="Young", age=25)
        repo.create(fullname="Middle", age=35)
        repo.create(fullname="Senior", age=55)
        
        results = repo.find_by_age_range(30, 50)
        assert len(results) == 1
        assert results[0].fullname == "Middle"


class TestEmployeeEdgeCases:
    """Test edge cases and validation for employees"""
    
    def test_create_employee_with_max_length_name(self, db_session):
        """Test creating employee with maximum length name (50 chars)"""
        repo = EmployeeRepository(db_session)
        long_name = "A" * 50
        employee = repo.create(fullname=long_name)
        assert employee.fullname == long_name
    
    def test_create_employee_with_max_length_job_title(self, db_session):
        """Test creating employee with maximum length job title (30 chars)"""
        repo = EmployeeRepository(db_session)
        long_title = "A" * 30
        employee = repo.create(fullname="Test", job_title=long_title)
        assert employee.job_title == long_title
    
    def test_create_employee_with_minimum_valid_age(self, db_session):
        """Test creating employee with minimum valid age (1)"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(fullname="Young Person", age=1)
        assert employee.age == 1
    
    def test_create_employee_with_very_high_age(self, db_session):
        """Test creating employee with very high age"""
        repo = EmployeeRepository(db_session)
        employee = repo.create(fullname="Ancient One", age=120)
        assert employee.age == 120
    
    def test_multiple_employees_same_name(self, clean_db):
        """Test that multiple employees can have the same name"""
        repo = EmployeeRepository(clean_db)
        emp1 = repo.create(fullname="John Smith")
        emp2 = repo.create(fullname="John Smith")
        
        assert emp1.id != emp2.id
        assert emp1.fullname == emp2.fullname


class TestEmployeeWithFaker:
    """Tests using Faker-generated data"""
    
    def test_create_employee_with_faker(self, db_session):
        """Test creating employee with Faker-generated data"""
        repo = EmployeeRepository(db_session)
        fake_emp = create_fake_employee()
        
        employee = repo.create(
            fullname=fake_emp.fullname,
            job_title=fake_emp.job_title,
            age=fake_emp.age
        )
        
        assert employee.id is not None
        assert employee.fullname == fake_emp.fullname
        assert employee.job_title == fake_emp.job_title
        assert employee.age == fake_emp.age
    
    def test_bulk_create_with_faker(self, clean_db):
        """Test creating multiple employees with Faker data"""
        repo = EmployeeRepository(clean_db)
        
        for _ in range(10):
            fake_emp = create_fake_employee()
            repo.create(
                fullname=fake_emp.fullname,
                job_title=fake_emp.job_title,
                age=fake_emp.age
            )
        
        employees = repo.get_all()
        assert len(employees) == 10
