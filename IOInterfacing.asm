.text
main: 		 
		jal init7SegDisp
		jal getPressedKey
		add $a0,$v0,$zero
		jal Num2SegDisp
		
		lw $t4, 8($t0)
		and $t4, $t4, $t6
		bne $t4, 0x71, getPressedKey
    
exit: 		
		li   $v0, 10          # system call for exit
		syscall
			
.data
	SegBytes: .byte  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6D, 0x7D, 0x7, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79

.text
init7SegDisp: 
		lui $t0, 0xffff   # load $t0 with base IO address
		addi $t1, $zero, 0x3F  # load seven segment display pattern for 0
		sb $t1, 0x10($t0)  # send 0 to right segment display
		sb $t1, 0x11($t0)  # send 0 to left segment display
			
Num2SegDisp:
		beqz $s0, L
		lui 	$t0, 0xffff  
		sb	$t1, 0x11($s0)
L:		
		la 	$t0, SegBytes # load the base address of seven-seg pentterns
		add 	$t0, $t0, $a0    # calculate the address of the target pattern
		lb	$t1, 0($t0)    # load the target pattern 
		lui 	$t0, 0xffff   # load $t0 with base IO address	
		sb 	$t1, 0x10($t0) # send the target pattern to the 7-segment disp
		move $s0, $t0
		
getPressedKey: 
		lui $t0, 0xffff   		# load $t0 with base IO address		
		
FstRow:		
		addi $t4,$zero, 1      # set $t4 to 1 to scan the first row
		sb $t4, 0x12($t0)  	# command first row scanning at 0xFFFF0012
		lb  $t2, 0x14($t0)  	# read  0xFFFF0014 for pressed keys 
		bne $t2, $zero, KeyPress # check any pressed keys [zero --> nothing pressed]		
		
#2nd row
		addi $t4,$zero, 2      
		sb $t4, 0x12($t0)  	
		lb  $t2, 0x14($t0)  
		bne $t2, $zero, KeyPress 
		
# 3rd row
		addi $t4,$zero, 4      
		sb $t4, 0x12($t0)  	
		lb  $t2, 0x14($t0)  	
		bne $t2, $zero, KeyPress 	
		
# 4th 
		addi $t4,$zero, 8
		sb $t4, 0x12($t0)  	
		lb  $t2, 0x14($t0)
		li $t6, -120
		beq $t2, $t6, p
		bne $t2, $zero, KeyPress 
		bne $t0, $t6, main
		
KeyPress:	
		andi $t3,$t2,0xf0    	# Mask 0xFFFF0014 most significant nibble 	
		andi $t2,$t2,0xf      	# Mask 0xFFFF0014 least significant nibble 
		srl   $t3,$t3,4         	# shift $t3 for further processing 

		####  Calculate log $t3   ##########
		add $t5,$zero, $zero
				
logt3:	srl   $t3,$t3,1       
		beqz $t3, t5_t3
		addi $t5, $t5, 1
		j  logt3
		
t5_t3:	move $t3,$t5
	####  Calculate log $t3   ##########
		add $t5,$zero, $zero
		
logt2:	srl   $t2,$t2,1       
		beqz $t2, t5_t2
		addi $t5, $t5, 1
		j  logt2
		
t5_t2:	move $t2,$t5
		## calculate the value of the pressed key ## 
		mul $t2,$t2,4
		add  $v0,$t3,$t2
		
		jr $ra 
		
p:
	li $v0, 15
