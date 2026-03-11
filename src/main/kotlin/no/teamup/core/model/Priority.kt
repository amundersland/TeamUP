package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Prioritetsnivå for en oppgave")
enum class Priority {
    @Schema(description = "Viktig oppgave")
    IMPORTANT,
    @Schema(description = "Moderat oppgave")
    MODERATE,
    @Schema(description = "Triviell oppgave")
    TRIVIAL
}
