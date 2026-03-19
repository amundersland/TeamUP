# How to Run Spotless Commands

Spotless is a code formatter that enforces consistent code style using KtLint for Kotlin. Here's how to use it:

## Quick Reference

### Check Formatting (without making changes)
```bash
./mvnw spotless:check
```

### Apply Formatting (automatically fix issues)
```bash
./mvnw spotless:apply
```

---

## Detailed Explanation

### What is Spotless?

Spotless is a Maven plugin that ensures code formatting consistency. For this project, it uses **KtLint 1.8.0** to format Kotlin files according to best practices.

### Command 1: Check Current Formatting

**Command:**
```bash
./mvnw spotless:check
```

**What it does:**
- Scans all Kotlin files
- Checks if they comply with the KtLint formatting rules
- **Does NOT modify any files**
- Returns exit code 0 if all files are properly formatted
- Returns exit code 1 if there are formatting violations

**Example Output (when formatting is correct):**
```
[INFO] Spotless.Kotlin is keeping 7 files clean - 0 needs changes to be clean, 0 were already clean, 7 were skipped because caching determined they were already clean
[INFO] BUILD SUCCESS
```

**Example Output (when formatting has issues):**
```
[ERROR] Failed to execute goal com.diffplug.spotless:spotless-maven-plugin:3.2.1:check (default-cli) on project core: The following files had format violations:
[ERROR]     src/main/kotlin/no/teamup/core/model/Employee.kt
[ERROR]     src/main/kotlin/no/teamup/core/controller/EmployeeController.kt
[ERROR] Run 'mvn spotless:apply' to fix these violations.
```

**Use this when:**
- You want to verify formatting without making changes
- Running in CI/CD pipelines
- You want to see what needs to be fixed

---

### Command 2: Apply Formatting

**Command:**
```bash
./mvnw spotless:apply
```

**What it does:**
- Scans all Kotlin files
- Automatically fixes formatting violations
- **Modifies files that don't comply**
- Returns exit code 0 on success

**Example Output:**
```
[INFO] clean file: /home/.../src/main/kotlin/no/teamup/core/model/Employee.kt
[INFO] clean file: /home/.../src/main/kotlin/no/teamup/core/model/LearningMaterial.kt
[INFO] Spotless.Kotlin is keeping 7 files clean - 4 were changed to be clean, 0 were already clean, 3 were skipped
[INFO] BUILD SUCCESS
```

**Use this when:**
- You've written new code and want to format it
- After running `spotless:check` shows violations
- Before committing code to ensure consistency

---

## Step-by-Step Workflow

### Scenario 1: Check if Code Needs Formatting

```bash
# Navigate to project
cd worktrees/18_sette-opp-spring-backend-med-dummy-endepunkter

# Check current formatting
./mvnw spotless:check
```

**If you see "BUILD SUCCESS":** Your code is properly formatted, no action needed.

**If you see formatting violations:** Move to Step 2.

### Scenario 2: Fix Formatting Violations

```bash
# Apply formatting fixes
./mvnw spotless:apply

# Verify all files are now clean
./mvnw spotless:check
```

Expected output:
```
[INFO] BUILD SUCCESS
```

---

## Common Issues and Solutions

### Issue: "The following files had format violations"

**Solution:** Run `spotless:apply` to fix them automatically:
```bash
./mvnw spotless:apply
```

### Issue: "One or more files have incorrect indentation"

**Solution:** The KtLint indentation rules (usually 4 spaces) are not being followed. Run:
```bash
./mvnw spotless:apply
```

### Issue: "Unexpected spacing around annotations"

**Solution:** Spotless will fix spacing around annotations. Run:
```bash
./mvnw spotless:apply
```

### Issue: Build fails with Spotless errors in CI/CD

**Solution:** The pipeline includes `spotless:check` to ensure code quality. You must fix locally:
```bash
./mvnw spotless:apply
git add .
git commit -m "chore: apply spotless formatting"
git push
```

---

## Configuration

Spotless is configured in `pom.xml`:

```xml
<plugin>
    <groupId>com.diffplug.spotless</groupId>
    <artifactId>spotless-maven-plugin</artifactId>
    <version>3.2.1</version>
    <configuration>
        <kotlin>
            <ktlint>
                <version>1.8.0</version>
            </ktlint>
        </kotlin>
    </configuration>
</plugin>
```

**Formatting Rules Applied:**
- KtLint 1.8.0 rules
- 4-space indentation
- No trailing whitespace
- Proper spacing around annotations
- Consistent style across all Kotlin files

---

## Integration with Git Workflow

### Recommended Pre-Commit Workflow

1. **Write or modify code**
   ```bash
   # Edit files...
   ```

2. **Check formatting before staging**
   ```bash
   ./mvnw spotless:check
   ```

3. **Apply fixes if needed**
   ```bash
   ./mvnw spotless:apply
   ```

4. **Verify everything is clean**
   ```bash
   ./mvnw spotless:check
   ```

5. **Stage and commit**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

---

## Useful Combinations

### Full Code Quality Check Before Commit

```bash
# Compile the code
./mvnw clean compile

# Check formatting
./mvnw spotless:check

# If spotless:check fails, apply fixes
./mvnw spotless:apply

# Run tests (if they exist)
./mvnw test

# Now safe to commit
git add .
git commit -m "your message"
```

### Quick Format + Build

```bash
./mvnw spotless:apply && ./mvnw clean install
```

---

## What Gets Formatted?

Spotless formats:
- All Kotlin files (`.kt`)
- Based on KtLint rules
- Only in `src/` directories

**Not formatted:**
- Documentation files
- Configuration files
- Build files (pom.xml is not reformatted)

---

## Verification

To verify the code is properly formatted:

```bash
./mvnw spotless:check
```

Should return:
```
[INFO] Spotless.Kotlin is keeping X files clean - 0 needs changes to be clean
[INFO] BUILD SUCCESS
```

The key indicator is **"0 needs changes to be clean"** - this means all files are properly formatted.

---

## For More Information

- [Spotless GitHub Repository](https://github.com/diffplug/spotless)
- [KtLint Rules](https://github.com/pinterest/ktlint)
- Project configuration: `pom.xml` lines 122-131
