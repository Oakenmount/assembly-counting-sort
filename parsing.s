.section .text

###############################################################################
# This function returns the amount of numbers in the given buffer in rax. First
# parameter is the address of the buffer, second parameter is the size of the
# buffer.
# Numbers are counted by counting the number of LF characters, so also the last
# line must be properly terminated.
###############################################################################
.globl get_number_count
.type get_number_count, @function
get_number_count:
	                        # rdi has the buffer start
	                        # rsi has the size
	addq %rdi, %rsi         # make rsi the past-the-end pointer
	xorq %rax, %rax         # count = 0
num_count:
	cmpq %rdi, %rsi
	je end_counting         # if rdi == rsi: we are done
	movb (%rdi), %dl        # load the next byte
	addq $1, %rdi
	cmpb $0xA, %dl          # is it the line-feed char?
	jne num_count           # if not, continue in the buffer
	addq $1, %rax           # completed a number
	jmp num_count
end_counting:
	ret


###############################################################################
# This function parses the raw data given in a buffer and stores integers
# in a second buffer. Note, this functions only expects unsigned ints and does
# no validity check at all.
# 
# Parameters:
# rdi: Address of raw data buffer
# rsi: Length of raw data buffer
# rdx: Address of target buffer with enough space for 8 bytes per number.
###############################################################################

.globl parse_number_buffer
.type parse_number_buffer, @function
parse_number_buffer:
	addq %rdi, %rsi         # make rsi the past-the-end pointer
	# Now, lets reconstruct the numbers!
for_each_number:
	cmpq %rdi, %rsi
	je end_for_each_number
	xorq %rax, %rax	        # the accumulated number
for_each_char:
	xorq %r10, %r10         # the next digit
	movb (%rdi), %r10b      # read byte
	addq $1, %rdi
	cmpq $0xA, %r10			# done with this number
	je end_for_each_char
	# add this digit to the current number
	subq $48, %r10          # convert the ASCII code to the digit it represents
	imul $10, %rax          # 'make room' for the new digit
	addq %r10, %rax         # and add the new digit
	jmp for_each_char
end_for_each_char:
	# we now have a number in rax
	movq %rax, (%rdx)		# store the number
	addq $8, %rdx           # point to the next place for a number
	jmp for_each_number
end_for_each_number:
	ret
