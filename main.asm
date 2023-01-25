bits 64
global _start

section .data
rows: equ 5
cols: equ 5
empty: equ 'O'
nonEmpty: equ 'X'
errorMsg: db "Error!"
errorMsgLen: equ $ - errorMsg
newLine: db 0x0A

section .bss
grid: resb rows * cols
nextGrid: resb rows * cols
tmp: resb 1

section .text
_start:
    call resetGrids

    call play

    call printTable


    jmp exit

play:
    call computeNextGen
    ret

computeNextGen:

    ret

applyRules:
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
    cmp bl, empty
    je .loop


    inc r10         ; cnt++

    cmp rcx, 9      ; i < 9
    jl .loop

    .end:
    ret

resetGrids:
    mov rcx, rows * cols
    .loopGrid:
        mov byte [grid + rcx - 1], empty
        dec rcx
        cmp rcx, 0
        jg .loopGrid

    mov rcx, rows * cols
    .loopNextGrid:
        mov byte [nextGrid + rcx - 1], empty
        dec rcx
        cmp rcx, 0
        jg .loopNextGrid

    ret

printTable:
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