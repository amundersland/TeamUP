# Dependencies

All dependencies are declared in `pom.xml`. Versions without an explicit entry are managed by the Spring Boot parent BOM.

---

## Parent BOM

### `spring-boot-starter-parent` `4.0.3`
The Spring Boot parent POM. Acts as a Bill of Materials (BOM) that manages compatible versions for all Spring and common third-party dependencies, so most dependencies below do not need explicit version numbers.

[Maven Repository](https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-parent/4.0.3)

---

## Compile / Runtime

### `spring-boot-starter-webmvc`
Bundles everything needed to build a Spring MVC REST API: an embedded Tomcat server, the Spring MVC dispatcher, and JSON support via Jackson. This is the core web dependency of the project.

[Maven Repository](https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-web)

---

### `kotlin-reflect`
The Kotlin reflection library. Required by Spring to inspect Kotlin classes, constructors, and nullability at runtime — without it, Spring cannot properly instantiate Kotlin data classes or handle constructor injection.

[Maven Repository](https://mvnrepository.com/artifact/org.jetbrains.kotlin/kotlin-reflect)

---

### `kotlin-stdlib`
The Kotlin standard library. Provides core language extensions, collections, and utilities. Required for any Kotlin project.

[Maven Repository](https://mvnrepository.com/artifact/org.jetbrains.kotlin/kotlin-stdlib)

---

### `jackson-module-kotlin`
A Jackson module that adds support for Kotlin-specific features such as data classes, default parameter values, and nullable types. Without it, Jackson cannot correctly serialize and deserialize Kotlin data classes to/from JSON.

[Maven Repository](https://mvnrepository.com/artifact/com.fasterxml.jackson.module/jackson-module-kotlin)

---

### `springdoc-openapi-starter-webmvc-ui` `3.0.1`
Generates an OpenAPI 3 specification from the Spring MVC controllers at runtime and serves an interactive Swagger UI at `/swagger-ui.html`. Allows exploring and testing the API directly in the browser without any extra tooling.

[Maven Repository](https://mvnrepository.com/artifact/org.springdoc/springdoc-openapi-starter-webmvc-ui/3.0.1)

---

## Test

### `spring-boot-starter-webmvc-test`
The Spring Boot test starter. Includes JUnit 5, AssertJ, MockMvc, and Spring's test context framework. Used for writing integration and slice tests against the web layer.

[Maven Repository](https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-test)

---

### `kotest-runner-junit5` `5.9.1`
The JUnit 5 runner for Kotest. Allows Kotest specs (such as `FunSpec`) to be discovered and executed by the standard JUnit 5 engine, including Maven Surefire and IDE test runners.

[Maven Repository](https://mvnrepository.com/artifact/io.kotest/kotest-runner-junit5/5.9.1)

---

### `kotest-extensions-spring` `1.3.0`
A Kotest extension that integrates Spring's test context into Kotest specs. Enables `@SpringBootTest` and Spring dependency injection to work within Kotest's `FunSpec` and other spec styles.

[Maven Repository](https://mvnrepository.com/artifact/io.kotest.extensions/kotest-extensions-spring/1.3.0)

---

### `mockk-jvm` `1.13.13`
A Kotlin-first mocking library. Provides a clean, idiomatic DSL for creating mocks, stubs, and verifying interactions — designed to work naturally with Kotlin's type system and coroutines.

[Maven Repository](https://mvnrepository.com/artifact/io.mockk/mockk-jvm/1.13.13)

---

### `springmockk` `4.0.2`
A companion library to MockK that provides Spring-aware mock support. Replaces Spring's `@MockBean` / `@SpyBean` (which use Mockito) with `@MockkBean` / `@SpykBean` for idiomatic Kotlin mocking in Spring tests.

[Maven Repository](https://mvnrepository.com/artifact/com.ninja-squad/springmockk/4.0.2)

---

## Build Plugin Dependencies

### `kotlin-maven-allopen` `2.2.21`
A Kotlin compiler plugin that makes classes annotated with Spring stereotypes (e.g. `@Component`, `@Service`, `@RestController`) open by default. Required because Kotlin classes are final by default, but Spring needs to subclass them for proxying and AOP.

[Maven Repository](https://mvnrepository.com/artifact/org.jetbrains.kotlin/kotlin-maven-allopen)
