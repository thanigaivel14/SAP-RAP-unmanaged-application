CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    TYPES : t_fail   TYPE TABLE  FOR FAILED  zi_travel_u,
            t_report TYPE TABLE FOR REPORTED  zi_travel_u.
    METHODS mapping_message
      IMPORTING
        cid          TYPE abp_behv_cid  OPTIONAL
        travelid     TYPE /dmo/travel_id OPTIONAL
        lt_messages  TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_boolean
      CHANGING
        fail         TYPE t_fail
        report       TYPE t_report.
    TYPES : t_book_fail   TYPE TABLE FOR FAILED zi_book_u,
            t_book_report TYPE TABLE FOR REPORTED zi_book_u.
    METHODS mapping_message_assc
      IMPORTING
        cid         TYPE abp_behv_cid
        is_depend   TYPE abap_boolean DEFAULT abap_true
        ls_messages TYPE /dmo/t_message
      EXPORTING
        fail_added  TYPE abap_boolean
      CHANGING
        book_fail   TYPE t_book_fail
        book_report TYPE t_book_report.



    METHODS get_instance_features FOR INSTANCE FEATURES
      keys REQUEST requested_features FOR travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR travel RESULT result.

    METHODS create FOR MODIFY
       entities FOR CREATE travel.

    METHODS update FOR MODIFY
       entities FOR UPDATE travel.

    METHODS delete FOR MODIFY
       keys FOR DELETE travel.

    METHODS read FOR READ
       keys FOR READ travel RESULT result.

    METHODS lock FOR LOCK
       keys FOR LOCK travel.

    METHODS rba_Booking FOR READ
       keys_rba FOR READ travel\_Booking FULL result_requested RESULT result LINK association_links.

    METHODS cba_Booking FOR MODIFY
       entities_cba FOR CREATE travel\_Booking.

ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.

  METHOD get_instance_features.
    READ ENTITIES OF  zi_travel_u IN LOCAL MODE
    ENTITY travel
    FIELDS ( TravelId Status )
    WITH CORRESPONDING #( keys )
    RESULT DATA(ls_travel).

    result = VALUE #( FOR travel IN ls_travel  ( TravelId = travel-TravelId
                                                  %assoc-_booking = COND #( WHEN travel-Status = 'B' OR travel-Status = 'X'
                                                                            THEN if_abap_behv=>fc-o-disabled
                                                                            ELSE if_abap_behv=>fc-o-enabled ) ) ).


  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.

    DATA : ls_travel_in    TYPE /dmo/travel,
           ls_travel_out   TYPE /dmo/travel,
           lt_message      TYPE /dmo/t_message,
           is_failed_added TYPE abap_boolean,
           fail            TYPE  RESPONSE FOR FAILED  zi_travel_u,
           report          TYPE RESPONSE FOR FAILED  zi_travel_u
           .

    LOOP AT entities INTO DATA(ls_entity).

      ls_travel_in = CORRESPONDING #( ls_entity  MAPPING FROM ENTITY USING CONTROL ).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_CREATE'
        EXPORTING
          is_travel         = CORRESPONDING /dmo/s_travel_in( ls_travel_in )
*         it_booking        =
*         it_booking_supplement =
          iv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-late
        IMPORTING
          es_travel         = ls_travel_out
*         et_booking        =
*         et_booking_supplement =
          et_messages       = lt_message.
      mapping_message(
EXPORTING
cid = ls_entity-%cid
lt_messages = lt_message
IMPORTING
failed_added = is_failed_added
CHANGING
fail = failed-travel
report = reported-travel ).

      IF is_failed_added = abap_false.
        INSERT VALUE #( %cid = ls_entity-%cid
                                     TravelID  = ls_travel_out-travel_id
                              ) INTO  TABLE mapped-travel.
      ENDIF.


    ENDLOOP.

  ENDMETHOD.

  METHOD update.
    DATA: ls_travel   TYPE /dmo/travel,
          ls_travelx  TYPE /dmo/s_travel_inx,
          lt_messages TYPE /dmo/t_message
          ,
          is_fail     TYPE abap_boolean.


    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entites>).

      ls_travel = CORRESPONDING #( <fs_entites> MAPPING FROM ENTITY ).
      ls_travelx-travel_id = <fs_entites>-TravelId.
      ls_travelx-_intx = CORRESPONDING #( <fs_entites> MAPPING FROM ENTITY    ).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
        EXPORTING
          is_travel   = CORRESPONDING /dmo/s_travel_in( ls_travel )
          is_travelx  = ls_travelx
