# TeamUP Python Testing Framework

A comprehensive Python test suite for the TeamUP PostgreSQL database, featuring SQLAlchemy ORM, pytest testing, and Jupyter notebook examples.

## Features

- 🐍 **Python 3.12** with modern async support
- 📦 **uv** package manager for fast, reliable dependency management
- 🗄️ **SQLAlchemy ORM** with PostgreSQL-specific features (arrays, JSONB)
- ✅ **pytest** testing framework with **91% code coverage**
- 🎭 **Faker** for generating realistic test data
- 📓 **Jupyter notebooks** with practical examples
- 🛠️ **CLI tool** for database operations
- 🔄 **Transaction management** with automatic commit/rollback

## Project Structure

```
python-testing/
├── teamup/                    # Main package
│   ├── __init__.py           # Package initialization
│   ├── config.py             # Environment configuration
│   ├── database.py           # Database connection management
│   ├── models.py             # SQLAlchemy ORM models
│   └── repository.py         # Data access layer (repositories)
├── tests/                     # Test suite
│   ├── __init__.py
│   ├── conftest.py           # Pytest configuration and fixtures
│   ├── factories.py          # Faker data generators
│   ├── test_database.py      # Database connection tests (10 tests)
│   ├── test_employee.py      # Employee model tests (27 tests)
│   ├── test_learning_material.py  # Learning material tests (33 tests)
│   └── test_complete_workflow.py  # Integration tests (13 tests)
├── notebooks/                 # Jupyter notebook examples
│   ├── 01_getting_started.ipynb
│   ├── 02_employee_crud.ipynb
│   ├── 03_learning_material_crud.ipynb
│   └── 04_advanced_examples.ipynb
├── cli.py                     # Command-line interface tool
├── pyproject.toml            # Project configuration
├── .env                      # Environment variables (not in git)
├── .env.example              # Environment template
└── README.md                 # This file
```

## Database Schema

### Employee Table
- **id** (Integer, PK) - Auto-generated
- **fullname** (String, max 50) - Required
- **job_title** (String, max 30) - Optional
- **age** (Integer) - Optional, must be >= 1

### Learning Material Type Table
- **id** (Integer, PK) - Auto-generated
- **name** (String, max 20) - Required, unique

### Learning Material Table
- **id** (Integer, PK) - Auto-generated
- **name** (String, max 100) - Required
- **description** (Text) - Optional
- **link** (String, max 100) - Optional
- **price** (Integer) - Optional, stored in cents
- **type_id** (Integer, FK) - Required, references learning_material_type
- **tag_ids** (INTEGER[]) - Optional, PostgreSQL array
- **wiki_note_ids** (INTEGER[]) - Optional, PostgreSQL array
- **notes** (JSONB) - Optional, stored as text

## Installation

### Prerequisites

