# AI Assistant Instructions

## General Rules

- always update tests
- use make commands when available
- always use relevant mcp language servers
- always use https://github.com/BurntSushi/ripgrep instead of grep in this system
- prefer TypeScript over JavaScript when working with JS/TS projects
- follow existing code style and patterns in the codebase
- write minimal, focused commits with clear messages

## Code Quality

- Always run linters and formatters before committing
- Add tests for new functionality
- Update documentation when making changes
- Prefer composition over inheritance
- Keep functions small and single-purpose

## Tools & Workflow

- Use `make` commands when available in the project
- For Go projects: respect `GOPRIVATE=source.golabs.io`
- For search operations: always use `rg` (ripgrep) instead of `grep`
- For file viewing: prefer `bat` over `cat`

## Language-Specific Guidance

### Go
- Use `gopls` MCP server for LSP functionality
- Follow Go conventions (gofmt, golint)
- Handle errors explicitly

### TypeScript/JavaScript
- Use TypeScript for new code
- Prefer ESM over CommonJS
- Use strict mode

### Rust
- Use `rust-analyzer` MCP server
- Follow Rust conventions (clippy, rustfmt)

### Java
- Use `jdtls` MCP server
- Follow Java conventions

### Svelte
- Use `svelte-docs` MCP server for documentation
- Follow Svelte best practices

### Frontend
- Use `frontend-design` principles
- Prioritize accessibility
- Use semantic HTML

## Project Context

- Check AGENTS.md at project root for project-specific instructions
- Respect existing project conventions
- Look at recent commits for context
