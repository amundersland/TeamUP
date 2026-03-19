# Annotations

A reference for every annotation used in this project, what it does, and where it appears.

---

## Spring Boot

### `@SpringBootApplication`
Used on the main application class (`CoreApplication.kt`). A convenience annotation that combines `@Configuration`, `@EnableAutoConfiguration`, and `@ComponentScan`. It bootstraps the entire Spring context and triggers auto-configuration of the application.

[Documentation](https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/autoconfigure/SpringBootApplication.html)

---

## Spring Context

### `@Configuration`
Marks a class as a source of bean definitions (`OpenApiConfig.kt`). Spring processes `@Configuration` classes during startup and registers any `@Bean` methods they contain into the application context.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/annotation/Configuration.html)

### `@Bean`
Marks a method inside a `@Configuration` class as a bean factory (`OpenApiConfig.kt`). Spring calls the method at startup and registers the returned object as a managed bean in the application context.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/context/annotation/Bean.html)

---

## Spring Web MVC

### `@RestController`
Applied to controller classes (`EmployeeController.kt`, `LearningMaterialController.kt`). A composed annotation of `@Controller` and `@ResponseBody` — tells Spring that this class handles HTTP requests and that all return values should be serialized directly to the HTTP response body (as JSON).

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/RestController.html)

### `@RequestMapping`
Defines the base URL path for all endpoints in a controller class. Both controllers use `@RequestMapping("/api")`, so all their endpoints are rooted under `/api`.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/RequestMapping.html)

### `@GetMapping`
Maps an HTTP `GET` request to a specific handler method. Used on methods that retrieve and return resources without modifying server state.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/GetMapping.html)

### `@PostMapping`
Maps an HTTP `POST` request to a handler method. Used on methods that create new resources.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/PostMapping.html)

### `@PutMapping`
Maps an HTTP `PUT` request to a handler method. Used on methods that replace an existing resource in full.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/PutMapping.html)

### `@DeleteMapping`
Maps an HTTP `DELETE` request to a handler method. Used on methods that remove a resource.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/DeleteMapping.html)

### `@PathVariable`
Binds a URI template variable (e.g. `/employees/{id}`) to a method parameter. Spring extracts the value from the URL and injects it as the parameter value.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/PathVariable.html)

### `@RequestBody`
Binds the HTTP request body to a method parameter. Spring uses Jackson to deserialize the incoming JSON into the annotated Kotlin object.

[Documentation](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/RequestBody.html)

---

## SpringDoc / Swagger (OpenAPI 3)

### `@Tag`
Applied at the controller class level. Groups all endpoints in that controller under a named section in the Swagger UI, making the API documentation easier to navigate.

[Documentation](https://docs.swagger.io/swagger-core/v2.0.0/apidocs/io/swagger/v3/oas/annotations/tags/Tag.html)

### `@Operation`
Applied to individual endpoint methods. Provides a human-readable `summary` and `description` for the endpoint in the generated OpenAPI spec and Swagger UI.

[Documentation](https://docs.swagger.io/swagger-core/v2.0.0/apidocs/io/swagger/v3/oas/annotations/Operation.html)

### `@ApiResponses`
A container annotation that groups multiple `@ApiResponse` entries on a single method, describing the possible HTTP response codes and their meanings.

[Documentation](https://docs.swagger.io/swagger-core/v2.0.0/apidocs/io/swagger/v3/oas/annotations/responses/ApiResponses.html)

### `@ApiResponse`
Documents a single HTTP response for an endpoint — the status code, a description, and optionally the response body schema. Used inside `@ApiResponses`.

[Documentation](https://docs.swagger.io/swagger-core/v2.0.0/apidocs/io/swagger/v3/oas/annotations/responses/ApiResponse.html)

### `@Schema`
Used on model classes and their properties to enrich the generated OpenAPI spec with descriptions, examples, and access mode (e.g. `READ_ONLY` for auto-assigned IDs). Appears on `Employee`, `LearningMaterial`, and `LearningMaterialType`.

[Documentation](https://docs.swagger.io/swagger-core/v2.0.0/apidocs/io/swagger/v3/oas/annotations/media/Schema.html)
