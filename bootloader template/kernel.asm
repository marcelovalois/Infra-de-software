org 0x7e00
jmp 0x0000:start

data:
	playerPosition: dw 0
    tablePosition: dw 0
    enemyPosition: dw 0
    endGame: db "Game end", 0
    len equ endGame - $
	;Dados do projeto...

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov cl, 1
    mov bl, 0
    mov bh, 0
    mov word [playerPosition], 0x2000
    mov word [tablePosition], 1
    mov word [enemyPosition], 0
    call makegrid
    ;mov al, 51h
    ;call putchar
    
    
    ;Código do projeto...

makegrid:
    
    .waitForInput:
        call clear
        call enemyMovement
        ;int 16h com AH = 1 checa no buffer do teclado para ver se alguma tecla foi apertada, se
        ;o buffer estiver vazio ZF é setado, se não estiver vazio ZF é resetado.

        ;!* essa checagem não reseta o buffer, ou seja ao checar e verificar que uma tecla foi 
        ;apertada é necessario depois limpar ele.

        ;int 16h com AH = 0 pega o input não extendido e depois limpa o buffer.
        ;int 16h com AX = 0601h limpa todo o buffer.
        ;http://www.ctyme.com/intr/int-16.htm <- source
        mov ah, 1
        int 16h
        ;se ZF está setado não houve aperto de teclas, então pule para o desenho da grid.
        jz .gridBegin
        ;int 16h com AH = 0 espera por um input do teclado. o valor de AH recebido é comparado ao
        ;SCANCODE da tecla que foi apertada 
        ;https://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html
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
            jmp .gridBegin
        .sPressed:
            jmp .gridBegin
        .aPressed:
            shl word [playerPosition], 1
            jmp .gridBegin
        .dPressed:
            shr word [playerPosition], 1
            jmp .gridBegin

    .gridBegin:
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
       call delay
       jmp .waitForInput

delay:
    ;faz o computador esperar o tempo determinado por CXDX, o intervalo de tempo utilizado está em microsegundos
    mov CX, 7
    mov DX, 0xA120
    mov AH, 0x86
    int 15h
    ;http://www.ctyme.com/intr/int-15.htm <- source

clear:
    mov ah, 0
    mov al, 3
    int 10h
    ret

enemyMovement:
    ;movimento do inimigo é feito por operação bitwise, para andar para baixo temos que mover
    ;o bit setado pela mesma quantidade de colunas que a grid tem, nesse caso é 3.
    cmp word[enemyPosition], 0 
    je notSpawned
    jne spawned
    notSpawned:
        mov word[enemyPosition], 2
        ret
    spawned:
        shl word[enemyPosition], 3
        ret

collision:

    ;se o bit setado do playerPosition é igual ao bit setado do enemyPosition, houve colisão
    mov ax, [word playerPosition]
    cmp ax, word[enemyPosition]
    je collided
    jne notCollided
    notCollided:
        ret
    collided:
        call clear
        mov si, endGame
        call end1
        jmp $


putchar:
    ;se o bit setado do playerPosition é igual ao bit setado do tablePosition, coloque @ na tela
    mov ax, word[playerPosition]
    cmp ax, word[tablePosition]
    je playerEncountered
    jne playerNotEncountered

    ;se player não foi encontrado, faça o mesmo teste para inimigos
    playerNotEncountered:
        mov ax, word[enemyPosition]
        cmp ax, word[tablePosition]
        mov ah, 0Eh
        je enemyEncountered
        jne enemyNotEncountered

        enemyEncountered:
        mov al, 118
        int 10h
        ret

        enemyNotEncountered:
        mov al, 46
        int 10h
        ret

    playerEncountered:
        call collision
        mov ah, 0x0E
        mov al, 64
        int 10h
        ret


jumpLine:
    mov ah, 0x0E
    mov al, 10
    int 10h
    mov al, 13
    int 10h
    ret

;colocando a mensagem na tela.
end1:
    lodsb
    mov ah, 0xE
    mov bh, 0
    mov bl, 0xF
    int 10h

    cmp al, 0
    jne end1
    ret

