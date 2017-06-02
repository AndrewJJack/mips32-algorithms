#---------------------------------------------------------------
# Assignment:           3
# Due Date:             March 11, 2016
# Name:                 Andrew Jack
# Unix ID:              ajack
# Lecture Section:      B1
# Lab Section:          H02
# Teaching Assistant(s): Vincent Zhang
#---------------------------------------------------------------

#---------------------------------------------------------------
# Summary: This program finds the length of L, then it stores 
# that value in n. It then puts the index of the first and last
# value on the stack. It then iterates through, and sorts
# everything to the left of the first breakpoint once it is in
# the correct position. After that, it gets the new values from
# the stack, and it sorts the values to the left of the new 
# breakpoint until the whole list is sorted. It can tell that
# the list is sorted because the stack will be empty so the 
# external loop will stop iterating. My program prints out the
# sorted list with their DECIMAL values (the values that are, 
# and puts spaces after each number with the str_space ascii
# character as seen in the data segment.
#
#---------------------------------------------------------------

# --------------- Data Segment -----------
			.data 
			#L is a 0-terminated list (at most 20 numbers, excluding the last 0)
L:			.half 10, 30, 20, 15, 8, 7, 5, 0
			.align 1
S:			.space 2*2*20
n:			.word 0
lt:			.space 2*2*20
gt:			.space 2*2*20
eq:			.space 2*2*20
piv:		.half 0
first:		.half 0
last:		.half 0
it:			.half 0
str_s:     	.asciiz " "





#main
#main function calls function getlen, gets length, stores it
#in the appropriate location. it then gets the index of the 
#last element, and to start the first elements index will be
#0, so it will upload that onto the stack.
#Register usage:		$t0: gets address of n
#						$v0: where the value of n is stored
#						$t1: n-1 for last index
#						$a0: address of L
#						$a1: address of s


			.text
main:	
			jal getlen
			la $t0, n 			#getting address of n
			sh $v0, ($t0) 		#storing value of cound at n addr.

			beqz $v0, exit 		#if empty, no point iterating, exit


			addi $t1, $v0, -1 	#index of last element (n-1)

			la $a0, L 			#saves start address of L
			la $a1, S 			#saves start address of S

			sh $zero, 0($a1) 	#first index always 0 to start
			sh $t1, 2($a1) 		#last element will be n-1


#quicksort: This is where L is sorted.
#Register Usage:				$t1: start address of S
#								$t0: counter for external loop
quicksort:
			move $t1, $a1 		#setting start address of S in t1
			li $t0, 0 			#setting up a counter to check loop


#loop1:		This is the external loop that checks if the stack 
#			is empty.
#			Register Usage: $t0: external loop counter

loop1:								#checks if the stack is empty
			beq $t0, 40, print_list #if count = 40, Stack empty

			lh $t2, 0($t1) 		#stores word at stack address in t2
			beqz $t2, cont1 	#if the hw = 0, cont1


##loop 2 is where the inner loop is. It stores the values into
#variables first and last. After the first iteration the first
#and last value are updated later on, so it skips down to upfl
#Register Use:		$t3: gets value of first index from stack
#					$t4: gets value of second index from stack

#-------------------------------------------------------------
loop2:							#this is where the inner loop is going to be.
			lh $t3, 0($a1) 		#saving first in t3
			lh $t4, 2($a1) 		#saving last in t4

			la $t8, first
			la $t9, last

			sh $t3, ($t8) 		#storing the value of first
			sh $t4, ($t9) 		#storing the value of last
			sh $zero, ($a1) 	#popping value from the stack
			sh $zero, 2($a1)


#upfl: This is storing indexes of first and last
#Register Use:					$t8: stores address stack[first]
#								$t9: stores address stack[last]
#								$t3: stores value stack[first]
#								$t4: stores value stack[last]

upfl:							#iterations > 1, set first and last
			la $t8, first
			la $t9, last

			lh $t3, ($t8)
			lh $t4, ($t9)

			bgt $t3, $t4, cont2 #if first>=last no loop
			beq $t3, $t4, cont2
			move $t5, $t3 		#pivot element index = t5



