---
title: "Façade Pattern in AL"
domain: patterns
difficulty: intermediate
tags:
  - facade
  - architecture
  - encapsulation
  - access-modifiers
  - system-application
related_topics:
  - template-method-pattern
---

# Façade Pattern in AL

## Intent

Provide a **unified, stable public API** to one or more potentially complex subsystems, hiding internal implementation details behind access modifiers.

> This is one of the most-used patterns in the BC System Application architecture.

---

## Problem

As systems grow, implementation becomes complex and hard to understand. Without structure:
- External callers depend on internal implementation details
- Refactoring breaks external dependencies
- Complexity leaks to callers

---

## Solution

Use AL `Access` modifiers to enforce a clean separation:

| Layer | Access | Role |
|-------|--------|------|
| **Façade** | `Access = Public` | Stable public API — the only entry point callers use |
| **Implementation** | `Access = Internal` | Complex logic, hidden from outside the module |

The façade codeunit contains **only documented procedures** that delegate to internal codeunits. Callers never see or reference the implementation directly.

---

## Structure

```al
// ============================================================
// FAÇADE — Public entry point (Access = Public)
// File: Image.Codeunit.al
// ============================================================
codeunit 3971 Image
{
    Access = Public;

    var
        ImageImpl: Codeunit "Image Impl.";

    /// <summary>
    /// Loads an image from a stream.
    /// </summary>
    /// <param name="InStream">The stream containing image data</param>
    procedure FromStream(InStream: InStream)
    begin
        ImageImpl.FromStream(InStream);
    end;

    /// <summary>
    /// Returns the image width in pixels.
    /// </summary>
    procedure GetWidth(): Integer
    begin
        exit(ImageImpl.GetWidth());
    end;
}

// ============================================================
// IMPLEMENTATION — Internal subsystem (Access = Internal)
// File: ImageImpl.Codeunit.al
// ============================================================
codeunit 3970 "Image Impl."
{
    Access = Internal;

    procedure FromStream(InStream: InStream)
    begin
        // Complex implementation — callers never depend on this
    end;

    procedure GetWidth(): Integer
    begin
        // Complex implementation
    end;
}
```

---

## Benefits

| Benefit | Explanation |
|---------|-------------|
| **Decoupling** | Callers depend on the stable facade, not volatile implementation |
| **Encapsulation** | Internal complexity is hidden — free to refactor |
| **Testability** | Tests focus on the public contract (facade) |
| **Maintainability** | Change internal logic without breaking external callers |
| **Readability** | One clear, documented entry point |

---

## When to Use

**Use Façade when:**
- Building reusable libraries or modules
- A subsystem is growing in complexity
- You need a stable long-term API
- Multiple codeunits implement one logical feature

**Avoid when:**
- The feature is simple with a single codeunit
- Internal extensibility is critical (requires special design with events)

---

## Real BC Examples

The pattern is used throughout the BC System Application:
- `Email` codeunit (public) → `Email Impl.` (internal)
- `Cryptography Management` (public) → internal crypto codeunits
- `Image` (public) → `Image Impl.` (internal)

---

## References

- [Façade Pattern — alguidelines.dev](https://alguidelines.dev/docs/patterns/facade-pattern/)

---

**Last Updated**: 2026-02-10
**Status**: Active
