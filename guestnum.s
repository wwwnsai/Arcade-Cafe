.data
secret_number:   .int 0   @ The 4-digit secret number
player_guess:    .int 0   @ The player's guess
remaining_guesses: .int 5 @ Number of remaining guesses

.text
.global _start

_start:
    @ Initialize the secret number (you can set your own)
    ldr r0, =secret_number
    mov r1, #1234  @ Set the secret number to 1234
    str r1, [r0]

game_loop:
    @ Check if the player has any remaining guesses
    ldr r0, =remaining_guesses
    ldr r1, [r0]
    cmp r1, #0
    beq game_over

    @ Prompt the player for a guess
    ldr r0, =prompt_message
    bl printf

    @ Get the player's input (guess)
    ldr r0, =player_guess
    bl scanf

    @ Check the player's guess
    ldr r0, =player_guess
    ldr r1, [r0]
    ldr r0, =secret_number
    ldr r2, [r0]
    bl check_guess

    @ Decrement the remaining guesses
    ldr r0, =remaining_guesses
    ldr r1, [r0]
    sub r1, r1, #1
    str r1, [r0]

    @ Display the number of correct digits and positions
    ldr r0, =result_message
    bl printf

    @ Repeat the game loop
    b game_loop

game_over:
    @ Display a game over message
    ldr r0, =lose_message
    bl printf

exit:
    mov r7, #1   @ Exit syscall
    mov r0, #0   @ Exit status
    swi 0

.data
prompt_message:  .asciz "Enter a 4-digit number: "
result_message:  .asciz "Correct digits: %d, Correct positions: %d\n"
lose_message:    .asciz "You're out of guesses! The secret number was 1234.\n"

.text
.global printf, scanf, check_guess

check_guess:
    @ Check the player's guess and calculate correct digits and positions
    push {r4, lr}      @ Preserve r4 and return address
    mov r3, #0         @ Correct digits
    mov r4, #0         @ Correct positions

check_loop:
    cmp r1, #0
    beq check_done

    ldr r6, [r0]       @ Load the secret number
    ldr r5, [r1]       @ Load the player's guess

    and r8, r6, #0xF   @ Extract the rightmost digit of the secret number
    and r9, r5, #0xF   @ Extract the rightmost digit of the player's guess

    cmp r8, r9
    beq inc_correct_position

    tst r6, r9
    beq no_match

inc_correct_digit:
    add r3, r3, #1
    and r6, r6, r6, lsr #4
    and r5, r5, r5, lsr #4
    b check_loop

inc_correct_position:
    add r4, r4, #1
    and r6, r6, r6, lsr #4
    and r5, r5, r5, lsr #4

no_match:
    and r6, r6, r6, lsr #4
    and r5, r5, r5, lsr #4
    b check_loop

check_done:
    @ Display the result message
    mov r0, r3
    mov r1, r4
    pop {r4, pc}      @ Restore r4 and return

