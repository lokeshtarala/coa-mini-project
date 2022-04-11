.data
buffer: .space 64
str1:  .asciiz "Enter the destination address between 2-9: "
str2:  .asciiz "\nEnter string(max 40 chars): "

.text
.globl main # define a global function main
# the program begins execution at main()

# this macro converts integer to ascii and stores it in the buffer
.macro itoa () # i stored in $t0
    # find the last digit of the two digit number by dividing by 10.
    div $t1,$t0,10
    # convert it to ascii by adding 48 to integer
    add $t1,$t1,48
    # store it in the buffer
    sb $t1,($a0)
    # point it to next byte
    addi $a0, $a0, 1 # go to next byte  

    # find the last digit
    rem $t1,$t0,10
    add $t1,$t1,48
    sb $t1,($a0)
    addi $a0, $a0, 1 # go to next byte  
    # divide the number by 10
.end_macro

.macro counter ()
    li $t0, 0 # initialize loop-counter 

    loop:
        lb $t1, ($a0) # load the content of the address stored in $a0
        beq $t1, $zero, exit    # branch if equal
                    # exit the program if $t0 == null 

        addi $t0, $t0, 1 # increment the loop counter
        addi $a0, $a0, 1 # go to next byte      
        j loop 
    exit:
        sub $t0,$t0,1
.end_macro

# this functions takes the address of the input and prints it on the screen
.macro print_str (%str)
    la $a0,%str 
    li $v0,4
    syscall
.end_macro

# this function takes the input from user and saves in the buffer 
.macro input_str (%buff)
    li $v0,8 # take in input
    li $a1, %buff # allot the byte space for string
    syscall
.end_macro

.macro checksum ()
        la $a0,buffer
        li $t3,3
        # initiate check sum
        li $t5,0
        # divide the number by 10
    loop3: 
        #take the first byte and convert it into integer and multuply by 10 
        lb $t1, ($a0) # load the content of the address stored in $a0
        sub $t1,$t1,48 #convert back to integer
        mul $t1,$t1,10
        addi $a0,$a0,1
        lb $t4, ($a0) # load the content of the address stored in $a0
        sub $t4,$t4,48 #convert back to integer
        add $t1,$t1,$t4
        addi $a0,$a0,1
        add $t5,$t5,$t1
        sub $t3,$t3,1
        beq $t3, $zero, exit    # branch if equal
        j loop3
    exit:
    .end_macro

main:
# load the address of empty space into $a0
la $a0, buffer 

# this is the source address
li $t0,1

# this converts the source address into ascii and stores it in the first two bytes of buffer  
itoa()

# temporarily store the address of 3rd byte of buffer in $t2 
move $t2,$a0

# print to ask for destination address 
print_str (str1)
 
# move back the address of buffer to $a0
move $a0,$t2

# read the destination address from user
li $v0,5
syscall

# store it to $t0 which is then converted to ascii and stored in 3rd and 4th byte of buffer 
move $t0,$v0
itoa ()
move $t2,$a0

# ask the user to enter the message 
print_str (str2)

# move back the address of buffer to $a0
move $a0,$t2

# reserve four bytes for length and checksum (each 2 bytes)
addi $a0,$a0,4

# read the message from user and save it in buffer starting from 9th byte
input_str(40)

# calculate the length of the message
counter () # stores the length of message in $t0 
move $a0,$t2 # move back the address of buffer to $a0
itoa () # convert the value in $t0 and store it in the 5th and 6th bytes of buffer

# similarly calculate the checksum and store it in the 7th and 8th bytes of buffer
checksum () 
move $a0,$t2 
addi $a0,$a0,2
move $t0,$t5
itoa()

# display the packet
print_str (buffer)