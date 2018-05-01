# CMPEN 331, Lab 2

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# switch to the Data segment
	.data
	# global data is defined here

	# Don't forget the backslash-n (newline character)
Homework:
	.asciiz	"CMPEN 331 Lab 2\n"
Name_1:
	.asciiz	"William\n"
Name_2:
	.asciiz	"Yoshida\n"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# switch to the Text segment
	.text
	# the program is defined here

	.globl	main
main:
	# Whose program is this?
	la	$a0, Homework
	jal	Print_string
	la	$a0, Name_1
	jal	Print_string
	la	$a0, Name_2
	jal	Print_string
	
	# int i, j = 2, n = 3;
	# for (i = 0; i <= 16; i++)
	#   {
	#      ... j = testcase[i]
	#      ... calculate n from j
	#      ... print i, j and n
	#   }
	
	# register assignments
	#  $s0    i
	#  $s1    j = testcase[i]
	#  $s2    n
	#  $s3    binary string '10'
	#  $s4-s7 hexadecimal ranges in else-if structure
	#  $t0    address of testcase[i]
	#  $t1    argument used for slt in else-if structure
	#  $t2    a
	#  $t3    b
	#  $t4    c
	#  $t5    d
	#  $t6    binary string to be added in front for each range
	#  $t7    binary string '10' from $s3, shifted
	#  $a0    argument to Print_integer, Print_string, etc.
	#  add to this list if you use any other registers

	# initialization
	li	$s1, 2			# j = 2
	li	$s2, 3			# n = 3
	
	# for (i = 0; i <= 16; i++)
	li	$s0, 0			# i = 0
	la	$t0, testcase		# address of testcase[i]
	bgt	$s0, 16, bottom
top:
	lw	$s1, 0($t0)		# j = testcase[i]
	# calculate n from j
	# Your part starts here
	
	li	$s3, 2			# binary string '10'
	li 	$s4, 0x80		# 0x80 (range) 
	sltu 	$t1, $s1, $s4		
	beq 	$t1, $zero, Range2  	# if (j < 0x80) {
	# // j fits in 7 bits, expand to 8 bits 
	
	add 	$s2, $s1, $zero		# n = j
	j 	Continue
	Range2: 
	li 	$s5, 0x800		# 0x800 (range)
	sltu 	$t1, $s1, $s5
	beq 	$t1, $zero, Range3 	# } else if (j < 0x800) {
	# // j fits in 11 bits, expand to 16 bits 
	
	andi 	$t3, $s1, 0x3f 		# b = low 6 bits of j 
	srl 	$t2, $s1, 6
	andi 	$t2, $t2, 0x1f 		# a = next 5 bits of j 
	li	$t6, 6			# binary string '110'
	add	$s2, $t3, $zero		# copy b into n
	
	 				# // n = 110 a 10 b 
	sll 	$t7, $s3, 6 		# // 			5	6 bits in
	or 	$s2, $s2, $t7 		# // j =		aaaaa bbbbbb
	sll 	$t2, $t2, 8 		# //             3   5    2     6 bits out 
	or 	$s2, $s2, $t2 		# // n =	110 aaaaa 10 bbbbbb 
	sll 	$t6, $t6, 13		# // to concatenate rest of bits, shift origin register by number of bits already inserted into n, then include desired bits using or
	or 	$s2, $s2, $t6
	j 	Continue
	Range3: 
	li 	$s6, 0x10000		# 0x10000 (range)
	sltu 	$t1, $s1, $s6
	beq 	$t1, $zero, Range4 	# } else if (j < 0x10000) {
	# // j fits in 16 bits, expand to 24 bits 
	
	andi 	$t4, $s1, 0x3f 		# // c = low 6 bits of j 
	srl 	$t3, $s1, 6
	andi 	$t3, $t3, 0x3f 		# // b = next 6 bits of j 
	srl 	$t2, $s1, 12 
	andi 	$t2, $t2, 0xf 		# // a = next 4 bits of j 
	li	$t6, 14			# binary string '1110'
	add 	$s2, $t4, $zero 	# copy c into n
	
					# // n = 1110 a 10 b 10 c 
	sll 	$t7, $s3, 6 		# //                      4     6     6 bits in 
	or 	$s2, $s2, $t7 		# // j =		aaaa bbbbbb cccccc 
	sll 	$t3, $t3, 8 		# //
	or 	$s2, $s2, $t3 		#          4    4   2    6   2    6 bits out 
	sll 	$t7, $s3, 14 		# // n = 1110 aaaa 10 bbbbbb 10 cccccc 
	or 	$s2, $s2, $t7		# // to concatenate rest of bits, shift origin register by number of bits already inserted into n, then include desired bits using or
	sll 	$t2, $t2, 16
	or 	$s2, $s2, $t2
	sll 	$t6, $t6, 20
	or 	$s2, $s2, $t6
	j 	Continue
	Range4: 
	li 	$s7, 0x110000		# 0x110000 (range)
	sltu 	$t1, $s1, $s7
	beq 	$t1, $zero, Range5 	# } else if (j < 0x110000) {
	# // j fits in 21 bits, expand to 32 bits 
	
	andi 	$t5, $s1, 0x3f 		# // d = low 6 bits of j 
	srl 	$t4, $s1, 6
	andi 	$t4, $t4, 0x3f 		# // c = next 6 bits of j 
	srl 	$t3, $s1, 12
	andi 	$t3, $t3, 0x3f 		# // b = next 6 bits of j 
	srl 	$t2, $s1, 18
	andi 	$t2, $t2, 0x7 		# // a = next 3 bits of j 
	li	$t6, 30			# binary string '11110'
	add 	$s2, $t5, $zero 	# copy d into n
		
					# // n = 11110 a 10 b 10 c 10 d 
	sll 	$t7, $s3, 6 		# //                     3    6      6       6 bits in  
	or 	$s2, $s2, $t7 		# // j = 		aaa bbbbbb cccccc dddddd
	sll 	$t4, $t4, 8 		# //        5   3   2     6  2     6   2     6 bits out    
	or 	$s2, $s2, $t4 		# // n = 11110 aaa 10 bbbbbb 10 cccccc 10 dddddd 
	sll 	$t7, $s3, 14		# // to concatenate rest of bits, shift origin register by number of bits already inserted into n, then include desired bits using or
	or 	$s2, $s2, $t7
	sll 	$t3, $t3, 16
	or 	$s2, $s2, $t3
	sll 	$t7, $s3, 22
	or 	$s2, $s2, $t7
	sll 	$t2, $t2, 24
	or 	$s2, $s2, $t2
	sll	$t6, $t6, 27
	or 	$s2, $s2, $t6
	j 	Continue
	Range5: # } else {
	# // j is outside the UTF-8 range of character codes 
	
	li 	$s2, 0xFFFFFFFF 	# // n = 0xFFFFFFFF
	# }
	Continue:
	# Your part ends here
	
	# print i, j and n
	move	$a0, $s0	# i
	jal	Print_integer
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s1	# j
	jal	Print_hex
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s2	# n
	jal	Print_hex
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s1	# j
	jal	Print_bin
	la	$a0, sp		# space
	jal	Print_string
	move	$a0, $s2	# n
	jal	Print_bin
	la	$a0, nl		# newline
	jal	Print_string
	
	# for (i = 0; i <= 16; i++)
	addi	$s0, $s0, 1	# i++
	addi	$t0, $t0, 4	# address of testcase[i]
	ble	$s0, 16, top	# i <= 16
