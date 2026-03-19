package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Learning material type entity")
data class LearningMaterialType(
    @Schema(description = "Unique identifier for the learning material type", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Int? = null,
    @Schema(description = "Name of the learning material type", example = "Book", required = true)
    val name: String,
)
