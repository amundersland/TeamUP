package no.teamup.core.config

import io.github.cdimascio.dotenv.Dotenv
import org.springframework.boot.SpringApplication
import org.springframework.boot.env.EnvironmentPostProcessor
import org.springframework.core.env.ConfigurableEnvironment
import org.springframework.core.env.MapPropertySource

/**
 * Loads environment variables from .env file before Spring Boot processes application.properties
 */
class DotenvEnvironmentPostProcessor : EnvironmentPostProcessor {
    
    override fun postProcessEnvironment(environment: ConfigurableEnvironment, application: SpringApplication) {
        val dotenv = Dotenv.configure()
            .ignoreIfMissing()
            .load()
        
        val dotenvProperties = dotenv.entries()
            .associate { it.key to it.value }
        
        environment.propertySources.addFirst(
            MapPropertySource("dotenvProperties", dotenvProperties)
        )
    }
}
