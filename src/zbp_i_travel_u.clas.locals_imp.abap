CLASS lsc_ZI_TRAVEL_U DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS adjust_numbers REDEFINITION.


    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_U IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD adjust_numbers.

    DATA:
    lt_booking_mapping      TYPE /dmo/if_flight_legacy=>tt_ln_booking_mapping,
    return_travel TYPE  /dmo/if_flight_legacy=>tt_ln_travel_mapping.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_ADJ_NUMBERS'
      IMPORTING
        et_travel_mapping = return_travel
       et_booking_mapping      = lt_booking_mapping
*       et_bookingsuppl_mapping =
      .

    mapped-travel = VALUE #( FOR ls_travel IN return_travel
                            ( %tmp = VALUE #( TravelId = ls_travel-preliminary-travel_id )
                            TravelId = ls_travel-final-travel_id )
    ).
     mapped-booking =  VALUE #( FOR ls_booking IN lt_booking_mapping ( %tmp = VALUE #( TravelID =  ls_booking-preliminary-travel_id
                                                                                       BookingID = ls_booking-preliminary-booking_id )
                                                                      TravelID = ls_booking-final-travel_id
                                                                      BookingID = ls_booking-final-booking_id   ) ).


  ENDMETHOD.

  METHOD save.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_SAVE'.
  ENDMETHOD.

  METHOD cleanup.
    CALL FUNCTION '/DMO/FLIGHT_TRAVEL_INITIALIZE'.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
