CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
       entities FOR UPDATE booking.

    METHODS delete FOR MODIFY
       keys FOR DELETE booking.

    METHODS read FOR READ
       keys FOR READ booking RESULT result.

    METHODS rba_Travel FOR READ
       keys_rba FOR READ booking\_Travel FULL result_requested RESULT result LINK association_links.

    TYPES : failed TYPE TABLE FOR FAILED  zi_travel_u,
            report TYPE TABLE FOR REPORTED  zi_travel_u.

    METHODS message_mapping
      IMPORTING
        travelid    TYPE /dmo/travel_id
        ls_messages TYPE /dmo/t_message
      EXPORTING
        if_failed   TYPE abap_boolean
      CHANGING
        fail        TYPE  failed
        report      TYPE report.

    TYPES: book_failed TYPE TABLE FOR FAILED zi_book_u,
           book_report TYPE TABLE FOR REPORTED zi_book_u.
    METHODS message_mapping_booking
      IMPORTING
        cid         TYPE abp_behv_cid
        travelid    TYPE /dmo/travel_id
        bookingid   TYPE /dmo/booking_id
        ls_messages TYPE /dmo/t_message
      EXPORTING
        is_failed   TYPE abap_boolean
      CHANGING
        fail        TYPE book_failed
        report      TYPE book_report.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD update.
    DATA: messages        TYPE /dmo/t_message,
          booking         TYPE /dmo/booking,
          bookingx        TYPE /dmo/s_booking_inx,
          ls_booking_out  TYPE /dmo/t_booking,
          ls_messages_out TYPE /dmo/t_message,
          is_failed       TYPE abap_boolean
          .

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_key>).
      booking = CORRESPONDING #( <fs_key> MAPPING FROM ENTITY ).
      bookingx-_intx       = CORRESPONDING #( <fs_key> MAPPING FROM ENTITY ).
      bookingx-booking_id  = <fs_key>-BookingID.
      bookingx-action_code = /dmo/if_flight_legacy=>action_code-update.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = booking-travel_id )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = booking-travel_id )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( CORRESPONDING #( bookingx ) ) )
        IMPORTING
          et_booking  = ls_booking_out
          et_messages = ls_messages_out.

      message_mapping_booking(
      EXPORTING
      cid = <fs_key>-%cid_ref
      travelid = <fs_key>-TravelId
      bookingid = <fs_key>-BookingId
      ls_messages = ls_messages_out
      IMPORTING
      is_failed = is_failed
      CHANGING
      fail = failed-booking
      report = reported-booking

        ).

      IF is_failed = abap_false.

      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD delete.
    DATA: messages        TYPE /dmo/t_message,
          booking         TYPE /dmo/booking,
          bookingx        TYPE /dmo/s_booking_inx,
          ls_booking_out  TYPE /dmo/t_booking,
          ls_messages_out TYPE /dmo/t_message,
          is_failed       TYPE abap_boolean
          .

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      booking = CORRESPONDING #( <fs_key> MAPPING FROM ENTITY ).
*      bookingx-_intx       = CORRESPONDING #( <fs_key> MAPPING FROM ENTITY ).
      bookingx-booking_id  = <fs_key>-BookingID.
      bookingx-action_code = /dmo/if_flight_legacy=>action_code-delete.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = VALUE /dmo/s_travel_in( travel_id = booking-travel_id )
          is_travelx  = VALUE /dmo/s_travel_inx( travel_id = booking-travel_id )
          it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( booking ) ) )
          it_bookingx = VALUE /dmo/t_booking_inx( ( CORRESPONDING #( bookingx ) ) )
        IMPORTING
          et_booking  = ls_booking_out
          et_messages = ls_messages_out.

      message_mapping_booking(
      EXPORTING
      cid = <fs_key>-%cid_ref
      travelid = <fs_key>-TravelId
      bookingid = <fs_key>-BookingId
      ls_messages = ls_messages_out
      IMPORTING
      is_failed = is_failed
      CHANGING
      fail = failed-booking
      report = reported-booking

        ).
      IF is_failed = abap_false.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Travel.
    DATA: ls_travel_out TYPE /dmo/travel,
          ls_message    TYPE /dmo/t_message,
          isfailed      TYPE abap_boolean,
          travel        LIKE LINE OF result.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<fs_keys>) GROUP BY <fs_keys>-TravelId.

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_keys>-TravelId
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = ls_travel_out
*         et_booking   =
*         et_booking_supplement =
          et_messages  = ls_message.
      message_mapping(

      EXPORTING
      travelid = ls_travel_out-travel_id
      ls_messages = ls_message
      IMPORTING
      if_failed = isfailed
      CHANGING
      fail = failed-travel
      report = reported-travel
      ).

      IF isfailed = abap_false.

        association_links = VALUE #( ( source-%key = <fs_keys>-%key
                                        target-TravelId = ls_travel_out-travel_id
           ) ).
        IF result_requested = abap_true.
          travel = CORRESPONDING #( ls_travel_out MAPPING TO ENTITY ).
          INSERT travel INTO TABLE result.
        ENDIF.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD message_mapping.
    if_failed = abap_false.
    LOOP AT ls_messages ASSIGNING FIELD-SYMBOL(<fs_message>).

      APPEND VALUE #(  TravelId = travelid
                        %fail-cause = zcl_fail_cause=>get_cause_from_message(
                                        msgid        = <fs_message>-msgid
                                        msgno        = <fs_message>-msgno
*                                    is_dependend = abap_false
                                      )



       ) TO fail.
      report = VALUE #( ( TravelId = travelid
                          %msg = new_message(
                                   id       = <fs_message>-msgid
                                   number   = <fs_message>-msgno
                                   severity = if_abap_behv_message=>severity-error
                                   v1       =  <fs_message>-msgv1
                                   v2       = <fs_message>-msgv2
*                                  v3       =
*                                  v4       =
                                 )

       ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD message_mapping_booking.
    is_failed = abap_false.
    LOOP AT ls_messages ASSIGNING FIELD-SYMBOL(<fs_message>).
      IF <fs_message>-msgty = 'E' OR <fs_message>-msgty = 'A'.

        APPEND VALUE #(  %cid = cid %fail-cause = zcl_fail_cause=>get_cause_from_message(
                                                     msgid        = <fs_message>-msgid
                                                     msgno        = <fs_message>-msgno
*                                               is_dependend = abap_false
                                                   ) ) TO fail.
        APPEND  VALUE #(   %cid = cid %msg = new_message(
                                                 id       = <fs_message>-msgid
                                                 number   = <fs_message>-msgno
                                                 severity = if_abap_behv_message=>severity-error
                                                 v1       =  <fs_message>-msgv1
                                                 v2       =  <fs_message>-msgv2
*                                         v3       =
*                                         v4       =
                                               ) ) TO report.



      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
