namespace rajkumar.view;

using { rajkumar.db.master, rajkumar.db.transaction  } from './02datamodel';

context CDSViews {
    define view![POWorklist] as 
      select from transaction.purchaseorder{
        key PO_ID as![purchaseOrderId],
        PARTNER_GUID.BP_ID as![PartnerId],
        PARTNER_GUID.COMPANY_NAME as![company_name],
        GROSS_AMOUNT as![POGrossAmount],
        Currency.code as![POCurrencyCode],
        LIFECYCLE_STATUS as![POStatus],
        key Items.PO_ITEM_POS as![ItemPostion],
        Items.PRODUCT_GUID.PRODUCT_ID as![ProductId],
        Items.PRODUCT_GUID.DESCRIPTION as![productName],
        PARTNER_GUID.ADDRESS_GUID.CITY as![City],
        PARTNER_GUID.ADDRESS_GUID.STREET as![Street],
        Items.GROSS_AMOUNT as![GrossAmount],
        Items.NET_AMOUNT as![NetAmount],
        Items.TAX_AMOUNT as![TaxAmount],
        Items.Currency.code as![CurrencyCode],
    };

     define view ProductValueHelp as 
        select from master.product{
            @EndUserText.label:[
                {
                    language: 'EN',
                    text: 'Product ID'
                },{
                    language: 'DE',
                    text: 'Prodekt ID'
                }
            ]
            PRODUCT_ID as ![ProductId],
            @EndUserText.label:[
                {
                    language: 'EN',
                    text: 'Product Description'
                },{
                    language: 'DE',
                    text: 'Prodekt Description'
                }
            ]
            DESCRIPTION as ![Description]
        };
        
    define view![ItemView] as 
    select from transaction.poitems{
        PARENT_KEY.PARTNER_GUID.NODE_KEY as![Partner],
        PRODUCT_GUID.NODE_KEY as![ProductId],
        Currency.code as![CurrencyCode],
        GROSS_AMOUNT as![GrossAmount],
        NET_AMOUNT as![NetAmount],
        TAX_AMOUNT as![TaxAmount],
        PARENT_KEY.OVERALL_STATUS as![POStatus]
    };

    define view ProductViewSub as 
    select from master.product as prod{
        PRODUCT_ID as![ProductId],
        texts.DESCRIPTION as![Description],
        (
            select from transaction.poitems as a{
                round(SUM(a.GROSS_AMOUNT),2) as SUM
            }
            where a.PRODUCT_GUID.NODE_KEY = prod.NODE_KEY
        ) as PO_SUM: Decimal(10, 2)
    };

    define view ProductView as select from master.product
    mixin{
        PO_ORDERS: Association[*] to ItemView on
                        PO_ORDERS.ProductId = $projection.ProductId
    }
    into{
        NODE_KEY as![ProductId],
        DESCRIPTION,
        CATEGORY as![Category],
        PRICE as![Price],
        TYPE_CODE as![TypeCode],
        SUPPLIER_GUID.BP_ID as![BPId],
        SUPPLIER_GUID.COMPANY_NAME as![CompanyName],
        SUPPLIER_GUID.ADDRESS_GUID.CITY as![City],
        SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as![Country],
        //Exposed Association, which means when someone read the view
        //the data for orders wont be read by default
        //until unless someone consume the association
        PO_ORDERS
    };

    define view CProductValuesView as 
        select from ProductView{
            ProductId,
            Country,
            PO_ORDERS.CurrencyCode as![CurrencyCode],
            round(sum(PO_ORDERS.GrossAmount),2) as ![POGrossAmount]: Decimal(10, 2)
        }
        group by ProductId,Country,PO_ORDERS.CurrencyCode

}