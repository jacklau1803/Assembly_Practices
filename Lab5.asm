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
	errmsg:		.asciiz	"Invalid input: Please input E, D, or X.\n"
	result_msg:	.asciiz "\nHere is the encrypted and decrypted string\n"
	en_msg:		.asciiz "<Encrypted> "
	de_msg:		.asciiz "<Decrypted> "
	newline:	.asciiz "\n"
	char:		.space 2
	str:		.space 100
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
	la	$a0, prompt0
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
		li	$v0, 8
		la	$a0, char
		syscall
		move	$v0, $a0
		beq	$v0, 69, return
		beq	$v0, 68, return
		beq	$v0, 88, return
		j	error_input
	
	string:
		li	$v0, 8
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
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	move	$t0, $a0
	move	$a0, $a1
	jal	compute_checksum
	move	$a1, $v0
	move	$a0, $a1
	la	$t1, ($a2)
	add	$t3, $zero, 0
	beq	$t0, 69, to_encry_loop
	beq	$t0, 68, to_decry_loop
to_encry_loop:
	beqz	$t1, after
	lb	$a0, ($t1)
	jal	encrypt
	move	$t2, $v0
	add	$t3, $t2, $t3
	sll	$t3, $t2, 1
	j	to_encry_loop
to_decry_loop:
	beqz	$t1, after
	lb	$a0, ($t1)
	jal	decrypt
	move	$t2, $v0
	add	$t3, $t2, $t3
	sll	$t3, $t3, 1
	j	to_decry_loop
after:
	srl	$t3, $t3, 1
	move	$v0, $t3
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
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	la	$t0, ($a0)
	lb	$t2, ($t0)
	xor	$t1, $t2, 0
	j	sum_loop
	sum_loop:
		beqz	$t0, sum_exit
		la	$t0, 1($t0)
		lb	$t2, ($t0)
		xor	$t1, $t2, $t1
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
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	add	$v0, $a0, $a1
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
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)
	sub	$v0, $a0, $a1
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
