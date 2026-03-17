package no.teamup.core.repository

import no.teamup.core.model.LearningMaterialType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface LearningMaterialTypeRepository : JpaRepository<LearningMaterialType, Int>
