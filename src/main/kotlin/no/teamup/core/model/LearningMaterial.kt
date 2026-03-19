package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Learning material entity representing educational resources")
data class LearningMaterial(
    @Schema(description = "Unique identifier for the learning material", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Int? = null,
    @Schema(description = "Name of the learning material", example = "Kotlin in Action", required = true)
    val name: String,
    @Schema(description = "Description of the learning material", example = "Comprehensive guide to Kotlin programming")
    val description: String? = null,
    @Schema(description = "Link to the learning material", example = "https://example.com/kotlin-book")
    val link: String? = null,
    @Schema(description = "Price of the learning material in smallest currency unit", example = "4995")
    val price: Int? = null,
    @Schema(description = "Type of the learning material", required = true)
    val type: LearningMaterialType,
)
