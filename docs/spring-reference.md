# Spring Reference

## Spring Concepts and Annotations

| Concept / Annotation | Usage in project | Links to online resources |
|---|---|---|
| `@SpringBootApplication` | Placed on `CoreApplication.kt` to bootstrap the entire application. Enables auto-configuration, component scanning, and Spring Boot defaults. | |
| `@Configuration` | Used in `OpenApiConfig.kt` to mark the class as a source of bean definitions. Allows defining Spring-managed beans via `@Bean` methods. | |
| `@Bean` | Used inside `OpenApiConfig.kt` to register the OpenAPI configuration object as a Spring-managed bean. | |
| `@RestController` | Placed on `EmployeeController` and `LearningMaterialController` to mark them as REST endpoints. Combines `@Controller` and `@ResponseBody` so return values are serialized directly to JSON. | |
| `@RequestMapping` | Set at class level on both controllers with the base path `/api`. All handler methods inherit this prefix. | |
| `@GetMapping` | Used on read endpoints in both controllers, e.g. `GET /api/employees` and `GET /api/employees/{id}`. Maps HTTP GET requests to the annotated handler method. | |
| `@PostMapping` | Used on create endpoints in both controllers, e.g. `POST /api/employees`. Maps HTTP POST requests to the annotated handler method. | |
| `@PutMapping` | Used on update endpoints in both controllers, e.g. `PUT /api/employees/{id}`. Maps HTTP PUT requests to the annotated handler method. | |
| `@DeleteMapping` | Used on delete endpoints in both controllers, e.g. `DELETE /api/employees/{id}`. Maps HTTP DELETE requests to the annotated handler method. | |
| `@PathVariable` | Extracts the `id` segment from the URL in get-by-id, update, and delete endpoints in both controllers. Binds the URI template variable to the method parameter. | |
| `@RequestBody` | Used on the `employee` and `learningMaterial` parameters in create and update endpoints. Deserializes the incoming JSON request body into the Kotlin data class. | |
| `@Tag` (OpenAPI) | Applied at controller class level to group related endpoints under a named tag in Swagger UI (e.g. "Employee", "Learning Material"). | |
| `@Operation` (OpenAPI) | Applied to each handler method to provide a human-readable summary and description visible in Swagger UI. All five CRUD endpoints in each controller are annotated. | |
| `@ApiResponses` (OpenAPI) | Wraps a list of `@ApiResponse` annotations on each handler method to document all possible HTTP response codes. | |
| `@ApiResponse` (OpenAPI) | Documents individual response codes (e.g. 200, 201, 404) per endpoint, including the content type and schema of the response body. | |
| `@Content` (OpenAPI) | Nested inside `@ApiResponse` to describe the media type (application/json) and link to the response schema for success responses. | |
| `@Schema` (OpenAPI) | Used both at class level on `Employee`, `LearningMaterial`, and `LearningMaterialType` models and on individual fields to provide descriptions and examples in the generated API docs. | |

## Libraries and Dependencies

| Library / Dependency | Usage in project | Links to online resources |
|---|---|---|
| `spring-boot-starter-parent` 4.0.3 | Declared as the Maven parent POM. Provides dependency management, default plugin versions, and build conventions for the whole project. | |
| `spring-boot-starter-webmvc` | Core web dependency that brings in Spring MVC, an embedded servlet container, and JSON support. Powers all REST controllers in the project. | |
| `kotlin-reflect` | Required by Spring to introspect Kotlin classes at runtime. Enables features like constructor injection and data class binding to work correctly. | |
| `kotlin-stdlib` | The Kotlin standard library. Provides core language extensions, collections, and utilities used throughout the Kotlin source code. | |
| `jackson-module-kotlin` | Enables Jackson to serialize and deserialize Kotlin data classes, including support for default parameter values and non-nullable types. Used when converting `Employee` and `LearningMaterial` to/from JSON. | |
| `springdoc-openapi-starter-webmvc-ui` 3.0.1 | Generates the OpenAPI 3 spec and serves Swagger UI at `/swagger-ui.html`. Picks up all `@Operation`, `@Schema`, and related annotations automatically. | |
| `spring-boot-starter-webmvc-test` | Provides `MockMvc` and Spring test context support for writing integration-style controller tests. | |
| `kotest-runner-junit5` 5.9.1 | Enables Kotest specs to run on the JUnit 5 platform used by Maven Surefire. All project tests are written in Kotest FunSpec style. | |
| `kotest-extensions-spring` 1.3.0 | Integrates the Spring test context (e.g. `@SpringBootTest`) with Kotest test lifecycle. Allows Spring beans to be injected into Kotest specs. | |
| `mockk-jvm` 1.13.13 | Kotlin-native mocking library used to create mocks and stubs in unit tests. Works well with Kotlin's non-nullable type system and coroutines. | |
| `springmockk` 4.0.2 | Bridges MockK with Spring's test context, providing `@MockkBean` as the Kotlin equivalent of `@MockBean`. Used to replace Spring beans with mocks in controller tests. | |
| `spring-boot-maven-plugin` | Packages the application as an executable JAR. Also used to run the app locally via `./mvnw spring-boot:run`. | |
| `spotless-maven-plugin` 3.2.1 | Enforces consistent code formatting using KtLint 1.8.0. Run via `./mvnw spotless:apply` to auto-format all Kotlin source files. | |
| `kotlin-maven-plugin` 2.2.21 | Compiles Kotlin sources as part of the Maven build lifecycle. Configured with the `allopen` compiler plugin to support Spring's proxy-based features. | |
| `kotlin-maven-allopen` 2.2.21 | Makes annotated Kotlin classes open at compile time without requiring the `open` keyword. Necessary because Spring needs to subclass beans for proxying. | |
