.data
# DONOTMODIFYTHISLINE
frameBuffer: .space 0x80000 # 512 wide X 256 high pixels
M: .word 100
N: .word 76
cr: .word 100
cg: .word 255
cb: .word 50
# DONOTMODIFYTHISLINE
# Your other variables go BELOW here only
# DONOTMODIFYTHISLINE
r: .word 255      # Red component for yellow (255)
g: .word 255      # Green component for yellow (255)
b: .word 255        # Blue component for yellow (0)

    .text  
    .globl main
    
main:
addi $a0, $zero, 0 # a0<-0, counter for what shapes
 
# check if M and N are valid
lw $t1, M # t1<-M
lw $t2, N # t2<-N
ble $t1, $zero, onlyBackground # M <= 0, only draw yellow
ble $t2, $zero, onlyBackground # N <= 0, only draw yellow
sub $t4, $t1, $t2 # t4<-M-N
ble $t4, $zero, onlyBackground # if M < N, only draw yellow
andi $t6, $t1, 1 # t6<-M+8 AND 1
bne $t6, $zero, onlyBackground # M is odd, only draw yellow

j drawAllShapes

onlyBackground:
subi $a0, $a0, 4 # stops from redrawing background and drawing other shakes 
la $t0,frameBuffer # t0 <- frameBuffer, bc it is only called in drawAllShapes
j Background

drawAllShapes:
la $t0,frameBuffer # t0 <- frameBuffer
addi $a0, $a0, 1
beq $a0,1, Background
beq $a0,2, Left
beq $a0,3, Right
beq $a0,4, TriangleColor
j Exit

Background:
li $t3,0x00FFFF00 # $t3 ← yellow

# background
addu $a1, $zero, $t0
addiu $a2, $zero, 512
sll $a2, $a2, 2 # a2<- 512*4
sll $a3, $a2, 8 # a3<- 512*4*256
addu $a2, $a1, $a2 # a2<- 512*4 + frameBuffer
addu $a3, $a1, $a3 # a3<- 512*4*256 + frameBuffer
addu $t0, $zero, $a1 # t0<-start position+framebuffer
j drawRectangle

Left:
#li $t3,0x0000FF00 # $t3 ← green

# load in green
lw $t4, cr
sll $t4, $t4, 16
lw $t5, cg
sll $t5, $t5, 8
lw $t6, cb
addu $t5, $t4, $t5
addu $t3, $t5, $t6 # $t3 ← green

addiu $t6, $zero, 512 #t6<-512
subu $t4, $t1, $t2 #t4<-M-N
srl $t4,$t4, 1 #t4<-(M-N)/2
addiu $t4,$t4,8 #t4<-(M-N)/2+8
addu $t4,$t4,$t1 #t4<-(M-N)/2+8+M
subu $t4, $t6, $t4 #t4<-512-(M-N)/2+8+M, 2w
srl $t4,$t4, 1 # t4<-512-(M-N)/2+8+M/2, w
addiu $t6, $zero, 256 #t6<-256
addiu $t5, $t1, 8 #t5<-M+8
subu $t5, $t6, $t5 #t5<-256-(M+8)
sll $t5, $t5, 8 # t5<-256-(M+8)/2*512, area of padding, v
addu $a1, $t4, $t5 # w + v
sll $a1, $a1, 2 # a1<-start position, (w + v*512)*4 = pixel translation
addu $a1, $t0, $a1 # a1<-start position+framebuffer

subu $t6, $t1, $t2 #t6<-M-N
sll $t6, $t6, 2 #t6<-M-N * 4
addu $a2, $a1, $t6 # a2 <- start position + width, right boundary

addu $t6, $zero, $t2 #t6<-N
sll $t6, $t6, 11 #t6<-N * 512 * 4
addu $a3, $t6, $a2 # t6<-N * 4 * 512 + a2, final boundary

addu $t0, $zero, $a1 # t0<-start position+framebuffer
j drawRectangle

Right: 
# li $t3,0x0000FF00 # $t3 ← 

sub $a1, $t1, $t2 # a1<-M-N
sll $a1, $a1, 2 # a1<-M-N*4
add $a2, $zero, $t2 # a2<-N
sll $a2, $a2, 2 # a2<-N*4
add $a2, $a2, $a1 # a2<-N*4+M-N*4
sub $a1, $a3, $a1 # a1<- last bound, a3-M-N*4, first positions
#add $a2, $a3, $a2 # a2<-a3+N*4+M-N*4, first bound
add $a2, $a1, $a2 # a2<-a1+4, first bound

