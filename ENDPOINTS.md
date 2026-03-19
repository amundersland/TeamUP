# TeamUP Backend - Barebone Implementation

This is a barebone Spring Boot backend based on worktree `4_skrive-og-lese-til-postgresDB`. The purpose is to provide a foundation for implementing the full solution step-by-step.

## Overview

This implementation contains:
- Spring Boot 4.0.3 with Kotlin 2.2.21
- REST API endpoints with Swagger/OpenAPI documentation
- Model classes without database persistence
- Controllers with dummy implementations

**Note:** This version does NOT include:
- Database configuration (PostgreSQL, JPA)
- Repository layers
- Actual data persistence
- Database-specific annotations

## Project Structure

```
src/main/kotlin/no/teamup/core/
├── CoreApplication.kt           # Main Spring Boot application
├── config/
│   └── OpenApiConfig.kt         # Swagger/OpenAPI configuration
├── controller/
│   ├── EmployeeController.kt    # Employee REST endpoints
│   └── LearningMaterialController.kt  # Learning material REST endpoints
└── model/
    ├── Employee.kt              # Employee model
    ├── LearningMaterial.kt      # Learning material model
    └── LearningMaterialType.kt  # Learning material type model
```

## Build and Run

### Build
```bash
./mvnw clean install
```

### Run
```bash
./mvnw spring-boot:run
```

The application will start on `http://localhost:8080`

### Access Swagger UI
Once running, access the API documentation at:
```
http://localhost:8080/swagger-ui.html
```

## API Endpoints

### Employee Endpoints

#### GET /api/employees
**Purpose:** Retrieve all employees  
**Current Implementation:** Returns a hardcoded list of 2 employees  
**TODO:** Implement database retrieval using EmployeeRepository.findAll()

**Example Response:**
```json
[
  {
    "id": 1,
    "fullname": "Ola Nordmann",
    "jobTitle": "Senior Developer",
    "age": 30
  },
  {
    "id": 2,
    "fullname": "Kari Hansen",
    "jobTitle": "Product Manager",
    "age": 28
  }
]
```

#### GET /api/employees/{id}
**Purpose:** Get a specific employee by ID  
**Current Implementation:** Returns employee if id=1, otherwise 404  
**TODO:** Implement database lookup using EmployeeRepository.findById(id)

**Example Response (id=1):**
```json
{
  "id": 1,
  "fullname": "Ola Nordmann",
  "jobTitle": "Senior Developer",
  "age": 30
}
```

#### POST /api/employees
**Purpose:** Create a new employee  
**Current Implementation:** Returns the submitted employee with id=1 (hardcoded)  
**TODO:** Implement database save using EmployeeRepository.save(employee)

**Example Request:**
```json
{
  "fullname": "Per Hansen",
  "jobTitle": "Junior Developer",
  "age": 25
}
```

**Example Response:**
```json
{
  "id": 1,
  "fullname": "Per Hansen",
  "jobTitle": "Junior Developer",
  "age": 25
}
```

#### PUT /api/employees/{id}
**Purpose:** Update an existing employee  
**Current Implementation:** Returns updated employee if id=1, otherwise 404  
**TODO:** Implement database check using EmployeeRepository.existsById(id) and update using EmployeeRepository.save(employee)

**Example Request (id=1):**
```json
{
  "fullname": "Ola Nordmann",
  "jobTitle": "Lead Developer",
  "age": 31
}
```

**Example Response:**
```json
{
  "id": 1,
  "fullname": "Ola Nordmann",
  "jobTitle": "Lead Developer",
  "age": 31
}
```

#### DELETE /api/employees/{id}
**Purpose:** Delete an employee by ID  
**Current Implementation:** Returns 204 No Content if id=1, otherwise 404  
**TODO:** Implement database check using EmployeeRepository.existsById(id) and delete using EmployeeRepository.deleteById(id)

**Response:** 204 No Content (on success) or 404 Not Found

---

### Learning Material Endpoints

#### GET /api/learning-materials
**Purpose:** Retrieve all learning materials  
**Current Implementation:** Returns a hardcoded list of 2 learning materials  
**TODO:** Implement database retrieval using LearningMaterialRepository.findAll()

**Example Response:**
```json
[
  {
    "id": 1,
    "name": "Kotlin in Action",
    "description": "Comprehensive guide to Kotlin programming",
    "link": "https://example.com/kotlin-book",
    "price": 4995,
    "type": {
      "id": 1,
      "name": "Book"
    }
  },
  {
    "id": 2,
    "name": "Spring Boot Masterclass",
    "description": "Learn Spring Boot from scratch",
    "link": "https://example.com/spring-course",
    "price": 9900,
    "type": {
      "id": 2,
      "name": "Course"
    }
  }
]
```

#### GET /api/learning-materials/{id}
**Purpose:** Get a specific learning material by ID  
**Current Implementation:** Returns learning material if id=1, otherwise 404  
**TODO:** Implement database lookup using LearningMaterialRepository.findById(id)

