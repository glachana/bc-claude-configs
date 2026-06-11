---
description: AL object architecture and testability rules
globs: ["**/*.al"]
---

# AL Architecture Rules

## Layer Responsibilities

**Pages and PageExtensions** — UI and UI control only.
- Acceptable: calling out to a codeunit, setting filters, navigating, visibility expressions, style expressions, and other logic that directly controls what the user sees or how the UI behaves.
- Not acceptable: business logic, calculations, domain rules, or direct table writes.

**Tables** — data structure and record-level entry points.
- Field definitions, keys, FlowFields, field-level validation (format, range checks).
- Table triggers may call a procedure defined on the same table to act on the current record — this is a valid pattern for keeping record-centric operations close to the data. The procedure itself should be thin and delegate to a codeunit for any real logic.
- No cross-table orchestration from table triggers.

**Codeunits** — own all business logic and orchestration.
- One codeunit = one domain responsibility.
- Codeunits may call other codeunits.
- Codeunits generally do not open pages. The exception is codeunits whose explicit responsibility is UI routing — opening, redirecting, or conditionally navigating to pages. This is a narrow exception, not a general pattern.

**Reports and XMLports** — data projection only.
- Format and extract data. No business rule enforcement.

## Testability and Dependency Injection

Code must be written so it can be tested without a full BC environment where possible.

**Injectable dependencies**: anything external to the procedure's own logic must be injectable:
- Setup and configuration (company info, setup tables)
- External services or integrations
- Date/time sources if behavior depends on them

**Pattern**: procedures receive dependencies as interface parameters, or the codeunit receives them via a setter before execution. No inline `CompanyInfo.Get()` or setup table reads buried in business logic — pass the values in or inject the source.

**Interfaces and dependency resolution**:
- Define an interface for every external dependency that may vary or need mocking.
- For simple cases, an overloaded procedure is sufficient: one overload takes the interface as a parameter, the other calls the first with the default implementation. No factory needed.
- Use a factory codeunit when the dependency resolution is non-trivial, shared across callers, or needs to be swappable at a higher level (e.g. test setup registers a mock once for the whole test). Factories are a tool, not a requirement everywhere.
- Test code substitutes the real implementation with a mock via the injection point — parameter overload or factory registration. This is the seam.
- A seam is a point where behavior can be changed without modifying the code under test. Design for seams deliberately.

## Clear Seams

Every place where an implementation might change — integrations, pricing logic, approval flows, external lookups — must be behind an interface. This is not optional for testability; it is also what allows individual implementations to be swapped when requirements change without touching surrounding code.

If you find yourself writing `if Environment = 'TEST' then` inside business logic, that is a missing seam. Replace it with an interface.
