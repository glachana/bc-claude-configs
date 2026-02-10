---
title: "AL Rest Client Module"
domain: bc-modules
difficulty: intermediate
tags:
  - rest-client
  - http
  - api
  - integration
  - authentication
  - testing
related_topics: []
---

# AL Rest Client Module

## What is the Rest Client Module?

The **Rest Client** module simplifies calling REST web services in Business Central by wrapping the standard HTTP objects (`HttpClient`, `HttpRequestMessage`, `HttpResponseMessage`). It reduces boilerplate, centralizes authentication, and enables mock-based unit testing.

> **Prefer `RestClient` over raw `HttpClient`** for all new integrations.

---

## Module Components

| Component | Type | Description |
|-----------|------|-------------|
| `Rest Client` | Codeunit | Core — use this to make requests |
| `Http Request Message` | Codeunit | Encapsulated HTTP request |
| `Http Response Message` | Codeunit | Encapsulated HTTP response |
| `Http Content` | Codeunit | Request/response body handling |
| `Http Method` | Enum | GET, POST, PUT, PATCH, DELETE |
| `Http Client Handler` | Interface | Controls execution (real or mocked) |
| `Http Authentication` | Interface | Handles authentication strategies |

---

## Why Use RestClient Instead of HttpClient?

| Problem with raw `HttpClient` | `RestClient` solution |
|-------------------------------|----------------------|
| Lots of repetitive boilerplate | 1-line calls (`GetAsJson`, `Post`) |
| Manual JSON/XML/header handling | Built-in content conversion |
| Not testable (can't mock) | Mock-friendly via `HttpClientHandler` |
| No built-in telemetry | Built-in telemetry & permission control |
| Manual auth setup | Authentication interface |

---

## Recommended Initialization

Always initialize with a custom `HttpClientHandler` — this ensures:
1. **Your extension** gets the external call permission
2. **Your telemetry** is tracked
3. **Mock testing** is possible

```al
// File: MyHttpClientHandler.Codeunit.al
codeunit 50100 MyHttpClientHandler implements "Http Client Handler"
{
    procedure Send(
        HttpClient: HttpClient;
        HttpRequestMessage: Codeunit "Http Request Message";
        var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        exit(HttpClient.Send(HttpRequestMessage.GetHttpRequestMessage(), HttpResponseMessage.GetHttpResponseMessage()));
    end;
}

// Usage
procedure CallApi()
var
    RestClient: Codeunit "Rest Client";
    MyHandler: Codeunit MyHttpClientHandler;
begin
    RestClient.Initialize(MyHandler);
    // ... make calls
end;
```

---

## Authentication

Three built-in authentication strategies:

| Strategy | When to use |
|----------|------------|
| `Anonymous Http Authentication` | Public APIs, no auth required |
| `Basic Authentication` | Username/password APIs |
| `OAuth2 Client Credentials Auth.` | OAuth2 client credentials flow |

You can also implement the `Http Authentication` interface for custom auth.

```al
// Basic auth example
var
    RestClient: Codeunit "Rest Client";
    BasicAuth: Codeunit "Basic Authentication";
begin
    BasicAuth.Initialize('myuser', 'mypassword');
    RestClient.Initialize(MyHandler, BasicAuth);
end;
```

---

## Usage Examples

### GET Request

```al
procedure GetCustomerData(CustomerNo: Code[20]): JsonObject
var
    RestClient: Codeunit "Rest Client";
    ResponseJson: JsonObject;
begin
    RestClient.Initialize(MyHandler);
    ResponseJson := RestClient.GetAsJson('https://api.example.com/customers/' + CustomerNo);
    exit(ResponseJson);
end;
```

### POST Request

```al
procedure CreateOrder(OrderJson: JsonObject)
var
    RestClient: Codeunit "Rest Client";
    HttpContent: Codeunit "Http Content";
    Response: Codeunit "Http Response Message";
begin
    RestClient.Initialize(MyHandler);
    HttpContent := HttpContent.Create(OrderJson);
    Response := RestClient.Post('https://api.example.com/orders', HttpContent);

    if not Response.GetIsSuccessStatusCode() then
        Error('API call failed: %1 %2', Response.GetHttpStatusCode(), Response.GetReasonPhrase());
end;
```

---

## HttpContent Handling

```al
// Create content
HttpContent := HttpContent.Create(MyJsonObject);               // JSON
HttpContent := HttpContent.Create('plain text', 'text/plain'); // Text
HttpContent := HttpContent.Create(MyTempBlob, 'application/pdf'); // Binary

// Read response content
var
    ResponseText: Text;
    ResponseJson: JsonObject;
    ResponseBlob: Codeunit "Temp Blob";
begin
    ResponseText := Response.GetContent().AsText();
    ResponseJson := Response.GetContent().AsJson();
    ResponseBlob := Response.GetContent().AsTempBlob();
end;
```

---

## Error Handling

`RestClient` does **not throw** on HTTP errors by default — always check the response status:

```al
procedure CallApiSafely(): Boolean
var
    RestClient: Codeunit "Rest Client";
    Response: Codeunit "Http Response Message";
    ApiCallFailedErr: Label 'API call failed with status %1: %2', Comment = '%1 = HTTP status code, %2 = Reason phrase';
begin
    RestClient.Initialize(MyHandler);
    Response := RestClient.Get('https://api.example.com/resource');

    if not Response.GetIsSuccessStatusCode() then begin
        Error(ApiCallFailedErr, Response.GetHttpStatusCode(), Response.GetReasonPhrase());
    end;

    exit(true);
end;
```

---

## Mock Testing

Use a custom handler to simulate API responses without real HTTP calls:

```al
codeunit 50199 MockHttpClientHandler implements "Http Client Handler"
{
    var
        MockStatusCode: Integer;
        MockBody: Text;

    procedure SetMockResponse(StatusCode: Integer; Body: Text)
    begin
        MockStatusCode := StatusCode;
        MockBody := Body;
    end;

    procedure Send(
        HttpClient: HttpClient;
        HttpRequestMessage: Codeunit "Http Request Message";
        var HttpResponseMessage: Codeunit "Http Response Message"): Boolean
    begin
        HttpResponseMessage.SetHttpStatusCode(MockStatusCode);
        HttpResponseMessage.SetContent(HttpContent.Create(MockBody, 'application/json'));
        exit(MockStatusCode < 400);
    end;
}

// In your test
[Test]
procedure TestApiCallHandlesError()
var
    MockHandler: Codeunit MockHttpClientHandler;
    MyService: Codeunit MyApiService;
begin
    MockHandler.SetMockResponse(500, '{"error":"internal server error"}');
    asserterror MyService.CallWithHandler(MockHandler);
end;
```

---

## References

- [Rest Client — Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.restclient.rest-client)
- [Http Content](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.restclient.http-content)
- [Http Response Message](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.restclient.http-response-message)
- [Http Client Handler Interface](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/interface/system.restclient.http-client-handler)
- [Http Authentication Interface](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/interface/system.restclient.http-authentication)

---

**Last Updated**: 2026-02-10
**Status**: Active
