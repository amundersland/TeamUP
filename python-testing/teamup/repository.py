"""
Repository classes for data access

All repositories in one file for simplicity.
Each repository provides CRUD operations for its model.

Repositories:
    - EmployeeRepository: CRUD operations for employees
    - LearningMaterialTypeRepository: CRUD operations for types
    - LearningMaterialRepository: CRUD operations for learning materials
"""
from sqlalchemy.orm import Session
from sqlalchemy import select
from typing import Optional, List
import logging

from teamup.models import Employee, LearningMaterial, LearningMaterialType

logger = logging.getLogger(__name__)


class EmployeeRepository:
    """
    Simple repository for Employee CRUD operations
    
    This class provides all database operations for the Employee model.
    All operations use the provided session and don't commit automatically.
    The session's context manager handles commit/rollback.
    
    Args:
        session: SQLAlchemy session to use for database operations
    
    Example:
        with get_session() as session:
            repo = EmployeeRepository(session)
            employee = repo.create(fullname="John Doe", job_title="Developer")
            # Automatically commits when exiting context
    """
    
    def __init__(self, session: Session):
        """Initialize repository with database session"""
        self.session = session
    
    def create(
        self,
        fullname: str,
        job_title: Optional[str] = None,
        age: Optional[int] = None
    ) -> Employee:
        """
        Create a new employee
        
        Args:
            fullname: Employee's full name (required, max 50 chars)
            job_title: Employee's job title (optional, max 30 chars)
            age: Employee's age (optional)
        
        Returns:
            Employee: The created employee with ID assigned
        
        Example:
            employee = repo.create(
                fullname="Jane Smith",
                job_title="Senior Developer",
                age=32
            )
            print(f"Created employee with ID: {employee.id}")
        """
        employee = Employee(fullname=fullname, job_title=job_title, age=age)
        self.session.add(employee)
        self.session.flush()  # Get the ID without committing
        logger.debug(f"Created employee: {employee}")
        return employee
    
    def get_by_id(self, employee_id: int) -> Optional[Employee]:
        """
        Get employee by ID
        
        Args:
            employee_id: The employee's ID
        
        Returns:
            Employee if found, None otherwise
        
        Example:
            employee = repo.get_by_id(1)
            if employee:
                print(f"Found: {employee.fullname}")
        """
        return self.session.get(Employee, employee_id)
    
    def get_all(self, limit: Optional[int] = None, offset: int = 0) -> List[Employee]:
        """
        Get all employees
        
        Args:
            limit: Maximum number of employees to return (optional)
            offset: Number of employees to skip (default: 0)
        
        Returns:
            List of all employees
        
        Example:
            # Get first 10 employees
            employees = repo.get_all(limit=10)
            
            # Get next 10 employees
            employees = repo.get_all(limit=10, offset=10)
        """
        query = select(Employee).offset(offset)
        if limit:
            query = query.limit(limit)
        return list(self.session.execute(query).scalars())
    
    def update(self, employee_id: int, **kwargs) -> Optional[Employee]:
        """
        Update employee fields
        
        Args:
            employee_id: The employee's ID
            **kwargs: Fields to update (fullname, job_title, age)
        
        Returns:
            Updated employee if found, None otherwise
        
        Example:
            updated = repo.update(
                1,
                job_title="Lead Developer",
                age=33
            )
        """
        employee = self.get_by_id(employee_id)
        if employee:
            for key, value in kwargs.items():
                if hasattr(employee, key):
                    setattr(employee, key, value)
            self.session.flush()
            logger.debug(f"Updated employee {employee_id}: {kwargs}")
        return employee
    
    def delete(self, employee_id: int) -> bool:
        """
        Delete employee by ID
        
        Args:
            employee_id: The employee's ID
        
        Returns:
            True if deleted, False if not found
        
        Example:
            if repo.delete(1):
                print("Employee deleted")
            else:
                print("Employee not found")
        """
        employee = self.get_by_id(employee_id)
        if employee:
            self.session.delete(employee)
            self.session.flush()
            logger.debug(f"Deleted employee {employee_id}")
            return True
        return False
    
    def find_by_name(self, name: str, exact: bool = False) -> List[Employee]:
        """
        Find employees by name (partial or exact match)
        
        Args:
            name: Name to search for
            exact: If True, exact match. If False, partial match (default)
        
        Returns:
            List of matching employees
        
        Example:
            # Partial match (finds "John Doe", "Johnny", etc.)
            results = repo.find_by_name("John")
            
            # Exact match
            results = repo.find_by_name("John Doe", exact=True)
        """
        if exact:
            query = select(Employee).where(Employee.fullname == name)
        else:
            query = select(Employee).where(Employee.fullname.ilike(f"%{name}%"))
        return list(self.session.execute(query).scalars())
    
    def find_by_job_title(self, job_title: str) -> List[Employee]:
        """
        Find employees by job title (exact match)
        
        Args:
            job_title: Job title to search for
        
        Returns:
            List of employees with matching job title
        
        Example:
            developers = repo.find_by_job_title("Developer")
        """
        query = select(Employee).where(Employee.job_title == job_title)
        return list(self.session.execute(query).scalars())
    
    def find_by_age_range(self, min_age: int, max_age: int) -> List[Employee]:
        """
        Find employees within an age range (inclusive)
        
        Args:
            min_age: Minimum age (inclusive)
            max_age: Maximum age (inclusive)
        
        Returns:
            List of employees within the age range
        
        Example:
            employees = repo.find_by_age_range(25, 35)
        """
        query = select(Employee).where(
            Employee.age >= min_age,
            Employee.age <= max_age
        )
        return list(self.session.execute(query).scalars())
    
    def count(self) -> int:
        """
        Count total number of employees
        
        Returns:
            Total count of employees
        
        Example:
            total = repo.count()
            print(f"Total employees: {total}")
        """
        return self.session.query(Employee).count()