*         it_booking  =
*         it_bookingx =
*         it_booking_supplement  =
*         it_booking_supplementx =
        IMPORTING
          et_messages = lt_messages.

      mapping_message(
        EXPORTING
          cid          = <fs_entites>-%cid_ref
           TravelId = <fs_entites>-TravelId
          lt_messages  = lt_messages
        IMPORTING
          failed_added = is_fail
        CHANGING
          fail         = failed-travel
          report       = reported-travel
      ).

      INSERT VALUE #( %cid = <fs_entites>-%cid_ref
                                    TravelID  = ls_travel-travel_id
                             ) INTO  TABLE mapped-travel.


    ENDLOOP.

  ENDMETHOD.

  METHOD delete.
    DATA: lt_message TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_DELETE'
        EXPORTING
          iv_travel_id = <fs_key>-TravelId
        IMPORTING
          et_messages  = lt_message.
      mapping_message(
        EXPORTING
          cid          = <fs_key>-%cid_ref
          travelid     = <fs_key>-TravelId
          lt_messages  = lt_message
*      IMPORTING
*        failed_added =
        CHANGING
          fail         = failed-travel
          report       = reported-travel
      ).
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    DATA : ls_travel_out TYPE /dmo/travel,
           lt_message    TYPE /dmo/t_message.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_key>-TravelId
        IMPORTING
          es_travel    = ls_travel_out
*         et_booking   =
*         et_booking_supplement =
          et_messages  = lt_message.
      mapping_message(
        EXPORTING
          travelid     = <fs_key>-TravelId
          lt_messages  = lt_message
    IMPORTING
      failed_added = DATA(fail_added)
        CHANGING
          fail         = failed-travel
          report       = reported-travel
      ).
    ENDLOOP.
    IF fail_added = abap_false.
      INSERT CORRESPONDING #( ls_travel_out MAPPING TO ENTITY  ) INTO TABLE result.
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Booking.
    DATA: ls_travel_out TYPE /dmo/travel,
          ls_book_out   TYPE /dmo/t_booking,
          ls_message    TYPE /dmo/t_message,
          booking       LIKE LINE OF result.

    LOOP AT keys_rba ASSIGNING FIELD-SYMBOL(<fs_key>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_key>-TravelId
*         iv_include_buffer     = abap_true
        IMPORTING
          es_travel    = ls_travel_out
          et_booking   = ls_book_out
*         et_booking_supplement =
          et_messages  = ls_message.
      mapping_message(
        EXPORTING
*      cid          =
          travelid     = <fs_key>-TravelId
          lt_messages  = ls_message
        IMPORTING
          failed_added = DATA(failed_add)
        CHANGING
          fail         = failed-travel
          report       = reported-travel
      ).

      IF failed_add  = abap_false.
        LOOP AT ls_book_out ASSIGNING FIELD-SYMBOL(<fs_book>).
          INSERT VALUE  #( source-%key = <fs_key>-%key
                                         target-%tky = VALUE #( travelid = <fs_key>-TravelId
                                                                BookingId = <fs_book>-booking_id ) ) INTO TABLE association_links  .
          IF result_requested = abap_true.
            booking = CORRESPONDING #( <fs_book> MAPPING TO ENTITY ).
            INSERT booking INTO TABLE result.
          ENDIF.

        ENDLOOP.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD cba_Booking.
    DATA: ls_new_bookingout TYPE /dmo/t_booking,
          ls_messages       TYPE /dmo/t_message,
          ls_booking        TYPE  /dmo/booking,
          ls_new_booking    TYPE /dmo/t_booking,
          ls_book_message   TYPE /dmo/t_message.

    LOOP AT entities_cba ASSIGNING FIELD-SYMBOL(<fs_entities>).

      CALL FUNCTION '/DMO/FLIGHT_TRAVEL_READ'
        EXPORTING
          iv_travel_id = <fs_entities>-TravelId
*         iv_include_buffer     = abap_true
        IMPORTING
*         es_travel    =
          et_booking   = ls_new_bookingout
