#=========================================================================
# Book Cipher Decryption
#=========================================================================
# Decrypts a given encrypted text with a given book.
# 
# Inf2C Computer Systems
# 
# Vladimir Hanin
# 18 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_book_cipher.txt"
book_file_name:               .asciiz  "book.txt"
newline:                      .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4       

keys:			       .space 10001       # maximum size of the size for keys CHANGE THIS VALUE
.align 4

book:                         .space 10001       # Maximum size of book_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

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


# opening file for reading (book)

        li   $v0, 13                    # system call for open file
        la   $a0, book_file_name        # book file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP1:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # book[idx] = c_input
        la   $a1, book($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(book_file);
        blez $v0, END_LOOP1             # if(feof(book_file)) { break }
        lb   $t1, book($t0)          
        beq  $t1, $0,  END_LOOP1        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP1
END_LOOP1:
        sb   $0,  book($t0)             # book[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(book_file)

#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# first convert the ascii text to normal binary numbers, as '0' is encoded as 48 as '1' is encoded as 49, etc
#------------------------------------------------------------------
# convert ascii characters to normal nmuber
#------------------------------------------------------------------
convert_ascii_decimal:   # this method is not called, it is run after the top one
	li   $t0, 0  # index of where the reader is inside input_book_cipher
	li   $s1, 10 # for the multiplication when the next character is also a number
	li   $t7, 0  # index inside the keys variable
	
loop_convert:

	beq   $t0, 10001, end_convert       # there can only be 10001 character in book_cipher at maximum

	lb    $t1, input_text($t0)        # get the asscii value of the character inside book_cypher
	                                  # so $t1 contains the ascii character
	                                 
	beq   $t1, $0, end_convert
	
	beq   $t1, 13, prepare_next_loop_convert       # check if the character is a cariage return, so you ignore that character
	beq   $t1, 10, prepare_next_loop_convert       # check if the character is a newline, so you ignore that character
	beq   $t1, 32, prepare_next_loop_convert       # check if the character is a space, so you ignore that character
	
	
	# at this point the character is a normal number
	subu  $t2, $t1, 48          # 48 is the ascii value for 0
	                            # so $t2 contains the correct number
	                        
	# we check if the next character is also a number, if so, then we need to combine the two character to make one ultimate value
	# if the next character is a number, then it is not a space, nor a newline, nor a carriage return
	addi  $t3, $t0, 1     # check the next value of the index
	
	beq   $t3, 10002, next_char_not_a_number   # check if we didn't read the end of the array
	
	lb    $t4, input_text($t3)        # get the asscii value of the next character
					   # so $t4 contains the ascii value of the next character
					   
	beq   $t4, 13, next_char_not_a_number       # check if the character is a cariage return
	beq   $t4, 10, next_char_not_a_number       # check if the character is a newline
	beq   $t4, 32, next_char_not_a_number       # check if the character is a space
	beq   $t4, $0, next_char_not_a_number       # check if the character is the end of file
	
	# at this point the ascii value of the next character is valid (a valid numer)
	subu  $t5, $t4, 48          # 48 is the ascii value for 0
	                            # so $t5 contains the integer value of the next number
	           
	                                            
	mult  $t2, $s1              # so now $t2 contains the actual value represnetatoin as it is the first number in a 2 figure number
	
	mflo  $t2
	
	add   $t6, $t2, $t5        # so $t6 contains the final two figure number
	
	# so now we finally have the value of the key
	
	# we can store it now
	sb   $t6, keys($t7)      # store the number as a word
	
	addi $t0, $t0, 2        # add 2 as you read two numbers this time
	addi $t7, $t7, 1        # move the index of where to write the next key
	
	j loop_convert
	
next_char_not_a_number:

	# so the one that is selected can be used for the key
	sb    $t2, keys($t7)
	
	addi  $t7, $t7, 1
	addi  $t0, $t0, 1
	
	j loop_convert
	

prepare_next_loop_convert: # this is called when the current character is a space, or a carriage return or a newline

	addi  $t0, $t0, 1
	j loop_convert

end_convert:

	# we know how big the key is (how many words, so we store that in a s register
	move $s1, $t7      # so $s1 is the number of keys inside the variable keys!




#------------------------------------------------------------------
# get the words from book and use keys
#------------------------------------------------------------------

# so here I just know how many words I have to print (and hence how many times I need to iterate orver the whole book

print_words_from_book_using_keys:
	li  $t0, 0     # this is the index of the reader that reads the keys inside 'keys', compare that to the size of the key which is $s1
	li  $t6, 1    # this bollean values says 'is the first word of the output sentence'
	li  $t7, 1    # this bollean values says 'this char is the first char of the word'
	
loop_new_key_find_word:

	beq $t0, $s1, end_print_words_from_book_using_keys          # we check if we are reading too far into the key variable, so we check if there are still keys
	
	lb    $s2, keys($t0)  # this loads the first element of the key
	                      # so $s2 contains the sentence number in the book from the key
	addi  $t0, $t0, 1     # add one
	
	lb    $s3, keys($t0)  # this load the second element of the key
	                      # so $s3 contains the word number in the sentence from the key
	addi  $t0, $t0, 1     # add one
	
	# we now know which word we need to find (according to its coordinates)          
	
	li $t1, 0      # this is the reader inside the book text, so it goes through the whole file and ends only when it reaches the end of the file
	li $t3, 1      # this keeps track of the sentence number where the reader is
	li $t4, 1      # this keeps track of the word number where the reader is
	
	
	li  $t7, 1
	       
	       
loop_read_character_analyse:
	
	beq $t1, 10001, loop_new_key_find_word              # the book text can only by 10001 characters long
	
        lb  $t2, book($t1)                                  # so $t2 contains the ascii value of the character
        
        beq $t2, $0, loop_new_key_find_word               # check if the character is the end of file      
        
             	              
	beq   $t2, 13, carriage_return       # check if the character is a cariage return
	beq   $t2, 10, new_line              # check if the character is a newline
	beq   $t2, 32, space                 # check if the character is a space
	               
	                            
	# so the current character is a normal letter
	
	bne  $s2, $t3, prepare_next_loop_read_character      # if the character is not on the right line then don't print that character
	bne  $s3, $t4, prepare_next_loop_read_character      # if the character is not on the right word then don't print that character                                 
	                                        
	                                            
	# so at this point the caracter is at the right line, and right word (and is also valid), so we check where it is in the word
	
	# check if the current word is the first of the output sentence
	beq  $t6, 1, print_normal_first_char
	
	#check if the char is the first char of the word
	beq  $t7, 1, print_space_char
	
	# at this point the character is in the middle of a word
	li    $v0, 11
	move  $a0, $t2
	syscall                                               
	                                                        
        j prepare_next_loop_read_character
 
 
print_normal_first_char:    # this gets executed if the character is the first word in the output sentence
	
	li  $t6, 0
	li  $t7, 0
	
	# print current character
 	li   $v0, 11
 	move $a0, $t2
 	syscall

 	j prepare_next_loop_read_character

print_space_char:

	# print space character
 	li   $v0, 11
 	li   $a0, 32
 	syscall

	# print current character
 	li   $v0, 11
 	move $a0, $t2
 	syscall

	li  $t7, 0

 	j prepare_next_loop_read_character      
 	
 	                    
                                                       
carriage_return:  # this gets executed if the current character is a carriage return    
                                                                          
	addi  $t1, $t1, 1  # this is the reader inside the book file
	j   loop_read_character_analyse 

new_line:   # this gets executed if the current character is a new line


	# there is the case that the reader was at the right sentence, but that there were not enough words, so when we
	# read the newline we check that it might be that case
	# thera are two condictoins for this to happen 1) you are on the right line  2) the reader word counter is smaler than the key word counter
	
	# we first check for the sentence number
	beq   $t3, $s2, new_line_check_word_count

	# as you hit a newline, you add one to the sentence count
	addi  $t3, $t3, 1
	
	# you also reaset the word counter
	li  $t4, 1


	addi  $t1, $t1, 1  # this is the reader inside the book file
	j   loop_read_character_analyse 

new_line_check_word_count:   # this gets executed when the current char is the newline and if the current sentence is the same as thekey sentence
	
	# so now we check if the word count is less than the key words count
	slt $t5, $t4, $s3
	# if t5 is one then it means you haven't found the word
	beq  $t5, 1, print_new_line_prepare_new_word
	
	# if not then it means that you finished a line where the word was printed, so you know that you can llook for the new word
	j loop_new_key_find_word

print_new_line_prepare_new_word: # this gets execute if in a key does not show a word so yo print a newline
	
	la  $a0, newline
	li  $v0, 4
	syscall
	
	# you also know that the next word is comming so it is the first of the sentence and that the char is the first
	li  $t6, 1
	li  $t7, 1
	
	# you can now look for the new word
	j loop_new_key_find_word		

space:   # this gets executed if the current character is a space

	# as you hit a space, you add one to the word count
	addi  $t4, $t4, 1

	addi  $t1, $t1, 1  # this is the reader inside the book file
	j   loop_read_character_analyse 

prepare_next_loop_read_character:   # this gets called if the current iteratoin of the loop we printed the character because of the key
	
	addi  $t1, $t1, 1  # this is the reader inside the book file
	j   loop_read_character_analyse                                                                                                                                                                                                                                                                                            
	                                                                                                                                                                                                                                                                
end_print_words_from_book_using_keys: # you have to end program with a new line so here it is
	
	la  $a0, newline
	li  $v0, 4
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
