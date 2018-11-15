###############################################################################
# Given a file descriptor %rdi, this function will return the size of
# the file (number of bytes) in %rax.
###############################################################################
.section .data
file_stat:
	.space 144            # size of the fstat struct
.section .text
.globl get_file_size
.type get_file_size, @function
get_file_size:
	movq $5, %rax         # fstat
	                      # rdi already contains the fd
	movq $file_stat, %rsi # reserved space for the stat struct
	syscall
	movq $file_stat, %rax
	movq 48(%rax), %rax   # position of size in the struct
	ret
