############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

.globl create_network
create_network:
 addi $sp, $sp, -4
 sw $ra, 0($sp)
 
 bltz $a0, wrong_end # checks if I is negative (No. of nodes possible)
 bltz $a1, wrong_end # checksif J is negative (No. of edges possible)
 
 move $t0, $a0 # maximum number of nodes 
 move $t1, $a1 # maximum number of edges
 
 li $t2, 4 # size of byte
 li $t3, 0 # register that stores the number of additonal storage (nodes)
 mul $t3, $t2, $t0
 
 li $t4, 0 # register that stores the number of additonal storage (edges)
 mul $t4, $t2, $t1
 
 add $t5, $t3, $t4
 addi $t5, $t5, 16 # 'N' - number of bytes to store in heap
 
 move $a0, $t5
 li $v0, 9
 syscall # $v0 has the storage allocation for the Network Instantiation
 
 move $t6, $v0 # moved the reference to the storage allocation in $t6
 
 sw $t0, 0($t6)
 sw $t1, 4($t6)
 
 j common_end

 wrong_end:
  li $v0, -1
  j common_end

 common_end:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

.globl add_person
add_person: # $a0, has the reference to the network and $a1 has the reference to the null-terminated word
 addi $sp, $sp, -4
 sw $ra, 0($sp)
 
 # check if the Network is at capacity
  move $t0, $a0
  lw $t1, 0($t0) # capacity
  addi $t0, $t0, 8
  lw $t2, 0($t0) # filled amount
  beq $t1, $t2, error_load
  
 
 # check if the input name exists in the Network
  jal get_person
  li $t0, -1
  bne $v0, $t0, error_load
 
 # instantiate the Node 
  
 li $t0, 0 # length of the string
 move $t1, $a1 # address of the string
   
 length_string: # find the length of the string
  lbu $t2, 0($t1)
  beqz $t2, end_counter
  addi $t0, $t0, 1
  addi $t1, $t1, 1
  j length_string
  
 end_counter:
  beqz $t0, error_load
  addi $t0, $t0, 1
  move $t1, $t0
  addi $t1, $t1, 4 # bytes required for Node
 
  move $t6, $a0
  
  move $a0, $t1
  li $v0, 9
  syscall
  
  move $a0, $t6
   
  move $t2, $v0 # reference to the node
  
  # modify the Node
   addi $t1, $t1, -5 # length of string
   sw $t1, 0($t2)
   
   move $t3, $t2
   addi $t3, $t3, 4 # moved the reference of node
  
   move $t4, $a1 # address to the string
   
  load_string: # find the length of the string
   lbu $t5, 0($t4)
   sb $t5, 0($t3) 
   beqz $t5, end_load
   addi $t3, $t3, 1
   addi $t4, $t4, 1
   j load_string
 
  end_load: # load the Node into the Network
   move $t3, $a0 # copied the reference of Network to $t3
   addi $t3, $t3, 8 # moving past N and E
   lw $t4, 0($t3)
   addi $t4, $t4, 1
   sw $t4, 0($t3) # updated the number of nodes
   addi $t3, $t3, 8 # moving past X and Y
   
  add_person_to_network:
   addi $t4, $t4, -1 # number of existing nodes
   li $t5, 4
   mul $t4, $t4, $t5 # number of entries to skip
   add $t3, $t3, $t4 # moved the reference of Network
   sw $t2, 0($t3)
   
   move $v0, $a0 # returning the reference to the Network
   j final_load
   
  error_load:
   li $v0, -1
   li $v1, -1

  final_load:
   lw $ra, 0($sp)
   addi $sp, $sp, 4
   jr $ra

.globl get_person
get_person: # $a0 has the reference to the Network and $a1 has the name of the person
  addi $sp, $sp, -4
  sw $ra, 0($sp)
  
  move $t0, $a0 # reference to the Network
  move $t1, $a1 # reference to the Name of the Person
  
  #check for failure cases
  
  addi $t0, $t0, 8 # changed the reference to the number of Nodes persent in the Network
  lw $t7, 0($t0) # X - number of nodes present in the Network
  beq $t7, $0, no_match
  
  addi $t0, $t0, 8 # changed the reference to the Nodes in the Network
  li $t8, 0 # number of nodes traversed
  
  lw $t2, 0($t0) # address of the Node
  addi $t2, $t2, 4
  move $t1, $a1 # reference to the Name of the Person
   
  compare_name:
   
   move $t6, $t0 # unchanged address of the Node
   lbu $t3, 0($t2) # Initials of the Name of the Node
   
   lbu $t4, 0($t1) # Initials of the Required Name of the Node
   
   bne $t3, $t4, no_name
   li $t5, 0
   add $t5, $t5, $t3
   sll $t5, $t5, 8
   add $t5, $t5, $t4
   
   beq $t5, $0, name
   addi $t2, $t2, 1
   addi $t1, $t1, 1
   j compare_name
   
  
  no_name:
   addi $t8, $t8, 1
   beq $t7, $t8, no_match
   addi $t0, $t0, 4
   lw $t2, 0($t0) # address of the Node
  addi $t2, $t2, 4
   j compare_name
   
  no_match:
   li $v0, -1
   li $v1, -1
   j common_name
  
  name:
   lw $t6, 0($t6)
   move $v0, $t6
   li $v1, 1
  
  common_name:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra

.globl add_relation
add_relation:
  addi $sp, $sp, -24
  sw $ra, 0($sp)
  sw $s0, 4($sp)
  sw $s1, 8($sp)
  sw $s4, 12($sp)
  sw $s5, 16($sp)
  sw $s3, 20($sp)
  
  # test for failures
   # name1 == name2
   
   move $t0, $a1 # address of name 1
   move $t1, $a2, # address of name 2
   
   is_name: # test for 'Saket' and 'Sak'
    lbu $t2, 0($t0)
    lbu $t3, 0($t1)
    bne $t2, $t3, network_cap
    beqz $t2, wrong_edge
    beqz $t3, wrong_edge
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j is_name
   
   # network is at capacity
   network_cap:
    move $t0, $a0
    addi $t0, $t0, 4
    lw $t1, 0($t0)
    addi $t0, $t0, 8
    lw $t2, 0($t0)
    beq $t1, $t2, wrong_edge
    
   # relation_type is less than 0 or greater than 3
   relation_check:
    move $t0, $a3
    bltz $t0, wrong_edge
    li $t1, 3
    bgt $t0, $t1, wrong_edge
   
   # names doesn't exist
    jal get_person
    li $t0, -1
    beq $v0, $t0, wrong_edge
    move $s4, $v0 # reference to Node 1
    move $s0, $a1
    
    move $a1, $a2
    jal get_person
    li $t0, -1
    beq $v0, $t0, wrong_edge
    move $s5, $v0 # reference to Node 2
    
    move $a2, $a1
    move $a1, $s0
    
   # edge between name1 and name2 already exists
   move $t0, $a0
   lw $t1, 0($t0) # number of max nodes
   addi $t0, $t0, 12
   lw $t2, 0($t0) # number of edges
   
   li $t3, 4
   mul $t4, $t3, $t1 # bits to skip for edges
   addi $t4, $t4, 4
   add $t0, $t4, $t0 # reference to the edge
   
   li $t4, 0 # number of edges iterated
   
   beq $t4, $t2, find_node
   
   edge_exists:
    lw $t7, 0($t0)
    lw $t5, 0($t7) # node 1
    lw $t6, 4($t7) # node 2
    
    beq $s4, $t5, check_next
    beq $s5, $t5, check_next
    addi $t0, $t0, 4
    addi $t4, $t4, 1
    beq $t4, $t2, find_node
    j edge_exists
    
    check_next:
    beq $s4, $t6, wrong_edge
    beq $s5, $t6, wrong_edge
    addi $t0, $t0, 4
    addi $t4, $t4, 1 
    beq $t4, $t2, find_node
    j edge_exists
  
  find_node:
   move $s0, $s4 # address to Node 1
   move $s1, $s5 # address to Node 2
   
  # create the Edge Data Structure
   move $s3, $a0
   li $a0, 12
   li $v0, 9
   syscall
   move $a0, $s3
   
   move $t0, $v0 # address for Edge Data Structure
   sw $s0, 0($t0)
   sw $s1, 4($t0)
   sw $a3, 8($t0)
  
  # add it to Network
   move $t1, $a0
   lw $t2, 0($t1) # number of nodes
   addi $t1, $t1, 12
   lw $t3, 0($t1) # number of existing edges
   addi $t3, $t3, 1
   sw $t3, 0($t1)
   addi $t3, $t3, -1
   addi $t1, $t1, 4
   
   li $t4, 4
   mul $t2, $t4, $t2 # bits to skip nodes
   mul $t3, $t4, $t3 # bits to skip edges
   add $t4, $t2, $t3 # total bits to skip
   
   add $t1, $t1, $t4 # bits skipped
   
   sw $t0, 0($t1) # edge saved
   
  correct_edge:
   move $v0, $a0
   li $v1, 1
   j end_edge
   
  wrong_edge:
  li $v0, -1
  li $v1, -1
  
  end_edge:
   lw $ra, 0($sp)
   lw $s0, 4($sp)
   lw $s1, 8($sp)
   lw $s4, 12($sp)
   lw $s5, 16($sp)
   lw $s3, 20($sp)
   addi $sp, $sp, 24
   jr $ra

.globl get_distant_friends
get_distant_friends:
 addi $sp, $sp, -4
 sw $ra, 0($sp)

 jal get_person
 
 li $t0, -1
 beq $t0, $v0, no_exist
 li $v0, -1
 j relation_exit
 
 no_exist:
  li $v0, -2
  
 relation_exit:
  lw $ra, 0($sp)
  addi $sp, $sp, 4
  jr $ra
