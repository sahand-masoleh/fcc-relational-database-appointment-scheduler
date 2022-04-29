#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "How may I help you?\n" 

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo  "$SERVICE_ID) $SERVICE_NAME"
    done

  echo -e "0) Exit"

  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    0) EXIT ;;
    *) CHOOSE_SERVICE $SERVICE_ID_SELECTED ;;
  esac
}

CHOOSE_SERVICE () {
  if [[ -z $1 ]]
  then
    MAIN_MENU "Please enter a valid number"
  fi

  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
  then
    MAIN_MENU "Please enter a valid number"
  else 
    ASK_NUMBER
  fi
}

ASK_NUMBER() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "What is your phone number?\n"
  read CUSTOMER_PHONE
  if [[ -z $CUSTOMER_PHONE ]]
  then
    ASK_NUMBER "Please enter a valid phone number"
  fi

  read CUSTOMER_ID BAR CUSTOMER_NAME <<< $($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "I could not find a record for that number, what is your name?\n"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi
  ASK_TIME
}

ASK_TIME() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ +//')
  
  echo -e "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?\n"
  read SERVICE_TIME
  if [[ -z $SERVICE_TIME ]]
  then
    ASK_TIME "Please enter a valid time"
  fi

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID)")
  echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

EXIT() {
  echo -e "Thank you for choosing us.\n"
}

MAIN_MENU