class LearningMaterialTypeRepository:
    """
    Simple repository for LearningMaterialType CRUD operations
    
    This class provides all database operations for the LearningMaterialType model.
    
    Args:
        session: SQLAlchemy session to use for database operations
    
    Example:
        with get_session() as session:
            repo = LearningMaterialTypeRepository(session)
            book_type = repo.create(name="Book")
    """
    
    def __init__(self, session: Session):
        """Initialize repository with database session"""
        self.session = session
    
    def create(self, name: str) -> LearningMaterialType:
        """
        Create a new learning material type
        
        Args:
            name: Type name (required, unique, max 20 chars)
        
        Returns:
            LearningMaterialType: The created type with ID assigned
        
        Example:
            book_type = repo.create(name="Book")
            video_type = repo.create(name="Video Course")
        """
        material_type = LearningMaterialType(name=name)
        self.session.add(material_type)
        self.session.flush()
        logger.debug(f"Created learning material type: {material_type}")
        return material_type
    
    def get_by_id(self, type_id: int) -> Optional[LearningMaterialType]:
        """
        Get type by ID
        
        Args:
            type_id: The type's ID
        
        Returns:
            LearningMaterialType if found, None otherwise
        """
        return self.session.get(LearningMaterialType, type_id)
    
    def get_by_name(self, name: str) -> Optional[LearningMaterialType]:
        """
        Get type by name (exact match)
        
        Args:
            name: The type's name
        
        Returns:
            LearningMaterialType if found, None otherwise
        
        Example:
            book_type = repo.get_by_name("Book")
        """
        query = select(LearningMaterialType).where(LearningMaterialType.name == name)
        return self.session.execute(query).scalar_one_or_none()
    
    def get_all(self) -> List[LearningMaterialType]:
        """
        Get all types
        
        Returns:
            List of all learning material types
        
        Example:
            types = repo.get_all()
            for t in types:
                print(f"{t.id}: {t.name}")
        """
        query = select(LearningMaterialType)
        return list(self.session.execute(query).scalars())
    
    def delete(self, type_id: int) -> bool:
        """
        Delete type by ID
        
        Warning: This will also delete all learning materials of this type
        due to the cascade relationship.
        
        Args:
            type_id: The type's ID
        
        Returns:
            True if deleted, False if not found
        """
        material_type = self.get_by_id(type_id)
        if material_type:
            self.session.delete(material_type)
            self.session.flush()
            logger.debug(f"Deleted learning material type {type_id}")
            return True
        return False
    
    def count(self) -> int:
        """
        Count total number of types
        
        Returns:
            Total count of types
        """
        return self.session.query(LearningMaterialType).count()


