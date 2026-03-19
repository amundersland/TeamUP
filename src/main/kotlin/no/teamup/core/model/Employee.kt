package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema

@Schema(description = "Employee entity representing a team member")
data class Employee(
    @Schema(description = "Unique identifier for the employee", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Int? = null,
    @Schema(description = "Full name of the employee", example = "Ola Nordmann", required = true)
    val fullname: String,
    @Schema(description = "Job title of the employee", example = "Senior Developer")
    val jobTitle: String? = null,
    @Schema(description = "Age of the employee", example = "30")
    val age: Int? = null,
)
