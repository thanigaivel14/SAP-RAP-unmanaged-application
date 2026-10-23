@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'cds for travel app unmange app'
@Metadata.ignorePropagatedAnnotations: true

define root view entity zi_travel_u as select from /dmo/travel as travel
composition [0..*] of zi_book_u as _booking 
association [0..1] to /DMO/I_Agency as _Agency on $projection.AgencyId = _Agency.AgencyID
association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
association [1..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
association [1..1] to /DMO/I_Travel_Status_VH as _TravelStatus on $projection.Status = _TravelStatus.TravelStatus

{
    key travel.travel_id as TravelId,
    travel.agency_id as AgencyId,
    travel.customer_id as CustomerId,
    travel.begin_date as BeginDate,
    travel.end_date as EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    travel.booking_fee as BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    travel.total_price as TotalPrice,
    travel.currency_code as CurrencyCode,
    travel.description as Description,
    travel.status as Status,
    travel.createdby as Createdby,
    travel.createdat as Createdat,
    travel.lastchangedby as Lastchangedby,
    travel.lastchangedat as Lastchangedat,
    _Agency,_Currency,_Customer,_TravelStatus,
    _booking
    
}
