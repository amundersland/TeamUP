package no.teamup.core

import no.teamup.core.controller.TaskController
import no.teamup.core.model.Priority
import no.teamup.core.model.Task
import no.teamup.core.repository.TaskRepository
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
class TaskControllerTest : FunSpec() {
    @MockkBean
    private lateinit var taskRepository: TaskRepository

    @Autowired
    private lateinit var taskController: TaskController

    override fun extensions() = listOf(SpringExtension) // enabler DI og Autowire i enhetstesten

    // Felles oppsett av mocks som brukes av begge kontekster
    private fun setupTaskRepositoryMocks(tasks: List<Task>) {
        every { taskRepository.findAll() } returns tasks

        every { taskRepository.findById(any()) } answers {
            val id = firstArg<Long>()
            tasks.find { it.id == id }?.let { Optional.of(it) } ?: Optional.empty()
        }

        every { taskRepository.existsById(any()) } answers {
            val id = firstArg<Long>()
            tasks.any { it.id == id }
        }

        every { taskRepository.deleteById(any()) } returns Unit

        // Generisk save-logikk: generer ny ID basert på siste ID i listen + 1
        every { taskRepository.save(any()) } answers {
            val task = firstArg<Task>()
            val nesteId = (tasks.maxOfOrNull { it.id ?: 0L } ?: 0L) + 1
            task.copy(id = nesteId)
        }
    }

