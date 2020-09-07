org 0x7e00
jmp 0x0000:start

data:
	playerPosition: dw 0
    tablePosition: dw 0
	;Dados do projeto...

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov cl, 1
    mov bl, 0
    mov bh, 0
    mov word [playerPosition], 1h
    mov word [tablePosition], 1
    call makegrid
    ;mov al, 51h
    ;call putchar
    
    
    ;Código do projeto...

makegrid:
    ;it waits for input, the value of AH is compared to the SCANCODE of the key released
    ;https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
    .waitForInput:
        xor ah, ah
        int 16h
        cmp ah, 0x11
        je .wPressed
        cmp ah, 0x1F
        je .sPressed
        cmp ah, 0x20
        je .aPressed
        cmp ah, 0x1E
        je .dPressed
        jmp .waitForInput
        .wPressed:
            ;call putchar
            ;call jumpLine
            call clear
            jmp .gridBegin
        .sPressed:
            ;call putchar
            ;call jumpLine
            call clear
            jmp .gridBegin
        .aPressed:
            ;call putchar
            ;call jumpLine
            call clear
            shl word [playerPosition], 1
            jmp .gridBegin
        .dPressed:
            ;call putchar
            ;call jumpLine
            call clear
            shr word [playerPosition], 1
            jmp .gridBegin
    .gridBegin:
       ;if it's in an even line, do space
       ;mov al, 124
       ;choose whether to use | or _
       ;put char in screen
       call putchar
       inc bl
       shl word[tablePosition], 1
       cmp  bl, 2
       jle .gridBegin
       call jumpLine
       mov bl, 0
       inc bh
       cmp bh, 4
       jle .gridBegin
       mov bh, 0 ;resetting bh
       mov cl, 1 ; resetting cl
       mov word[tablePosition], 1
       jmp .waitForInput

clear:
    mov ah, 0
    mov al, 3
    int 10h
    ret


putchar:
    ;this puts the char in the screen.
    mov ax, word[playerPosition]
    cmp ax, word[tablePosition]
    mov ah, 0eh
    je playerEncountered
    jne playerNotEncountered
    playerNotEncountered:
        mov al, 46
        int 10h
        ret
    playerEncountered:
        mov al, 64
        int 10h
        ret
jumpLine:
    mov ah, 0eh
    mov al, 10
    int 10h
    mov al, 13
    int 10h
    ret


jmp $