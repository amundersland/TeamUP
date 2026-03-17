package no.teamup.core.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import no.teamup.core.model.LearningMaterial
import no.teamup.core.repository.LearningMaterialRepository
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
@Tag(name = "Learning Material", description = "API for managing learning materials")
class LearningMaterialController(
    private val learningMaterialRepository: LearningMaterialRepository,
) {
    @GetMapping("/learning-materials")
    @Operation(summary = "Get all learning materials", description = "Retrieves a list of all learning materials in the database")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "200", description = "List of learning materials retrieved successfully"),
        ],
    )
    fun getAllLearningMaterials(): List<LearningMaterial> = learningMaterialRepository.findAll()

    @GetMapping("/learning-materials/{id}")
    @Operation(summary = "Get learning material by ID", description = "Retrieves a specific learning material based on ID")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Learning material found",
                content = [Content(schema = Schema(implementation = LearningMaterial::class))],
            ),
            ApiResponse(responseCode = "404", description = "Learning material not found", content = [Content()]),
        ],
    )
    fun getLearningMaterialById(
        @PathVariable id: Int,
    ): ResponseEntity<LearningMaterial> {
        val learningMaterial = learningMaterialRepository.findById(id)
        return if (learningMaterial.isPresent) {
            ResponseEntity.ok(learningMaterial.get())
        } else {
            ResponseEntity.notFound().build()
        }
    }

    @PostMapping("/learning-materials")
    @Operation(summary = "Create a new learning material", description = "Creates a new learning material in the database")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "Learning material created",
                content = [Content(schema = Schema(implementation = LearningMaterial::class))],
            ),
        ],
    )
    fun createLearningMaterial(
        @RequestBody learningMaterial: LearningMaterial,
    ): ResponseEntity<LearningMaterial> {
        val savedLearningMaterial = learningMaterialRepository.save(learningMaterial)
        return ResponseEntity.status(HttpStatus.CREATED).body(savedLearningMaterial)
    }

    @PutMapping("/learning-materials/{id}")
    @Operation(summary = "Update learning material", description = "Updates an existing learning material in the database")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Learning material updated",
                content = [Content(schema = Schema(implementation = LearningMaterial::class))],
            ),
            ApiResponse(responseCode = "404", description = "Learning material not found", content = [Content()]),
        ],
    )
    fun updateLearningMaterial(
        @PathVariable id: Int,
        @RequestBody learningMaterial: LearningMaterial,
    ): ResponseEntity<LearningMaterial> =
        if (learningMaterialRepository.existsById(id)) {
            val updatedLearningMaterial = learningMaterial.copy(id = id)
            ResponseEntity.ok(learningMaterialRepository.save(updatedLearningMaterial))
        } else {
            ResponseEntity.notFound().build()
        }

    @DeleteMapping("/learning-materials/{id}")
    @Operation(summary = "Delete learning material", description = "Deletes a learning material from the database based on ID")
    @ApiResponses(
        value = [
            ApiResponse(responseCode = "204", description = "Learning material deleted", content = [Content()]),
            ApiResponse(responseCode = "404", description = "Learning material not found", content = [Content()]),
        ],
    )
    fun deleteLearningMaterial(
        @PathVariable id: Int,
    ): ResponseEntity<Void> =
        if (learningMaterialRepository.existsById(id)) {
            learningMaterialRepository.deleteById(id)
            ResponseEntity.noContent().build()
        } else {
            ResponseEntity.notFound().build()
        }
}
