#include "alloc.s"
#include "file_handling.s"
#include "parsing.s"
#include "print.s"
#include "invalidfile.lmao"

.section .data
.section .text
.globl _start

_start:
	#get file size
	movq $0, %rdi		# stdin
	call get_file_size	# get file size of stdi
	movq %rax,%r8

	#allocate memory for file
	movq %rax,%rdi		# result of call in %rdi
	call alloc_mem		# allocate memory for file reading
	movq %rax,%r9		# move buffer pointer to r8

	#read file
	movq $0, %rax		# rax: read
	movq $0, %rdi		# file: stdin
	movq %r9,%rsi		# buffer location
	movq %r8,%rdx		# size
	syscall			# read into buffer

	#get number count
	movq %r9,%rdi		# buffer pointer
	movq %r8,%rsi		# buffer size
	push %r9		# push to stack for later use
	push %r8		# same as above
	call get_number_count	# put number count in rax

	#allocate memory for numbers
	movq $8,%r10		# move multiplier to r10
	mul %r10		# multiply rax by 8 (rax is get_number_count)
	movq %rax,%rdi		# move required mem to rdi
	push %rdi		# push mem size to stack
	call alloc_mem		# allocate mem to rax
	movq %rax,%r11		# store pointer in r11
	pop %r8			# get mem size


	#parse numbers
	pop %rsi		# read buffer size
	pop %rdi		# read buffer pointer
	push %r8		# push write buffer size for later use
	movq %r11,%rdx		# write buffer pointer
	push %rdx		# push buffer pointer to stack for reading
	call parse_number_buffer

	# get higest number
	pop %rdx		# get buffer pointer
	pop %rsi		# get write buffer size
	push %rdx		# push both values again
	push %rsi
	call get_highest_num	# get highest number

	#allocate mem for array B (the counting array)
	addq $2,%rdi		# need max + 2. (1 each val and a 0 at end)
	movq %rdi,%rax		# multiply by 8
	movq $8,%r8
	mul %r8
	movq %rax,%rdi
	push %rdi		# push count array length
	call alloc_mem

	pop %r8			# count array length
	pop %rdi		# get input size. input pointer is at top of stack
	push %rdi		# push input size to stack
	push %rax		# put counting array on top of stack
	push %r8		# push count array length to stack
	call alloc_mem		# allocate output array

	#run count sort		# r8=in,r9=count,r10=out,r=11 count len, rdi=in out len
	movq %rax,%r10		# output
	pop %r11		# count len
	pop %r9			# counting array
	pop %rdi		# input/output len
	pop %r8			# input


	push %rdi		# inout len
	push %r10		# output arr

	call countingsort	# run sorting algorithm

	pop %rax		# retrive output array to print
	pop %rdi
	call print_array

	call exit		# exit

#rax=buf,rdi=len
print_array:
	movq %rdi,%rsi		# setup loot
	addq %rax,%rsi
	jmp print_array_loop
print_array_loop:
	cmpq %rax,%rsi
	je print_array_end

	push %rax
	push %rsi
	movq (%rax),%rdi
	call print_number
	pop %rsi
	pop %rax
	addq $8,%rax
	jmp print_array_loop
print_array_end:
	ret

countingsort:
	movq %rdi,%rsi		# set end point of buffer for iteration
	addq %r8,%rsi
	push %r8		# save input buffer location
	push %r9		# save count buffer
	jmp count_numbers
count_numbers:
	jmp count_numbers_loop

count_numbers_loop:
	cmpq %r8,%rsi		# are we at the end of the array?
	je add_numbers		# time to output numbers then
	movq (%r8),%r12		# move current num to r12
	addq $8,%r8		# move forward in array
	addq $1,(%r9,%r12,8)	# increment memory location of number by 1
	jmp count_numbers_loop	# loop again

add_numbers:
	movq %r11,%rsi		# set end point of buffer. r11=count len, r9= count array
	addq %r9,%rsi
	jmp add_numbers_loop

add_numbers_loop:
	cmpq %r9,%rsi		# are we at end of array?
	je output_numbers
	movq (%r9),%r12		# move cur num to r12
	addq $8,%r9		# increment iterator
	addq %r12,(%r9)		# add cur num to next num
	jmp add_numbers_loop

output_numbers:
	pop %r9			# get r9 buffer start
	pop %r8			# get r8 buffer start (we iterate over this)
	movq %rdi,%rsi		# set end point of input buffer
	addq %r8,%rsi		# r8 is input buf that we iterate over
	jmp output_numbers_loop

# this needs to look at input and count array. Assume everything else works
#r8 in, r9 count, r10 out,r11 count len, rdi inout len 
output_numbers_loop:
	cmpq %r8,%rsi		# are we at the end of the array?
	je countingsort_end	# time to output numbers then

	movq (%r8),%r12		# curval
	movq (%r9,%r12,8),%r13	# count value
	subq $1,(%r9,%r12,8)	# decrement value at index
	movq %r12,-8(%r10,%r13,8) # set output index to curval

	addq $8,%r8		# increment and loop
	jmp output_numbers_loop
countingsort_end:
	subq %rdi,%r10		# set r10 to buffer start
	movq %r10,%rax		# move r10 to rax
	ret


# rdx=buf start, rsi=buf size, rdi=highest num at finish
get_highest_num:
	movq $0,%rdi		# rdi is highest num
	addq %rdx,%rsi		# rsi is now the end of mem heap
	jmp check_next_num	# keep it moving

check_next_num:
	cmpq %rdx,%rsi		# are we at end of mem heap?
	je end_highest_num	# end if we are

	movq (%rdx),%r13	# store cur num in %r13
	addq $8,%rdx		# get next num

	cmpq %r13,%rdi		# compare current number with higest
	jl set_highest_num

	jmp check_next_num	# keep looping

set_highest_num:
	movq %r13,%rdi		# set new highest num
	jmp check_next_num	# go back to start of loop

end_highest_num:
	ret





exit:
	# Syscall calling sys_exit
	movq $60, %rax            # rax: int syscall number
	movq $0, %rdi             # rdi: int error code
	syscall