1. **Python 3.12** installed
2. **uv** package manager ([installation guide](https://github.com/astral-sh/uv))
3. **PostgreSQL 16+** running on localhost:5432
4. **teamup database** with the schema above

### Setup Steps

1. **Clone the repository** (if applicable):
   ```bash
   cd /path/to/TeamUP/python-testing
   ```

2. **Create virtual environment with uv**:
   ```bash
   uv venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   uv pip install -e .
   ```

4. **Configure environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

   Required `.env` variables:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=teamup
   DB_TEST_NAME=teamup_test
   DB_USER=your_username
   DB_PASSWORD=your_password
   DB_SCHEMA=teamup
   LOG_LEVEL=DEBUG
   ```

5. **Verify installation**:
   ```bash
   python -c "from teamup.database import test_connection; test_connection()"
   ```

## Running Tests

### Run All Tests
```bash
pytest tests/
```

### Run Specific Test File
```bash
pytest tests/test_employee.py -v
```

### Run with Coverage Report
```bash
pytest tests/ --cov=teamup --cov-report=html --cov-report=term-missing
```

View HTML coverage report:
```bash
open htmlcov/index.html  # macOS
xdg-open htmlcov/index.html  # Linux
start htmlcov/index.html  # Windows
```

### Run Tests in Parallel (faster)
```bash
pytest tests/ -n auto
```

### Current Test Coverage

**Overall: 91%** ✅ (Target: 90%+)

- `teamup/__init__.py`: 100%
- `teamup/config.py`: 100%
- `teamup/database.py`: 73%
- `teamup/models.py`: 92%
- `teamup/repository.py`: 97%

**Total: 83 tests passing**

## Using the CLI Tool

The CLI provides quick database operations:

### Employee Commands
```bash
# List all employees
python cli.py employee list

# Create employee
python cli.py employee create "John Doe" --job-title "Developer" --age 30

# Delete employee
python cli.py employee delete 123
```

### Material Type Commands
```bash
# List all types
python cli.py type list

# Create type
python cli.py type create "Book"
```

### Material Commands
```bash
# List all materials
python cli.py material list

# Create material
python cli.py material create "Python Guide" --type-id 1 --price 2999
```

## Using Jupyter Notebooks

The notebooks provide interactive examples for learning and experimentation.

### Start Jupyter
```bash
jupyter notebook notebooks/
```

### Notebook Guide

1. **01_getting_started.ipynb**
   - Setup and imports
   - Database connection testing
   - Understanding context managers

2. **02_employee_crud.ipynb**
   - Create, read, update, delete employees
   - Search by name, job title, age range
   - Using Faker for test data

3. **03_learning_material_crud.ipynb**
   - Working with material types
   - CRUD operations on learning materials
   - PostgreSQL arrays and JSONB
   - Foreign key relationships

4. **04_advanced_examples.ipynb**
   - Complete workflows (onboarding, career progression)
   - Batch operations
   - Complex queries and analytics
   - Error handling patterns
   - JSON data manipulation
   - Data export

## Code Examples

### Basic CRUD Operations

```python
from teamup.database import get_session
from teamup.repository import EmployeeRepository

# Create
with get_session() as session:
    repo = EmployeeRepository(session)
    employee = repo.create(
        fullname="Alice Johnson",
        job_title="Senior Developer",
        age=32
    )
    print(f"Created: {employee}")

# Read
with get_session() as session:
    repo = EmployeeRepository(session)
    employee = repo.get_by_id(1)
    if employee:
        print(f"Found: {employee}")

# Update
with get_session() as session:
    repo = EmployeeRepository(session)
    updated = repo.update(
        employee_id=1,
        job_title="Principal Developer",
        age=33
    )
    print(f"Updated: {updated}")

# Delete
with get_session() as session:
    repo = EmployeeRepository(session)
    success = repo.delete(1)
    print(f"Deleted: {success}")
```

### Search Operations

```python
with get_session() as session:
    repo = EmployeeRepository(session)
    
    # Find by name (case-insensitive, partial match)
    results = repo.find_by_name("Alice")
    
    # Find by job title
    developers = repo.find_by_job_title("Developer")
    
    # Find by age range
    young = repo.find_by_age_range(min_age=25, max_age=35)
```

### Working with Learning Materials

```python
from teamup.repository import LearningMaterialRepository, LearningMaterialTypeRepository
import json

with get_session() as session:
    type_repo = LearningMaterialTypeRepository(session)
    material_repo = LearningMaterialRepository(session)
    
    # Create type
    book_type = type_repo.create(name="Book")
    
    # Create material with JSON notes
    material = material_repo.create(
        name="Python for Data Science",
        description="Comprehensive Python guide",
        type_id=book_type.id,
        price=4500,  # $45.00 (stored in cents)
        tag_ids=[],  # Empty array (safe)
        wiki_note_ids=[],
        notes=json.dumps({"difficulty": "intermediate", "pages": 450})
    )
```

### Error Handling

```python
# The context manager automatically handles rollback on errors
try:
    with get_session() as session:
        repo = EmployeeRepository(session)
        emp = repo.create(fullname="Test User", age=25)
        
        # Simulate an error
        raise ValueError("Something went wrong")
        
except ValueError as e:
    # The employee creation was automatically rolled back
    print(f"Error: {e}")

# Verify the employee wasn't created
with get_session() as session:
    repo = EmployeeRepository(session)
    not_found = repo.find_by_name("Test User")
    assert len(not_found) == 0  # True - rolled back
```

## Database Constraints

### Important Constraints to Know

1. **Employee age**: Must be >= 1 (database check constraint)
2. **Tag validation**: `tag_ids` array values are validated against a tag table via PostgreSQL trigger
3. **Wiki note validation**: `wiki_note_ids` similar validation
4. **Field lengths**:
   - Employee fullname: max 50 chars
   - Employee job_title: max 30 chars
   - Material type name: max 20 chars (unique)
   - Material name: max 100 chars
   - Material link: max 100 chars

### Working with Arrays

Due to database triggers that validate array contents, it's safest to use empty arrays:

```python
# Safe approach - empty arrays
material = repo.create(
    name="My Material",
    type_id=1,
    tag_ids=[],  # Empty array
    wiki_note_ids=[]  # Empty array
)
```

## Architecture

### Context Manager Pattern

The `get_session()` function is a context manager that:
1. Opens a database connection
2. Sets the correct schema (`teamup`)
3. **Commits on success** - all changes are saved
4. **Rolls back on error** - nothing is saved if exception occurs
5. Closes the connection

### Repository Pattern

All database operations go through repository classes:
- **EmployeeRepository** - Employee CRUD + search
- **LearningMaterialTypeRepository** - Type management
- **LearningMaterialRepository** - Material CRUD + search

Benefits:
- Separation of concerns
- Easy to test
- Consistent API
- Type hints for IDE support

### Model Layer

SQLAlchemy ORM models in `teamup/models.py`:
- **Base** - Declarative base for all models
- **Employee** - Employee model with validation
- **LearningMaterialType** - Material type model
- **LearningMaterial** - Material model with relationships

## Testing Strategy

### Test Organization

1. **Unit tests** - Individual model and repository methods
2. **Integration tests** - Complete workflows
3. **Edge case tests** - Boundary conditions, max lengths
4. **Error handling tests** - Rollback, validation failures

### Test Database

- **Currently using main database** with transaction rollback for isolation
- **Test database (`teamup_test`) not yet created** - requires admin privileges
- Each test runs in a transaction that's rolled back after completion
- Tests are fully isolated - no shared state

### Fixtures

- `setup_test_database` - Ensures tables exist (session-scoped)
- `db_session` - Provides clean database session (function-scoped)
- `clean_db` - Ensures empty tables between tests (function-scoped)

## Troubleshooting

### Connection Issues

```python
from teamup.database import test_connection

if not test_connection():
    print("Check your .env file and database credentials")
```

### Import Errors

```bash
# Make sure package is installed in editable mode
uv pip install -e .
```

### Test Failures

```bash
# Run with verbose output
pytest tests/ -v -s

# Run single test for debugging
pytest tests/test_employee.py::TestEmployeeRepository::test_create_employee -v
```

### Array Validation Errors

If you see errors about tag_ids or wiki_note_ids:
```python
# Use empty arrays to avoid trigger validation
tag_ids=[]
wiki_note_ids=[]
```

## Contributing

### Code Style

- Follow PEP 8
- Use type hints
- Write docstrings for public methods
- Keep functions simple and focused

### Adding Tests

1. Add test file in `tests/`
2. Use descriptive test names: `test_<action>_<expected_result>`
3. Use fixtures for setup
4. Clean up test data

### Running Quality Checks

```bash
# Format code
black teamup/ tests/

# Check types
mypy teamup/

# Run linter
ruff check teamup/ tests/
```

## License

[Your license here]

## Support

For issues or questions:
- Check the Jupyter notebooks for examples
- Review the test files for usage patterns
- Check database logs for connection issues

## Changelog

### v1.0.0 (2024-03-17)
- Initial release
- 91% test coverage (83 tests)
- Complete CRUD operations for all models
- CLI tool
- 4 Jupyter notebook examples
- Comprehensive documentation
