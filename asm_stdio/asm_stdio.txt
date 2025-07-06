bits 32
%include "stdio.h"
global _start
section .text

_start:
	printf "Number seven is %d and 0x%x.", 7, 7

	mov ebx,0xcccc
	printf "EBX: 0x%x", ebx

exit:
	mov eax,0x01
	xor ebx,ebx
	int 0x80

