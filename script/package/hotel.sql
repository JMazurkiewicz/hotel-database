CREATE OR REPLACE PACKAGE BODY HOTEL IS
    FUNCTION IS_RESERVATION_VALID(
        ARG_ROOM_NUMBER NUMBER,
        ARG_START_DATE DATE,
        ARG_END_DATE DATE
    ) RETURN BOOLEAN AS  
    BEGIN
        FOR RESERVATION IN (SELECT RESERVATION_ID, START_DATE, END_DATE FROM RESERVATIONS WHERE ROOM_NUMBER = ARG_ROOM_NUMBER)
        LOOP
            IF(NOT(RESERVATION.START_DATE >= ARG_END_DATE OR ARG_START_DATE >= RESERVATION.END_DATE)) THEN
                RETURN FALSE;
            END IF;
        END LOOP;
        RETURN TRUE;
    END IS_RESERVATION_VALID;
    
    FUNCTION CALCULATE_MONTHLY_INCOME(
        MONTH_NUMBER NUMBER,
        YEAR_NUMBER NUMBER
    ) RETURN NUMBER AS
        INCOME_FROM_RESERVATIONS NUMBER;
        INCOME_FROM_OFFERS NUMBER;
    BEGIN
        SELECT SUM(ESTIMATED_COST)
            INTO INCOME_FROM_RESERVATIONS
            FROM RESERVATIONS
            WHERE
                EXTRACT(MONTH FROM START_DATE) = MONTH_NUMBER AND
                EXTRACT(YEAR FROM START_DATE) = YEAR_NUMBER;
        SELECT SUM(ESTIMATED_COST)
            INTO INCOME_FROM_OFFERS
            FROM BOUGHT_OFFERS
            WHERE
                EXTRACT(MONTH FROM START_DATE) = MONTH_NUMBER AND
                EXTRACT(YEAR FROM START_DATE) = YEAR_NUMBER;
        RETURN INCOME_FROM_RESERVATIONS + INCOME_FROM_OFFERS;
    END CALCULATE_MONTHLY_INCOME;
    
    FUNCTION GET_DISCOUNT_ID(
        ARG_CLIENT_ID NUMBER
    ) RETURN NUMBER AS
        CLIENT_DOJ DATE;
        YEARS_PASSED NUMBER;
    BEGIN
        SELECT DATE_OF_JOINING INTO CLIENT_DOJ
            FROM CLIENTS
            WHERE CLIENT_ID = ARG_CLIENT_ID;
        YEARS_PASSED := FLOOR(MONTHS_BETWEEN(SYSDATE, CLIENT_DOJ) / 12);
        IF(YEARS_PASSED >= 10) THEN
            RETURN 2; -- gold client if >=10 years
        ELSIF(YEARS_PASSED >= 5) THEN
            RETURN 1; -- long-term-client if >=5 years but <10
        END IF;
        RETURN NULL;
    END;
    
    PROCEDURE RESERVE(
        ARG_CLIENT_ID NUMBER,
        ARG_ROOM_TYPE NUMBER,
        ARG_START_DATE DATE, 
        ARG_END_DATE DATE,
        ARG_DISCOUNT_ID NUMBER
    ) AS
        GRANTED_DISCOUNT NUMBER := ARG_DISCOUNT_ID;
    BEGIN
        IF(GRANTED_DISCOUNT IS NULL) THEN
            GRANTED_DISCOUNT := GET_DISCOUNT_ID(ARG_CLIENT_ID);
        END IF;
        FOR POSSIBLE_ROOM IN (SELECT ROOM_NUMBER FROM ROOMS WHERE TYPE_ID = ARG_ROOM_TYPE)
        LOOP
            IF(IS_RESERVATION_VALID(POSSIBLE_ROOM.ROOM_NUMBER, ARG_START_DATE, ARG_END_DATE)) THEN
                INSERT INTO RESERVATIONS (START_DATE, END_DATE, CLIENT_ID, ROOM_NUMBER, DISCOUNT_ID)
                    VALUES (ARG_START_DATE, ARG_END_DATE, ARG_CLIENT_ID, POSSIBLE_ROOM.ROOM_NUMBER, GRANTED_DISCOUNT);
                RETURN;
            END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Brak wolnych pokoi tego typu w podanym terminie.');
    END;
    
    PROCEDURE BUY_OFFER(
        ARG_CLIENT_ID NUMBER,
        ARG_OFFER_ID NUMBER,
        ARG_START_DATE DATE,
        ARG_END_DATE DATE
    ) AS
    BEGIN
        INSERT INTO BOUGHT_OFFERS (START_DATE, END_DATE, CLIENT_ID, OFFER_ID)
            VALUES (ARG_START_DATE, ARG_END_DATE, ARG_CLIENT_ID, ARG_OFFER_ID);
    END;
END HOTEL;
