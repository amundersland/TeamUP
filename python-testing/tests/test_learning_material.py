"""
Tests for LearningMaterialType and LearningMaterial models and repositories

This module tests all CRUD operations for learning material types and materials, including:
- Creating types and materials with various field combinations
- Reading individual and multiple items
- Updating information
- Deleting items
- Relationships between types and materials
- Edge cases and validation for PostgreSQL arrays and JSONB
"""
import pytest
import json
from teamup.models import LearningMaterialType, LearningMaterial
from teamup.repository import LearningMaterialTypeRepository, LearningMaterialRepository
from tests.factories import create_fake_type, create_fake_material


class TestLearningMaterialTypeModel:
    """Tests for LearningMaterialType model"""
    
    def test_create_type_with_name(self):
        """Test creating a type with a name"""
        type_obj = LearningMaterialType(name="Book")
        assert type_obj.name == "Book"
    
    def test_type_representation(self):
        """Test type string representation"""
        type_obj = LearningMaterialType(name="Online Course")
        repr_str = repr(type_obj)
        assert "LearningMaterialType" in repr_str
        assert "Online Course" in repr_str


class TestLearningMaterialTypeRepository:
    """Tests for LearningMaterialTypeRepository CRUD operations"""
    
    def test_create_type(self, db_session):
        """Test creating a new type"""
        repo = LearningMaterialTypeRepository(db_session)
        type_obj = repo.create(name="Video Tutorial")
        
        assert type_obj.id is not None
        assert type_obj.name == "Video Tutorial"
    
    def test_get_by_id_existing(self, db_session):
        """Test retrieving an existing type by ID"""
        repo = LearningMaterialTypeRepository(db_session)
        created = repo.create(name="Workshop")
        
        retrieved = repo.get_by_id(created.id)
        assert retrieved is not None
        assert retrieved.id == created.id
        assert retrieved.name == "Workshop"
    
    def test_get_by_id_nonexistent(self, db_session):
        """Test retrieving a non-existent type returns None"""
        repo = LearningMaterialTypeRepository(db_session)
        type_obj = repo.get_by_id(999999)
        assert type_obj is None
    
    def test_get_by_name_existing(self, db_session):
        """Test retrieving a type by name"""
        repo = LearningMaterialTypeRepository(db_session)
        repo.create(name="Certification")
        
        retrieved = repo.get_by_name("Certification")
        assert retrieved is not None
        assert retrieved.name == "Certification"
    
    def test_get_by_name_nonexistent(self, db_session):
        """Test retrieving non-existent type by name returns None"""
        repo = LearningMaterialTypeRepository(db_session)
        type_obj = repo.get_by_name("NonExistent")
        assert type_obj is None
    
    def test_get_all_empty(self, clean_db):
        """Test get_all returns empty list when no types exist"""
        repo = LearningMaterialTypeRepository(clean_db)
        types = repo.get_all()
        assert types == []
    
    def test_get_all_multiple(self, clean_db):
        """Test get_all returns all types"""
        repo = LearningMaterialTypeRepository(clean_db)
        
        repo.create(name="Book")
        repo.create(name="Course")
        repo.create(name="Video")
        
        types = repo.get_all()
        assert len(types) == 3
        names = [t.name for t in types]
        assert "Book" in names
        assert "Course" in names
        assert "Video" in names
    
    def test_delete_existing_type(self, clean_db):
        """Test deleting an existing type"""
        repo = LearningMaterialTypeRepository(clean_db)
        type_obj = repo.create(name="To Be Deleted")
        type_id = type_obj.id
        
        result = repo.delete(type_id)
        assert result is True
        
        # Verify it's gone
        deleted = repo.get_by_id(type_id)
        assert deleted is None
    
    def test_delete_nonexistent_type(self, db_session):
        """Test deleting a non-existent type returns False"""
        repo = LearningMaterialTypeRepository(db_session)
        result = repo.delete(999999)
        assert result is False