sub $a3, $t1, $t2 # a3<-M-N
sll $a3, $a3, 11 # a3<-M-N*512*4
add $a3, $a2, $a3 # a3<- M-N*512*4 + a1+4N, final placement

addu $t0, $zero, $a1 # t0<-start position+framebuffer
j drawRectangle


drawRectangle:
# a1 is top left starting position
# a2 is the right boundary to not go past, a0 + width
# a3 is the right ending position (a0 + height*512 + width)

ble $t0, $a2, drawLine
addiu $a1, $a1, 2048 # a1<- next line position
addu $t0, $zero, $a1 # t0<- next line position
addiu $a2, $a2, 2048 # a1<- next line boundary

ble $a2, $a3, drawRectangle
j drawAllShapes
# j drawLine # draw last line

drawLine:
# sw and incredmenting by 4 until hit boundary
# t0 is current pointer
sw $t3,($t0)
addiu $t0, $t0, 4
ble $t0, $a2, drawLine
j drawRectangle

TriangleColor:
# loads colors in t4,t5,t6
lw $t4, cr 
lw $t5, cg
lw $t6, cb

# shift left twice to multiply by 4
sll $t4, $t4, 2
sll $t5, $t5, 2
sll $t6, $t6, 2

# now check
j checkColor

checkColor:
# see if under 256
# if yes, lower
bge $t4, 256, lowerRed
bge $t5, 256, lowerGreen
bge $t6, 256, lowerBlue

j drawTriangle

lowerRed:
addi $t4, $zero, 255
j checkColor

lowerGreen:
addi $t5, $zero, 255
j checkColor

lowerBlue:
addi $t6, $zero, 255
j checkColor

drawTriangle:
# each part is shifts to combine and create new color
sll $t4, $t4, 16
sll $t5, $t5, 8
addu $t5, $t4, $t5
addu $t3, $t5, $t6 # $t3 ← input color * 4

# mark 3 points (bottom, middle, top) to decide boundaries
addiu $a1, $zero, 8 #a1<-8
sll $a1, $a1, 11 #a1<-8*512*4
addu $a1, $a3, $a1 #a1<-bottom right rect to padding to get to triangle edge, bottom

subu $a2, $t1, $t2 #a2<-M-N
srl $a2, $a2, 1 #a2<-M-N/2
addu $a3, $a2, $zero #a3<-M-N/2
addiu $a2, $a2, 8 #a2<-M-N/2+8, triangle height
sll $a2, $a2, 11 #a2<-M-N/2+8*512*4, triangle padding
subu $a2, $a1, $a2 #a2<- top-M-N/2+8*512, middle

addiu $t6, $zero, 8
addu $a3, $t6, $a3 # #a3<-8-M-N/2
sll $a3, $a3, 11 #a3<-8-M-N/2*512*4, triangle padding
subu $a3, $a2, $a3 #a3<- middle - 8-M-N/2*512*4, top

addu $t0, $zero, $a1 # t0<-start position+framebuffer
addiu $t7, $a1, 0  # t7<-boundary

j drawTriangleLower

drawTriangleLower:
ble $t0, $t7, drawLineTriangle
addiu $t7, $t7, 4 # counter of how many times to add by
subiu $t7, $t7, 2048 # move to above row
subiu $a1, $a1, 2048 # move to above row
addu $t0, $zero, $a1 # update pointer that draws
ble $a2, $a1, drawTriangleLower
# bgt $a2, $a1, drawTriangleUpper
j drawTriangleUpper

drawTriangleUpper:
ble $t0, $t7, drawLineTriangle
subiu $t7, $t7, 4 # counter of how many times to add by
subiu $t7, $t7, 2048 # move to above row
subiu $a1, $a1, 2048 # move to above row
addu $t0, $zero, $a1 # update postion that draws to new row
ble $a3, $a1, drawTriangleUpper
# bgt $a3, $a1, drawAllShapes
j drawAllShapes

drawLineTriangle:
# sw and incredmenting by 4 until hit boundary
# t0 is current pointer
sw $t3,($t0)
addiu $t0, $t0, 4
ble $t0, $t7, drawLineTriangle # draw line till end boundary
blt $a2, $a1, drawTriangleLower # loop back to lower label if in that section
blt $a3, $a1, drawTriangleUpper # loop back to lower label if in that sectiona3

Exit:
li $v0, 10 # exit code
syscall # exit to OS

