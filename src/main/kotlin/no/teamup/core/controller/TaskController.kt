package no.teamup.core.controller

import no.teamup.core.model.Task
import no.teamup.core.repository.TaskRepository
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api")
@Tag(name = "Task", description = "API for å administrere oppgaver")
class TaskController(
    private val taskRepository: TaskRepository,
) {
    @GetMapping("/tasks")
    @Operation(summary = "Hent alle oppgaver", description = "Henter en liste med alle oppgaver i databasen")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Listen med oppgaver ble hentet"),
        ],
    )
    fun getAllTasks(): List<Task> = taskRepository.findAll()

    @GetMapping("/tasks/{id}")
    @Operation(summary = "Hent oppgave med ID", description = "Henter en spesifikk oppgave basert på ID")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Oppgave funnet",
                content = [Content(schema = Schema(implementation = Task::class))],
            ),
            ApiResponse(responseCode = "404", description = "Oppgave ikke funnet", content = [Content()]),
        ],
    )
    fun getTaskById(
        @PathVariable id: Long,
    ): ResponseEntity<Task> {
        val task = taskRepository.findById(id)
        return if (task.isPresent) {
            ResponseEntity.ok(task.get())
        } else {
            ResponseEntity.notFound().build()
        }
    }

    @PostMapping("/tasks")
    @Operation(summary = "Opprett en ny oppgave", description = "Oppretter en ny oppgave i databasen")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "Oppgave opprettet",
                content = [Content(schema = Schema(implementation = Task::class))],
            ),
        ],
    )
    fun createTask(
        @RequestBody task: Task,
    ): ResponseEntity<Task> {
        val savedTask = taskRepository.save(task)
        return ResponseEntity.status(HttpStatus.CREATED).body(savedTask)
    }

    @DeleteMapping("/tasks/{id}")
    @Operation(summary = "Slett oppgave", description = "Sletter en oppgave fra databasen basert på ID")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "204", description = "Oppgave slettet", content = [Content()]),
            ApiResponse(responseCode = "404", description = "Oppgave ikke funnet", content = [Content()]),
        ],
    )
    fun deleteTask(
        @PathVariable id: Long,
    ): ResponseEntity<Void> =
        if (taskRepository.existsById(id)) {
            taskRepository.deleteById(id)
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }

    @GetMapping("/persons/{personId}/tasks")
    @Operation(summary = "Hent alle oppgaver for en person", description = "Henter alle oppgaver tildelt en spesifikk person")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Listen med oppgaver ble hentet"),
        ],
    )
    fun getTasksByPersonId(
        @PathVariable personId: Long,
    ): List<Task> =
        taskRepository
            .findAll()
            .filter { task -> task.assignedToPerson == personId }
}