class TestLearningMaterialModel:
    """Tests for LearningMaterial model"""
    
    def test_create_material_with_all_fields(self):
        """Test creating a material with all fields"""
        material = LearningMaterial(
            name="Python Guide",
            description="Comprehensive Python guide",
            link="https://example.com",
            price=2500,
            type_id=1,
            tag_ids=[1, 2, 3],
            wiki_note_ids=[10, 20],
            notes='{"author": "John", "rating": 5}'
        )
        assert material.name == "Python Guide"
        assert material.description == "Comprehensive Python guide"
        assert material.link == "https://example.com"
        assert material.price == 2500
        assert material.type_id == 1
        assert material.tag_ids == [1, 2, 3]
        assert material.wiki_note_ids == [10, 20]
        assert material.notes == '{"author": "John", "rating": 5}'
    
    def test_create_material_minimal(self):
        """Test creating material with only required fields"""
        material = LearningMaterial(name="Minimal", type_id=1)
        assert material.name == "Minimal"
        assert material.type_id == 1
        assert material.description is None
        assert material.link is None
        assert material.price is None
        assert material.tag_ids is None
        assert material.wiki_note_ids is None
        assert material.notes is None


class TestLearningMaterialRepository:
    """Tests for LearningMaterialRepository CRUD operations"""
    
    def test_create_material_full(self, clean_db):
        """Test creating a material with all fields (except arrays that need foreign keys)"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create a type first
        type_obj = type_repo.create(name="Book")
        
        # Create material
        material = mat_repo.create(
            name="Advanced Python",
            description="Deep dive into Python",
            link="https://python.org",
            price=3000,
            type_id=type_obj.id,
            notes='{"author": "Guido", "year": 2026}'
        )
        
        assert material.id is not None
        assert material.name == "Advanced Python"
        assert material.description == "Deep dive into Python"
        assert material.link == "https://python.org"
        assert material.price == 3000
        assert material.type_id == type_obj.id
        assert material.notes == '{"author": "Guido", "year": 2026}'
    
    def test_create_material_minimal(self, clean_db):
        """Test creating material with only required fields"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Course")
        material = mat_repo.create(name="Basics", type_id=type_obj.id)
        
        assert material.id is not None
        assert material.name == "Basics"
        assert material.type_id == type_obj.id
    
    def test_get_by_id_existing(self, clean_db):
        """Test retrieving an existing material by ID"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Video")
        created = mat_repo.create(name="Test Video", type_id=type_obj.id)
        
        retrieved = mat_repo.get_by_id(created.id)
        assert retrieved is not None
        assert retrieved.id == created.id
        assert retrieved.name == "Test Video"
    
    def test_get_by_id_nonexistent(self, db_session):
        """Test retrieving a non-existent material returns None"""
        repo = LearningMaterialRepository(db_session)
        material = repo.get_by_id(999999)
        assert material is None
    
    def test_get_all_empty(self, clean_db):
        """Test get_all returns empty list when no materials exist"""
        repo = LearningMaterialRepository(clean_db)
        materials = repo.get_all()
        assert materials == []
    
    def test_get_all_multiple(self, clean_db):
        """Test get_all returns all materials"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        
        mat_repo.create(name="Material 1", type_id=type_obj.id)
        mat_repo.create(name="Material 2", type_id=type_obj.id)
        mat_repo.create(name="Material 3", type_id=type_obj.id)
        
        materials = mat_repo.get_all()
        assert len(materials) == 3
    
    def test_update_material_all_fields(self, clean_db):
        """Test updating all fields of a material (except arrays that need foreign keys)"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        material = mat_repo.create(name="Old", type_id=type_obj.id)
        
        updated = mat_repo.update(
            material.id,
            name="New Name",
            description="New desc",
            link="https://new.com",
            price=5000,
            notes='{"updated": true}'
        )
        
        assert updated.name == "New Name"
        assert updated.description == "New desc"
        assert updated.link == "https://new.com"
        assert updated.price == 5000
        assert updated.notes == '{"updated": true}'
    
    def test_update_material_partial(self, clean_db):
        """Test updating only some fields"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        material = mat_repo.create(
            name="Original",
            price=1000,
            type_id=type_obj.id
        )
        
        updated = mat_repo.update(material.id, price=2000)
        
        assert updated.name == "Original"  # Unchanged
        assert updated.price == 2000  # Changed
    
    def test_delete_existing_material(self, clean_db):
        """Test deleting an existing material"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        material = mat_repo.create(name="To Delete", type_id=type_obj.id)
        material_id = material.id
        
        result = mat_repo.delete(material_id)
        assert result is True
        
        # Verify it's gone
        deleted = mat_repo.get_by_id(material_id)
        assert deleted is None
    
    def test_delete_nonexistent_material(self, db_session):
        """Test deleting a non-existent material returns False"""
        repo = LearningMaterialRepository(db_session)
        result = repo.delete(999999)
        assert result is False
    
    def test_find_by_name(self, clean_db):
        """Test finding materials by name"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        mat_repo.create(name="Python Basics", type_id=type_obj.id)
        mat_repo.create(name="Java Basics", type_id=type_obj.id)
        mat_repo.create(name="Python Advanced", type_id=type_obj.id)
        
        results = mat_repo.find_by_name("Python")
        assert len(results) == 2
        names = [m.name for m in results]
        assert "Python Basics" in names
        assert "Python Advanced" in names
    
    def test_find_by_type(self, clean_db):
        """Test finding materials by type ID"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        book_type = type_repo.create(name="Book")
        video_type = type_repo.create(name="Video")
        
        mat_repo.create(name="Book 1", type_id=book_type.id)
        mat_repo.create(name="Book 2", type_id=book_type.id)
        mat_repo.create(name="Video 1", type_id=video_type.id)
        
        books = mat_repo.find_by_type(book_type.id)
        assert len(books) == 2
        for mat in books:
            assert mat.type_id == book_type.id
    
    def test_find_by_price_range(self, clean_db):
        """Test finding materials by price range"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        mat_repo.create(name="Cheap", price=500, type_id=type_obj.id)
        mat_repo.create(name="Medium", price=2500, type_id=type_obj.id)
        mat_repo.create(name="Expensive", price=5000, type_id=type_obj.id)
        
        results = mat_repo.find_by_price_range(1000, 3000)
        assert len(results) == 1
        assert results[0].name == "Medium"


