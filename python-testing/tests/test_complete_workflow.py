"""
End-to-end workflow tests

This module tests complete workflows that combine multiple operations
across different models, simulating real-world usage scenarios.
"""
import pytest
from teamup.repository import EmployeeRepository, LearningMaterialTypeRepository, LearningMaterialRepository
from tests.factories import create_fake_employee


class TestCompleteWorkflows:
    """Test complete end-to-end workflows"""
    
    def test_create_employee_and_assign_learning_materials(self, clean_db):
        """Test creating an employee and tracking their learning materials"""
        emp_repo = EmployeeRepository(clean_db)
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create an employee
        employee = emp_repo.create(
            fullname="Alice Developer",
            job_title="Junior Developer",
            age=25
        )
        
        # Create learning material types
        book_type = type_repo.create(name="Book")
        course_type = type_repo.create(name="Online Course")
        
        # Create learning materials
        python_book = mat_repo.create(
            name="Python for Beginners",
            description="Learn Python from scratch",
            price=2500,
            type_id=book_type.id
        )
        
        advanced_course = mat_repo.create(
            name="Advanced Python Programming",
            description="Master advanced Python concepts",
            price=5000,
            type_id=course_type.id
        )
        
        # Verify everything was created
        assert employee.id is not None
        assert python_book.id is not None
        assert advanced_course.id is not None
        
        # Verify we can retrieve everything
        retrieved_emp = emp_repo.get_by_id(employee.id)
        assert retrieved_emp.fullname == "Alice Developer"
        
        all_materials = mat_repo.get_all()
        assert len(all_materials) == 2
    
    def test_update_employee_career_progression(self, clean_db):
        """Test tracking employee career progression with learning"""
        emp_repo = EmployeeRepository(clean_db)
        
        # Create junior employee
        employee = emp_repo.create(
            fullname="Bob Developer",
            job_title="Junior Developer",
            age=23
        )
        
        # After 1 year, promote to mid-level
        emp_repo.update(
            employee.id,
            job_title="Developer",
            age=24
        )
        
        # After 2 more years, promote to senior
        emp_repo.update(
            employee.id,
            job_title="Senior Developer",
            age=26
        )
        
        # Verify final state
        final = emp_repo.get_by_id(employee.id)
        assert final.fullname == "Bob Developer"
        assert final.job_title == "Senior Developer"
        assert final.age == 26
    
    def test_bulk_import_learning_materials(self, clean_db):
        """Test bulk importing learning materials from different sources"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create types
        types_data = ["Book", "Online Course", "Video", "Workshop", "Conference"]
        created_types = {}
        for type_name in types_data:
            t = type_repo.create(name=type_name)
            created_types[type_name] = t
        
        # Bulk create materials
        materials_data = [
            {"name": "Python Basics", "type": "Book", "price": 1500},
            {"name": "Django Course", "type": "Online Course", "price": 3000},
            {"name": "React Tutorial", "type": "Video", "price": 0},  # Free
            {"name": "DevOps Workshop", "type": "Workshop", "price": 8000},
            {"name": "PyCon 2026", "type": "Conference", "price": 15000},
        ]
        
        for mat_data in materials_data:
            type_obj = created_types[mat_data["type"]]
            mat_repo.create(
                name=mat_data["name"],
                price=mat_data["price"],
                type_id=type_obj.id
            )
        
        # Verify all materials were created
        all_materials = mat_repo.get_all()
        assert len(all_materials) == 5
        
        # Verify we can find free materials
        free_materials = mat_repo.find_by_price_range(0, 0)
        assert len(free_materials) == 1
        assert free_materials[0].name == "React Tutorial"
    
    def test_search_and_filter_workflow(self, clean_db):
        """Test complex search and filtering operations"""
        emp_repo = EmployeeRepository(clean_db)
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create diverse employees
        emp_repo.create(fullname="Alice Smith", job_title="Developer", age=25)
        emp_repo.create(fullname="Bob Smith", job_title="Designer", age=30)
        emp_repo.create(fullname="Charlie Jones", job_title="Developer", age=28)
        emp_repo.create(fullname="Diana Brown", job_title="Manager", age=35)
        
        # Search by name
        smiths = emp_repo.find_by_name("Smith")
        assert len(smiths) == 2
        
        # Search by job title
        developers = emp_repo.find_by_job_title("Developer")
        assert len(developers) == 2
        
        # Search by age range (25, 28 are in range; 30 is not)
        young_employees = emp_repo.find_by_age_range(20, 29)
        assert len(young_employees) == 2
        
        # Create materials with different prices
        book_type = type_repo.create(name="Book")
        mat_repo.create(name="Cheap Book", price=500, type_id=book_type.id)
        mat_repo.create(name="Medium Book", price=2500, type_id=book_type.id)
        mat_repo.create(name="Expensive Book", price=5000, type_id=book_type.id)
        
        # Find affordable materials
        affordable = mat_repo.find_by_price_range(0, 3000)
        assert len(affordable) == 2
    
    def test_delete_cascade_workflow(self, clean_db):
        """Test deleting and verifying cascade behavior"""
        emp_repo = EmployeeRepository(clean_db)
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create data
        employee = emp_repo.create(fullname="Temp Employee")
        book_type = type_repo.create(name="Book")
        material = mat_repo.create(name="Temp Material", type_id=book_type.id)
        
        # Delete employee (should work independently)
        result = emp_repo.delete(employee.id)
        assert result is True
        assert emp_repo.get_by_id(employee.id) is None
        
        # Delete material (should work)
        result = mat_repo.delete(material.id)
        assert result is True
        assert mat_repo.get_by_id(material.id) is None
        
        # Type should still exist (no cascade from material)
        assert type_repo.get_by_id(book_type.id) is not None
        
        # Clean up type
        result = type_repo.delete(book_type.id)
        assert result is True
    
    def test_batch_employee_operations(self, clean_db):
        """Test batch operations on employees"""
        emp_repo = EmployeeRepository(clean_db)
        
        # Batch create employees
        employees = []
        for i in range(10):
            fake_emp = create_fake_employee()
            emp = emp_repo.create(
                fullname=fake_emp.fullname,
                job_title=fake_emp.job_title,
                age=fake_emp.age
            )
            employees.append(emp)
        
        # Verify all created
        assert len(employees) == 10
        all_employees = emp_repo.get_all()
        assert len(all_employees) == 10
        
        # Batch update - give everyone a raise (reflected in job title)
        # Truncate to avoid exceeding 30 char limit
        for emp in employees[:5]:
            if emp.job_title:
                new_title = f"Senior {emp.job_title}"
                if len(new_title) > 30:
                    new_title = new_title[:27] + "..."
                emp_repo.update(emp.id, job_title=new_title)
        
        # Batch delete
        for emp in employees[5:]:
            emp_repo.delete(emp.id)
        
        # Verify final state
        remaining = emp_repo.get_all()
        assert len(remaining) == 5
    
    def test_material_type_relationship_workflow(self, clean_db):
        """Test working with material-type relationships"""
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create multiple types
        book_type = type_repo.create(name="Book")
        video_type = type_repo.create(name="Video")
        course_type = type_repo.create(name="Online Course")
        
        # Create materials for each type
        mat_repo.create(name="Python Book 1", type_id=book_type.id)
        mat_repo.create(name="Python Book 2", type_id=book_type.id)
        mat_repo.create(name="Python Video", type_id=video_type.id)
        mat_repo.create(name="Python Course", type_id=course_type.id)
        
        # Find materials by type
        books = mat_repo.find_by_type(book_type.id)
        videos = mat_repo.find_by_type(video_type.id)
        courses = mat_repo.find_by_type(course_type.id)
        
        assert len(books) == 2
        assert len(videos) == 1
        assert len(courses) == 1
        
        # Verify relationship works
        book = books[0]
        assert book.type is not None
        assert book.type.name == "Book"
    
    def test_complex_json_notes_workflow(self, clean_db):
        """Test storing and retrieving complex JSON data"""
        import json
        
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        book_type = type_repo.create(name="Book")
        
        # Create material with complex notes
        complex_notes = {
            "author": "John Doe",
            "publisher": "Tech Books Inc",
            "isbn": "978-3-16-148410-0",
            "rating": 4.5,
            "reviews": [
                {"reviewer": "Alice", "score": 5, "comment": "Excellent!"},
                {"reviewer": "Bob", "score": 4, "comment": "Very good"}
            ],
            "metadata": {
                "pages": 350,
                "language": "English",
                "edition": 2
            }
        }
        
        material = mat_repo.create(
            name="Advanced Programming",
            type_id=book_type.id,
            notes=json.dumps(complex_notes)
        )
        
        # Retrieve and verify
        retrieved = mat_repo.get_by_id(material.id)
        parsed_notes = json.loads(retrieved.notes)
        
        assert parsed_notes["author"] == "John Doe"
        assert parsed_notes["rating"] == 4.5
        assert len(parsed_notes["reviews"]) == 2
        assert parsed_notes["metadata"]["pages"] == 350
    
    def test_empty_database_workflow(self, clean_db):
        """Test operations on empty database"""
        emp_repo = EmployeeRepository(clean_db)
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Verify everything is empty
        assert emp_repo.get_all() == []
        assert type_repo.get_all() == []
        assert mat_repo.get_all() == []
        
        # Verify searches return empty
        assert emp_repo.find_by_name("Anyone") == []
        assert emp_repo.find_by_job_title("Any Job") == []
        assert mat_repo.find_by_name("Anything") == []
        
        # Verify counts are zero
        assert emp_repo.count() == 0
        assert type_repo.count() == 0
        assert mat_repo.count() == 0


class TestErrorHandling:
    """Test error handling and edge cases"""
    
    def test_get_nonexistent_records(self, clean_db):
        """Test retrieving non-existent records returns None"""
        emp_repo = EmployeeRepository(clean_db)
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        assert emp_repo.get_by_id(999999) is None
        assert type_repo.get_by_id(999999) is None
        assert mat_repo.get_by_id(999999) is None
        assert type_repo.get_by_name("NonExistent") is None
    
    def test_update_nonexistent_records(self, clean_db):
        """Test updating non-existent records returns None"""
        emp_repo = EmployeeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        assert emp_repo.update(999999, fullname="Ghost") is None
        assert mat_repo.update(999999, name="Ghost") is None
    
    def test_delete_nonexistent_records(self, clean_db):
        """Test deleting non-existent records returns False"""
        emp_repo = EmployeeRepository(clean_db)
        type_repo = LearningMaterialTypeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        assert emp_repo.delete(999999) is False
        assert type_repo.delete(999999) is False
        assert mat_repo.delete(999999) is False
    
    def test_empty_search_results(self, clean_db):
        """Test that searches with no matches return empty lists"""
        emp_repo = EmployeeRepository(clean_db)
        mat_repo = LearningMaterialRepository(clean_db)
        
        # Create some data
        emp_repo.create(fullname="Alice")
        type_repo = LearningMaterialTypeRepository(clean_db)
        book_type = type_repo.create(name="Book")
        mat_repo.create(name="Python Book", type_id=book_type.id)
        
        # Search for things that don't exist
        assert emp_repo.find_by_name("Nonexistent") == []
        assert emp_repo.find_by_job_title("Nonexistent Job") == []
        assert emp_repo.find_by_age_range(100, 200) == []
        assert mat_repo.find_by_name("Nonexistent Material") == []
        assert mat_repo.find_by_price_range(1000000, 2000000) == []
