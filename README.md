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

## Quick Start

### Prerequisites
- Java 24 installed
- Maven (or use the included Maven wrapper)

### Build the Project
```bash
./mvnw clean install
```

### Run the Application
```bash
./mvnw spring-boot:run
```

The application will start on `http://localhost:8080`

### Access Swagger UI
Once the application is running, open your browser to:
```
http://localhost:8080/swagger-ui.html
```

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

## API Endpoints

### Employee Endpoints
- `GET /api/employees` - Get all employees
- `GET /api/employees/{id}` - Get employee by ID
- `POST /api/employees` - Create new employee
- `PUT /api/employees/{id}` - Update employee
- `DELETE /api/employees/{id}` - Delete employee

### Learning Material Endpoints
- `GET /api/learning-materials` - Get all learning materials
- `GET /api/learning-materials/{id}` - Get learning material by ID
- `POST /api/learning-materials` - Create new learning material
- `PUT /api/learning-materials/{id}` - Update learning material
- `DELETE /api/learning-materials/{id}` - Delete learning material

For detailed endpoint documentation, see [ENDPOINTS.md](./ENDPOINTS.md)

## Manual Testing

For step-by-step manual testing instructions, see [docs/TEST.md](./docs/TEST.md)

## Understanding the Dummy Implementation

### Current Behavior

All endpoints return hardcoded data:
- **GET** endpoints return predefined objects
- **POST** endpoints accept data but return it with id=1
- **PUT** endpoints only work for id=1
- **DELETE** endpoints only work for id=1
- **No data persistence** - restarting the app resets everything

### Location of Dummy Code

Look for `// TODO:` comments in the controller files:
- `src/main/kotlin/no/teamup/core/controller/EmployeeController.kt` - Employee endpoints at src/main/kotlin/no/teamup/core/controller/EmployeeController.kt:35,52,74,96,113
- `src/main/kotlin/no/teamup/core/controller/LearningMaterialController.kt` - Learning material endpoints at src/main/kotlin/no/teamup/core/controller/LearningMaterialController.kt:35,52,75,96,113

These comments mark where real database operations should be implemented.

## Next Steps: Adding Real Database Support

See [ENDPOINTS.md](./ENDPOINTS.md) for detailed instructions on:
1. Adding database dependencies
2. Creating repository interfaces
3. Adding JPA annotations to models
4. Replacing dummy implementations with real database calls
5. Configuring PostgreSQL connection
6. Setting up database schema

## Technology Stack

- **Spring Boot:** 4.0.3
- **Kotlin:** 2.2.21
- **Java:** 24
- **Build Tool:** Maven
- **API Documentation:** SpringDoc OpenAPI 3.0.1
- **Code Formatting:** Spotless with KtLint 1.8.0

## Documentation Files

- **README.md** (this file) - Getting started guide
- **[docs/TEST.md](./docs/TEST.md)** - Step-by-step manual testing guide
- **[docs/SPOTLESS.md](./docs/SPOTLESS.md)** - Code formatting with Spotless
- **[ENDPOINTS.md](./ENDPOINTS.md)** - Detailed endpoint documentation and implementation guide

## Troubleshooting

### Application Won't Start

**Problem:** Port 8080 is already in use  
**Solution:** Stop any other application using port 8080, or change the port in `application.yml`

**Problem:** Java version error  
**Solution:** Ensure Java 24 is installed and set as the active version

### Swagger UI Not Loading

**Problem:** 404 error when accessing `/swagger-ui.html`  
**Solution:** Ensure the application is running and try `http://localhost:8080/swagger-ui/index.html`

### Build Failures

**Problem:** Maven build fails  
**Solution:** Ensure you have internet connection for dependency downloads, or try `./mvnw clean install -U` to force update dependencies
test
