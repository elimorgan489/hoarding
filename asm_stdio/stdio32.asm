; stdio32.asm
%define putchar     putchar32
%define printstr    printstr32
%define printhex    printhex32
%define printint    printint32

section .text

; _printf :: String -> [Word16] -> Bool
_printf32:
    .init:
        push ebx
        push ecx
        push esi

        push ebp
        mov ebp,esp
        add ebp,(3*sz)

        mov eax,[ebp+(2*sz)]
        mov esi,eax
        xor ebx,ebx
        xor ecx,ecx
        inc ecx
        clc

    .loop:
        mov eax,0x00
        lodsb
        jc .special

        cmp al,'%'
        je .percent
        or al,al
        jz .end

        push eax
        call putchar
        clc
        jmp .loop

    .percent:
        stc
        jmp .loop

    .special:
        push eax
        mov ax,0x02
        add ax,cx
        mov bx,sz
        mul bl
        mov bx,ax
        mov eax,[ebp+ebx]
        pop ebx
        push eax
        inc cx

        cmp bl,'%'
        je .percent2
        cmp bl,'d'
        je .int
        cmp bl,'x'
        je .hex
        cmp bl,'s'
        je .str
        cmp bl,'c'
        je .char
        pop eax
        jmp .spcend

    .percent2:
        pop eax
        push ebx
        call putchar
        jmp .spcend
    .int:
        call printint
        jmp .spcend

    .hex:
        call printhex
        jmp .spcend

    .str:
        call printstr
        jmp .spcend

    .char:
        call putchar
    
    .spcend:
        clc
        jmp .loop

    .end:
        sub ebp,(3*sz)
        mov esp,ebp
        pop ebp

        pop esi
        pop ecx
        pop ebx

        mov eax,0x01

        ret









; exit :: Void -> Void
exit32:
    push ebp
    mov ebp,esp

    mov eax,0x01
    xor ebx,ebx
    int 0x80

    mov esp,ebp
    pop ebp

    ret

; putchar :: Char -> Bool
putchar32:
    push ebx
    push ecx
    push edx

    push ebp
    mov ebp,esp
    add ebp,(3*sz)

    mov eax,[ebp+(2*sz)]
    mov ecx,buf
    mov byte [ecx],al

    mov eax,0x04
    mov ebx,0x01
    mov edx,ebx
    int 0x80

    sub ebp,(3*sz)
    mov esp,ebp
    pop ebp

    pop edx
    pop ecx
    pop ebx

    mov eax,0x01

    ret

; printstr :: String -> Bool
printstr32:
    push esi
    push ebp
    mov ebp,esp
    add ebp,(1*sz)

    mov eax,[ebp+(2*sz)]
    mov esi,eax

.loop:
    xor eax,eax
    mov byte al,[esi]
    or al,al
    jz .done

    push eax
    call putchar
    inc esi
    jmp .loop

.done:
    sub ebp,(1*sz)
    mov esp,ebp
    pop ebp
    pop esi
    mov eax,0x01

    ret

; printint :: Word16 -> Bool
printint32:
    push ebx
    push ecx
    push edx
    push edi

    push ebp
    mov ebp,esp
    add ebp,(4*sz)

    mov eax,buf
    mov edi,eax
    mov eax,[ebp+(2*sz)]
    mov ecx,0x06
    add edi,ecx
    mov byte [edi],0x00

    dec ecx
    xor ebx,ebx
    xor edx,edx

.loop:
    dec edi
    mov bx,0x0a
    div bx
    call .digit
    xor dx,dx
    loop .loop

    xor eax,eax
    mov ecx,0x04

 .zeroloop:
    mov byte al,[edi]
    cmp al,0x30
    jne .pr
    inc edi
    loop .zeroloop

.pr:
    mov eax,edi
    push eax
    call printstr

    sub ebp,(4*sz)
    mov esp,ebp
    pop ebp

    pop edi
    pop edx
    pop ecx
    pop ebx

    mov eax,0x01

    ret

.digit:
    push ebp
    mov ebp,esp

    add dl,0x30
    mov byte [edi],dl

    mov esp,ebp
    pop ebp
    ret

; printhex :: Word16 -> Bool
printhex32:
    push ebp
    mov ebp,esp
    mov eax,[ebp+(2*sz)]

 .dig01:
    and ax,0xf000
    shr ax,12
    call .digit

 .dig02:
    mov eax,[ebp+(2*sz)]
    and ax,0x0f00
    shr ax,8
    call .digit

 .dig03:
    mov eax,[ebp+(2*sz)]
    and ax,0x00f0
    shr ax,4
    call .digit

 .dig04:
    mov eax,[ebp+(2*sz)]
    and ax,0x000f
    call .digit

 .end:
    mov esp,ebp
    pop ebp
    mov eax,0x01

    ret

 .digit:
    push ebp
    mov ebp,esp

    cmp al,0x09
    jg .hexdigit
    add al,0x30
    jmp .enddigit

  .hexdigit:
    add al,0x57

  .enddigit:
    push eax
    call putchar

    mov esp,ebp
    pop ebp

    ret

section .data

data:
    nl  equ 0x000a
    buf times 64 db 0x00
