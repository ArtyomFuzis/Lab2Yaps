%include "colon.inc"
%ifndef WORDS_H
%define WORDS_H
section .data
root_dict:
colon "hello", node1
db "Hello world!!!", 0
colon "privet", node2
db "Privet mir!!!", 0
colon "key1", node3
db "val1", 0
colon "key2", node4
db "val2",0
colon "key3", node5
db "val3",0
colon "key4", node6
db "val4",0
%endif
