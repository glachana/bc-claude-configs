// Wrong: suffix instead of prefix, missing prefix where required,
// and prefixing a custom-table field where it is not needed.

tableextension 50100 "Customer Ext ABC" extends Customer   // suffix - wrong, we never suffix
{
    fields
    {
        field(50100; "Credit Limit ABC"; Decimal) { }      // suffix - wrong
        field(50101; "Credit Warning"; Boolean) { }        // missing prefix on extension field - collision risk
    }
}

table 50100 "Loan Application"                             // missing prefix on a custom object - wrong
{
    fields
    {
        field(1; "ABC Application No."; Code[20]) { }      // prefixing a custom-table field - unnecessary
    }
}
