# Libraries

A short overview of the third-party libraries used in this project, what they are, and why they are here.

---

## Spring Boot

Spring Boot is an opinionated framework built on top of the Spring Framework. It removes most boilerplate configuration by providing sensible defaults and auto-configuration, letting you start a production-ready web application with minimal setup.

In this project it provides the embedded web server, dependency injection container, MVC request handling, and JSON serialization.

[Maven Repository](https://mvnrepository.com/artifact/org.springframework.boot/spring-boot)

---

## Kotlin Standard Library

The official Kotlin standard library from JetBrains. Provides the core language utilities, collection extensions, and runtime support that every Kotlin program depends on.

[Maven Repository](https://mvnrepository.com/artifact/org.jetbrains.kotlin/kotlin-stdlib)

---

## Jackson (with Kotlin module)

Jackson is the de-facto standard JSON library for the JVM. The `jackson-module-kotlin` extension makes it understand Kotlin data classes, default parameter values, and nullable types, enabling clean serialization and deserialization of Kotlin objects to and from JSON.

[Maven Repository](https://mvnrepository.com/artifact/com.fasterxml.jackson.module/jackson-module-kotlin)

---

## SpringDoc OpenAPI

SpringDoc automatically generates an OpenAPI 3 specification by scanning your Spring MVC controllers and model classes. It also serves a Swagger UI at `/swagger-ui.html`, giving you interactive documentation and a way to test all endpoints directly in the browser — with no manual spec writing required.

[Maven Repository](https://mvnrepository.com/artifact/org.springdoc/springdoc-openapi-starter-webmvc-ui)

---

## Kotest

Kotest is a Kotlin-native testing framework. It offers several spec styles suited to different testing philosophies; this project uses `FunSpec`, which provides a clean `test("description") { }` syntax. It integrates with JUnit 5 so it works with standard build and IDE tooling.

[Maven Repository](https://mvnrepository.com/artifact/io.kotest/kotest-runner-junit5)

---

## MockK

MockK is the idiomatic Kotlin mocking library. It is built from the ground up for Kotlin, with full support for data classes, extension functions, coroutines, and Kotlin's type system. It replaces Mockito for Kotlin projects.

[Maven Repository](https://mvnrepository.com/artifact/io.mockk/mockk-jvm)

---

## SpringMockK

SpringMockK is a small companion library to MockK that bridges it with Spring Boot's test infrastructure. It provides `@MockkBean` and `@SpykBean` annotations as Kotlin-native replacements for Spring's `@MockBean` and `@SpyBean`, which are tied to Mockito.

[Maven Repository](https://mvnrepository.com/artifact/com.ninja-squad/springmockk)

---

## Spotless (with KtLint)

Spotless is a Maven/Gradle plugin for enforcing consistent code formatting. In this project it is configured to use KtLint as the Kotlin formatter. Running `./mvnw spotless:apply` automatically formats all Kotlin source files to the KtLint standard; `./mvnw spotless:check` (used in CI) fails the build if any file is not formatted.

[Maven Repository](https://mvnrepository.com/artifact/com.diffplug.spotless/spotless-maven-plugin)
