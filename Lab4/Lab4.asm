##########################################################################
# Created by: Liu, Jack
# dliu34
# 20 Febuary 2019
#
# Assignment: Lab 4: ASCII Conversion
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: Read a string input and convert ASCII characters into base 4 number and print it out.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################
#psuedocode:
#take inputs
#convert by prefix
#store
#addition
#print in base-4

.data
	msg1: .asciiz "You entered the numbers: \n"
	msg2: .asciiz "The sum in base 4 is: \n"
	ascii_array1: .space 10
	ascii_array2: .space 10
.text
	#load args
	lw 	$t0, 0($a1)
	lw 	$t1, 4($a1)
	
	#print first msg
	li 	$v0, 4
	la 	$a0, msg1
	syscall
	
	#print numbers
	li 	$v0, 4
	move 	$a0, $t0
	syscall
	
	li 	$v0, 11
	la 	$a0, 32
	syscall
	
	li 	$v0, 4
	move 	$a0, $t1
	syscall
	
	li 	$v0, 11
	la 	$a0, 10
	syscall
	
	#print second msg
	li 	$v0, 4
	la 	$a0, msg2
	syscall
	
	#hex or bin
	lb 	$t2, 1($t0)
	bge 	$t2, 120, hex1
	j bin1
	
	hex1:
		lb	$t2, 2($t0)
		bge	$t2, 65, alph1
		j num1
		alph1:
			subi $t3, $t2, 55
			j con_hex1
		num1:
			subi $t3,$t2, 48
			j con_hex1
		con_hex1:
			lb	$t2, 3($t0)
			bge	$t2, 65, alph11
			j num11
			alph11:
				subi $t4, $t2, 55
				j con_hex11
			num11:
				subi $t4,$t2, 48
				j con_hex11
		con_hex11:
			mul $t3, $t3, 16
			add $s1, $t3, $t4
			
			j second
	bin1:
		move	$t3, $t0
		addi	$t2, $zero, 0
		addi	$t5, $zero, 0
		j loop1
		loop1:
			lb 	$t4, 2($t3)
			bge 	$t4, 49, addone1
			j afteradd1
			addone1:
				addi 	$t5, $t5, 1
				j afteradd1
			afteradd1:
				mul 	$t5, $t5, 2
				j loop1_con
			loop1_con:
				la	$t3, 1($t3)
				addi 	$t2, $t2, 1
				ble	$t2, 7, loop1
				move	$s1, $t5
				j second	
	second:
		lb 	$t2, 1($t1)
		bge 	$t2, 120, hex2
		j bin2
		hex2:
		lb	$t2, 2($t1)
		bge	$t2, 65, alph2
		j num2
		alph2:
			subi $t3, $t2, 55
			j con_hex2
		num2:
			subi $t3,$t2, 48
			j con_hex2
		con_hex2:
			lb	$t2, 3($t1)
			bge	$t2, 65, alph22
			j num22
			alph22:
				subi $t4, $t2, 55
				j con_hex22
			num22:
				subi $t4,$t2, 48
				j con_hex22
		con_hex22:
			mul $t3, $t3, 16
			add $s2, $t3, $t4
			j sum
	bin2:
		move	$t3, $t1
		addi	$t2, $zero, 0
		addi	$t5, $zero, 0
		loop2:
			lb 	$t4, 2($t3)
			bge 	$t4, 49, addone2
			j afteradd2
			addone2:
				addi 	$t5, $t5, 1
				j afteradd2
			afteradd2:
				mul 	$t5, $t5, 2
				j loop2_con
			loop2_con:
				la	$t3, 1($t3)
				addi 	$t2, $t2, 1
				ble	$t2, 7, loop2
				move	$s2, $t5
				j sum
	sum:
		add 	$s0, $s1, $s2
		li 	$v0, 1
		andi 	$t6, $t6, 0xFF
		
		
		
		
		move 	$a0, $s0
		syscall
		li 	$v0, 11
		la 	$a0, 10
		syscall
		li	$v0, 10
		syscall
			