@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'consumption for booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
define view entity zc_book_u
  as projection on zi_book_u
{
      @Search.defaultSearchElement: true
  key TravelId,
      @Search.defaultSearchElement: true
  key BookingId,
      BookingDate,
      @Consumption.valueHelpDefinition: [{entity: {name: '/DMO/I_Customer_StdVH', element: 'CustomerID' }, useForValidation: true}]
      @Search.defaultSearchElement: true
      @ObjectModel.text.element: ['CustomerName']
      CustomerId,
      _Customer.LastName as CustomerName,
      @ObjectModel.text.element: ['CarrierName']
      @Consumption.valueHelpDefinition: [
          { entity: {name: '/DMO/I_Flight_StdVH', element: 'AirlineID'},
            additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate',   usage: #RESULT},
                                 { localElement: 'CarrierId', element: 'AirlineID', usage: #RESULT},
                                 { localElement: 'FlightPrice',  element: 'Price',        usage: #RESULT},
                                 { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT },
                                 { localElement: 'ConnectionId', element: 'ConnectionID', usage: #RESULT } ],
            useForValidation: true }
        ]
      CarrierId,
      _Carrier.Name      as CarrierName,

      ConnectionId,
      @Consumption.valueHelpDefinition: [
            { entity: {name: '/DMO/I_Flight_StdVH', element: 'FlightDate'},
              additionalBinding: [ { localElement: 'ConnectionId',    element: 'AirlineID',    usage: #FILTER_AND_RESULT},
                                   { localElement: 'ConnectionID', element: 'ConnectionID', usage: #FILTER_AND_RESULT},
                                   { localElement: 'FlightPrice',  element: 'Price',        usage: #RESULT},
                                   { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ],
              useForValidation: true }
          ]
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @Consumption.valueHelpDefinition: [
           { entity: {name: '/DMO/I_Flight_StdVH', element: 'Price'},
             additionalBinding: [ { localElement: 'FlightDate',   element: 'FlightDate',   usage: #FILTER_AND_RESULT},
                                  { localElement: 'CarrierId',    element: 'AirlineID',    usage: #FILTER_AND_RESULT},
                                  { localElement: 'ConnectionID', element: 'ConnectionID', usage: #FILTER_AND_RESULT},
                                  { localElement: 'CurrencyCode', element: 'CurrencyCode', usage: #RESULT } ],
             useForValidation: true }
         ]
      FlightPrice,
      @Consumption.valueHelpDefinition: [{entity: {name: 'I_CurrencyStdVH', element: 'Currency' }, useForValidation: true }]
      CurrencyCode,
      /* Associations */
      _Carrier,
      _Connection,
      _Currency,
      _Customer,
      _Travel : redirected to parent zc_travel_u
}
