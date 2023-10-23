.section .data
.global _start

_start:
    mov r0, #0        @ Initialize color (0 for black, 1 for white)
    mov r1, #0        @ Initialize position
    mov r2, #1        @ Initialize direction (1 for right, -1 for left)

loop:
    @ Set the color (0 for black, 1 for white)
    cmp r0, #0
    beq set_black
    b set_white

set_black:
    @ Set the background color to black (You can't directly control the background color using syscalls)
    mov r3, #0
    b set_color

set_white:
    @ Set the background color to white (You can't directly control the background color using syscalls)
    mov r3, #1

set_color:
    @ Print a "ping" or "pong" at the current position
    mov r7, #4        @ syscall number for write (to stdout)
    ldr r4, =ping_pong
    ldr r5, =5
    svc 0

    @ Delay to make the movement visible
    bl delay

    @ Move the position
    add r1, r1, r2

    @ Check if it reached the edge
    cmp r1, #0
    beq change_direction
    cmp r1, #10
    beq change_direction

    b loop

change_direction:
    @ Change the direction
    neg r2, r2
    b loop

delay:
    @ Simple delay loop
    mov r6, #0
delay_loop:
    add r6, r6, #1
    cmp r6, #100000
    bne delay_loop
    bx lr

.section .data
ping_pong:
    .ascii "Ping\n"
    .ascii "Pong\n"
