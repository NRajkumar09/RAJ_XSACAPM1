 namespace rajkumar.db;
     entity orders
{ 
    key ID : Integer64;
    customername : String(120);
    contactname : String(64);
    grossamount : Decimal(10,2);
    currency : String(4);
}