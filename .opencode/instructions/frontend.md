# Frontend instructions

You are assisting with the React frontend located at `TeamUP/frontend` in the TeamUP project.

## Frontend setup and commands

- The React app is in `TeamUP/frontend/`.
- Prefer modern React with functional components and hooks.

Run the following commands from the frontend directory:

- Install dependencies:

  ```bash
  cd TeamUP/frontend
  npm install
  ```

- Start the dev server:

  ```bash
  npm start
  ```

- Build for production (if configured):

  ```bash
  npm run build
  ```

Prefer `npm` unless the project explicitly uses `yarn` or `pnpm`.

## Code style and conventions

- Use `PascalCase` for React component files (e.g., `UserList.tsx`).
- Place components in `src/components/`‑like folders.
- Prefer:
  - Functional components.
  - TypeScript (if present) or clean PropTypes/JS if not.
  - Hooks (`useState`, `useEffect`, custom hooks) over class components.
- If ESLint / Prettier is present, match the existing rules.

## Integration with backend

- Assume the backend exposes a REST or OpenAPI endpoint at:
  - `http://localhost:8080` (default Spring Boot host:port).
- If OpenAPI is present, use `springdoc-openapi-starter-webmvc-ui` to generate and inspect the API spec under `/swagger-ui.html` or `/v3/api-docs`.

## Boundaries and what to avoid

- Do not:
  - Commit secrets or environment variables to the repo.
  - Change build tooling (e.g., from `npm` to `yarn`) without explicit approval.
  - Rewrite the entire frontend structure unless explicitly requested.
- When in doubt:
  - Propose a small, focused change first.
  - Ask clarifying questions or suggest a short plan before implementing large frontend features.