#!/bin/bash

function validateInput {
  # DO NOT ECHO ANYTHING EXCEPT RETURNING VALUE
  # $1 regex to accept
  # $2 input
  local validateInputReturn


  if [[ "$2" =~ $1 ]]  &&  [[ ! -z $2 ]];
  then
    validateInputReturn=true
  else
    validateInputReturn=false
  fi

  # Returning value
  echo $validateInputReturn
}

