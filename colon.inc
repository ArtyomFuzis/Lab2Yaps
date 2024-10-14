%ifndef COLON_H
%define COLON_H
%define OF_VA 16 ; offset value address
%define OF_KA 8 ; offset key address
%define OF_PA 0 ; offset prev address
%define PREV_START_KEY 0x0
%define PREV_KEY PREV_START_KEY
%macro colon 2

%2: 
.addrs
dq  PREV_KEY
dq .key
dq .value
.key
db %1, 0
.value
%define PREV_KEY %2
%endmacro
%endif