#loop3: Getting the value of the pivot element
#Register Usage:				$t6: counter
#								$a0: start address of L
#								$t7: L address to be iterated
#								

			li $t6, 0 			#using t6 as a counter 
			move $t7, $a0 		#address of L
loop3:		beq $t6, $t5, cont3 #if count = index, cont
			addi $t6, $t6, 1
			addi $t7, $t7, 2
			b loop3


cont3:	 	lh $t6, 0($t7) #stores the value of split in $t6


#cont 4 is where I load the addresses of the less than, greater
#than, and equal to variables. I then clear the registers 
#$s0-$s2 to use as a counter for how many variables are 
#either less than, equal to, or greater than the pivot.
#Register Usage:				$s3: address of variables less
#								than the pivot
#								$s4: address of variables greater
#								than the pivot
#								$s5: address of variables equal
#								to the pivot
#								$s0: count of less than
#								$s1: count of greater than
#								$s2: count of equal to
#								$t7: address of L for iteration
#								$t8: address of n for iteration
#								$s6: counter

cont4:


			la $s3, lt
			la $s4, gt
			la $s5, eq

			move $s0, $zero
			move $s1, $zero
			move $s2, $zero
					
			move $t7, $a0 		#storing the starting address of L
			la $t8, n 			#address of n
			lh $s7, ($t8) 
			li $s6, 0 			#counter in s6

#lcheck: This is where the program iterates throught the values
#between first and last (values from the stack), and 
#assigns them to less, greater, or equal (lt, gt, eq).
#It will iterate until all vaules have been assigned to
#one of these three, and then it goes to up 1 where L is 
#updated to hve all values less than the curent pivot to the left,
#and all values gtreater than the pivot to the right. It includes
#the less, greater and equal subroutines.
#Register usage: same as cont 4 with some additional ones
								#t3: value of L


lcheck:		beq $s6, $s7, upl 	#loop through until L is ready to update
			lh $t3, 0($t7) 		#storing the value of L in t3
			blt $t3, $t6, less
			bgt $t3, $t6, greater
			beq $t3, $t6, equal


less:		sh $t3, 0($s3)
			addi $s3, $s3, 2
			addi $s0, $s0, 1
			addi $t7, $t7, 2 	#incrementing the address of L
			
			addi $s6, $s6, 1
			b lcheck

greater:	sh $t3, 0($s4)
			addi $s4, $s4, 2
			addi $s1, $s1, 1
			addi $t7, $t7, 2 	#incrementing the address of L
			
			addi $s6, $s6, 1
			b lcheck

equal:		sh $t3, 0($s5)
			addi $s5, $s5, 2
			addi $s2, $s2, 1
			addi $t7, $t7, 2 	#incrementing the address of L
			
			addi $s6, $s6, 1
			b lcheck
#up1 takes the values less than, greater than, and equal to
#the pivot, and stores them from left to right in the order
#that they were in, so the pivot goes to its correct location
#and then the elements that are less than and greater than the 
#pivot go to the left and right (These parts wont be sorted 
#until the the program has iterated through enough times to 
#empty the stack). Loop 4 stores values less than, loop 5
#stores values greater than, and then loop 6 stores values 
#equal to the pivot
#Register Usage:				#s0:count elements < pivot
								#s1:count elements > pivot
								#s2:count elements == pivot
#								$s3: address of variables less
#								than the pivot
#								$s4: address of variables greater
#								than the pivot
#								$s5: address of variables equal
#								to the pivot
#								$t9: counter
upl: 		move $s3, $zero
			move $s4, $zero
			move $s5, $zero
			la $s3, lt
			la $s4, gt
			la $s5, eq
			move $s6, $a0

			li $t9, 0 			#counter is $t9

