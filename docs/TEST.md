# Manual Testing Guide

This guide provides step-by-step instructions for manually testing the barebone Spring Boot backend implementation.

## Prerequisites

Before starting the tests, ensure you have:
- Java 24 installed
- The application built successfully (`./mvnw clean install`)

---

## Step 1: Verify the Build

First, ensure the project compiles without errors:

```bash
./mvnw clean compile
```

**Expected Result:** Build should complete successfully with "BUILD SUCCESS"

---

## Step 2: Start the Application

Start the Spring Boot application:

```bash
./mvnw spring-boot:run
```

**Expected Result:** 
- Application starts without errors
- You should see log messages indicating the server started on port 8080
- Look for: `Tomcat started on port 8080`

**Tip:** Keep this terminal window open while testing. Open a new terminal for the following steps.

---

## Step 3: Access Swagger UI

Open your web browser and navigate to:
```
http://localhost:8080/swagger-ui.html
```

**Expected Result:**
- Swagger UI page loads successfully
- You should see two sections:
  - **Employee** - API for managing employees
  - **Learning Material** - API for managing learning materials
- Each section shows the available endpoints (GET, POST, PUT, DELETE)

**What to Check:**
- All endpoints are documented with descriptions
- Each endpoint shows the expected request/response formats
- HTTP status codes are documented

---

## Step 4: Test Employee Endpoints

### 4.1 Get All Employees

**Using Swagger UI:**
1. Expand the `GET /api/employees` endpoint
2. Click "Try it out"
3. Click "Execute"

**Using curl:**
```bash
curl -X GET http://localhost:8080/api/employees
```

**Expected Response:**
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

**Status Code:** 200 OK

**What This Tests:** The dummy implementation returns a hardcoded list of employees.

---

### 4.2 Get Employee by ID

**Using Swagger UI:**
1. Expand the `GET /api/employees/{id}` endpoint
2. Click "Try it out"
3. Enter `1` in the id field
4. Click "Execute"

**Using curl:**
```bash
curl -X GET http://localhost:8080/api/employees/1
```

**Expected Response:**
```json
{
  "id": 1,
  "fullname": "Ola Nordmann",
  "jobTitle": "Senior Developer",
  "age": 30
}
```

**Status Code:** 200 OK

**Now test with a non-existent ID:**

```bash
curl -X GET http://localhost:8080/api/employees/999
```

**Expected Response:** Empty body  
**Status Code:** 404 Not Found

**What This Tests:** The dummy implementation returns employee for id=1, and 404 for other IDs.

---

### 4.3 Create New Employee

**Using Swagger UI:**
1. Expand the `POST /api/employees` endpoint
2. Click "Try it out"
3. Replace the example JSON with:
```json
{
  "fullname": "Per Hansen",
  "jobTitle": "Junior Developer",
  "age": 25
}
```
4. Click "Execute"

**Using curl:**
```bash
curl -X POST http://localhost:8080/api/employees \
  -H "Content-Type: application/json" \
  -d '{
    "fullname": "Per Hansen",
    "jobTitle": "Junior Developer",
    "age": 25
  }'
```

**Expected Response:**
```json
{
  "id": 1,
  "fullname": "Per Hansen",
  "jobTitle": "Junior Developer",
  "age": 25
}
```

**Status Code:** 201 Created

**What This Tests:** The dummy implementation accepts the employee data and returns it with a hardcoded id=1.

---

### 4.4 Update Employee

**Using Swagger UI:**
1. Expand the `PUT /api/employees/{id}` endpoint
2. Click "Try it out"
3. Enter `1` in the id field
4. Replace the example JSON with:
```json
{
  "fullname": "Ola Nordmann",
  "jobTitle": "Lead Developer",
  "age": 31
}
```
5. Click "Execute"

**Using curl:**
```bash
curl -X PUT http://localhost:8080/api/employees/1 \
  -H "Content-Type: application/json" \
  -d '{
    "fullname": "Ola Nordmann",
    "jobTitle": "Lead Developer",
    "age": 31
  }'
```

