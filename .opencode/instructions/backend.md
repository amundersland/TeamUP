# Backend instructions

You are assisting with the Kotlin‑based Spring Boot 4 backend (`TeamUP/core`) using Maven, Java 25, Kotlin 2.2.21, and PostgreSQL.

## Dependencies and versions

From the current `pom.xml`:

- Spring Boot version: `4.0.3`.
- Java: `25`.
- Kotlin: `2.2.21`.
- Testing:
  - Kotest: `5.9.1`.
  - MockK: `1.13.13`.
- API docs:
  - SpringDoc‑OpenAPI: `springdoc-openapi-starter-webmvc-ui:3.0.1`.
- Database:
  - PostgreSQL driver: `org.postgresql:postgresql`.
  - In‑memory H2 only for tests.

Prefer to keep these dependency versions aligned (or use newer patch/minor versions only if explicitly requested).

## Build and run commands

- Build the project:

  ```bash
  cd TeamUP
  ./mvnw clean install
  ```

- Run the backend:

  ```bash
  ./mvnw spring-boot:run
  ```

- Run tests (including Kotest):

  ```bash
  ./mvnw test
  ./mvnw verify
  ```

Prefer `mvn`‑based commands and avoid Gradle unless explicitly requested.

## Code style and conventions

- Use idiomatic Kotlin:
  - Prefer `val` over `var`.
  - Prefer extension functions, `sealed` classes, and coroutines where appropriate.
- For Spring:
  - Use constructor injection over field injection.
  - Use `@Component`, `@Service`, `@Repository`, `@Controller` consistently.
  - Align with existing package layout (e.g., `no.teamup.*`).
- For tests:
  - Use Kotest FunSpec style where the project already uses it.
  - Use MockK for Kotlin mocking, via `com.ninja-squad:springmockk` for Spring‑aware mocks.

## Spotless / formatting

Spotless with KtLint is configured in the `pom.xml`:

```xml
<plugin>
  <groupId>com.diffplug.spotless</groupId>
  <artifactId>spotless-maven-plugin</artifactId>
  <configuration>
    <kotlin>
      <ktlint>
        <version>1.8.0</version>
      </ktlint>
    </kotlin>
  </configuration>
</plugin>
```

Prefer to format code via:

```bash
./mvnw spotless:apply
```

or at least match the KtLint style.

## Boundaries and what to avoid

- Do not:
  - Commit secrets or credentials to the repo.
  - Rewrite unrelated features or large parts of the backend without explicit approval.
  - Change major dependency versions (e.g., Spring Boot 4.x → 5.x) without explicit approval.
- When in doubt:
  - Propose a small, focused change first.
  - Ask clarifying questions or suggest a short plan before implementing large backend features.