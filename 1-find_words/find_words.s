#=========================================================================
# Word Finder 
#=========================================================================
# Finds words in a given text.
# 
# Inf2C Computer Systems
# 
# Vladimir hanin
# 11 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_words.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)       # so $t1 contains the byte of the character read
                 
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)


#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------



#------------------------------------------------------------------
# now the string is stored inside input_text so we can print the words
#------------------------------------------------------------------

print_char:
	# initialises the index before the loop begins
	li   $t0, 0
	j loop
	
break_line:        # this is executed if the character to print is a space
	
	# print character
 	li   $v0, 4
 	la   $a0, newline
 	syscall
 
 	#prepare next iteration of loop
 	addi $t0, $t0, 1
 	j loop

loop:
	beq  $t0, 10000, end            # should stop printing when the index is at its maximum
	
 	lb   $t1, input_text($t0)       # so $t1 contains the byte of the character
 	
 	# should stop if you hit the end of the variable
 	beq  $t1, $0, end               
 	
 	#check if the character is a space, if so then instead of printing it, you print a new line
 	beq  $t1, 32, break_line
 	
 	# print character
 	li   $v0, 11
 	move $a0, $t1
 	syscall
 
 	#prepare next iteration of loop
 	addi $t0, $t0, 1
 	j loop


end:    # this is only so that you can break out of the loop
	

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
