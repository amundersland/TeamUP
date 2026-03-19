.PHONY: compile install run spotless smoke-test

compile:
	./mvnw clean compile

install:
	./mvnw clean install

run:
	./mvnw spring-boot:run

spotless:
	@./mvnw spotless:check || { \
		printf "Spotless check failed. Run spotless:apply to fix formatting? [y/N] "; \
		read answer; \
		[ "$$answer" = "y" ] || [ "$$answer" = "Y" ] && ./mvnw spotless:apply || true; \
	}

smoke-test:
	@./mvnw spring-boot:run & SERVER_PID=$$!; \
	MAX_WAIT=60; WAITED=0; \
	echo "Waiting for application to start (timeout: $$MAX_WAIT seconds)..."; \
	until curl -sf http://localhost:8080/api/employees > /dev/null; do \
		sleep 1; \
		WAITED=$$((WAITED + 1)); \
		if [ $$WAITED -ge $$MAX_WAIT ]; then \
			echo "Application failed to start within $$MAX_WAIT seconds"; \
			kill $$SERVER_PID 2>/dev/null || true; \
			wait $$SERVER_PID 2>/dev/null || true; \
			exit 1; \
		fi; \
	done; \
	curl -s http://localhost:8080/api/employees | cat; \
	kill $$SERVER_PID && wait $$SERVER_PID 2>/dev/null; \
	echo "\033[0;32mSMOKE TEST PASSED\033[0m"
