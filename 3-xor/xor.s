#=========================================================================
# XOR Cipher Encryption
#=========================================================================
# Encrypts a given text with a given key.
# 
# Inf2C Computer Systems
# 
# Vladimir Hanin
# 9 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_xor.txt"
key_file_name:                .asciiz  "key_xor.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned

key_ascii:                    .space 33          # Maximum size of key_file + NULL
.align 4                                         # The next field will be aligned

key_byte:                     .space 4           # the maximum size of the key
.align 4


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

# opening file for reading (text)

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


# opening file for reading (key)

        li   $v0, 13                    # system call for open file
        la   $a0, key_file_name         # key file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # key[idx] = c_input
        la   $a1, key_ascii($t0)              # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, key_ascii($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  key_ascii($t0)              # key[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------

# first convert the ascii text to normal binary numbers, as '0' is encoded as 48 as '1' is encoded as 49
#------------------------------------------------------------------
# convert ascii characters to binary numbers for key
#------------------------------------------------------------------
convert_ascii_binary:   # this method is not called, it is run after the top one
	li   $t0, 0  # index of where the reader is inside key_ascii
	li   $t3, 7  # stores the place of the character inside the number, so that you can convert the character to its real value compared the the rest of the number
	li   $t5, 0  # this is the sum of the characters when we find the actual value
	li   $t6, 0  # this stores the number of key values we have to store the next key value inside key_byte
	
loop_convert:

	beq   $t0, 32, end_convert       # there can only be 32 character in keu__ascii at maximum

	lb    $t1, key_ascii($t0)        # get the asscii value of the character inside key_ascii
	                                 # so $t1 contains the ascii character
	                                 
	beq   $t1, $0, end_convert
	
	beq   $t1, 13, end_convert       # check if the character is a cariage return, so you got the end of the key
	beq   $t1, 10, end_convert       # check if the character is a newline, so you got to the end of the key
	
	
	# at this point the character is a normal value for the key
	subu  $t2, $t1, 48          # 48 is the ascii value for 0
	                            # so $t2 contains the binary number value for the key
	                        
	# so we get the value of the character in $t2, now we can know its true value if we multiply it by 2^n where n is $t3
	sllv  $t4, $t2, $t3      # so $t4 contains the real value
	
	add   $t5, $t5, $t4      # so we add the result of the shift to the sum of all the characters
	                                
      
	beq   $t3, 0, store_number_key_byte_and_prepare_next_loop_convert   # if the place of the character inside the number is 0, then we hit the 
	                                                                    # end of the number, so we have a special thing
	
	# if we are in the middle of a value we keep going
	j prepare_next_loop_convert
	
	
store_number_key_byte_and_prepare_next_loop_convert:  # this gets executed when we have read a complete value of the key

	# we first store the value of the key inside one byte of the key_byte variable at the place $t6
	sb  $t5, key_byte($t6)          # store the value inside at place $t6 where $t6 is incremented each time we add a value
	
	addi  $t6, $t6, 1

        li  $t3, 7     # we reset the place of the character
        li  $t5, 0     # we reset the sum of all the characters to zero
        
	addi  $t0, $t0, 1      # index of the reader inside key_ascii    
        j loop_convert


prepare_next_loop_convert:    # this gets executed when we are reading a character inside a number
        
        addi  $t0, $t0, 1      # index of the reader inside key_ascii
        addi  $t3, $t3, -1     # the place of the character inside the number
        
        j loop_convert
	 

end_convert:
	# so when the end is done, we only need to keep the length of the key (how many bytes we have)
	move $s1, $t6       # so $s1 contains the size of the key!

# ----------------------test----------------------------------
# just want to make sure that the key saved is the right value
# so we print the numbers inside key_byte
test_print_values_key_byte:
	li  $t7, 0
	lb  $a0, key_byte($t7)
	li  $v0, 1
	#syscall

#------------------------------------------------------------------
# END convert ascii characters to binary numbers for key
#------------------------------------------------------------------


# now we can do the xor on each byte on the input text, with the key
xor_input_text_with_key:
        li   $t0, 0     # this is the index of the reader of the input text that reads one character at a time
        li   $t2, 0     # this stores which value in the key we are using for the xor (as an index)
        

loop_xor:

	beq  $t0, 10001, end_xor         # there can only be 10001 characters in input text
	
	lb   $t1, input_text($t0)        # get the asscii value of the character inside input_text
	                                 # so $t1 contains the ascii character of the text
	                                 
	beq  $t1, $0, end_xor           # should stop if you hit the end of the variable
	                                 
	beq $t1, 32, print_space_prepare_next_loop           # if the character inside the input text is a space, then ignore the xor thing, just print the space
	beq $t1, 13, print_cariageReturn_prepare_next_loop   # if the character inside the input text is a cariage return (\r), IGNORE IT
	beq $t1, 10, print_newline_prepare_next_loop         # if the character is a new line, then print that new line (odn't do the xor thing
	
	lb   $t3, key_byte($t2)              # load the corresponding key value
	                                     # so $t3 contains the key value
	
	xor  $t4, $t1, $t3                   # we xor the two
	                                     # so $t4 contains the result value
	
	j print_char_and_prepare

print_newline_prepare_next_loop:
        # simply print a newline
	la     $v0, 4
	la     $a0, newline
	syscall
	
	addi  $t0, $t0, 1        # add one to the reader
	addi  $t2, $t2, 1        # add one to the corresponding value of the key
	
	beq   $t2, $s1, reset_key_value_and_repare
	
	j loop_xor


print_cariageReturn_prepare_next_loop: # for the cariage return I don't print anything
	
	addi  $t0, $t0, 1        # add one to the reader
	
	j loop_xor
	
print_space_prepare_next_loop:
	
	# simply print a space
	li     $v0, 11
	li     $a0, 32
	syscall
	
	addi  $t0, $t0, 1        # add one to the reader
	addi  $t2, $t2, 1        # add one to the corresponding value of the key
	
	beq   $t2, $s1, reset_key_value_and_repare
	
	j loop_xor


print_char_and_prepare:   # this is executed when we have to print the resulting character after the xor

	# print character from result in register $t4
	li     $v0, 11
	move   $a0, $t4
	syscall
	
	addi  $t0, $t0, 1        # add one to the reader
	addi  $t2, $t2, 1        # add one to the corresponding vlaue of the key
	
	beq   $t2, $s1, reset_key_value_and_repare
	
	j loop_xor

reset_key_value_and_repare:   # this gets executed if the index of the valu eof the key is the same as the size of the key

	li   $t2, 0          # reset the key index
	j loop_xor


end_xor:   #nothing for now

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
