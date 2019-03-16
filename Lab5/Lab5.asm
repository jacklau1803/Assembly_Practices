##########################################################################
# Created by: Liu, Jack
# dliu34
# 15 March 2019
#
# Assignment: Lab 5: Subroutines
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: In this lab, you will learn how to implement subroutines and manage data on the stack.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################
.data
	prompt00:	.asciiz	"\nDo you want to (E)ncrypt, (D)ecrypt, or e(X)it? "
	errmsg:		.asciiz	"Invalid input: Please input E, D, or X.\n"
	result_msg:	.asciiz "\nHere is the encrypted and decrypted string\n"
	en_msg:		.asciiz "<Encrypted> "
	de_msg:		.asciiz "<Decrypted> "
	newline:	.asciiz "\n"
	char:		.space 2
	key:		.space 100
	str:		.space 100
	result:		.space 100
.text
#helper function
return:
	lw 	$ra, 0($sp)
	addiu 	$sp, $sp, 4
	jr	$ra
error_input:
	la	$a0, errmsg
	li	$v0, 4
	syscall
	la	$a0, prompt00
	li	$a1, 0
	j	give_prompt
	
#--------------------------------------------------------------------
# give_prompt
#
# This function should print the string in $a0 to the user, store the user’s input in
# an array, and return the address of that array in $v0. Use the prompt number in $a1
# to determine which array to store the user’s input in. Include error checking for
# the first prompt to see if user input E, D, or X if not print error message and ask
# again.
#
# arguments: $a0 - address of string prompt to be printed to user
# $a1 - prompt number (0, 1, or 2)
#
# note: prompt 0: Do you want to (E)ncrypt, (D)ecrypt, or e(X)it?
# prompt 1: What is the key?
# prompt 2: What is the string?
#
# return: $v0 - address of the corresponding user input data
#--------------------------------------------------------------------
give_prompt:
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	#Print prompt0
	li	$v0, 4
	syscall
	
	#branch based on prompt number
	beqz	$a1, letter
	b	string
	
	letter:
		la	$a0, char
		li	$a1, 100
		li	$v0, 8
		syscall
		move 	$v0, $a0
		lb	$t0, 0($v0)
		beq	$t0, 69, return
		beq	$t0, 68, return
		beq	$t0, 88, return
		j	error_input
	
	string:
		li	$v0, 8
		la	$a0, str
		li	$a1, 100
		syscall
		move	$v0, $a0
		j	return
		
	
#--------------------------------------------------------------------
# cipher
#
# Calls compute_checksum and encrypt or decrypt depending on if the user input E or
# D. The numerical key from compute_checksum is passed into either encrypt or decrypt
#
# note: this should call compute_checksum and then either encrypt or decrypt
#
# arguments: $a0 - address of E or D character
# $a1 - address of key string
# $a2 - address of user input string
#
# return: $v0 - address of resulting encrypted/decrypted string
#--------------------------------------------------------------------
cipher:
	addiu	$sp, $sp, -8
	sw 	$s0, 4($sp)
	move	$t9, $a0
	move	$a0, $a1
	move	$s0, $a2
	jal	compute_checksum
	move	$t7, $v0
	lb	$t6, 0($t9)
	la	$t5, result
cipher_loop:
	lb	$t0, 0($s0)
	beq	$t0, $zero, after
	move	$a0, $t0
	move	$a1, $t7
	beq 	$t6, 'D', to_decry
	jal 	encrypt
	j 	almost
to_decry:
	jal	decrypt
	j	after
almost:
	sb	$v0, 0($t5)
	addi	$t5, $t5, 1
	addi	$t8, $t8, 1
	j	cipher_loop
after:
	#sb	$zero, 0($t6)
	la	$v0, result
	lw 	$s0, 4($sp)
	addiu 	$sp, $sp, 4
	j	return
#--------------------------------------------------------------------
# compute_checksum
#
# Computes the checksum by xor’ing each character in the key together. Then,
# use mod 26 in order to return a value between 0 and 25.
#
# arguments: $a0 - address of key string
#
# return: $v0 - numerical checksum result (value should be between 0 - 25)
#--------------------------------------------------------------------
compute_checksum:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	li	$t0, 0
	move	$t1, $a0
	sum_loop:
		lb $t2, 0($t1)
		beq $t2, $zero, sum_exit
		xor $t0, $t0, $t2
		addi $t1, $t1, 1
		j	sum_loop
	sum_exit:
		rem	$v0, $t1, 26
		j	return
#--------------------------------------------------------------------
# encrypt
#
# Uses a Caesar cipher to encrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments: $a0 - character to encrypt
# $a1 - checksum result
#
# return: $v0 - encrypted character
#--------------------------------------------------------------------
encrypt:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	jal	check_ascii
	move	$t0, $v0
	beq	$t0, -1, encry_non
	li	$t8, 26
	beq	$t0, 0, upletter
	li	$t9, 'a'
	j	encry_process
upletter:
	li	$t9, 'A'
	j	encry_process
encry_process:
	sub	$t2, $a0, $t9
	add	$t2, $t2, $a1
	add	$t2, $t2, $t8
	div 	$t2, $t8
	mfhi 	$t2
	add 	$v0, $t2, $t9
	j 	return
encry_non:
	move	$v0, $a0
	j	return

#--------------------------------------------------------------------
# decrypt
#
# Uses a Caesar cipher to decrypt a character using the key returned from
# compute_checksum. This function should call check_ascii.
#
# arguments: $a0 - character to decrypt
# $a1 - checksum result
#
# return: $v0 - decrypted character
#--------------------------------------------------------------------
decrypt:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)
	sub	$a1, $zero, $a1
	jal	encrypt
	j	return
#--------------------------------------------------------------------
# check_ascii
#
# This checks if a character is an uppercase letter, lowercase letter, or
# not a letter at all. Returns 0, 1, or -1 for each case, respectively.
#
# arguments: $a0 - character to check
#
# return: $v0 - 0 if uppercase, 1 if lowercase, -1 if not letter
#--------------------------------------------------------------------
check_ascii:
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	move	$t0, $a0
	ble	$t0, 65, return_not
	bge	$t0, 122, return_not
	ble	$t0, 91, return_upper
	bge	$t0, 96, return_lower
	b	return_not
	
	return_upper:
		li	$v0, 0
		j	return
	return_lower:
		li	$v0, 1
		j	return
	return_not:
		li	$v0, -1
		j	return
#--------------------------------------------------------------------
# print_strings
#
# Determines if user input is the encrypted or decrypted string in order
# to print accordingly. Prints encrypted string and decrypted string. See
# example output for more detail.
#
# arguments: $a0 - address of user input string to be printed
# $a1 - address of resulting encrypted/decrypted string to be printed
# $a2 - address of E or D character
#
# return: prints to console
#--------------------------------------------------------------------
print_strings:
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	move	$t0, $a0
	li	$v0, 4
	la	$a0, result_msg
	syscall
	beq	$a2, 69, en
	beq	$a2, 68, de
	de:
		li	$v0, 4
		la	$a0, en_msg
		syscall
	
		li	$v0, 4
		move	$a0, $t0
		syscall
	
		li	$v0, 4
		la	$a0, de_msg
		syscall
		
		li	$v0, 4
		move	$a0, $a1
		syscall
		j	return
	en:
		li	$v0, 4
		la	$a0, en_msg
		syscall
	
		li	$v0, 4
		move	$a0, $a1
		syscall
	
		li	$v0, 4
		la	$a0, de_msg
		syscall
		
		li	$v0, 4
		move	$a0, $t0
		syscall
		j	return
