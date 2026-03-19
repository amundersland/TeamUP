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
    @Schema(description = "Array of tag IDs associated with this learning material", example = "[1,2,3]")
    val tagIds: IntArray = intArrayOf(),
    @Schema(description = "Array of wiki note IDs associated with this learning material", example = "[1,2]")
    val wikiNoteIds: IntArray = intArrayOf(),
    @Schema(description = "Array of notes (stored as a JSONB array in the database)", example = "[\"Note 1\", \"Note 2\"]")
    val notes: List<String> = emptyList(),
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as LearningMaterial

        if (id != other.id) return false
        if (name != other.name) return false
        if (description != other.description) return false
        if (link != other.link) return false
        if (price != other.price) return false
        if (type != other.type) return false
        if (!tagIds.contentEquals(other.tagIds)) return false
        if (!wikiNoteIds.contentEquals(other.wikiNoteIds)) return false
        if (notes != other.notes) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id?.hashCode() ?: 0
        result = 31 * result + name.hashCode()
        result = 31 * result + (description?.hashCode() ?: 0)
        result = 31 * result + (link?.hashCode() ?: 0)
        result = 31 * result + (price ?: 0)
        result = 31 * result + type.hashCode()
        result = 31 * result + tagIds.contentHashCode()
        result = 31 * result + wikiNoteIds.contentHashCode()
        result = 31 * result + notes.hashCode()
        return result
    }
}
