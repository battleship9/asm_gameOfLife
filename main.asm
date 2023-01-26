bits 64
global _start

section .data
rows: equ 30
cols: equ 30
dead: equ '.'
alive: equ 'X'
errorMsg: db "Error!"
errorMsgLen: equ $ - errorMsg
newLine: db 0x0A
grid: db '.X..............................X...........................XXX............................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................................XXX......................................................................................'
nextGrid: times rows * cols db '.'

section .bss
; grid: resb rows * cols
; nextGrid: resb rows * cols
tmp: resb 1

section .text
_start:
    call play

    jmp exit

play:
    times 30 call computeNextGen
    ; call computeNextGen
    ; jmp play
    ret

computeNextGen:
    xor r10, r10
    xor r11, r11

    .loop1:

        .loop2:
        call applyRules

        inc r11
        cmp r11, cols
        jl .loop2

    mov r11, 0
    inc r10
    cmp r10, rows
    jl .loop1

    call copyAndResetGrid

    call printTable

    ret

applyRules:
    push r10
    push r11

    mov rdi, r10
    mov rsi, r11

    call countNeighbors

    mov rax, cols
    mov rbx, rdi
    mul rbx
    add rax, rsi

    mov cl, [grid + rax]
    cmp cl, alive
    jne .else
        cmp r10, 2
        jl .do1

        cmp r10, 2
        je .do2
        cmp r10, 3
        je .do2

        cmp r10, 3
        jg .do3

        jmp .skip

    .else:
        cmp r10, 3
        jne .skip

        mov [nextGrid + rax], byte alive
        jmp .skip

    .do1:
    mov [nextGrid + rax], byte dead
    jmp .skip

    .do2:
    mov [nextGrid + rax], byte alive
    jmp .skip

    .do3:
    mov [nextGrid + rax], byte dead

    .skip:
    .end:

    pop r11
    pop r10
    ret

copyAndResetGrid:
    mov rcx, rows * cols
    .loop:
        dec rcx

        mov al, [nextGrid + rcx]
        mov byte [grid + rcx], al
        mov byte [nextGrid + rcx], dead

        cmp rcx, 0
        jg .loop

    ret

countNeighbors:

    ; for(i=0; i<9; i++) {
    ;     dx = i/3 - 1
    ;     dy = i%3 - 1
    ;     cpos = {x:pos.x+dx, y:pos.y+dy}
    ;     if(dx==0&&dy==0) continue
    ;     if(!inbounds(cpos) continue
    ;     if(!isset(cpos)) continue
    ;     cnt++
    ; }

    ; rdi = row
    ; rsi = col

    push rbx
    push rcx

    xor r10, r10    ; cnt = 0
    xor rcx, rcx    ; i = 0

    .loop:
    xor rdx, rdx    ; required for division

    mov rax, rcx
    mov rbx, 3
    div rbx
    mov r11, rax
    sub r11, 1      ; dx
    mov r12, rdx
    sub r12, 1      ; dy

    mov rax, cols
    mov rbx, rdi
    add rbx, r12
    mul rbx         ; cpos y

    mov r13, rsi
    add r13, r11    ; cpos x


    inc rcx         ; i++

    cmp rcx, 9      ; make sure it won't run forever
    jg .end


    cmp r13, 0
    jl .loop

    cmp r13, cols
    jge .loop


    add rax, r13    ; cpos


    cmp r11, 0      ; dx == 0
    jne .skip
    cmp r12, 0      ; dy == 0
    je .loop

    .skip:


    cmp rax, 0      ; inbounds
    jl .loop

    cmp rax, rows * cols    ; inbounds
    jge .loop

    mov bl, [grid + rax]   ; is alive  ; todo fix
    cmp bl, dead
    je .loop


    inc r10         ; cnt++

    cmp rcx, 9      ; i < 9
    jl .loop

    .end:
    pop rcx
    pop rbx
    ret

resetGrids:
    mov rcx, rows * cols
    .loop:
        dec rcx
        mov byte [grid + rcx], dead
        mov byte [nextGrid + rcx], dead

        cmp rcx, 0
        jg .loop

    ret

printTable:
    push r10

    xor r10, r10    ; rows counter

    .loop:
        mov rax, cols
        mul r10
        add rax, grid
        mov rcx, rax

        mov rax, 4
        mov rbx, 1
        mov rdx, cols
        int 80h

        mov rax, 4
        mov rbx, 1
        mov rcx, newLine
        mov rdx, 1
        int 80h

        inc r10

        cmp r10, rows
        jl .loop

    mov rax, 4
    mov rbx, 1
    mov rcx, newLine
    mov rdx, 1
    int 80h

    pop r10
    ret

error:
    mov rax, 4
    mov rbx, 1
    mov rcx, errorMsg
    mov rdx, errorMsgLen
    int 80h

exit:
    mov rax, 1
    int 80h