#=========================================================================
# XOR Cipher Cracking
#=========================================================================
# Finds the secret key for a given encrypted text with a given hint.
# 
# Inf2C Computer Systems
# 
# Vladmiir hanin
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

input_text_file_name:         .asciiz  "input_xor_crack.txt"
hint_file_name:               .asciiz  "hint.txt"
newline:                      .asciiz  "\n"

zero: 				.asciiz "0"
one: 				.asciiz "1"
minus: 				.asciiz "-"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned
hint:                         .space 101         # Maximum size of key_file + NULL
.align 4                                         # The next field will be aligned



candidate_text:               .space 10001       # same space as the input text
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


# opening file for reading (hint)

        li   $v0, 13                    # system call for open file
        la   $a0, hint_file_name        # hint file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # hint[idx] = c_input
        la   $a1, hint($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(key_file);
        blez $v0, END_LOOP1             # if(feof(key_file)) { break }
        lb   $t1, hint($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP1        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  hint($t0)             # hint[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(key_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# ----- the logic of the program is the following: ------

# set register $s1 to the xor key that will loop from 00000000 to 11111111
# in order to do all combinations of 00000000 to 11111111, we start at zero and end at 2 ^8 - 1
# value is in $s1, we just have to icrement it and it will give all binary combinations
# so we want to initialise $s1 to 0

# xor the content of the input text with that key

# in the resulting text, check if it contains the text in the hint file

# if it does then print the key to stdout using ascii for each value of the binary value



# start of program
begin_reverse_xor:
	
	# set the smallest value of one byte:
	li  $s1, 0
	
	# set the biggest value of the key in s2
	li  $s2, 256
	

	
# now that we have the key, we can xor the content of input text with it. We store the result in candidate_text
reverse_xor_input_text_with_candidate_key:

	beq $s1, $s2, no_key_found   # check if the key is not too big
	
	li  $t0, 0    # this is the index of the reader and writer inside input text and candidate text
	
	
loop_reverse_xor_candidate_key:
	
	beq  $t0, 10001, end_reverse_xor_bound     
	
	lb   $t1, input_text($t0)   # so $t1 contains the ascii value of the character at the reader index
	
	beq  $t1, $0, end_reverse_xor_EOF
	
	beq  $t1, 32, xor_space              # you found a space so you don't exor that, you simply write it to the candidate text
	beq  $t1, 13, xor_cariage_return     # same for the carriage return
	beq  $t1, 10, xor_newline            # same for the newline


	# so the character is a valie character that we need to xor now
	
	xor  $t2, $s1, $t1    # decrypt using the candidate key
	                      # so $t2 contains the candidate character
	
	# we just need to write it to the candidate_text at the right location
	sb   $t2, candidate_text($t0)
	
	# now we prepare for the next iteration
	
	addi $t0, $t0, 1   # increment index of reader
	
	j loop_reverse_xor_candidate_key
	

xor_space:   # this is called when the character inside the input text is a space, so you just store that value
	
 	# we just need to write it to the candidate_text at the right location
	sb   $t1, candidate_text($t0)
	
	# now we prepare for the next iteration
	
	addi $t0, $t0, 1   # increment index of reader
	
	j loop_reverse_xor_candidate_key

xor_cariage_return:   # this is called when the character inside the input text is a carriage return, so you just store that value
	
 	# we just need to write it to the candidate_text at the right location
	sb   $t1, candidate_text($t0)
	
	# now we prepare for the next iteration
	
	addi $t0, $t0, 1   # increment index of reader
	
	j loop_reverse_xor_candidate_key
	
xor_newline:   # this is called when the character inside the input text is a newline, so you just store that value
	
 	# we just need to write it to the candidate_text at the right location
	sb   $t1, candidate_text($t0)
	
	# now we prepare for the next iteration
	
	addi $t0, $t0, 1   # increment index of reader
	
	j loop_reverse_xor_candidate_key
	
	
	
end_reverse_xor_EOF:
	# in order to have a valid last byte for the variable candidate_text, we add a EOF
	# at this point the program ended ither if the reader saw EOF in the input text, or if it hit read EOF in the input array
	# in the case that is went too far, ten we need to remove one to the index
	
	sb  $0, candidate_text($t0)
	
	j END_reverse_xor
	
end_reverse_xor_bound:
	# or out of bound then we remove one and write 0 at the right index
	addi $t0, $t0, -1
	
	sb  $0, candidate_text($t0)

END_reverse_xor:
	
#------------ test print the content of the candidate text to see if xor worked
# so we want to print the content of candidate_text	
begin_print_candidate:
	j end_print
print_candidate_text:
	li   $t0, 0

loop_print:
	lb   $t1, candidate_text($t0)
	beq  $t1, $0, end_print
	
	beq  $t1, 10, print_newline
	
	move  $a0, $t1
	li  $v0, 11
	syscall
	
	addi $t0, $t0, 1
	j loop_print

print_newline:
	la  $a0, newline
	li  $v0, 4
	syscall
	
	addi $t0, $t0, 1
	j loop_print

end_print:


# at this point you still have registers $s1 for the candidate key, and the variable candidate_text
# now yoy have to check if th hint message is inside the candidate text. If not, then increment key and restart

check_hint_in_candidate_text:
	
	li   $t0, 0    # this is the index of the reader inside candidate text
	li   $t1, 0    # this is the index of the reader inside the hint message

loop_check_hint_in_candidate:
	
	beq  $t0, 10001, end_candidate_bound
	beq  $t1, 10001, end_candidate_bound   # not needed
	
	lb   $t2, candidate_text($t0)    # so $t2 contains the ascii value of the character inside the candidate text
	lb   $t3, hint($t1)              # so $t3 contains the ascii value of the hcaracter insdie the hint
	
	# check for the character form the candidate text
	beq  $t2, $0, end_candidate_EOF            # should check if the index of corresponding index of the hint is the end of the hint
	
	beq  $t2, 32, candidate_space              # you found a space
	beq  $t2, 13, candidate_cariage_return     # same for the carriage return
	beq  $t2, 10, candidate_newline            # same for the newline
	
	# check for the character form the hint
	beq  $t3, $0, end_hint_EOF    # this should never happen as you stop the loop when you get a cariage return
	
	beq  $t3, 32, hint_space              # you found a space
	beq  $t3, 13, hint_cariage_return     # you want the program to say that you foudnt the entirery of the text and hence end and print the key
	                                      # JUST CHECK THAT THE CORRESPONDING CHARACTER IN CANDIDATE IS A SPACE OR NEWLINE otherwise boogbey in candidate will correspond with good in hint
	beq  $t3, 10, hint_newline            # same for the newline
	
	
	# at this point the character in the candidate test and hint are valid
	
	# check if the two characters are the same
	beq  $t2, $t3, found_matching_characters
	
	# if the two characters are not the same, then we reset the counter of the hint index
	li  $t1, 0
	
	# need to find the end of the word
	
loop_find_end_word_normal:
	
	lb $t2, candidate_text($t0)
	
	beq  $t2, 32, end_loop_find_end_word_normal   # find a space in the text
	beq  $t2, 13, end_loop_find_end_word_normal   # find a cariage return in the text
	beq  $t2, 10, end_loop_find_end_word_normal   # find a space in the text
	beq  $t2, $0, end_candidate_EOF   # find a space in the text
	
	# so you found a legit character
	# have to start again
	addi  $t0, $t0, 1
	
	j loop_find_end_word_normal
	
end_loop_find_end_word_normal:
	
	j loop_check_hint_in_candidate
	

end_candidate_bound:
	# so you went to the very last index of the candidate string, or candidate hint
		
	# so now it means we can add the key and restart the procedure
	addi  $s1, $s1, 1
	j     reverse_xor_input_text_with_candidate_key
	
found_matching_characters:
	# so you found matcing characters at index of candidate text and hint
	
	# increment index of hint
	addi  $t1, $t1, 1	
	
	# prepare for next character loop
	addi  $t0, $t0, 1
	j loop_check_hint_in_candidate


candidate_space:
	# so the character in the candidate text is a space, it should correspond to the space character of the hint, or a cariare return or newline or end of file
	
	
	# check if the two characters are spaces
	beq  $t2, $t3, found_matching_characters
	
	# check if the hint hcaracter is a cariage return or newline or end of file
	beq  $t3, 13, found_key
	beq  $t3, 10, found_key
	beq  $t3, $0, found_key
	
	# if the two characters are not the same, then we reset the counter of the hint index
	li  $t1, 0
	
	addi  $t0, $t0, 1
	j loop_check_hint_in_candidate

candidate_cariage_return:
	# so the character in the candidate text is a cariage return, you should ignore that character, it does not count as a read character

	# prepare for next character loop
	addi  $t0, $t0, 1
	j loop_check_hint_in_candidate

candidate_newline:
	# so the character in the candidate text is a newline, it counts as a space for the hint message,
	# so check if the hint message is a space, it it is then the comparison still holds true
	
	beq  $t3, 32, found_matching_characters
	
	beq  $t3, 13, found_key
	beq  $t3, 10, found_key
	beq  $t3, $0, found_key
	
	# so here you have a newlin in the candidate but no space in the hint, so the characters don't correspond
	li  $t1, 0
	
	# prepare for next character loop
	addi  $t0, $t0, 1
	j loop_check_hint_in_candidate


end_candidate_EOF:
	# so you reached the end of the candidate text, check that the hint has reached the end too
	# you hit the end if the hint character is a cariage return or newline or eof
	
	beq  $t3, 13, found_key
	beq  $t3, 10, found_key
	beq  $t3, $0, found_key
	
	# so at this point the character at the end of the hint is not finished, it still has some stuff inside that the candidate did not meantion
		
	# so now it means we can add the key and restart the procedure
	addi  $s1, $s1, 1
	j     reverse_xor_input_text_with_candidate_key

end_hint_EOF:
	# so this means that you hit the end of the hint file, so you must have found the right candidate
	# check if the corresponding thin in text is correct too
	# the same as for carriage return but for Linux
	
	# in the three cases then the candidate text is the right one
	beq  $t2, 32, found_key	
	beq  $t2, 13, found_key
	beq  $t2, 10, found_key
	beq  $t2, $0, found_key		
	
	# here it means that the word in the candidate text is not finished, like you tested for good and the candidate says goodbye
	li  $t1, 0
	
	# SO YOU WANNA MAKE SURE THAT YOU GO TO THE END OF THE WORD
	
loop_find_end_word_eof:
	
	lb $t2, candidate_text($t0)
	
	beq  $t2, 32, end_loop_find_end_word_eof   # find a space in the text
	beq  $t2, 13, end_loop_find_end_word_eof   # find a cariage return in the text
	beq  $t2, 10, end_loop_find_end_word_eof   # find a newline in the text
	beq  $t2, $0, end_candidate_EOF   # find a space in the text
	
	# so you found a legit character
	# have to start again
	addi  $t0, $t0, 1
	
	j loop_find_end_word_eof
	
end_loop_find_end_word_eof:
	
	j loop_check_hint_in_candidate

hint_space:

	beq  $t2, 32, found_matching_characters   # should never be run
	
	# this is when the candiate is not a valid character and the int is a space, then comparison failed
	li  $t1, 0
	
	# THIS IS WHERE AN ERROR MIGHT BE
	# here we need to find the next valid character for the andidate text. it needs to look for a character that is not a noormal vluae.
	# we are looking for a space, or a newline or a cariage return or end of file

loop_find_end_word_space:
	
	lb $t2, candidate_text($t0)
	
	beq  $t2, 32, end_loop_find_end_word_space   # find a space in the text
	beq  $t2, 13, end_loop_find_end_word_space   # find a cariage return in the text
	beq  $t2, 10, end_loop_find_end_word_space   # find a space in the text
	beq  $t2, $0, end_candidate_EOF   # find a space in the text
	
	# so you found a legit character
	# have to start again
	addi  $t0, $t0, 1
	
	j loop_find_end_word_space
	
end_loop_find_end_word_space:
	
	j loop_check_hint_in_candidate
	
	
	
	
hint_cariage_return:
	# so the character in the candidate text is a cariage return, you should ignore that character, it does not count as a read character

	# prepare for next character loop
	addi  $t1, $t1, 1
	j loop_check_hint_in_candidate

hint_newline:
	# the same as for carriage return but for Linux
	
	# in the three cases then the candidate text is the right one
	beq  $t2, 32, found_key	
	beq  $t2, 13, found_key
	beq  $t2, 10, found_key
	beq  $t2, $0, found_key		
	
	# here it means that the word in the candidate text is not finished, like you tested for good and the candidate says goodbye
	li  $t1, 0
	
	# SO YOU WANNA MAKE SURE THAT YOU GO TO THE END OF THE WORD
	
loop_find_end_word_newline:
	
	lb $t2, candidate_text($t0)
	
	beq  $t2, 32, end_loop_find_end_word_newline   # find a space in the text
	beq  $t2, 13, end_loop_find_end_word_newline   # find a cariage return in the text
	beq  $t2, 10, end_loop_find_end_word_newline   # find a newline in the text
	beq  $t2, $0, end_candidate_EOF   # find a space in the text
	
	# so you found a legit character
	# have to start again
	addi  $t0, $t0, 1
	
	j loop_find_end_word_newline
	
end_loop_find_end_word_newline:
	
	j loop_check_hint_in_candidate
	


found_key:
	# so the hint is inside the candidate, so now you can print the key
	
	
	j print_ascii_key

no_key_found: # thi sis called when the key s1 is at the maximum value, hence print -1
	
	# if no key cound then -1 has to be printed in askii
	la $a0, minus
	li $v0, 4
	syscall
	
	la $a0, one
	li $v0, 4
	syscall
	
	la  $a0, newline
	li  $v0, 4
	syscall
	
	j main_end




# --------- so at this point we know that the key is stored in $s1, we just need to print it
# in order to check what the value is of each bit, we can do the following:
# for the most significatn bit, what we can do it the follwoing:
# load the key:  01001110
# load a num  :  10000000
# then do and operation on both
# if the result is zero then there was a zero in the ith bit

print_ascii_key:
	
	li  $t0, 7    # this is the shift for the eight bites of the key

loop_print_ascii_key:

	beq  $t0, -1, end_print_ascii
	
	li  $t1, 1
	
	sllv $t1, $t1, $t0
	
	and  $t2, $t1, $s1
	
	beq $t2, $0, print_zero
	
	j print_one

print_zero:
	
	la  $a0, zero
	li  $v0, 4
	syscall
	
	addi $t0, $t0, -1
	j loop_print_ascii_key


print_one:
	
	la  $a0, one
	li  $v0, 4
	syscall
	
	addi $t0, $t0, -1
	j loop_print_ascii_key

end_print_ascii:
	la  $a0, newline
	li $v0, 4
	syscall

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
