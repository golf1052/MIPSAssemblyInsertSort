.globl main
.data
.align 2
pointers: .space 64
.align 5
names:  .asciiz "Joe"
	.align 5
	.asciiz "Jenny"
	.align 5
	.asciiz "Jill"
	.align 5
	.asciiz "John"
	.align 5
	.asciiz "Jeff"
	.align 5
	.asciiz "Joyce"
	.align 5
	.asciiz "Jerry"
	.align 5
	.asciiz "Janice"
	.align 5
	.asciiz "Jake"
	.align 5
	.asciiz "Jonna"
	.align 5
	.asciiz "Jack"
	.align 5
	.asciiz "Jocelyn"
	.align 5
	.asciiz "Jessie"
	.align 5
	.asciiz "Jess"
	.align 5
	.asciiz "Janet"
	.align 5
	.asciiz "Jane"
size: .word 16
leftbracket: .asciiz "["
space: .asciiz " "
rightbracket: .asciiz "]\n"
initialarray: .asciiz "Initial array is:\n"
nullchar: .ascii "\0"
finishedinsertsort: .asciiz "Insertion sort is finished!\n"

.text
main:
	# char * data[] = {"Joe", "Jenny", "Jill", "John", "Jeff", "Joyce",
	#	"Jerry", "Janice", "Jake", "Jonna", "Jack", "Jocelyn",
	#	"Jessie", "Jess", "Janet", "Jane"};
	# int size = 16;
	
	# load size, names, and pointers
	lw $t0, size
	la $t1, names
	la $t2, pointers
	jal setup_pointers_loop
	
	# reload our things because they were modified in the loop
	lw $t0, size
	la $t1, names
	la $t2, pointers
	
	# printf("Initial array is:\n");
	li $v0, 4
	la $a0, initialarray
	syscall
	
	# print_array(data, size);
	move $a0, $t0
	move $a1, $t2
	jal print_array
	
	# reload our things because they were modified in the loop
	lw $t0, size
	la $t1, names
	la $t2, pointers
	
	# call insert sort
	move $a0, $t2
	move $a1, $t0
	jal insert_sort
	
	# printf("Insertion sort is finished!\n");
	li $v0, 4
	la $a0, finishedinsertsort
	syscall
	
	# reload our things because they were modified in the loop
	lw $t0, size
	la $t1, names
	la $t2, pointers
	
	# print_array(data, size);
	move $a0, $t0
	move $a1, $t2
	jal print_array
	
	# exit(0);
	li $v0, 10
	syscall
	
setup_pointers_loop:
	sw $t1, 0($t2) # set $t2 to point to $t1
	subi $t0, $t0, 1 # sub the count by one
	addi $t1, $t1, 32 # move to the next name
	addi $t2, $t2, 4 # move to the next pointer location in pointers
	bgtz $t0, setup_pointers_loop # if we arent done setting pointers yet then loop
	jr $ra # if we are done then go back to main
	
insert_sort:
	addi $sp, $sp, -4 # add memory to the call frame
	sw $ra, 0($sp) # save the return address from main
	move $s0, $a0 # move array into $s0 to use
	move $s1, $a1 # move length into $s1 to use
	
	# $s2 = i $s3 = j
	# int i, j;
	move $s2, $zero # i = 0
	move $s3, $zero # j = 0
	addi $s2, $s2, 1 # i = 1
	j insert_sort_i_loop

# for(i = 1; i < length; i++) {
insert_sort_i_loop:
	move $s7, $zero
	mul $s7, $s2, 4 # multiply i by 4 to get the location we want to get to in the array
	add $s0, $s7, $s0 # add the result to the array to move the array to where a[i] is
	# char *value = a[i];
	lw $s4, 0($s0) # $s4 = *value
	sub $s0, $s0, $s7 # subtract the result again to reset the pointer
	move $s3, $s2 # j = i
	subi $s3, $s3, 1 # j = i - 1
	j insert_sort_j_loop
	
# a[j+1] = value;
insert_sort_i_loop_end:
	addi $s3, $s3, 1 # j++
	move $s7, $zero
	mul $s7, $s3, 4 # multiply j by 32 to get the location we want to get to in the array
	subi $s3, $s3, 1 # j-- to reset j
	add $s0, $s7, $s0 # add the result to the array to move the array to where a[j + 1] is
	sw $s4, 0($s0) # set a[j + 1] to what a[i] is
	sub $s0, $s0, $s7 # subtract the result again to reset the pointer
	addi $s2, $s2, 1 # i++
	blt $s2, $s1, insert_sort_i_loop
	lw $ra, 0($sp)
	addi $sp, $sp, 4 # pop the stack
	jr $ra

