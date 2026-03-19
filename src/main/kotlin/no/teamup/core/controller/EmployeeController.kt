package no.teamup.core.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import no.teamup.core.model.Employee
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api")
@Tag(name = "Employee", description = "API for managing employees")
class EmployeeController {
    @GetMapping("/employees")
    @Operation(summary = "Get all employees", description = "Retrieves a list of all employees in the database")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "List of employees retrieved successfully"),
        ],
    )
    fun getAllEmployees(): List<Employee> {
        // TODO: Implement database retrieval
        return listOf(
            Employee(id = 1, fullname = "Ola Nordmann", jobTitle = "Senior Developer", age = 30),
            Employee(id = 2, fullname = "Kari Hansen", jobTitle = "Product Manager", age = 28),
        )
    }

    @GetMapping("/employees/{id}")
    @Operation(summary = "Get employee by ID", description = "Returns an employee by their ID")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Found the employee",
                content = [Content(schema = Schema(implementation = Employee::class))],
            ),
            ApiResponse(responseCode = "404", description = "Employee not found"),
        ],
    )
    fun getEmployeeById(
        @PathVariable id: Int,
    ): ResponseEntity<Employee> {
        // TODO: Implement database lookup by ID
        return if (id == 1) {
            ResponseEntity.ok(Employee(id = 1, fullname = "Ola Nordmann", jobTitle = "Senior Developer", age = 30))
        } else {
            ResponseEntity.notFound().build()
        }
    }

    @PostMapping("/employees")
    @Operation(summary = "Create a new employee", description = "Creates a new employee in the database")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "Employee created",
                content = [Content(schema = Schema(implementation = Employee::class))],
            ),
        ],
    )
    fun createEmployee(
        @RequestBody employee: Employee,
    ): ResponseEntity<Employee> {
        // TODO: Implement database save operation
        val savedEmployee = employee.copy(id = 1)
        return ResponseEntity.status(HttpStatus.CREATED).body(savedEmployee)
    }

    @PutMapping("/employees/{id}")
    @Operation(summary = "Update employee", description = "Updates an existing employee in the database")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Employee updated",
                content = [Content(schema = Schema(implementation = Employee::class))],
            ),
            ApiResponse(responseCode = "404", description = "Employee not found", content = [Content()]),
        ],
    )
    fun updateEmployee(
        @PathVariable id: Int,
        @RequestBody employee: Employee,
    ): ResponseEntity<Employee> {
        // TODO: Implement database check and update operation
        return if (id == 1) {
            val updatedEmployee = employee.copy(id = id)
            ResponseEntity.ok(updatedEmployee)
        } else {
            ResponseEntity.notFound().build()
        }
    }

    @DeleteMapping("/employees/{id}")
    @Operation(summary = "Delete employee", description = "Deletes an employee from the database based on ID")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "204", description = "Employee deleted", content = [Content()]),
            ApiResponse(responseCode = "404", description = "Employee not found", content = [Content()]),
        ],
    )
    fun deleteEmployee(
        @PathVariable id: Int,
    ): ResponseEntity<Void> {
        // TODO: Implement database check and delete operation
        return if (id == 1) {
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }
    }
}
