package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "employee", schema = "teamup")
@Schema(description = "Employee entity representing a team member")
data class Employee(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique identifier for the employee", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Int? = null,

    @Column(nullable = false, length = 50)
    @Schema(description = "Full name of the employee", example = "Ola Nordmann", required = true)
    val fullname: String,

    @Column(name = "job_title", length = 30)
    @Schema(description = "Job title of the employee", example = "Senior Developer")
    val jobTitle: String? = null,

    @Schema(description = "Age of the employee", example = "30")
    val age: Int? = null,
)
