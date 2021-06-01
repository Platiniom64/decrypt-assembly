# decrypt-assembly
This is a coursework for University.
I created decrypt and encrypt tools for different types of encryptions, using the MIPS assembly programming language.

In the file 1-find_words, there is a program that can list each word in input_text in order of occurence, one per line.

In the file 2-steganography, there is a program that will take each word on each line when the word number matches the line number. If a line has fewer words than its line number that signifies a newline character.

In the file 3-xor, there is a program that applies the bitwise XOR operator to characters using a secret key. input_xor.txt contains the text to encrypt and key_xor.txt
contains the secret key.

In the file 4-book, there is a program that decrypt a text by using a book cipher. input_book_cipher.txt contains the keys for decoding the book, and book.txt is the book to decode.

In the file 5-xor_cracking, there is a program that cracks a XOR cipher by finding the secret 1 byte key. There is also a hint phrase provided to find what the key is. input_xor_crack.txt contains the encrypted text to decrypt and hint.txt contains the hint phrase.
