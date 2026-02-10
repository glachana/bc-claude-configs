---
title: "IsolatedStorage in AL"
domain: bc-modules
difficulty: intermediate
tags:
  - isolated-storage
  - settings
  - persistence
  - security
related_topics: []
---

# IsolatedStorage in AL

## What is IsolatedStorage?

`IsolatedStorage` is a **system function** (not a codeunit) accessible directly in AL. It allows extensions to store data in a **persistent, private, and secure** way. Each extension has its own isolated storage space — other extensions cannot read or manipulate it.

> **Syntax note:** Use `IsolatedStorage` directly, not via a codeunit variable.

---

## Available Scopes

| Scope | Description |
|-------|-------------|
| `DataScope::Company` | Data is specific to the extension **and the current company** |
| `DataScope::User` | Data is specific to the **user within the current company** |
| `DataScope::Module` | Data is specific to the extension across all companies |
| `DataScope::UserAndCompany` | Data is specific to both the user and the current company |

---

## API Reference

### `IsolatedStorage.Set`

Stores a value under a given key in the specified scope.

```al
IsolatedStorage.Set('MyKey', 'MyValue', DataScope::Company);
```

### `IsolatedStorage.Get`

Retrieves the value for a key. Raises an error if the key does not exist.

```al
var
    Value: Text;
begin
    IsolatedStorage.Get('MyKey', DataScope::Company, Value);
end;
```

### `IsolatedStorage.Contains`

Returns `true` if the key exists in the specified scope. Use this before `Get` to avoid errors.

```al
if IsolatedStorage.Contains('MyKey', DataScope::Company) then
    IsolatedStorage.Get('MyKey', DataScope::Company, Value);
```

### `IsolatedStorage.Delete`

Removes the value associated with a key in the given scope.

```al
IsolatedStorage.Delete('MyKey', DataScope::Company);
```

---

## Best Practices

- Use `DataScope::Company` for global configuration or settings shared across users.
- Use `DataScope::User` for user preferences or per-user state.
- Always check `IsolatedStorage.Contains` before calling `Get` to avoid runtime errors.
- Store sensitive values (API keys, tokens) in IsolatedStorage rather than in setup tables — it is not exposed in the database.

**Example — Safe read pattern:**
```al
procedure GetApiKey(): Text
var
    ApiKey: Text;
    ApiKeyNotConfiguredErr: Label 'API key is not configured. Please set it up in the setup page.';
begin
    if not IsolatedStorage.Contains('ApiKey', DataScope::Company) then
        Error(ApiKeyNotConfiguredErr);

    IsolatedStorage.Get('ApiKey', DataScope::Company, ApiKey);
    exit(ApiKey);
end;

procedure SetApiKey(ApiKey: Text)
begin
    IsolatedStorage.Set('ApiKey', ApiKey, DataScope::Company);
end;
```

---

## Limitations

- Storage size is limited (not publicly documented by Microsoft).
- Only accessible from the extension that created the data.
- Cannot be synchronized between environments or read directly from files.
- Cannot be exported/imported like table data.

---

## References

- [IsolatedStorage — Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-isolated-storage)

---

**Last Updated**: 2026-02-10
**Status**: Active
