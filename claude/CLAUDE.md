# Code

In every web project, follow the `codebase-standard` skill (`~/.claude/skills/codebase-standard/SKILL.md`): read it before writing, moving or reviewing code.

# Git

- Commit when asked. Push only when the user explicitly says "push" for that work; never push on your own initiative, and never force-push. Otherwise, when a branch needs to catch up, give them the command to run.
- Commit messages are one line, two at most. Never add `Co-Authored-By` or any Claude/AI attribution line, to commits or PR descriptions.
- Before committing, run `git status` on its own and read it. The tree can change between turns. Stage only the task's files, by path; never `git add -A` or `git add .`. Anything the session did not touch stays out and is reported to the user.