# for (j = i-1; j >= 0 && str_lt(value, a[j]); j--) {
insert_sort_j_loop:
	move $s7, $zero
	mul $s7, $s3, 4 # multiply j by 4 to get the location we want to get to in the array
	add $s0, $s7, $s0 # add the result to the array to move the array to where a[j] is
	# s5 = *value2
	lw $s5, 0($s0) # char *value2 = a[j]
	sub $s0, $s0, $s7 # subtract the result again to reset the pointer
	la $a0, 0($s4) # move value into $a0 so we can send it to string_less_than
	la $a1, 0($s5) # move value2 into $a1 so we can send it to string_less_than
	jal string_less_than
	move $t8, $v0 # move the result from string_less_than into a register so we can use it
	beq $t8, 1, shift_values # if string_less_than returns 1 shift the values
back_to_j:
	j insert_sort_i_loop_end # else break and go back to i loop

# a[j+1] = a[j];
shift_values:
	move $s7, $zero
	mul $s7, $s3, 4 # multiply j by 4 to get the location we want to get to in the array
	add $s0, $s7, $s0 # add the result to the array to move the array to where a[j] is
	lw $t9, 0($s0) # store a[j] in a temp
	sub $s0, $s0, $s7 # subtract the result again to reset the pointer
	addi $s3, $s3, 1 # j = j + 1
	move $s7, $zero
	mul $s7, $s3, 4 # multiply j by 4 to get the location we want to get in the array
	subi $s3, $s3, 1 # j = j - 1 to reset j
	add $s0, $s7, $s0 # add the result to the array to move the array to where a[j + 1] is
	sw $t9, 0($s0) # set a[j + 1] to a[j]
	sub $s0, $s0, $s7 # subtract the result again to reset the pointer
	subi $s3, $s3, 1 # sub j by 1
	# THIS WAS THE LAST BROKEN LINE
	bgez $s3, insert_sort_j_loop
	# ALSO I HATE MARS FOR NOT TELLING ME ABOUT STACK OVERFLOWS
	j back_to_j

##### STRING LESS THAN METHOD #####
string_less_than:
	# move the strings into useable registers
	move $t0, $a0 # $t0 = string a (not actually string but pointer to string)
	move $t1, $a1 # $t1 = string b (not actually string but pointer to string)
	la $t2, nullchar # load the nullchar so we can compare it to stuff
	lb $t5, 0($t2) # load the null char
	j string_less_than_loop

# for (; *x!='\0' && *y!='\0'; x++, y++) {
string_less_than_loop:
	lb $t3, 0($t0) # load the first char
	lb $t4, 0($t1) # load the second char
	blt $t3, $t4, string_less_than_return1
	blt $t4, $t3, string_less_than_return0
	addi $t0, $t0, 1 # increase the pointer by 4 bits to get to the next letter
	addi $t1, $t1, 1 # same as above
	# if ( *x < *y ) return 1;
	bne $t3, $t5, string_less_than_loop # if x != \0 then loop again
	# if ( *y < *x ) return 0;
	bne $t4, $t5, string_less_than_loop # if y != \0 then loop again
	# if ( *y == '\0' ) return 0;
	beq $t4, $t5, string_less_than_return0 # if y == \0 then return 0
	# else return 1;
	j string_less_than_return1 # else return 1

# return 0;
string_less_than_return0:
	li $v0, 0
	jr $ra
	
# return 1;
string_less_than_return1:
	li $v0, 1
	jr $ra
##### STRING LESS THAN METHOD END #####



##### PRINT ARRAY METHOD #####	
print_array:
	# move size and names into usable registars
	move $t0, $a0
	move $t1, $a1
	
	# int i=0;
	# set t2 to 0, $t2 will be our count
	move $t2, $zero
	
	# printf("[");
	li $v0, 4
	la $a0, leftbracket
	syscall
	
	j print_array_loop

#while(i < size)
print_array_loop:
	# printf("  %s", a[i++]);
	li $v0, 4
	la $a0, space
	syscall
	
	# print what section in names we are at currently
	li $v0, 4
	lw $a0, 0($t1)
	syscall
	
	addi $t1, $t1, 4 # increase pointer to names by 4 to get the next name
	addi $t2, $t2, 1 # increase the count by one
	beq $t2, $t0, print_array_end # if the count is equal to the size then jump
	j print_array_loop
	
print_array_end:
	# print space
	li $v0, 4
	la $a0, space
	syscall
	
	# printf(" ]\n");
	li $v0, 4
	la $a0, rightbracket
	syscall
	
	# go back to where ever we were called
	jr $ra	
##### PRINT ARRAY METHOD END #####	
