package no.teamup.core.model

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.EnumType
import jakarta.persistence.Enumerated
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Table

@Entity
@Table(name = "tasks")
@Schema(description = "Task-entitet som representerer en oppgave i systemet")
data class Task(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unik identifikator for oppgaven", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    val id: Long? = null,
    @Column(nullable = false)
    @Schema(description = "Tittel på oppgaven", example = "Implementer ny funksjonalitet", required = true)
    val title: String,
    @Column(nullable = false)
    @Schema(description = "Beskrivelse av oppgaven", example = "Detaljert beskrivelse av hva som skal gjøres", required = true)
    val description: String,
    @Column(name = "assigned_to_person")
    @Schema(description = "ID til personen oppgaven er tildelt", example = "1")
    val assignedToPerson: Long? = null,
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Schema(description = "Prioritetsnivå for oppgaven", example = "IMPORTANT", required = true)
    val priority: Priority,
)
