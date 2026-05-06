# Interview Question Categories for BC/AL Projects

Use these categories as a guide during requirements interviews. Adapt questions based on the user's answers — skip irrelevant categories, dig deeper where complexity emerges.

## 1. Business Logic & Requirements

- What is the end-to-end business process this feature supports? Walk me through the happy path step by step.
- What validation rules apply at each stage? Are they blocking errors or warnings the user can override?
- Which user roles interact with this feature? Do they have different permissions or see different data?
- Does this need to work in a multi-company environment? If so, do companies share configuration or is it per-company?
- Are number sequences involved? Should they use BC standard number series, or is there a custom numbering scheme?

## 2. BC Base App Integration

- Which existing BC tables does this feature extend or interact with? (e.g., Customer, Item, Sales Header/Line)
- Are you extending existing tables with new fields, or creating entirely new tables? What drives that decision?
- Which BC events do we need to subscribe to? (e.g., OnBeforePostSalesDocument, OnAfterValidateField)
- Which standard BC pages need extensions? Are we adding fields, actions, or both?
- Is there risk of conflicting with other installed extensions? What other extensions are in the environment?

## 3. Data Model & State

- What are the key fields and their types? Any specific field lengths or format requirements? (e.g., Code[20], Text[100])
- What are the table relationships? One-to-many? Many-to-many? How are foreign keys structured?
- Are FlowFields or FlowFilters needed? What calculations should they perform?
- What primary and secondary keys are needed? What are the typical query patterns?
- Is there existing data that needs to be migrated or upgraded when this is deployed? What volume?

## 4. User Interface

- What page type is needed? (List, Card, Worksheet, Document, etc.) What is the primary workflow?
- Which fields should be visible by default vs. hidden in "Show more"? Any fields that are conditionally visible?
- What actions does the user need? Where should they appear — in the action bar, on lines, or both?
- Are there lookups or drill-downs needed? What should the user see when they click on a field?
- Does this need to work well on the web client, phone, and tablet? Any responsive layout considerations?

## 5. Error Handling & Validation

- When should validation run — on field entry, on action trigger, on posting, or all of the above?
- Which errors should block the operation vs. show a confirmation dialog the user can accept?
- Can users override certain validations with sufficient permissions? Which ones?
- What should be logged? Do we need an error log table, or are standard BC error messages sufficient?
- If an operation partially fails, what should be rolled back? What can remain?

## 6. Integration Points

- Does this feature need to communicate with external systems? What protocols? (REST API, SOAP, files, etc.)
- Should BC expose web services (API pages, OData, SOAP) for this feature? Who consumes them?
- Is there data import/export needed? What formats? (CSV, XML, JSON, Excel) How often?
- Does this interact with any third-party extensions? Which ones and how?
- Is Power BI, Power Automate, or other Power Platform integration needed?

## 7. Performance & Scale

- What is the expected record volume? (Today and in 2-3 years) Are we talking hundreds, thousands, or millions?
- Are there operations that process many records at once? What batch sizes are expected?
- Should any processing happen in background sessions (job queue)? What triggers it?
- Are there queries that could be slow? Do we need to think about SIFT keys or indexed fields?
- Is caching needed for frequently accessed configuration data?

## 8. Testing Strategy

- What are the critical test scenarios? What must work perfectly on day one?
- What test data is needed? Can we generate it, or does it need to match production patterns?
- Which areas need automated unit tests? What business logic is complex enough to warrant them?
- Are integration tests needed for external system connections?
- Who performs UAT? What is their test plan? When does UAT happen relative to deployment?

## 9. Security & Compliance

- What permission sets are needed? Who can read, insert, modify, delete?
- Is field-level security needed? Are there fields that only certain roles should see or edit?
- Does this feature need an audit trail? What changes should be tracked and how?
- Are there GDPR implications? Personal data that needs classification or retention policies?
- Are there financial controls or segregation of duties requirements?

## 10. Deployment & Migration

- What is the rollout strategy? Big bang, phased by company, or feature-flagged gradual rollout?
- Is there data to migrate from an existing system or spreadsheet? What is the volume and quality?
- What is the rollback plan if something goes wrong after deployment?
- Are feature flags or setup toggles needed to control activation?
- What user training or documentation is needed before go-live?

## 11. Edge Cases & Unknowns

- What happens at boundary conditions? (Zero quantity, empty fields, maximum values, first/last record)
- What if two users edit the same record simultaneously? How should concurrency be handled?
- What happens with partial or incomplete data? Can records be saved in a draft state?
- Are there system limits we might hit? (Field count per table, key count, text length limits)
- What is the worst thing that could go wrong with this feature? (Murphy's Law scenario)
