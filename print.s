.section .text

###############################################################################
# This function prints a non-negative number followed by an LF character to
# stdout. The number is given in rdi.
###############################################################################

.globl print_number
.type print_number, @function
print_number:
	movq $1, %r9            # count the number of chars to print
	push $10                # store the chars on the stack, we always have '\n'
	movq %rdi, %rax         # things are easier with it in rax
	movq $10, %rcx
decode_loop:	
	movq $0, %rdx          
	idivq %rcx              # do rdx:rax / rcx
	addq $48, %rdx          # convert the remainder to an ASCII digit
	pushq %rdx              # and save it on the stack
	addq $1, %r9            # while counting the number of chars
	cmpq $0, %rax
	jne decode_loop         # loop until rax == 0
write_loop:
	movq $1, %rax           # write
	movq $1, %rdi           # to stdout
	movq %rsp, %rsi         # which is stored here
	movq $1, %rdx           # a single character/byte
	syscall
	addq $8, %rsp           # pop the character
	addq $-1, %r9           # correct the char count
	jne write_loop          # loop until r9 reaches 0
	ret


###############################################################################
# This function prints a nul-terminated string to some file.
# The file descriptor to print to must be in rdi.
# The address of string is given in rsi.
###############################################################################

.globl print_string
.type print_string, @function
print_string:
	movq %rsi, %rdx
string_length:
	movb (%rdx), %r9b       # load byte
	cmpb $0, %r9b           # end of string?
	jz string_length_done
	addq $1, %rdx           # increase pointer
	jmp string_length
string_length_done:
	movq $1, %rax           # write
	                        # fd already in rdi
	                        # pointer to buffer already in rsi
	subq %rsi, %rdx         # length of string
	syscall
	ret
