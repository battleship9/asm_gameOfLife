bits 64

section .text
printTable:
    push rax
    push rbx
    push rcx
    push rdx
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
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

resetGrids:
    push rcx

    mov rcx, rows * cols
    .loop:
        dec rcx
        mov byte [grid + rcx], dead
        mov byte [nextGrid + rcx], dead

        cmp rcx, 0
        jg .loop

    pop rcx
    ret

countNeighbors:     ; in: rdi, rsi; out: r10

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

    push rax
    push rbx
    push rcx
    push rdx
    push r11
    push r12
    push r13

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
    pop r13
    pop r12
    pop r11
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

copyAndResetGrid:
    push rax
    push rcx

    mov rcx, rows * cols
    .loop:
        dec rcx

        mov al, [nextGrid + rcx]
        mov byte [grid + rcx], al
        mov byte [nextGrid + rcx], dead

        cmp rcx, 0
        jg .loop

    pop rcx
    pop rax
    ret

applyRules:
    push rax
    push rbx
    push rcx
    push rdi
    push rsi
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
    pop rsi
    pop rdi
    pop rcx
    pop rbx
    pop rax
    ret

computeNextGen:
    push r10
    push r11

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

    pop r11
    pop r10
    ret