**Expected Response:**
```json
{
  "id": 1,
  "fullname": "Ola Nordmann",
  "jobTitle": "Lead Developer",
  "age": 31
}
```

**Status Code:** 200 OK

**Now test with a non-existent ID:**

```bash
curl -X PUT http://localhost:8080/api/employees/999 \
  -H "Content-Type: application/json" \
  -d '{
    "fullname": "Test User",
    "jobTitle": "Test",
    "age": 25
  }'
```

**Expected Response:** Empty body  
**Status Code:** 404 Not Found

**What This Tests:** The dummy implementation accepts updates for id=1, returns 404 for other IDs.

---

### 4.5 Delete Employee

**Using Swagger UI:**
1. Expand the `DELETE /api/employees/{id}` endpoint
2. Click "Try it out"
3. Enter `1` in the id field
4. Click "Execute"

**Using curl:**
```bash
curl -X DELETE http://localhost:8080/api/employees/1
```

**Expected Response:** Empty body  
**Status Code:** 204 No Content

**Now test with a non-existent ID:**

```bash
curl -X DELETE http://localhost:8080/api/employees/999
```

**Expected Response:** Empty body  
**Status Code:** 404 Not Found

**What This Tests:** The dummy implementation returns 204 for id=1, 404 for other IDs.

---

## Step 5: Test Learning Material Endpoints

### 5.1 Get All Learning Materials

**Using Swagger UI:**
1. Expand the `GET /api/learning-materials` endpoint
2. Click "Try it out"
3. Click "Execute"

**Using curl:**
```bash
curl -X GET http://localhost:8080/api/learning-materials
```

**Expected Response:**
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
    },
    "tagIds": [1, 2],
    "wikiNoteIds": [],
    "notes": "[]"
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
    },
    "tagIds": [3, 4],
    "wikiNoteIds": [1],
    "notes": "[]"
  }
]
```

**Status Code:** 200 OK

**What This Tests:** The dummy implementation returns a hardcoded list of learning materials with nested type objects.

---

### 5.2 Get Learning Material by ID

**Using Swagger UI:**
1. Expand the `GET /api/learning-materials/{id}` endpoint
2. Click "Try it out"
3. Enter `1` in the id field
4. Click "Execute"

**Using curl:**
```bash
curl -X GET http://localhost:8080/api/learning-materials/1
```

**Expected Response:**
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
  },
  "tagIds": [1, 2],
  "wikiNoteIds": [],
  "notes": "[]"
}
```

**Status Code:** 200 OK

**Now test with a non-existent ID:**

```bash
curl -X GET http://localhost:8080/api/learning-materials/999
```

**Expected Response:** Empty body  
**Status Code:** 404 Not Found

**What This Tests:** The dummy implementation returns material for id=1, and 404 for other IDs.

---

### 5.3 Create New Learning Material

**Using Swagger UI:**
1. Expand the `POST /api/learning-materials` endpoint
2. Click "Try it out"
3. Replace the example JSON with:
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
4. Click "Execute"

**Using curl:**
```bash
curl -X POST http://localhost:8080/api/learning-materials \
  -H "Content-Type: application/json" \
  -d '{
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
  }'
```

**Expected Response:**
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

**Status Code:** 201 Created

**What This Tests:** The dummy implementation accepts the learning material data and returns it with a hardcoded id=1.

---

### 5.4 Update Learning Material

**Using Swagger UI:**
1. Expand the `PUT /api/learning-materials/{id}` endpoint
2. Click "Try it out"
3. Enter `1` in the id field
4. Replace the example JSON with:
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
5. Click "Execute"

**Using curl:**
```bash
curl -X PUT http://localhost:8080/api/learning-materials/1 \
  -H "Content-Type: application/json" \
  -d '{
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
  }'
```

**Expected Response:**
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

**Status Code:** 200 OK

**Now test with a non-existent ID:**