**Example Response (id=1):**
```json
{
  "id": 1,
  "name": "Kotlin in Action",
  "description": "Comprehensive guide to Kotlin programming",
  "link": "https://example.com/kotlin-book",
  "price": 4995,
  "type": {
    "id": 1,
    "name": "Book"
  }
}
```

#### POST /api/learning-materials
**Purpose:** Create a new learning material  
**Current Implementation:** Returns the submitted learning material with id=1 (hardcoded)  
**TODO:** Implement database save using LearningMaterialRepository.save(learningMaterial)

**Example Request:**
```json
{
  "name": "Advanced Kotlin",
  "description": "Deep dive into Kotlin",
  "link": "https://example.com/advanced-kotlin",
  "price": 5995,
  "type": {
    "id": 1,
    "name": "Book"
  },
  "tagIds": [1, 5],
  "wikiNoteIds": [],
  "notes": "[]"
}
```

**Example Response:**
```json
{
  "id": 1,
  "name": "Advanced Kotlin",
  "description": "Deep dive into Kotlin",
  "link": "https://example.com/advanced-kotlin",
  "price": 5995,
  "type": {
    "id": 1,
    "name": "Book"
  },
  "tagIds": [1, 5],
  "wikiNoteIds": [],
  "notes": "[]"
}
```

#### PUT /api/learning-materials/{id}
**Purpose:** Update an existing learning material  
**Current Implementation:** Returns updated learning material if id=1, otherwise 404  
**TODO:** Implement database check using LearningMaterialRepository.existsById(id) and update using LearningMaterialRepository.save(learningMaterial)

**Example Request (id=1):**
```json
{
  "name": "Kotlin in Action - 2nd Edition",
  "description": "Updated guide to Kotlin programming",
  "link": "https://example.com/kotlin-book-v2",
  "price": 5495,
  "type": {
    "id": 1,
    "name": "Book"
  },
  "tagIds": [1, 2, 6],
  "wikiNoteIds": [],
  "notes": "[]"
}
```

**Example Response:**
```json
{
  "id": 1,
  "name": "Kotlin in Action - 2nd Edition",
  "description": "Updated guide to Kotlin programming",
  "link": "https://example.com/kotlin-book-v2",
  "price": 5495,
  "type": {
    "id": 1,
    "name": "Book"
  },
  "tagIds": [1, 2, 6],
  "wikiNoteIds": [],
  "notes": "[]"
}
```

#### DELETE /api/learning-materials/{id}
**Purpose:** Delete a learning material by ID  
**Current Implementation:** Returns 204 No Content if id=1, otherwise 404  
**TODO:** Implement database check using LearningMaterialRepository.existsById(id) and delete using LearningMaterialRepository.deleteById(id)

**Response:** 204 No Content (on success) or 404 Not Found

---

## Next Steps for Implementation

To transform this barebone implementation into a fully functional backend:

1. **Add Database Dependencies**
   - Add `spring-boot-starter-data-jpa` dependency
   - Add PostgreSQL driver dependency

2. **Create Database Configuration**
   - Configure `application.yml` with database connection details
   - Set up schema and connection properties

3. **Add Database Annotations to Models**
   - Add `@Entity`, `@Table`, `@Id`, `@Column` annotations to model classes
   - Configure relationships (e.g., `@ManyToOne` for LearningMaterial.type)
   - Add custom types for PostgreSQL arrays (PostgreSQLIntArrayType)

4. **Create Repository Interfaces**
   - Create `EmployeeRepository extends JpaRepository<Employee, Int>`
   - Create `LearningMaterialRepository extends JpaRepository<LearningMaterial, Int>`
   - Create `LearningMaterialTypeRepository extends JpaRepository<LearningMaterialType, Int>`

5. **Update Controllers**
   - Inject repositories via constructor injection
   - Replace dummy implementations with actual repository calls
   - Remove hardcoded data

6. **Set Up Database**
   - Create PostgreSQL database
   - Run schema creation scripts
   - Seed initial data if needed

7. **Add Tests**
   - Create integration tests with H2 in-memory database
   - Add unit tests for controllers with MockK
   - Use Kotest FunSpec style for testing

## Technology Stack

- **Spring Boot:** 4.0.3
- **Kotlin:** 2.2.21
- **Java:** 25
- **Build Tool:** Maven
- **API Documentation:** SpringDoc OpenAPI 3.0.1
- **Code Formatting:** Spotless with KtLint 1.8.0
- **Testing:** Kotest 5.9.1, MockK 1.13.13

## Swagger/OpenAPI Documentation

All endpoints are fully documented with OpenAPI annotations including:
- Operation summaries and descriptions
- Request/response schemas
- HTTP status codes and their meanings
- Example values for fields

Access the interactive API documentation at `http://localhost:8080/swagger-ui.html` when the application is running.
