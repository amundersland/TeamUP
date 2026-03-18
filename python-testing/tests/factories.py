"""
Test data factories using Faker

This module provides simple functions to generate realistic test data
for employees, learning material types, and learning materials.

Each function creates a new random instance using Faker.
"""
from faker import Faker
from teamup.models import Employee, LearningMaterialType, LearningMaterial

# Initialize Faker
fake = Faker()

# Common learning material type names
COMMON_TYPES = [
    "Book",
    "Online Course",
    "Video Tutorial",
    "Workshop",
    "Conference",
    "Certification",
    "Documentation",
    "Podcast",
    "Webinar",
    "Article"
]


def create_fake_employee(**kwargs) -> Employee:
    """
    Create a fake Employee instance with random data.
    
    Args:
        **kwargs: Override any field with specific values
        
    Returns:
        Employee: A new Employee instance (not saved to database)
        
    Example:
        employee = create_fake_employee(fullname="John Doe")
    """
    job_title = fake.job()
    # Truncate job_title if longer than 30 chars
    if len(job_title) > 30:
        job_title = job_title[:27] + "..."
    
    data = {
        'fullname': fake.name()[:50],  # Max 50 chars
        'job_title': job_title,
        'age': fake.random_int(min=20, max=65)  # Age must be >= 1 per DB constraint
    }
    data.update(kwargs)
    return Employee(**data)


def create_fake_type(**kwargs) -> LearningMaterialType:
    """
    Create a fake LearningMaterialType instance.
    
    Args:
        **kwargs: Override any field with specific values
        
    Returns:
        LearningMaterialType: A new type instance (not saved to database)
        
    Example:
        type_obj = create_fake_type(name="Book")
    """
    data = {
        'name': fake.random_element(COMMON_TYPES)
    }
    data.update(kwargs)
    return LearningMaterialType(**data)


def create_fake_material(**kwargs) -> LearningMaterial:
    """
    Create a fake LearningMaterial instance with random data.
    
    Args:
        **kwargs: Override any field with specific values
        
    Returns:
        LearningMaterial: A new material instance (not saved to database)
        
    Note:
        You must provide a valid type_id or the save will fail.
        
    Example:
        material = create_fake_material(
            type_id=1,
            name="Advanced Python Programming"
        )
    """
    data = {
        'name': fake.catch_phrase(),
        'description': fake.text(max_nb_chars=200),
        'link': fake.url(),
        'price': fake.random_int(min=0, max=5000),
        'tag_ids': [fake.random_int(min=1, max=10) for _ in range(fake.random_int(min=0, max=5))],
        'wiki_note_ids': [fake.random_int(min=1, max=10) for _ in range(fake.random_int(min=0, max=3))],
        'notes': f'{{"author": "{fake.name()}", "rating": {fake.random_int(min=1, max=5)}}}'
    }
    data.update(kwargs)
    return LearningMaterial(**data)


def create_fake_fullname() -> str:
    """Generate a fake full name"""
    return fake.name()


def create_fake_job_title() -> str:
    """Generate a fake job title"""
    return fake.job()


def create_fake_url() -> str:
    """Generate a fake URL"""
    return fake.url()


def create_fake_text(max_chars: int = 200) -> str:
    """Generate fake text"""
    return fake.text(max_nb_chars=max_chars)
