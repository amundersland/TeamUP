# TeamUP API Testing Scripts

Professional bash scripts for testing CRUD operations on the TeamUP Spring Boot API.

## 📋 Overview

This directory contains comprehensive testing scripts for:
- **Employee** entity (CREATE, READ, UPDATE, DELETE)
- **LearningMaterial** entity (CREATE, READ, UPDATE, DELETE)
- **Integration testing** with complete workflows

## 🚀 Quick Start

1. **Start the Spring Boot application**:
   ```bash
   cd /path/to/TeamUP
   ./mvnw spring-boot:run
   ```

2. **Run integration tests**:
   ```bash
   ./curl-testing/live-testing/run-all-tests.sh
   ```

3. **Test individual entities**:
   ```bash
   # Employee operations
   ./curl-testing/live-testing/employee-test.sh create -n "John Doe" -j "Developer"
   ./curl-testing/live-testing/employee-test.sh get-all
   
   # Learning Material operations
   ./curl-testing/live-testing/learning-material-test.sh create -n "Clean Code" -t 2
   ./curl-testing/live-testing/learning-material-test.sh get-all
   ```

## 📁 Files

| File | Description |
|------|-------------|
| `common.sh` | Shared utilities (HTTP requests, JSON formatting, colors) |
| `employee-test.sh` | Employee CRUD operations testing |
| `learning-material-test.sh` | LearningMaterial CRUD operations testing |
| `run-all-tests.sh` | Integration test suite (full CRUD workflows) |
| `responses/` | Auto-created directory for saved JSON responses |

## 🔧 Scripts Usage

### employee-test.sh

```bash
# Show help
./employee-test.sh --help

# Create employee
./employee-test.sh create -n "Jane Smith" -j "Designer" -a 28

# Get all employees
./employee-test.sh get-all

# Get employee by ID
./employee-test.sh get -i 1

# Update employee
./employee-test.sh update -i 1 -n "Jane Smith-Jones" -j "Senior Designer" -a 29

# Delete employee (with confirmation)
./employee-test.sh delete -i 1

# Delete employee (skip confirmation)
./employee-test.sh delete -i 1 -y
```

### learning-material-test.sh

```bash
# Show help
./learning-material-test.sh --help

# Create learning material (minimal)
./learning-material-test.sh create -n "Design Patterns" -t 2

# Create with all fields
./learning-material-test.sh create \
  -n "Clean Architecture" \
  -d "Book about software architecture" \
  -l "https://example.com/book" \
  -p 499 \
  -t 2 \
  --tag-ids "1,2,3" \
  --wiki-note-ids "100,200" \
  --notes '{"author":"Robert C. Martin","pages":432}'

# Get all learning materials
./learning-material-test.sh get-all

# Get learning material by ID
./learning-material-test.sh get -i 1

# Update learning material
./learning-material-test.sh update -i 1 -n "Updated Name" -t 2

# Delete learning material
./learning-material-test.sh delete -i 1
```

### run-all-tests.sh

```bash
# Run all tests with cleanup
./run-all-tests.sh

# Run tests but keep test data
./run-all-tests.sh --no-cleanup

# Run with verbose output
./run-all-tests.sh --verbose
```

## 🎨 Features

- ✅ **Color-coded output** (success=green, error=red, warning=yellow, info=blue)
- ✅ **Automatic response saving** to `responses/` directory with timestamps
- ✅ **Pretty-printed JSON** with syntax highlighting (requires `jq`)
- ✅ **Server health check** before making requests
- ✅ **Comprehensive help** for each function with examples
- ✅ **Short & long options** (e.g., `-n` or `--name`)
- ✅ **Function aliases** (e.g., `create`, `create_employee`, `create-employee`)
- ✅ **Array handling** for comma-separated values → JSON arrays
- ✅ **Confirmation prompts** for delete operations (skip with `-y`)
- ✅ **Verbose mode** for debugging (`--verbose` or `-v`)
- ✅ **NO_COLOR support** for non-color terminals

## 🔑 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `API_BASE_URL` | API base URL | `http://localhost:8080/api` |
| `SAVE_RESPONSES` | Save responses to files | `true` |
| `RESPONSE_DIR` | Response save directory | `./responses` |
| `VERBOSE` | Enable verbose output | `false` |
| `NO_COLOR` | Disable colored output | (unset) |

