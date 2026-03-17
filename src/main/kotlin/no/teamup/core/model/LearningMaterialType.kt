package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "learning_material_type", schema = "teamup")
@Schema(description = "Learning material type entity")
data class LearningMaterialType(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for the learning material type", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Int? = null,

    @Column(nullable = false, length = 20, unique = true)
    @Schema(description = "Name of the learning material type", example = "Book", required = true)
    val name: String,
)
