// Wrong: affix prepended as a prefix, and one field missing the affix entirely.
tableextension 50100 ABCCustomerExt extends Customer   // affix as PREFIX - wrong
{
    fields
    {
        field(50100; ABCCreditLimit; Decimal) { }      // affix as PREFIX - wrong
        field(50101; CreditWarning; Boolean) { }        // affix MISSING - collision risk
    }
}

codeunit 50100 ABCCreditValidation                      // affix as PREFIX - wrong
{
    procedure ValidateCredit(CustomerNo: Code[20])      // affix MISSING
    begin
    end;
}