*         et_booking_supplement =
          et_messages  = ls_messages.

      mapping_message(
        EXPORTING
*        cid          =
          travelid     = <fs_entities>-TravelId
          lt_messages  = ls_messages
      IMPORTING
        failed_added = DATA(is_failed)
        CHANGING
          fail         = failed-travel
          report       = reported-travel
      ).


      IF is_failed = abap_true.


        LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<entities>).

          mapping_message_assc(

          EXPORTING
          cid = <entities>-%cid
          is_depend = abap_true
          ls_messages = ls_messages
          IMPORTING
          fail_added = DATA(book_fail)
          CHANGING
          book_fail  = failed-booking
          book_report = reported-booking
           ).

        ENDLOOP.


      ENDIF.



      DATA(bookingid) = VALUE #( ls_new_bookingout[ lines( ls_new_bookingout ) ]-booking_id OPTIONAL ).

      LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<fs_target>).
        ls_booking = CORRESPONDING #( <fs_target> MAPPING FROM ENTITY USING CONTROL ).
        bookingid  += 1.
        ls_booking-booking_id = bookingid.
        CALL FUNCTION '/DMO/FLIGHT_TRAVEL_UPDATE'
          EXPORTING
            is_travel   = VALUE /dmo/s_travel_in( travel_id = <fs_target>-TravelId )
            is_travelx  = VALUE /dmo/s_travel_inx( travel_id = <fs_target>-TravelId )
            it_booking  = VALUE /dmo/t_booking_in( ( CORRESPONDING #( ls_booking ) ) )
            it_bookingx = VALUE /dmo/t_booking_inx(
                                                   ( booking_id = ls_booking-booking_id
                                                      action_code = /dmo/if_flight_legacy=>action_code-create
                                                       )
                                                         )
          IMPORTING
            et_booking  = ls_new_booking
            et_messages = ls_book_message.


        mapping_message_assc(
          EXPORTING
            cid         = <fs_target>-%cid
            is_depend   = abap_true
            ls_messages = ls_book_message
          IMPORTING
            fail_added  = book_fail
          CHANGING
            book_fail   = failed-booking
            book_report = reported-booking
        ).

        IF book_fail = abap_false.
          INSERT VALUE #(  %cid = <fs_target>-%cid
                                      TravelId = <fs_entities>-TravelId
                                      BookingId = ls_booking-booking_id  ) INTO TABLE mapped-booking .
        ENDIF.
      ENDLOOP.




    ENDLOOP.




  ENDMETHOD.


  METHOD mapping_message.
    failed_added = abap_false.
    LOOP AT lt_messages INTO DATA(ls_message).
      IF ls_message-msgty = 'E' OR ls_message-msgty = 'A'.
        APPEND VALUE #(  %cid = cid
                        travelid = travelid
                  %fail-cause = zcl_fail_cause=>get_cause_from_message(
                                  msgid        = ls_message-msgid
                                  msgno        = ls_message-msgno
                                  is_dependend = abap_false
                                )
                           ) TO fail.
        failed_added = abap_true.
      ENDIF.
      report = VALUE #( ( %cid = cid
      travelid = travelid
                     %msg = new_message(
                              id       = ls_message-msgid
                              number   = ls_message-msgno
                              severity = if_abap_behv_message=>severity-error
                                  v1       = ls_message-msgv1
                                  v2       = ls_message-msgv2
*                                  v3       =
*                                  v4       =
                            ) ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD mapping_message_assc.
    fail_added = abap_false.
    ASSERT cid IS NOT INITIAL.
    LOOP AT ls_messages ASSIGNING FIELD-SYMBOL(<fs_message>).
      IF <fs_message>-msgty = 'E' OR <fs_message>-msgty = 'A'.
        fail_added = abap_true.
        APPEND VALUE #(   %cid = cid
                                %fail-cause = zcl_fail_cause=>get_cause_from_message(
                                        msgid        = <fs_message>-msgid
                                        msgno        = <fs_message>-msgno
                                        is_dependend = is_depend )

        ) TO book_fail.


        APPEND VALUE #( %cid = cid
                        %msg = new_message(
                                 id       = <fs_message>-msgid
                                 number   = <fs_message>-msgno
                                 severity = if_abap_behv_message=>severity-error
                                 v1       = <fs_message>-msgv1
                                 v2       = <fs_message>-msgv2
*                           v3       =
*                           v4       =
                               ) ) TO book_report.
      ENDIF.



    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
