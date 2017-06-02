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

# Explanation: The program will iterate through until the value
# of n is decremented to 0. It will print out the value of x,
# n, the result of x^n, and then it will give the return address
# associated with each iteration in the stack.
#---------------------------------------------------------------

# --------------- Data Segment -------------------------
			.data 

N:			.word 2
X:			.word 2
result:		.word 0

str_dash:	.asciiz "           ------------------------\n"
str_x:	    .asciiz "| x= "
str_n:     	.asciiz "  n= "
str_res:    .asciiz "  result= "
str_ra:	    .asciiz "  ra= "

#------------------Text Segment-------------------------
			.text
#------------main---------------------------------------
#The main function clears space for registers a0-a3, and then
#uses jal to get to powXN.
#Register usage:    $a0 stores X
#					$a1 stores N
#					$a2 stores the address of result	
main:			addi $sp, $sp, -16 #clearing space for registers $a0 - $a3

				lw $a0, X 				#Stores X in a0
				lw $a1, N 				#Stores N in a1
				la $a2, result 			#stores address of result in a2

				jal powXN


#--------exit--------------------------------------------
#releases the stack frame and exits the program. I used the
#value of 20 because I allocate space in the stack in the 
#powXN function that I need until the end of the program, so
#I clear it at the end. 

exit:			addi $sp, $sp, 20 #Releases the stack frame
				li    $v0, 10; syscall	# exit

#---------powXN--------------------------------------------
#This function allocates space for 5 registers. 
				nop; nop
powXN:			addi $sp, $sp, -20
				sw   $a0, 20($sp)		# store $a0= X in caller's frame
	  			sw   $a1, 24($sp)		# store $a1= N in caller's frame
		  		sw 	 $a2, 28($sp)		# store $a2 = address of result in a2
		  		sw   $ra, 16($sp)		# store $ra in powXM frame
		  		sw	 $a3, 32($sp)		# store the value of the mult

		  		jal clear_reg			#clears the registers a0 to a3

		  		lw $a1, 24($sp) 		#Puts n in a1
		  		lw $a0, 20($sp) 		#puts X in $a0
		  		lw $a2, 28($sp)			#puts address of result in a2


		  		li $t0, 1 #
		  		sw $t0, ($a2)  			#setting value as 1

	  			beqz $a1, cont1 		#if n is 0, break


#This loop iterates throuh and gets the appropriate value for
#x to the power of N
#Register Usage:		$t2:loads current result 
#						$t0: used to load 0, then compare to
#						exponent

	  			li $t0, 0 				#Setting up count in t0
loop1:	  		beq $t0, $a1, cont2 	#if count = exponent, break
				lw $t2, ($a2)       	#loading current result in t2
			
	  			mult $t2, $a0 			#multiply val by x
	  			mflo $t2				#updating current result in t2
	  			sw $t2, ($a2)			#storing result in the address
	  			move $a3, $t2  			#storing result in a3 for stack
	  			addi $t0, 1
	  			b loop1




#cont1 loads the value of 1 when the exponent is 0, becuase
#any number to the power of 0 is going to be 1. So 1 is 
#added to the stack with association to n = 0.
#Regiser Usage:				$t0: has 1 loaded into it,
#							then stores in the sp

cont1:	  		bnez $a1, cont2
				addi $sp, $sp, -4
				li $t0, 1
				sw $t0, 16($sp)  		#Stores a result of 0
				b powline

cont2:			addi $a1, $a1, -1 		#decrease exponent val by 1


	  			jal powXN


powline:		jal print_frame

#This clears the space allocated in the stack frame and restores
#the value of the return address so the program can exit.
#register Usage:		$t4 is used to save value of ra	
pow_end:
				lw   $ra, 20($sp)		# restore $ra
				lw 	 $t4, 20($sp)
		  		addi $sp, $sp, 20		# release stack frame
		  		jr   $ra  				# return




#print_frame is where the items on the stack are printed
#register usage:		$a0: stores values to be printed
#						$v0: operation

print_frame:   
			   	addi  $sp, $sp, -4		  # allocate frame: $ra
			   	sw    $ra, 0($sp)		  # store $ra from call in pyramid line

			   							  # print the frame that starts at $sp + 4

		        la    $a0, str_dash		  # print a separator line
			    li    $v0, 4; syscall			 

			   	addi  $a0, $sp, 4	      # $a0 = input $sp		 
			   	li    $v0, 1; syscall	  # print $sp

			   	la	 $a0, str_x;  li $v0,4; syscall    # print x = 
			   	lw	 $a0, 28($sp);  li $v0 1; syscall  # print value

			   	la	 $a0, str_n;  li $v0,4; syscall    # print n = 
			   	lw	 $a0, 32($sp);  li $v0 1; syscall  # print value

			   	la	 $a0, str_res;  li $v0,4; syscall  # print result = 
			   	lw	 $a0, 20($sp); li $v0,1; syscall   # print value

			   	la	 $a0, str_ra;  li $v0,4; syscall   # print $ra = 
		       	lw	 $a0, 24($sp); li $v0,1; syscall   # print value

			   	jal   print_NL      	 # print NL
			   
			   	lw    $ra, 0($sp)		 # restore $ra
			   	addi  $sp, $sp, 4		 # release frame
			   	jr	 $ra

#This is the clear register function that fills registers
#a0 through a0 with 0s.
clear_reg:		move $a3, $zero
				move $a2, $zero
				move $a1, $zero
				move $a0, $zero
				jr $ra


# ------------------------------
# function print_NL(), prints a new line in the program
#
	  			nop; nop
print_NL:
          		li   $a0, 0xA   		# newline character
          		li   $v0, 11
          		syscall
          		jr    $ra
# ------------------------------
