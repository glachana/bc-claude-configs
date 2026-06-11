// Project affix "ABC" applied as a SUFFIX on every custom identifier.
tableextension 50100 CustomerExtABC extends Customer
{
    fields
    {
        field(50100; CreditLimitABC; Decimal) { }      // affix as suffix, on a table-ext field
        field(50101; CreditWarningABC; Boolean) { }    // affix as suffix
    }
}

codeunit 50100 CreditValidationABC
{
    procedure ValidateCreditABC(CustomerNo: Code[20])
    begin
    end;
}