    init {

        context("GITT databasen har tre oppgaver") {

            // Arrange
            val tasks =
                listOf(
                    Task(
                        id = 1L,
                        title = "Implementer login",
                        description = "Lag innloggingsside",
                        assignedToPerson = 1L,
                        priority = Priority.IMPORTANT,
                    ),
                    Task(
                        id = 2L,
                        title = "Skriv dokumentasjon",
                        description = "Oppdater README",
                        assignedToPerson = 2L,
                        priority = Priority.MODERATE,
                    ),
                    Task(
                        id = 3L,
                        title = "Rydd kode",
                        description = "Fjern ubrukt kode",
                        assignedToPerson = 1L,
                        priority = Priority.TRIVIAL,
                    ),
                )

            beforeTest {
                setupTaskRepositoryMocks(tasks)
            }

            test("NÅR man henter alle oppgaver SKAL man få en liste med oppgaver") {
                // Act
                val result = taskController.getAllTasks()

                // Assert
                result shouldBe tasks
                result.size shouldBe 3
                verify(exactly = 1) { taskRepository.findAll() }
            }

            test("NÅR man henter en oppgave som finnes SKAL man få oppgaven tilbake") {
                // Arrange
                val expectedTask = tasks[0]

                // Act
                val result = taskController.getTaskById(expectedTask.id as Long)

                // Assert
                result.statusCode shouldBe HttpStatus.OK
                result.body shouldBe expectedTask
                result.body?.title shouldBe "Implementer login"
                verify(exactly = 1) { taskRepository.findById(1L) }
            }

            test("NÅR man henter en oppgave som ikke finnes SKAL man få 404") {
                // Act
                val result = taskController.getTaskById(999L)

                // Assert
                result.statusCode shouldBe HttpStatus.NOT_FOUND
                result.body shouldBe null
                verify(exactly = 1) { taskRepository.findById(999L) }
            }

            test("NÅR man oppretter en ny oppgave SKAL man få 201 status og oppgaven tilbake") {
                // Arrange
                val nyOppgave =
                    Task(
                        title = "Fix bug",
                        description = "Fiks kritisk bug",
                        assignedToPerson = 3L,
                        priority = Priority.IMPORTANT,
                    )

                // Act
                val result = taskController.createTask(nyOppgave)

                // Assert
                result.statusCode shouldBe HttpStatus.CREATED
                result.body shouldNotBe null
                result.body?.id shouldBe 4L
                result.body?.title shouldBe "Fix bug"
                result.body?.description shouldBe "Fiks kritisk bug"
                result.body?.priority shouldBe Priority.IMPORTANT
                verify(exactly = 1) { taskRepository.save(nyOppgave) }
            }

            test("NÅR man sletter en oppgave som finnes SKAL man få 204 status") {
                // Arrange
                val taskId = tasks.first().id as Long

                // Act
                val result = taskController.deleteTask(taskId)

                // Assert
                result.statusCode shouldBe HttpStatus.NO_CONTENT
                result.body shouldBe null
                verify(exactly = 1) { taskRepository.existsById(taskId) }
                verify(exactly = 1) { taskRepository.deleteById(taskId) }
            }

            test("NÅR man sletter en oppgave som ikke finnes SKAL man få 404") {
                // Act
                val result = taskController.deleteTask(999L)

                // Assert
                result.statusCode shouldBe HttpStatus.NOT_FOUND
                result.body shouldBe null
                verify(exactly = 1) { taskRepository.existsById(999L) }
                verify(exactly = 0) { taskRepository.deleteById(999L) }
            }

            test("NÅR man henter oppgaver for person 1 SKAL man få to oppgaver") {
                // Act
                val result = taskController.getTasksByPersonId(1L)

                // Assert
                result.size shouldBe 2
                result.all { it.assignedToPerson == 1L } shouldBe true
                result.map { it.title } shouldBe listOf("Implementer login", "Rydd kode")
                verify(exactly = 1) { taskRepository.findAll() }
            }

            test("NÅR man henter oppgaver for person 2 SKAL man få én oppgave") {
                // Act
                val result = taskController.getTasksByPersonId(2L)

                // Assert
                result.size shouldBe 1
                result.first().title shouldBe "Skriv dokumentasjon"
                result.first().assignedToPerson shouldBe 2L
                verify(exactly = 1) { taskRepository.findAll() }
            }

            test("NÅR man henter oppgaver for person som ikke har oppgaver SKAL man få tom liste") {
                // Act
                val result = taskController.getTasksByPersonId(999L)

                // Assert
                result.size shouldBe 0
                verify(exactly = 1) { taskRepository.findAll() }
            }
        }

        context("GITT databasen har oppgaver med ulike prioriteter") {

            // Arrange
            val tasks =
                listOf(
                    Task(
                        id = 1L,
                        title = "Viktig oppgave 1",
                        description = "Må gjøres nå",
                        assignedToPerson = 1L,
                        priority = Priority.IMPORTANT,
                    ),
                    Task(
                        id = 2L,
                        title = "Viktig oppgave 2",
                        description = "Må også gjøres nå",
                        assignedToPerson = 1L,
                        priority = Priority.IMPORTANT,
                    ),
                    Task(
                        id = 3L,
                        title = "Moderat oppgave",
                        description = "Kan gjøres senere",
                        assignedToPerson = 2L,
                        priority = Priority.MODERATE,
                    ),
                    Task(
                        id = 4L,
                        title = "Triviell oppgave",
                        description = "Ikke så viktig",
                        assignedToPerson = null,
                        priority = Priority.TRIVIAL,
                    ),
                )

            beforeTest {
                setupTaskRepositoryMocks(tasks)
            }

            test("NÅR man henter alle oppgaver SKAL man få oppgaver med ulike prioriteter") {
                // Act
                val result = taskController.getAllTasks()

                // Assert
                result.size shouldBe 4
                result.count { it.priority == Priority.IMPORTANT } shouldBe 2
                result.count { it.priority == Priority.MODERATE } shouldBe 1
                result.count { it.priority == Priority.TRIVIAL } shouldBe 1
                verify(exactly = 1) { taskRepository.findAll() }
            }

            test("NÅR man henter oppgaver for person 1 SKAL man få bare viktige oppgaver") {
                // Act
                val result = taskController.getTasksByPersonId(1L)

                // Assert
                result.size shouldBe 2
                result.all { it.priority == Priority.IMPORTANT } shouldBe true
                verify(exactly = 1) { taskRepository.findAll() }
            }

            test("NÅR man oppretter oppgave uten tildelt person SKAL det være mulig") {
                // Arrange
                val nyOppgave =
                    Task(
                        title = "Utildelt oppgave",
                        description = "Ingen har tatt denne enda",
                        assignedToPerson = null,
                        priority = Priority.MODERATE,
                    )

                // Act
                val result = taskController.createTask(nyOppgave)

                // Assert
                result.statusCode shouldBe HttpStatus.CREATED
                result.body?.assignedToPerson shouldBe null
                verify(exactly = 1) { taskRepository.save(nyOppgave) }
            }
        }
    }
}