bottom:
	
	la	$a0, done	# mark the end of the program
	jal	Print_string
	
	jal	Exit0	# end the program, default return status

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	.data
	# global data is defined here
sp:
	.asciiz	" "	# space
nl:
	.asciiz	"\n"	# newline
done:
	.asciiz	"All done!\n"

testcase:
	# UTF-8 representation is one byte
	.word 0x0000	# nul		# Basic Latin, 0000 - 007F
	.word 0x0024	# $ (dollar sign)
	.word 0x007E	# ~ (tilde)
	.word 0x007F	# del

	# UTF-8 representation is two bytes
	.word 0x0080	# pad		# Latin-1 Supplement, 0080 - 00FF
	.word 0x00A2	# cent sign
	.word 0x0627	# Arabic letter alef
	.word 0x07FF	# unassigned

	# UTF-8 representation is three bytes
	.word 0x0800
	.word 0x20AC	# Euro sign
	.word 0x2233	# anticlockwise contour integral sign
	.word 0xFFFF

	# UTF-8 representation is four bytes
	.word 0x10000
	.word 0x10348	# Hwair, see http://en.wikipedia.org/wiki/Hwair
	.word 0x22E13	# randomly-chosen character
	.word 0x10FFFF

	.word 0x89ABCDEF	# randomly chosen bogus value

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Wrapper functions around some of the system calls
# See P&H COD, Fig. A.9.1, for the complete list.

	.text

	.globl	Print_integer
Print_integer:	# print the integer in register $a0 (decimal)
	li	$v0, 1
	syscall
	jr	$ra

	.globl	Print_string
Print_string:	# print the string whose starting address is in register $a0
	li	$v0, 4
	syscall
	jr	$ra

	.globl	Exit
Exit:		# end the program, no explicit return status
	li	$v0, 10
	syscall
	jr	$ra	# this instruction is never executed

	.globl	Exit0
Exit0:		# end the program, default return status
	li	$a0, 0	# return status 0
	li	$v0, 17
	syscall
	jr	$ra	# this instruction is never executed

	.globl	Exit2
Exit2:		# end the program, with return status from register $a0
	li	$v0, 17
	syscall
	jr	$ra	# this instruction is never executed

# The following syscalls work on MARS, but not on QtSPIM

	.globl	Print_hex
Print_hex:	# print the integer in register $a0 (hexadecimal)
	li	$v0, 34
	syscall
	jr	$ra

	.globl	Print_bin
Print_bin:	# print the integer in register $a0 (binary)
	li	$v0, 35
	syscall
	jr	$ra

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
