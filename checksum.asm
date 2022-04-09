.data
buffer: .space 20
str1:  .asciiz "Enter string(max 20 chars): "
str2:  .asciiz "You wrote:\n"

.text
.globl main #define a global function main
# the program begins execution at main()

main:

#print to ask for input
la $a0,str1 #Load and print string asking for string
         li $v0,4
         syscall


li $v0,8 #take in input
         la $a0, buffer #load byte space into address
         li $a1, 20 # allot the byte space for string
         move $t0,$a0 #save string to t0
         syscall
         
la $a0,str2 #load and print "you wrote" string
         li $v0,4
         syscall

         la $a0, buffer #reload byte space to primary address
         move $a0,$t0 # primary address = t0 address (load pointer)
         li $v0,4 # print string
         syscall

#
li $t0, 0 # initialize loop-counter 
la $a0, buffer # $a0 = address of message1

    loop:
        lb $t1, ($a0) # load the content of the address stored in $a0
        beq $t1, $zero, exit    # branch if equal
                    # exit the program if $t0 == null 

        addi $t0, $t0, 1 # increment the loop counter
        addi $a0, $a0, 1 # go to next byte      

        j loop 

    exit:
        move $a0, $t0 # prepare to print the integer
        li $v0, 1 # integer syscall
        syscall

        li $v0, 10
        syscall 