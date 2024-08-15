#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # show available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  echo -e "\nWe offer the following services:\n"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done    
  
  # ask for service
  echo -e "\nWhich service would you like to book?\n"
  read SERVICE_ID_SELECTED

  # check if input matches any of the service ids
  ALL_SERVICE_IDS=$($PSQL "SELECT service_id FROM services")
  if echo "$ALL_SERVICE_IDS" | grep -q -w "$SERVICE_ID_SELECTED";
  then
    # get customer info
    echo -e "\nPlease enter your phone number."
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nPlease enter your name."
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else
      # get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    # get service time
    echo -e "\nWhat time would you like to book your appointment?"
    read SERVICE_TIME
    # insert new appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    # send to booking menu
    MAIN_MENU "Please select a valid service id."
  fi
}

MAIN_MENU
