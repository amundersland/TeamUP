package no.teamup.core.repository

import no.teamup.core.model.LearningMaterial
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LearningMaterialRepository : JpaRepository<LearningMaterial, Int>
