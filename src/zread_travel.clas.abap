CLASS zread_travel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zread_travel IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  READ ENTITIES OF zi_travel_u
  ENTITY travel
  by \_booking
  ALL FIELDS
  WITH
  VALUE #( ( TravelId = '7721' ) )
  RESULT data(ls_travel).

  out->write( ls_travel ).
  ENDMETHOD.
ENDCLASS.