class LearningMaterialRepository:
    """
    Simple repository for LearningMaterial CRUD operations
    
    This class provides all database operations for the LearningMaterial model,
    including handling PostgreSQL-specific features like arrays and JSONB.
    
    Args:
        session: SQLAlchemy session to use for database operations
    
    Example:
        with get_session() as session:
            repo = LearningMaterialRepository(session)
            material = repo.create(
                name="Clean Code",
                type_id=2,
                price=3999
            )
    """
    
    def __init__(self, session: Session):
        """Initialize repository with database session"""
        self.session = session
    
    def create(
        self,
        name: str,
        type_id: int,
        description: Optional[str] = None,
        link: Optional[str] = None,
        price: Optional[int] = None,
        tag_ids: Optional[List[int]] = None,
        wiki_note_ids: Optional[List[int]] = None,
        notes: str = "[]"
    ) -> LearningMaterial:
        """
        Create a new learning material
        
        Args:
            name: Material name (required, max 100 chars)
            type_id: Learning material type ID (required, must exist)
            description: Description text (optional)
            link: URL link (optional, max 100 chars)
            price: Price in smallest currency unit (optional)
            tag_ids: List of tag IDs (optional, PostgreSQL array)
            wiki_note_ids: List of wiki note IDs (optional, PostgreSQL array)
            notes: JSON string for notes (optional, defaults to "[]")
        
        Returns:
            LearningMaterial: The created material with ID assigned
        
        Example:
            material = repo.create(
                name="Python for Beginners",
                type_id=3,  # Online Course
                description="Learn Python from scratch",
                price=4999,  # $49.99
                tag_ids=[1, 2, 3],
                notes='{"instructor": "Jane Doe", "hours": 10}'
            )
        """
        material = LearningMaterial(
            name=name,
            type_id=type_id,
            description=description,
            link=link,
            price=price,
            tag_ids=tag_ids or [],
            wiki_note_ids=wiki_note_ids or [],
            notes=notes
        )
        self.session.add(material)
        self.session.flush()
        logger.debug(f"Created learning material: {material}")
        return material
    
    def get_by_id(self, material_id: int) -> Optional[LearningMaterial]:
        """
        Get learning material by ID
        
        Args:
            material_id: The material's ID
        
        Returns:
            LearningMaterial if found (with type relationship loaded), None otherwise
        
        Example:
            material = repo.get_by_id(1)
            if material:
                print(f"{material.name} ({material.type.name})")
        """
        return self.session.get(LearningMaterial, material_id)
    
    def get_all(self, limit: Optional[int] = None, offset: int = 0) -> List[LearningMaterial]:
        """
        Get all learning materials
        
        Args:
            limit: Maximum number of materials to return (optional)
            offset: Number of materials to skip (default: 0)
        
        Returns:
            List of all learning materials
        
        Example:
            materials = repo.get_all(limit=20)
        """
        query = select(LearningMaterial).offset(offset)
        if limit:
            query = query.limit(limit)
        return list(self.session.execute(query).scalars())
    
    def update(self, material_id: int, **kwargs) -> Optional[LearningMaterial]:
        """
        Update learning material fields
        
        Args:
            material_id: The material's ID
            **kwargs: Fields to update
        
        Returns:
            Updated material if found, None otherwise
        
        Example:
            updated = repo.update(
                1,
                name="Clean Code (2nd Edition)",
                price=4499,
                tag_ids=[1, 2, 3, 4]
            )
        """
        material = self.get_by_id(material_id)
        if material:
            for key, value in kwargs.items():
                if hasattr(material, key):
                    setattr(material, key, value)
            self.session.flush()
            logger.debug(f"Updated learning material {material_id}: {kwargs}")
        return material
    
    def delete(self, material_id: int) -> bool:
        """
        Delete learning material by ID
        
        Args:
            material_id: The material's ID
        
        Returns:
            True if deleted, False if not found
        
        Example:
            if repo.delete(1):
                print("Material deleted")
        """
        material = self.get_by_id(material_id)
        if material:
            self.session.delete(material)
            self.session.flush()
            logger.debug(f"Deleted learning material {material_id}")
            return True
        return False
    
    def find_by_type(self, type_id: int) -> List[LearningMaterial]:
        """
        Find learning materials by type
        
        Args:
            type_id: The type's ID
        
        Returns:
            List of materials with matching type
        
        Example:
            # Get all books (assuming type_id=2 is Book)
            books = repo.find_by_type(2)
        """
        query = select(LearningMaterial).where(LearningMaterial.type_id == type_id)
        return list(self.session.execute(query).scalars())
    
    def find_by_name(self, name: str, exact: bool = False) -> List[LearningMaterial]:
        """
        Find learning materials by name
        
        Args:
            name: Name to search for
            exact: If True, exact match. If False, partial match (default)
        
        Returns:
            List of matching materials
        
        Example:
            # Find all materials with "Python" in the name
            python_materials = repo.find_by_name("Python")
        """
        if exact:
            query = select(LearningMaterial).where(LearningMaterial.name == name)
        else:
            query = select(LearningMaterial).where(LearningMaterial.name.ilike(f"%{name}%"))
        return list(self.session.execute(query).scalars())
    
    def find_by_price_range(
        self,
        min_price: Optional[int] = None,
        max_price: Optional[int] = None
    ) -> List[LearningMaterial]:
        """
        Find learning materials within a price range
        
        Args:
            min_price: Minimum price (inclusive, optional)
            max_price: Maximum price (inclusive, optional)
        
        Returns:
            List of materials within price range
        
        Example:
            # Find materials between $10 and $50
            materials = repo.find_by_price_range(min_price=1000, max_price=5000)
        """
        query = select(LearningMaterial)
        if min_price is not None:
            query = query.where(LearningMaterial.price >= min_price)
        if max_price is not None:
            query = query.where(LearningMaterial.price <= max_price)
        return list(self.session.execute(query).scalars())
    
    def count(self) -> int:
        """
        Count total number of learning materials
        
        Returns:
            Total count of materials
        """
        return self.session.query(LearningMaterial).count()
