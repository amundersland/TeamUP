.PHONY: compile install run spotless smoke-test

compile:
	./mvnw clean compile

install:
	./mvnw clean install

run:
	./mvnw spring-boot:run

spotless:
	./mvnw spotless:apply

smoke-test:
	@./mvnw spring-boot:run & SERVER_PID=$$!; \
	echo "Waiting for application to start..."; \
	until curl -sf http://localhost:8080/api/employees > /dev/null; do sleep 1; done; \
	curl -s http://localhost:8080/api/employees | cat; \
	kill $$SERVER_PID && wait $$SERVER_PID 2>/dev/null; \
	echo "\033[0;32mSMOKE TEST PASSED\033[0m"