class TestMaterialTypeRelationship:
    """Test the relationship between materials and types"""
    
    def test_material_has_type_relationship(self, clean_db):
        """Test that material can access its type through relationship"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Workshop")
        material = mat_repo.create(name="Python Workshop", type_id=type_obj.id)
        
        # Retrieve and check relationship
        retrieved = mat_repo.get_by_id(material.id)
        assert retrieved.type is not None
        assert retrieved.type.name == "Workshop"


class TestPostgreSQLSpecificFeatures:
    """Test PostgreSQL-specific features: ARRAY and JSONB"""
    
    def test_empty_arrays(self, clean_db):
        """Test creating material with empty arrays"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        material = mat_repo.create(
            name="Test",
            type_id=type_obj.id,
            tag_ids=[],
            wiki_note_ids=[]
        )
        
        assert material.tag_ids == []
        assert material.wiki_note_ids == []
    
    def test_jsonb_notes(self, clean_db):
        """Test storing complex JSON in notes field"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        
        complex_json = json.dumps({
            "author": "John Doe",
            "rating": 5,
            "tags": ["python", "advanced"],
            "metadata": {
                "pages": 500,
                "isbn": "123-456"
            }
        })
        
        material = mat_repo.create(
            name="Test",
            type_id=type_obj.id,
            notes=complex_json
        )
        
        # Parse and verify JSON
        parsed = json.loads(material.notes)
        assert parsed["author"] == "John Doe"
        assert parsed["rating"] == 5
        assert parsed["metadata"]["pages"] == 500


class TestEdgeCases:
    """Test edge cases and validation"""
    
    def test_create_type_with_max_length_name(self, db_session):
        """Test creating type with maximum length name (20 chars)"""
        repo = LearningMaterialTypeRepository(db_session)
        long_name = "A" * 20
        type_obj = repo.create(name=long_name)
        assert type_obj.name == long_name
    
    def test_create_material_with_max_length_name(self, clean_db):
        """Test creating material with maximum length name (100 chars)"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        long_name = "A" * 100
        material = mat_repo.create(name=long_name, type_id=type_obj.id)
        assert material.name == long_name
    
    def test_create_material_with_long_description(self, clean_db):
        """Test creating material with very long description"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        long_desc = "A" * 1000
        material = mat_repo.create(
            name="Test",
            description=long_desc,
            type_id=type_obj.id
        )
        assert len(material.description) == 1000
    
    def test_material_with_zero_price(self, clean_db):
        """Test creating material with price 0 (free)"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        type_obj = type_repo.create(name="Book")
        material = mat_repo.create(name="Free Book", price=0, type_id=type_obj.id)
        assert material.price == 0