```bash
curl -X PUT http://localhost:8080/api/learning-materials/999 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Material",
    "description": "Test",
    "link": "https://example.com/test",
    "price": 1000,
    "type": {
      "id": 1,
      "name": "Book"
    },
    "tagIds": [],
    "wikiNoteIds": [],
    "notes": "[]"
  }'
```

**Expected Response:** Empty body  
**Status Code:** 404 Not Found

**What This Tests:** The dummy implementation accepts updates for id=1, returns 404 for other IDs.

---

### 5.5 Delete Learning Material

**Using Swagger UI:**
1. Expand the `DELETE /api/learning-materials/{id}` endpoint
2. Click "Try it out"
3. Enter `1` in the id field
4. Click "Execute"

**Using curl:**
```bash
curl -X DELETE http://localhost:8080/api/learning-materials/1
```

**Expected Response:** Empty body  
**Status Code:** 204 No Content

**Now test with a non-existent ID:**

```bash
curl -X DELETE http://localhost:8080/api/learning-materials/999
```

**Expected Response:** Empty body  
**Status Code:** 404 Not Found

**What This Tests:** The dummy implementation returns 204 for id=1, 404 for other IDs.

---

## Step 6: Verify API Documentation

Check the OpenAPI JSON specification:

```bash
curl http://localhost:8080/v3/api-docs
```

**Expected Result:**
- Returns a JSON document with the complete OpenAPI specification
- Contains all endpoints, schemas, and documentation

**What This Tests:** The OpenAPI documentation is properly configured and accessible.

---

## Step 7: Review the Code Structure

Verify the project structure:

```bash
tree src/main/kotlin/no/teamup/core/
```

**Expected Structure:**
```
src/main/kotlin/no/teamup/core/
├── CoreApplication.kt
├── config/
│   └── OpenApiConfig.kt
├── controller/
│   ├── EmployeeController.kt
│   └── LearningMaterialController.kt
└── model/
    ├── Employee.kt
    ├── LearningMaterial.kt
    └── LearningMaterialType.kt
```

**What to Check:**
- All files are in the correct packages
- No database-related files (repositories, configurations)
- Clean separation of concerns

---

## Step 8: Check Code Formatting

Run the code formatter to ensure consistent style:

```bash
./mvnw spotless:check
```

**Expected Result:** "BUILD SUCCESS" (code is properly formatted)

If formatting issues are found, fix them with:

```bash
./mvnw spotless:apply
```

---

## Step 9: Stop the Application

Return to the terminal where the application is running and press `Ctrl+C` to stop it.

**Expected Result:** Application shuts down gracefully.

---

## Test Summary

Once you've completed all the steps above, you should have verified:

✅ **Build System:** Project compiles successfully  
✅ **Application Startup:** Spring Boot starts without errors  
✅ **Swagger UI:** API documentation is accessible and complete  
✅ **Employee Endpoints:** All 5 endpoints work with dummy data  
✅ **Learning Material Endpoints:** All 5 endpoints work with dummy data  
✅ **HTTP Status Codes:** Correct codes returned (200, 201, 204, 404)  
✅ **JSON Serialization:** Complex objects with nested types serialize correctly  
✅ **OpenAPI Spec:** API specification is available  
✅ **Code Structure:** Clean organization without database complexity  

---

## Next Steps

After verifying that all tests pass, you can:

1. Review the dummy implementation code in the controllers
2. See [ENDPOINTS.md](../ENDPOINTS.md) for implementation guidance
3. Start implementing real database persistence step-by-step

---

## Troubleshooting

### Tests Failing?

**Problem:** Getting different status codes than expected  
**Solution:** Ensure you're using the correct endpoint URL and HTTP method

**Problem:** JSON parsing errors  
**Solution:** Check that your JSON request body is properly formatted (valid JSON syntax)

**Problem:** Connection refused errors  
**Solution:** Make sure the application is running on port 8080

### Need More Help?

See the main [README.md](../README.md) for additional troubleshooting tips and contact information.