Example:
```bash
# Change API URL
export API_BASE_URL="http://localhost:9090/api"
./employee-test.sh get-all

# Disable response saving
export SAVE_RESPONSES=false
./employee-test.sh create -n "Test"

# Enable verbose mode
export VERBOSE=true
./run-all-tests.sh
```

## 📊 Learning Material Types

When creating/updating learning materials, use these type IDs:

| ID | Type |
|----|------|
| 2 | Book |
| 3 | Online Course |
| 4 | YouTube |
| 5 | Live Course |

Example:
```bash
./learning-material-test.sh create -n "React Tutorial" -t 4  # YouTube
./learning-material-test.sh create -n "Design Patterns" -t 2  # Book
```

## 🧪 Testing Workflow

The `run-all-tests.sh` script executes:

1. **Employee Workflow**:
   - CREATE → GET by ID → GET ALL → UPDATE → DELETE

2. **LearningMaterial Workflow**:
   - CREATE → GET by ID → GET ALL → UPDATE → DELETE

3. **Summary Report**:
   - Color-coded pass/fail counts
   - Exit code 0 if all pass, 1 if any fail

## 📝 Response Files

All API responses are automatically saved to `responses/` with format:
```
responses/
├── employee_create_20260317_143022.json
├── employee_get_20260317_143023.json
├── learning_material_create_20260317_143025.json
└── ...
```

Timestamps use format: `YYYYMMDD_HHMMSS`

## 🛠️ Requirements

- **curl** - HTTP client (required)
- **jq** - JSON processor (optional, for pretty-printing)
- **bash** 4.0+ - Shell interpreter
- **TeamUP API** running on `http://localhost:8080`

Install jq (optional):
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq

# Fedora
sudo dnf install jq
```

## 🐛 Troubleshooting

### Server not responding
```bash
# Check if Spring Boot is running
curl http://localhost:8080/api/employees

# Start the application
./mvnw spring-boot:run
```

### Permission denied
```bash
# Make scripts executable
chmod +x curl-testing/live-testing/*.sh
```

### JSON parsing errors
```bash
# Install jq for better JSON handling
sudo apt-get install jq  # Ubuntu/Debian
brew install jq          # macOS
```

### Colored output issues
```bash
# Disable colors if terminal doesn't support them
export NO_COLOR=1
./run-all-tests.sh
```

## 💡 Tips

1. **Use verbose mode** for debugging:
   ```bash
   ./employee-test.sh create -n "Test" --verbose
   ```

2. **Keep test data** for manual inspection:
   ```bash
   ./run-all-tests.sh --no-cleanup
   ```

3. **View saved responses**:
   ```bash
   ls -lh responses/
   cat responses/employee_create_*.json | jq '.'
   ```

4. **Chain operations** in bash:
   ```bash
   # Create and capture ID, then get it
   ID=$(./employee-test.sh create -n "Test" | jq -r '.id')
   ./employee-test.sh get -i $ID
   ```

## 📚 Examples

### Complete Employee Workflow
```bash
# Create
./employee-test.sh create -n "Alice Johnson" -j "Developer" -a 30

# List all (note the ID)
./employee-test.sh get-all

# Get specific (use ID from above)
./employee-test.sh get -i 1

# Update
./employee-test.sh update -i 1 -n "Alice Johnson-Smith" -j "Senior Developer" -a 31

# Delete
./employee-test.sh delete -i 1 -y
```

### Complete Learning Material Workflow
```bash
# Create with arrays and JSONB
./learning-material-test.sh create \
  -n "Kubernetes in Action" \
  -d "Learn Kubernetes from the ground up" \
  -l "https://manning.com/books/kubernetes-in-action" \
  -p 599 \
  -t 2 \
  --tag-ids "5,6,7" \
  --wiki-note-ids "300,301,302" \
  --notes '{"author":"Marko Lukša","publisher":"Manning","isbn":"9781617293726"}'

# List all
./learning-material-test.sh get-all

# Get specific
./learning-material-test.sh get -i 1

# Update
./learning-material-test.sh update -i 1 -n "Kubernetes in Action (2nd Edition)" -t 2

# Delete
./learning-material-test.sh delete -i 1
```

## 📄 License

Part of the TeamUP project.
