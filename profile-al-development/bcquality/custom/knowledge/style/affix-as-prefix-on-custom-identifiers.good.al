// Affix "ABC" as a PREFIX on every custom object.
// Extension fields are prefixed; fields inside a fully custom table are NOT.

tableextension 50100 "ABC Customer Ext" extends Customer   // custom object: prefixed
{
    fields
    {
        field(50100; "ABC Credit Limit"; Decimal) { }      // extension field: prefixed
        field(50101; "ABC Credit Warning"; Boolean) { }    // extension field: prefixed
    }
}

table 50100 "ABC Loan Application"                          // custom object: prefixed
{
    fields
    {
        field(1; "Application No."; Code[20]) { }          // custom-table field: NOT prefixed
        field(2; Amount; Decimal) { }                      // custom-table field: NOT prefixed
        field(3; Status; Option) { OptionMembers = Open,Approved,Rejected; }
    }
}

codeunit 50100 "ABC Credit Validation" { }                 // custom object: prefixed
