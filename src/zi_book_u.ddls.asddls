@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'interface for booking inmange'
@Metadata.ignorePropagatedAnnotations: true
define view entity zi_book_u as select from /dmo/booking as booking
association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
association [1..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
association [0..1] to /DMO/I_Carrier as _Carrier on $projection.CarrierId = _Carrier.AirlineID 
association [0..1] to /DMO/I_Connection as _Connection on $projection.CarrierId = _Connection.AirlineID and $projection.ConnectionId = _Connection.ConnectionID
association to parent zi_travel_u  as _Travel on $projection.TravelId = _Travel.TravelId
{
    key travel_id as TravelId,
    key booking_id as BookingId,
    booking_date as BookingDate,
    customer_id as CustomerId,
    carrier_id as CarrierId,
    connection_id as ConnectionId,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    _Customer,
    _Currency,
    _Carrier,
    _Connection,
    _Travel
}
