# TeamUP - Setup Instructions

## PostgreSQL Migration Complete! ✓

All code changes have been successfully implemented. The application is now configured to use PostgreSQL instead of SQLite.

---

## Prerequisites

Before running the application, you need to:

### 1. Ensure PostgreSQL is Running

Make sure PostgreSQL is installed and running on your system at `localhost:5432`.

### 2. Create the Database and Schema

Run the following commands in your terminal:

```bash
# Create the database
psql -U amund.ersland -c "CREATE DATABASE teamup;"

# Apply the schema (creates tables, triggers, functions)
psql -U amund.ersland -d teamup -f db-schema/schema.sql

# (Optional) Load seed data with test employees and learning materials
psql -U amund.ersland -d teamup -f db-schema/seed.sql
```

If you need to enter a password, use: `hest123` (or whatever password you set)

### 3. Update Password (Optional)

The `.env` file currently contains `DB_PASSWORD=hest123`. You can change this to your actual PostgreSQL password:

```bash
# Edit the .env file
nano .env
```

---

## Running the Application

```bash
# Build and run
./mvnw spring-boot:run

# Or build a JAR and run it
./mvnw clean package
java -jar target/core-0.0.1-SNAPSHOT.jar
```

---

## API Endpoints

Once running, the application provides these endpoints:

### Employee Endpoints
- `GET    /api/employees` - Get all employees
- `GET    /api/employees/{id}` - Get employee by ID
- `POST   /api/employees` - Create new employee
- `PUT    /api/employees/{id}` - Update employee
- `DELETE /api/employees/{id}` - Delete employee

### Learning Material Endpoints
- `GET    /api/learning-materials` - Get all learning materials
- `GET    /api/learning-materials/{id}` - Get learning material by ID
- `POST   /api/learning-materials` - Create new learning material
- `PUT    /api/learning-materials/{id}` - Update learning material
- `DELETE /api/learning-materials/{id}` - Delete learning material

### Swagger UI
- Navigate to: `http://localhost:8080/swagger-ui.html`
- API Docs: `http://localhost:8080/api-docs`

---

## Example API Calls

### Create an Employee
```bash
curl -X POST http://localhost:8080/api/employees \
  -H "Content-Type: application/json" \
  -d '{
    "fullname": "Ola Nordmann",
    "jobTitle": "Senior Developer",
    "age": 35
  }'
```

### Get All Employees
```bash
curl http://localhost:8080/api/employees
```

### Create a Learning Material
```bash
curl -X POST http://localhost:8080/api/learning-materials \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Kotlin in Action",
    "description": "Comprehensive guide to Kotlin",
    "link": "https://example.com/kotlin-book",
    "price": 4995,
    "type": {
      "id": 1
    },
    "tagIds": [1, 2],
    "wikiNoteIds": [],
    "notes": "[]"
  }'
```

**Note:** The `type.id` should reference an existing `learning_material_type.id` in the database. If you ran the seed data, valid IDs are:
- 1 = Book
- 2 = Online Course
- 3 = YouTube
- 4 = Live Course

---

## Changes Summary

### Database Configuration
- ✓ Switched from SQLite to PostgreSQL
- ✓ Database: `teamup`, Schema: `teamup`
- ✓ User: `amund.ersland`
- ✓ Password loaded from `.env` file (not committed to git)

### New Entities Created
- ✓ `Employee` - Maps to `teamup.employee` table
- ✓ `LearningMaterialType` - Maps to `teamup.learning_material_type` table
- ✓ `LearningMaterial` - Maps to `teamup.learning_material` table with PostgreSQL array and JSONB support

### Dependencies Added
- ✓ `postgresql` - PostgreSQL JDBC driver
- ✓ `hypersistence-utils-hibernate-63` - PostgreSQL array/JSONB support
- ✓ `dotenv-java` - Environment variable management

### Removed
- ✓ SQLite dependencies
- ✓ Old `Person` and `Task` entities (replaced with Employee and LearningMaterial)

---

## Troubleshooting

### "Connection refused" error
Make sure PostgreSQL is running:
```bash
sudo systemctl status postgresql
# or
sudo service postgresql status
```

### "Database does not exist" error
Create the database:
```bash
psql -U amund.ersland -c "CREATE DATABASE teamup;"
```

### "Relation does not exist" error
Apply the schema:
```bash
psql -U amund.ersland -d teamup -f db-schema/schema.sql
```

### "Authentication failed" error
Update the password in `.env` file to match your PostgreSQL user password.

---

## Next Steps

You can now:
1. Run the application and test the endpoints
2. Add more entity types from the schema (e.g., `Tag`, `WikiNote`, `LearningPath`, etc.)
3. Add custom query methods to repositories
4. Create integration tests
5. Add validation annotations to entities

Enjoy your PostgreSQL-powered TeamUP application! 🚀
