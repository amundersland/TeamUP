package no.teamup.core.controller

import no.teamup.core.model.Person
import no.teamup.core.repository.PersonRepository
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
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api")
@Tag(name = "Person", description = "API for å administrere personer")
class PersonController(
    private val personRepository: PersonRepository,
) {
    companion object {
        const val MIN_AGE_YOUNG_ADULT = 18
    }

    @GetMapping("/persons")
    @Operation(summary = "Hent alle personer", description = "Henter en liste med alle personer i databasen")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Listen med personer ble hentet"),
        ],
    )
    fun getAllPersons(): List<Person> = personRepository.findAll()

    @GetMapping("/persons/{id}")
    @Operation(summary = "Hent person med ID", description = "Henter en spesifikk person basert på ID")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Person funnet",
                content = [Content(schema = Schema(implementation = Person::class))],
            ),
            ApiResponse(responseCode = "404", description = "Person ikke funnet", content = [Content()]),
        ],
    )
    fun getPersonById(
        @PathVariable id: Long,
    ): ResponseEntity<Person> {
        val person = personRepository.findById(id)
        return if (person.isPresent) {
            ResponseEntity.ok(person.get())
        } else {
            ResponseEntity.notFound().build()
        }
    }

    @PostMapping("/persons")
    @Operation(summary = "Opprett en ny person", description = "Oppretter en ny person i databasen")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "Person opprettet",
                content = [Content(schema = Schema(implementation = Person::class))],
            ),
        ],
    )
    fun createPerson(
        @RequestBody person: Person,
    ): ResponseEntity<Person> {
        val savedPerson = personRepository.save(person)
        return ResponseEntity.status(HttpStatus.CREATED).body(savedPerson)
    }

    @DeleteMapping("/persons/{id}")
    @Operation(summary = "Slett person", description = "Sletter en person fra databasen basert på ID")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "204", description = "Person slettet", content = [Content()]),
            ApiResponse(responseCode = "404", description = "Person ikke funnet", content = [Content()]),
        ],
    )
    fun deletePerson(
        @PathVariable id: Long,
    ): ResponseEntity<Void> =
        if (personRepository.existsById(id)) {
            personRepository.deleteById(id)
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }

    @GetMapping("/persons/unge-voksne")
    @Operation(summary = "Hent unge voksne", description = "Henter personer over 18 år og under en gitt aldersgrense (standard 40 år)")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "Listen med unge voksne ble hentet"),
        ],
    )
    fun getYoungAdults(
        @RequestParam(defaultValue = "40") maxAge: Int,
    ): List<Person> =
        personRepository
            .findAll()
            .filter { person ->
                person.age != null && person.age > MIN_AGE_YOUNG_ADULT && person.age < maxAge
            }
}
