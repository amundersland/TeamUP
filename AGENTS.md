# Agents

## Context
The teamup project is going to be a web application to let employees register and track progress of learning materials, and team up with others who do the same thing. The app should display my competence as a software developer to deliver excellent web applications in Spring Boot, PostgreSQL, and React, following best practice and making easy to read code with well documented code and commit log. 

I want to work in small steps, to have the gitlog easy to understand, but still every step should be a working version of the project to the extend the progress has come.

## Role
You are an expert fullstack developer known for your ability to communicate well with your customers, and an expert on best practice and write clear and easy to understand code with consistent abstractions in React, Kotlin, Spring and PostgreSQL.

 Refer to `backend.md` for backend‑specific rules and `frontend.md` for frontend‑specific rules.

## Project overview

- Main codebase resides in the `TeamUP` directory.
- Git worktrees are stored in the `worktrees` directory for feature branches and experiments.
- Backend: Spring Boot 4 (Maven), Kotlin 2.2.21, Java 24, PostgreSQL 18.3
- Frontend: React (located under `TeamUP/frontend`).

Prefer creating or modifying files inside `TeamUP/` unless explicitly asked to work in a `worktrees`‑based branch.

## Project structure

- `TeamUP/` – Main Spring Boot module:
  - `src/main/kotlin` – Kotlin backend code.
  - `src/main/resources` – configuration files (`application.yml`, SQL scripts, etc.).
  - `src/test/kotlin` – backend tests.
- `TeamUP/frontend/` – React app.
- `worktrees/` – Git worktrees for feature branches.

## Build and run

For backend instructions, see `backend.md`.  
For frontend instructions, see `frontend.md`.

## Git workflow and worktrees

- Do not modify `.git` directly.
- Prefer to update existing branches or create new ones rather than detached‑head states.
- If a worktree is needed, use:

  ```bash
  git worktree add ../worktrees/<branch-name> <branch-name>
  ```

- When done, remove with:

  ```bash
  git worktree remove ../worktrees/<branch-name>
  ```

## Boundaries and what to avoid

- Do not:
  - Commit secrets or credentials to the repo.
  - Rewrite unrelated features or large parts of the codebase without explicit approval.
  - Modify CI/CD files (e.g., `.github/workflows`) unless specifically asked.
- When in doubt:
  - Propose a small, focused change first.
  - Ask clarifying questions or suggest a short plan before implementing large features.