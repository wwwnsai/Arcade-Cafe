.global _start

.section .data
    player_choice: .word 0    @ Player's choice (0 for rock, 1 for paper, 2 for scissors)
    computer_choice: .word 0  @ Computer's choice (0 for rock, 1 for paper, 2 for scissors)
    message_prompt: .asciz "Enter your choice (0 for rock, 1 for paper, 2 for scissors): "
    message_win: .asciz "You win!\n"
    message_lose: .asciz "Computer wins!\n"
    message_draw: .asciz "It's a draw!\n"

.section .text
_start:
    @ Print the game prompt
    mov r7, 4                   @ sys_write system call number
    mov r0, 1                   @ file descriptor STDOUT
    ldr r1, =message_prompt      @ pointer to the message
    ldr r2, =56                  @ message length
    svc 0

    @ Read user input (player's choice)
    mov r0, 0                   @ file descriptor STDIN
    ldr r1, =player_choice
    mov r2, #4                  @ buffer size
    mov r7, 0x3                 @ sys_read system call number
    svc 0

    @ Convert user input to integer
    ldr r1, =player_choice
    bl  atoi

    @ Get a random number for computer's choice (0 for rock, 1 for paper, 2 for scissors)
    mov r1, r0                  @ Use the current time as a seed
    mov r7, 0x0                 @ sys_random system call number
    svc 0
    mov r2, #3                  @ Set the maximum random number value (0, 1, or 2)
    bl  modulo_random

    @ Determine the winner
    ldr r3, =computer_choice
    str r0, [r3]                @ Store computer's choice
    cmp r0, r4                  @ Compare player's choice with computer's choice
    beq _draw                   @ Branch to draw if equal
    blt _player_wins            @ Branch to player wins if less
    b _computer_wins            @ Branch to computer wins

_player_wins:
    @ Print "You win!" message
    mov r7, 4
    mov r0, 1
    ldr r1, =message_win
    ldr r2, =9
    svc 0
    b _exit

_computer_wins:
    @ Print "Computer wins!" message
    mov r7, 4
    mov r0, 1
    ldr r1, =message_lose
    ldr r2, =16
    svc 0
    b _exit

_draw:
    @ Print "It's a draw!" message
    mov r7, 4
    mov r0, 1
    ldr r1, =message_draw
    ldr r2, =13
    svc 0
    b _exit

_exit:
    @ Exit the program
    mov r7, 1
    mov r0, 0
    svc 0

.modulo_random:
    @ Calculate random number mod n (r0 = random number, r2 = n)
    mov r3, r1                  @ Copy seed to r3
    mov r4, #1103515245         @ Multiplier used in glibc random() function
    mul r3, r3, r4              @ r3 = seed * multiplier
    add r3, r3, #12345          @ r3 = seed * multiplier + increment
    mov r4, #4294967296         @ 2^32 (maximum value of a 32-bit unsigned integer)
    udiv r3, r3, r4             @ r3 = (seed * multiplier + increment) / 2^32
    mov r4, r2                  @ Modulo divisor (n)
    umod r0, r3, r4             @ r0 = (seed * multiplier + increment) % n
    bx lr                       @ Return from the subroutine

.atoi:
    @ Convert string to integer
    mov r2, #0                  @ Initialize result to 0
.loop:
    ldrb r3, [r1], #1           @ Load next byte of string into r3, move pointer
    cmp r3, #0                  @ Check for null terminator
    beq .done                   @ If null terminator, conversion is done
    sub r3, r3, #'0'            @ Convert ASCII character to integer ('0' -> 0, '1' -> 1, ..., '9' -> 9)
    mul r2, r2, #10             @ Multiply result by 10 (shift left by 1 and add a zero)
    add r2, r2, r3              @ Add the new digit to the result
    b .loop                     @ Repeat the loop for the next character
.done:
    mov r0, r2                  @ Return the result in r0
    bx lr                       @ Return from the subroutine
