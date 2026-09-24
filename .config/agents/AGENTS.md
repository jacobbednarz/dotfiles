## Quick Obligations

- Starting a task: read this guide end-to-end and align with fresh user instructions.
- Reviewing git status or diffs: treat them as read-only; never revert or assume missing changes were yours.
- Shipping formatters and linters before handing off.
- Adding a dependency: research well-maintained options and confirm fit with the user before adding.
- Always use Australian english. Not US. Code comments, git commits, everything. However, do not rewrite something just in order to change to Australian english.
- Where you output shell commands, ensure you take into account the shell in use. I.e. if it's to be run by me, use `fish`. Otherwise inspect the context and use that shell.

## Mindset & Process

- Work like a craftsman. Do the better fix, not the quickest fix. We do not value lazy work or simple bandaids that only hush the symptom for one more day.
- **No breadcrumbs**. If you delete or move code, do not leave a comment in the old place. No "// moved to X", no "relocated". Just remove it.
- **Think hard, do not lose the plot**.
- Instead of applying a bandaid, fix things from first principles. Find the source, solve the real problem, and do not stack a cheap patch on top of a broken design just because it is faster today.
- When taking on new, larger pieces of work, follow this order:
  1. Think about the architecture.
  2. Research official docs, blogs, or papers on the best architecture.
  3. Review the existing codebase.
  4. Compare the research with the codebase to choose the best fit.
  5. Implement the fix or ask about the tradeoffs the user is willing to make.
When editing existing code:
  6. Don't "improve" adjacent code, comments, or formatting.
  7. Don't refactor things that aren't broken.
  8. Match existing style, even if you'd do it differently.
  9. Write idiomatic, simple, maintainable code with readable, nice APIs. Prefer clarity and a clean interface over cleverness or unnecessary complexity. Always ask yourself if this is the most simple intuitive solution to the problem. If a simpler approach exists, say so. Push back when warranted.
  10. If you write 200 lines and it could be 50, rewrite it.
- Leave each repo better than how you found it. If something is giving a code smell, fix it for the next person.
- Clean up unused code ruthlessly. If a function no longer needs a parameter or a helper is dead, delete it and update the callers instead of letting the junk linger.
- **Search before pivoting**. If you are stuck or uncertain, do a quick web search for official docs or specs, then continue with the current approach. Do not change direction unless asked.
- If code is very confusing or hard to understand:
  1. Try to simplify it.
  1. Add an ASCII art diagram in a code comment if it would help.
- Do not write comments about the how of the code or just what it intends to do. Code comments should be reserved for reasoning, the why and documenting the methods, classes, constants and other language grammars.
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- For multi-step tasks, state a brief plan:

  ```
  1. [Step] → verify: [check]
  2. [Step] → verify: [check]
  3. [Step] → verify: [check]
  ```

  Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## Testing Philosophy

- Follow the guidelines of Test Driven Development where possible. Don't just write tests to cover the code you wrote for the sake of it.
- Test everything with rigor. Our intent is ensuring a new person contributing to the same code base cannot break our stuff and that nothing slips by. We love rigour.
- Initially, only run the tests associated with your change. After they are passing, run the entire test suite for a belt and braces approach.

## Committing with Git

- Do not reset, add or commit files that you did not modify. Don't assume a dirty tree needs to be committed or reset.
- Do not ever commit to `main` or `master`. Branch off onto your own.
- Do not ever co-sign commits. Just never.
- When referencing code symbols, surround them in backticks. Example, "changed `SomeMethod` to accept two new parameters"
- Follow conventional commit formats
- Titles should be ~ 72 characters. Body should be hard wrapped at 80 characters (except for code blocks if present)
- Always write a title and a body description. You may omit the body if the title is clear.
  1. The body should always include the WHY of the change and explaining it at a high level. Include details about the problem, the reason we opted for the solution and any references to errors, metrics or logs.
- Do not commit intermediary, planning or spec documents.
- Pull requests should not use headers for arbitary separation. Just write the overview using structured sentences, examples and references in normal english.
- Refer to the humanise skill for proof reading and writing.

## Final Handoff

Before finishing a task:

- Confirm all touched tests or commands were run and passed (list them if asked).
- Summarise changes with file and line references.
- Call out any TODOs, follow-up work, or uncertainties so the user is never surprised later.

## Dependencies & external APIs

- If you need to add a new dependency to a project to solve an issue, search the web and find the best, most maintained option. Something most other folks use with the best exposed API. We don't want to be in a situation where we are using an unmaintained dependency, that no one else relies on.
