CREATE OR REPLACE PACKAGE HOTEL IS
    FUNCTION IS_RESERVATION_VALID(
        ARG_ROOM_NUMBER NUMBER,
        ARG_START_DATE DATE,
        ARG_END_DATE DATE
    ) RETURN BOOLEAN;
    
    FUNCTION CALCULATE_MONTHLY_INCOME(
        MONTH_NUMBER NUMBER,
        YEAR_NUMBER NUMBER
    ) RETURN NUMBER;
    
    FUNCTION GET_DISCOUNT_ID(
        ARG_CLIENT_ID NUMBER
    ) RETURN NUMBER;
    
    PROCEDURE RESERVE(
        ARG_CLIENT_ID NUMBER,
        ARG_ROOM_TYPE NUMBER,
        ARG_START_DATE DATE, 
        ARG_END_DATE DATE,
        ARG_DISCOUNT_ID NUMBER
    );
    
    PROCEDURE BUY_OFFER(
        ARG_CLIENT_ID NUMBER,
        ARG_OFFER_ID NUMBER,
        ARG_START_DATE DATE,
        ARG_END_DATE DATE
    );
END HOTEL;