loop4:		beq $t9, $s0, next1
			lh $t4, 0($s3)
			sh $t4, 0($s6)
			addi $t9, $t9, 1 	
			addi $s6, $s6, 2
			addi $s3, $s3, 2
			b loop4

next1:		li $t9, 0 			#counter is $t9
loop5:		beq $t9, $s2, next2
			lh $t4, 0($s5)
			sh $t4, 0($s6)
			addi $t9, $t9, 1
			addi $s6, $s6, 2
			addi $s5, $s5, 2
			b loop5

next2:		li $t9, 0 			#counter is $t9
loop6:		beq $t9, $s1, nu
			lh $t4, 0($s4)
			sh $t4, 0($s6)
			addi $t9, $t9, 1
			addi $s6, $s6, 2
			addi $s4, $s4, 2
			b loop6




#nu: This is where I update the pivot, and where I 
#put the pivot + 1 to end on the stack. The purpose of skip
#is so it doesn't update the stack eachtime it gets to this 
#point, so for each iteration it will update the stack with 
#split+1, end. if I did not have skip in it would continue to
#bring the start value down to 0 because of the way I store 
#values. it is just a variable that stores the iteration count
#Register Usage:				$t8: address of iterationcount
#								$t9: value of iteration count
#								$s0: count of values less than
#								the pivot
#

nu:			la $t8, it
			lh $t9, ($t8)
			bnez $t9, skip  	#not first iteration, skip stack update


			add $t9, $s0, $s2 	#switch 
			sh $t9, ($a1) 		#added to stack

			la $t9, n
			lh $t8, 0($t9)
			addi $t8, $t8, -1
			sh $t8, 2($a1)     	#index of last element in stack

skip:							#Now updating first and last, 

			la $t9, last
			sh $s0, ($t9)



			b upfl
#cont2:This is where it comes once all the elements to the left of
#the pivot are smaller than the pivot, and the elements to the 
#right are greater. It resets t0 to 0 so that the outer loop
#can start checking stack elements from the start again, because
#the previous value of the stack was popped, and there are now
#new values on the stack. It jumps to the end of the inner loop 
#whereit is redirected to the start of the external loop.
#Register usage 				$t0: outer loop counter
#								$a1: starting address of L
#								$t1: address of L that is being
#								iterated through in the outer
#								loop, now set back to the start

cont2: 							#This is where it goes if the first >= last from stack for inner loop

			li $t0, 0 			#resetting outter count
			move $t1, $a1 		#setting start address of S in t1
			j re 


#cont1: checking the stack. it looks through the entire stack
#to see if it is empty or not.
#Register Usage:				$t0: outer loop counter
#								$t1: address of L that is being
#								iterated through in the outer
#								loop, now set back to the start


cont1:		addi $t1, $t1, 2 	#moving address to next halfword
			addi $t0, $t0, 1 	#moving the counter up 1
re:			b loop1


exit:		li $v0, 10 			# exit
			syscall

#print2: This is where the program prints. It prints out the 
#decimal value.
#Register Usage:				$t0: address of n
#								$t1: value of n
#								$t2: counter
#								#t3: address of L to be iterated

print_list:	la $t0, n 			#getting address of n
			lh $t1, ($t0) 		#storing value of n 
			li $t2, 0 			#setting up count

			la $t3, L

ploop:		beq $t2, $t1, exit
			lh $a0, ($t3)
			li $v0, 1
			syscall
			la	 $a0, str_s;  li $v0,4; syscall
			addi $t3, $t3, 2
			addi $t2, $t2, 1

			b ploop
#getlen: This is where I get the length of L.
#Register Usage:				$s0: address of L
#								$s1: address of L to be iterated
#								$t1: counter
#								$t2: stores character from L
#								$v0: used to send length back
getlen:
			la $s0, L
			la $s1, L 			#saving end address of L
			li $t1, 0

st:			lh $t2, 0($s1) 		#stores L character in t2


			beq $t2, $zero, quit

			addi $s1, $s1, 2
			addi $t1, $t1, 1

			b st

quit: 		move $v0, $t1 
			jr $ra