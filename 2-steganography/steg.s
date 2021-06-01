#=========================================================================
# Steganography
#=========================================================================
# Retrive a secret message from a given text.
# 
# Inf2C Computer Systems
# 
# Vladimir Hanin
# 13 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_steg.txt"
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
        lb   $t1, input_text($t0)          
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
# Block that prints the hidden message
#------------------------------------------------------------------

find_hidden_message:
	li   $t0, 0    # this is the index of the character inside the string, so at the end of each iteration you add one
	li   $t2, 1    # this keeps track of the count of the word inside that sentence
	li   $t3, 1    # this keeps track of the number of the sentence inside the input
	
	li   $t4, 1    # this bollean values says 'is the first word of the output sentence'
	li   $t5, 1    # this bollean values says 'this chat is the first char of the word'
	
	
loop_whole_input:

	beq  $t0, 10000, end            # should stop printing when the index is at its maximum
	
	lb   $t1, input_text($t0)       # so $t1 contains the byte of the character in ascii
	
	beq  $t1, $0, end               # should stop if you hit the end of the variable
	
	beq  $t1, 32, new_word          # check if the character is a space, if so then call new_word
	
	beq  $t1, 10, new_sentence      # check if character is a new line, if so then call new_sentence
	
	beq  $t2, $t3, print_char       # if the count of the sentence is the same as the count of the word, then print the character
	
	# here it means that the character is not a space, not a newline, not in the right place, so we must igore it
	j prepare_next_iteration


new_word: # this gets executed if the character in the input is a space
	addi $t2, $t2, 1    # this keeps track of the count of the word inside that sentence
	li  $t5, 1          # hence we know that if we were to print the next character, it would be the first of a word
	
	j prepare_next_iteration
	
new_sentence:

	# first we chech that we have indeed aleady looked at the first word of the input sentence
	# if not, then it means that the sentence is empty, so we just print a newline
	#beq   $s6, $0, print_new_line     # branch if the first word is not yet seen
	
	# first we chech that the word in the sentence was printed
	# it was printed if the register of the word is the same (or higher) as the register of the sentence
	# hence it was not printed if the register of the word is strickly smaller than the sentence
	
	slt $t7, $t2, $t3
	li  $t6, 1
	
	beq, $t7, $t6, print_new_line

	addi $t3, $t3, 1
	li   $t2, 1    # this keeps track of the count of the word inside that sentence
	
	j prepare_next_iteration

print_new_line:

	li  $t4, 1
	
	addi $t3, $t3, 1
	li   $t2, 1    # this keeps track of the count of the word inside that sentence
	
	# print new line
 	li   $v0, 4
 	la   $a0, newline
 	syscall
 	
 	j prepare_next_iteration



print_char:
	
	li   $t6, 1
	
	# check if the current word is the first of the output sentence
	beq  $t4, $t6, print_normal_first_char
	
	#check if the char is the first char of the word
	beq  $t5, $t6, print_space_char
	
	
	#then character is not in first word nor at the start
	
	# print current character
 	li   $v0, 11
 	move $a0, $t1
 	syscall
 	
 	j prepare_next_iteration
 	
 	
print_char_special_for_r:
	
	# print current character
 	li   $v0, 11
 	move $a0, $t1
 	syscall
 	
 	j prepare_next_iteration

print_normal_first_char:    # this gets executed if the word is the first word in the output sentence
	
	li  $t4, 0
	li  $t5, 0
	
	# print current character
 	li   $v0, 11
 	move $a0, $t1
 	syscall

 	j prepare_next_iteration

print_space_char:

	# print space character
 	li   $v0, 11
 	li   $a0, 32
 	syscall

	# print current character
 	li   $v0, 11
 	move $a0, $t1
 	syscall

	li  $t5, 0

 	j prepare_next_iteration



prepare_next_iteration:	
	# prepare next index of character
	addi $t0, $t0, 1
	j loop_whole_input


end: # the last charater of output is a newline so you just print that

	# print new line
 	li   $v0, 4
 	la   $a0, newline
 	syscall

#------------------------------------------------------------------
# End of block that prints hidden message
#------------------------------------------------------------------


#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
