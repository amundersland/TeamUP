package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "persons")
@Schema(description = "Person-entitet som representerer en bruker i systemet")
data class Person(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unik identifikator for personen", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Long? = null,
    @Column(nullable = false)
    @Schema(description = "Fullt navn på personen", example = "Ola Nordmann", required = true)
    val name: String,
    @Column(nullable = false)
    @Schema(description = "E-postadresse til personen", example = "ola.nordmann@example.com", required = true)
    val email: String,
    @Schema(description = "Alder på personen", example = "30")
    val age: Int? = null,
)
