.PHONY: compile install run spotless

compile:
	./mvnw clean compile

install:
	./mvnw clean install

run:
	./mvnw spring-boot:run

spotless:
	./mvnw spotless:apply
