###############################################################################
# This function is our simple and naive memory manager.
# It expects to receive the number of bytes to be reserved in %rdi and will
# return a pointer to the beginning of the allocated memory in %rax.
###############################################################################

.section .text
.globl alloc_mem
.type alloc_mem, @function
alloc_mem:
	push %rdi           # push the argument
	#First, we need to retrieve the current end of our heap
	movq $12, %rax      # brk
	xorq %rdi, %rdi     # passing 0 means we retrieve the current end of the heap
	syscall
	pop %rdi            # get the argument back
	push %rax           # the current end will be the address of the beginning of
	                    # of the extension of the heap that we next create
	addq %rax, %rdi     # add the old break to the amount of space the user wants
	movq $12, %rax      # brk
	syscall
	pop %rax            # get back the beginning of the new memory block
	ret
