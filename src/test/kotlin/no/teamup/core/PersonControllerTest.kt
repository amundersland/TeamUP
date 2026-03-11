package no.teamup.core

import no.teamup.core.controller.PersonController
import no.teamup.core.model.Person
import no.teamup.core.repository.PersonRepository
import com.ninjasquad.springmockk.MockkBean
import io.kotest.core.spec.style.FunSpec
import io.kotest.extensions.spring.SpringExtension
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe
import io.mockk.every
import io.mockk.verify
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.HttpStatus
import java.util.Optional

@SpringBootTest
class PersonControllerTest : FunSpec() {
    @MockkBean
    private lateinit var personRepository: PersonRepository

    @Autowired
    private lateinit var personController: PersonController

    override fun extensions() = listOf(SpringExtension) // enabler DI og Autowire i enhetstesten

    // Felles oppsett av mocks som brukes av begge kontekster
    private fun setupPersonRepositoryMocks(persons: List<Person>) {
        every { personRepository.findAll() } returns persons

        every { personRepository.findById(any()) } answers {
            val id = firstArg<Long>()
            persons.find { it.id == id }?.let { Optional.of(it) } ?: Optional.empty()
        }

        every { personRepository.existsById(any()) } answers
            { call ->
                val id = firstArg<Long>()
                persons.any { it.id == id }
            }

        every { personRepository.deleteById(any()) } returns Unit

        // Generisk save-logikk: generer ny ID basert på siste ID i listen + 1
        every { personRepository.save(any()) } answers
            { call ->
                val person = firstArg<Person>()
                val nesteId = (persons.maxOfOrNull { it.id ?: 0L } ?: 0L) + 1
                person.copy(id = nesteId)
            }
    }

    init {

        context("GITT databasen har to personer") {

            // Arrange
            val persons =
                listOf(
                    Person(id = 1L, name = "Anne", email = "anne@example.com", age = 30),
                    Person(id = 2L, name = "Bent", email = "bent@example.com", age = 25),
                )

            beforeTest {
                setupPersonRepositoryMocks(persons)
            }

            test("NÅR man henter alle personer SKAL man få en liste med personer") {
                // Act
                val result = personController.getAllPersons()

                // Assert
                result shouldBe persons
                result.size shouldBe 2
                verify(exactly = 1) { personRepository.findAll() }
            }

            test("NÅR man henter en person som finnes SKAL man få personen tilbake") {
                // Arrange
                val expectedPerson = persons[0]

                // Act
                val result = personController.getPersonById(expectedPerson.id as Long)

                // Assert
                result.statusCode shouldBe HttpStatus.OK
                result.body shouldBe expectedPerson
                result.body?.name shouldBe "Anne"
                verify(exactly = 1) { personRepository.findById(1L) }
            }

            test("NÅR man henter en person som ikke finnes SKAL man få 404") {
                // Act
                val result = personController.getPersonById(999L)

                // Assert
                result.statusCode shouldBe HttpStatus.NOT_FOUND
                result.body shouldBe null
                verify(exactly = 1) { personRepository.findById(999L) }
            }

            test("NÅR man oppretter en ny person SKAL man få 201 status og personen tilbake") {
                // Arrange
                val nyPerson = Person(name = "Cara", email = "cara@example.com", age = 28)

                // Act
                val result = personController.createPerson(nyPerson)

                // Assert
                result.statusCode shouldBe HttpStatus.CREATED
                result.body shouldNotBe null
                result.body?.id shouldBe 3L
                result.body?.name shouldBe "Cara"
                result.body?.email shouldBe "cara@example.com"
                verify(exactly = 1) { personRepository.save(nyPerson) }
            }

            test("NÅR man sletter en person som finnes SKAL man få 204 status") {
                // Arrange
                val personId = persons.first().id as Long

                // Act
                val result = personController.deletePerson(personId)

                // Assert
                result.statusCode shouldBe HttpStatus.NO_CONTENT
                result.body shouldBe null
                verify(exactly = 1) { personRepository.existsById(personId) }
                verify(exactly = 1) { personRepository.deleteById(personId) }
            }

            test("NÅR man sletter en person som ikke finnes SKAL man få 404") {
                // Act
                val result = personController.deletePerson(999L)

                // Assert
                result.statusCode shouldBe HttpStatus.NOT_FOUND
                result.body shouldBe null
                verify(exactly = 1) { personRepository.existsById(999L) }
                verify(exactly = 0) { personRepository.deleteById(999L) }
            }

            test("NÅR man henter unge voksne med standard aldersgrense SKAL man få personer mellom 18 og 40") {
                // Act
                val result = personController.getYoungAdults(40)

                // Assert
                result.size shouldBe 2
                result.all { it.age != null && it.age > 18 && it.age < 40 } shouldBe true
                verify(exactly = 1) { personRepository.findAll() }
            }

            test("NÅR man henter unge voksne med tilpasset aldersgrense SKAL man få personer mellom 18 og grensen") {
                // Act
                val result = personController.getYoungAdults(30)

                // Assert
                result.size shouldBe 1
                result.first().age shouldBe 25
                result.all { it.age != null && it.age > 18 && it.age < 30 } shouldBe true
                verify(exactly = 1) { personRepository.findAll() }
            }
        }

        context("GITT databasen har personer med alder fra 10 til 90") {

            // Arrange
            val persons =
                (1..9).map { i ->
                    Person(
                        id = i.toLong(),
                        name = "Person$i",
                        email = "person$i@example.com",
                        age = i * 10,
                    )
                }

            beforeTest {
                setupPersonRepositoryMocks(persons)
            }

            test("NÅR man henter unge voksne med standard aldersgrense (40) SKAL man få personer med alder 20 og 30") {
                // Act
                val result = personController.getYoungAdults(40)

                // Assert
                result.size shouldBe 2
                result.map { it.age } shouldBe listOf(20, 30)
                result.all { it.age != null && it.age > 18 && it.age < 40 } shouldBe true
                verify(exactly = 1) { personRepository.findAll() }
            }

            test("NÅR man henter unge voksne med aldersgrense 70 SKAL man få personer med alder 20, 30, 40, 50 og 60") {
                // Act
                val result = personController.getYoungAdults(70)

                // Assert
                result.size shouldBe 5
                result.map { it.age } shouldBe listOf(20, 30, 40, 50, 60)
                result.all { it.age != null && it.age > 18 && it.age < 70 } shouldBe true
                verify(exactly = 1) { personRepository.findAll() }
            }

            test("NÅR man henter unge voksne med aldersgrense 20 SKAL man få en tom liste") {
                // Act
                val result = personController.getYoungAdults(20)

                // Assert
                result.size shouldBe 0
                verify(exactly = 1) { personRepository.findAll() }
            }
        }
    }
}

/** Liten integrasjonstest for å sjekke at spring context lastes inn */
@SpringBootTest
class ApplicationContextTest : FunSpec() {
    override fun extensions() = listOf(SpringExtension)

    init {
        test("Spring context loads successfully") { true shouldBe true }
    }
}
