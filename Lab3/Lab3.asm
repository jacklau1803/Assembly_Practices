##########################################################################
# Created by: Liu, Jack
# dliu34
# 15 Febuary 2019
#
# Assignment: Lab 3: MIPS Looping ASCII Art
# CMPE 012, Computer Systems and Assembly Language
# UC Santa Cruz, Winter 2019
#
# Description: This lab will introduce you to the MIPS ISA using MARS. You will write a program that draws triangles based on values specified by a user.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################
.data
	pmpt1: .asciiz "Enter the length of one of the triangle legs: "
	pmpt2: .asciiz "Enter the number of triangles to print: "
	sign1: .asciiz "\\\n"
	sign2: .asciiz "/\n"
	newline: .asciiz "\n"
.text
	main:
		#prompt to get the length
		li $v0, 4
		la $a0, pmpt1
		syscall
	
		#get length input
		li $v0, 5
		syscall
	
		#store
		move $t0, $v0
	
		#prompt to get the number
		li $v0, 4
		la $a0, pmpt2
		syscall
	
		#get number input
		li $v0, 5
		syscall
	
		#store
		move $t1, $v0
		
		#i = 0
		addi $t2, $zero, 0
		
		#newline
		li $v0, 4
		la $a0, newline
		syscall
		
		#loop
		loop:
			bge  $t2, $t1, exit #while i<=t1
			addi $t3, $zero, 0 #j = 1
			inner_loop1:
				bge $t3, $t0, inner_loop2
				addi $t4, $zero, 0
				addi $t5, $t3, 0
				space_loop1:
					bge $t4, $t5, space_exit1
					li $a0, 32 #space
					li $v0, 11 # syscall number for printing character
					syscall
					addi $t4, $t4, 1
					j space_loop1
				space_exit1:
					li $v0, 4
					la $a0, sign1
					syscall
					addi $t3, $t3, 1 #j++
					j inner_loop1
			inner_loop2:
				ble $t3, $zero, inner_exit
				addi $t4, $zero, 0
				subi $t6, $t3, 1
				space_loop2:
					bge $t4, $t6, space_exit2
					li $a0, 32 #space
					li $v0, 11 #syscall number for printing character
					syscall
					addi $t4, $t4, 1
					j space_loop2
				space_exit2:
					li $v0, 4
					la $a0, sign2
					syscall
					subi $t3, $t3, 1 #j--
					j inner_loop2
			inner_exit:
			addi $t2, $t2, 1 #i++
			j loop
		exit:
			li $v0, 10
			syscall
