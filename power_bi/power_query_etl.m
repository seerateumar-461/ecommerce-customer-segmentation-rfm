// =============================================================================
// Power Query M Script: E-Commerce Automated Ingestion & Schema Cleanse
// =============================================================================
let
    Source = Csv.Document(File.Contents("data/cleaned/online_retail_cleaned.csv"), [Delimiter=",", Columns=11, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{
        {"InvoiceNo", type text},
        {"StockCode", type text},
        {"Description", type text},
        {"Category", type text},
        {"Quantity", Int64.Type},
        {"InvoiceDate", type datetime},
        {"UnitPrice", type number},
        {"CustomerID", type text},
        {"Country", type text},
        {"TotalAmount", type number},
        {"InvoiceMonth", type text}
    }),
    #"Filtered Valid Rows" = Table.SelectRows(#"Changed Type", each [Quantity] > 0 and [CustomerID] <> null)
in
    #"Filtered Valid Rows"
