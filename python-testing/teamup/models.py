"""
SQLAlchemy models for TeamUP database

All models in one file for simplicity and easy reference.

Models:
    - Employee: Team member information
    - LearningMaterialType: Types of learning materials (Book, Course, etc.)
    - LearningMaterial: Educational resources with PostgreSQL-specific fields
"""
from sqlalchemy import String, Integer, Text, ForeignKey, ARRAY
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
from typing import Optional, List


class Base(DeclarativeBase):
    """Base class for all models"""
    pass


class Employee(Base):
    """
    Employee model - represents a team member
    
    Table: teamup.employee
    
    Fields:
        id: Primary key (auto-increment)
        fullname: Full name (required, max 50 chars)
        job_title: Job title (optional, max 30 chars)
        age: Age (optional)
    
    Example:
        employee = Employee(
            fullname="John Doe",
            job_title="Senior Developer",
            age=30
        )
    """
    __tablename__ = "employee"
    __table_args__ = {"schema": "teamup"}
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    fullname: Mapped[str] = mapped_column(String(50), nullable=False)
    job_title: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    age: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    
    def __repr__(self) -> str:
        """String representation for debugging"""
        return f"<Employee(id={self.id}, name='{self.fullname}', title='{self.job_title}')>"
    
    def to_dict(self) -> dict:
        """
        Convert employee to dictionary
        
        Returns:
            dict: Employee data as dictionary
        
        Example:
            employee_dict = employee.to_dict()
            # {'id': 1, 'fullname': 'John Doe', ...}
        """
        return {
            "id": self.id,
            "fullname": self.fullname,
            "job_title": self.job_title,
            "age": self.age
        }


class LearningMaterialType(Base):
    """
    Learning Material Type model - categorizes learning materials
    
    Table: teamup.learning_material_type
    
    Fields:
        id: Primary key (auto-increment)
        name: Type name (required, unique, max 20 chars)
    
    Examples of types:
        - Book
        - Online Course
        - YouTube
        - Live Course
    
    Relationships:
        learning_materials: One-to-many relationship with LearningMaterial
    
    Example:
        book_type = LearningMaterialType(name="Book")
    """
    __tablename__ = "learning_material_type"
    __table_args__ = {"schema": "teamup"}
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(20), nullable=False, unique=True)
    
    # Relationship - one type can have many learning materials
    learning_materials: Mapped[List["LearningMaterial"]] = relationship(
        back_populates="type",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self) -> str:
        """String representation for debugging"""
        return f"<LearningMaterialType(id={self.id}, name='{self.name}')>"
    
    def to_dict(self) -> dict:
        """
        Convert type to dictionary
        
        Returns:
            dict: Type data as dictionary
        """
        return {
            "id": self.id,
            "name": self.name
        }


class LearningMaterial(Base):
    """
    Learning Material model - represents educational resources
    
    Table: teamup.learning_material
    
    Fields:
        id: Primary key (auto-increment)
        name: Material name (required, max 100 chars)
        description: Description (optional, text)
        link: URL link (optional, max 100 chars)
        price: Price in smallest currency unit, e.g., cents (optional)
        type_id: Foreign key to learning_material_type (required)
        tag_ids: Array of tag IDs (PostgreSQL INTEGER[])
        wiki_note_ids: Array of wiki note IDs (PostgreSQL INTEGER[])
        notes: JSON notes stored as text (PostgreSQL JSONB)
    
    Relationships:
        type: Many-to-one relationship with LearningMaterialType
    
    PostgreSQL-Specific Features:
        - ARRAY columns for tag_ids and wiki_note_ids
        - JSONB column for notes (stored as text)
    
    Example:
        material = LearningMaterial(
            name="Clean Code",
            description="A handbook of agile software craftsmanship",
            link="https://example.com/clean-code",
            price=3999,  # $39.99 in cents
            type_id=2,  # Book type
            tag_ids=[1, 2, 3],
            wiki_note_ids=[100, 200],
            notes='{"author": "Robert C. Martin", "pages": 464}'
        )
    """
    __tablename__ = "learning_material"
    __table_args__ = {"schema": "teamup"}
    
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    link: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    price: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    type_id: Mapped[int] = mapped_column(
        ForeignKey("teamup.learning_material_type.id"),
        nullable=False
    )
    
    # PostgreSQL-specific types
    tag_ids: Mapped[Optional[List[int]]] = mapped_column(
        ARRAY(Integer),
        nullable=True,
        default=[]
    )
    wiki_note_ids: Mapped[Optional[List[int]]] = mapped_column(
        ARRAY(Integer),
        nullable=True,
        default=[]
    )
    notes: Mapped[str] = mapped_column(
        Text,
        nullable=False,
        default="[]"
    )  # Stored as JSON string for JSONB compatibility
    
    # Relationship - many materials belong to one type
    type: Mapped["LearningMaterialType"] = relationship(
        back_populates="learning_materials"
    )
    
    def __repr__(self) -> str:
        """String representation for debugging"""
        type_name = self.type.name if self.type else "Unknown"
        return f"<LearningMaterial(id={self.id}, name='{self.name}', type='{type_name}')>"
    
    def to_dict(self) -> dict:
        """
        Convert learning material to dictionary
        
        Returns:
            dict: Learning material data as dictionary
        
        Example:
            material_dict = material.to_dict()
            # Includes all fields plus related type information
        """
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "link": self.link,
            "price": self.price,
            "type_id": self.type_id,
            "type": self.type.to_dict() if self.type else None,
            "tag_ids": self.tag_ids,
            "wiki_note_ids": self.wiki_note_ids,
            "notes": self.notes
        }
