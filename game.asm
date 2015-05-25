# sPosX/sPosY are start positions.
# p1 is player 1's color/id.
#
# GR0 - head x
# GR1 - head y
# GR2 - dir
# GR3 - misc
#
# Input uses interupts. Changes dir (GR2) to change players direction.
#

# Init
LOAD sPosX GR0
LOAD sPosY GR1
# Write to GPU
STOREG p1 GR0 GR1
STOREG p1 GR0 GR1+1
STOREG p1 GR0+1 GR1
STOREG p1 GR0+1 GR1+1


# Move
@GAME
INCR GR0
INCR GR1
STOREG p1 GR0 GR1
STOREG p1 GR0 GR1+1
STOREG p1 GR0+1 GR1
STOREG p1 GR0+1 GR1+1

# Check collision
LOADG HR GR0+1 GR1+1
CMP HR "0000"
BNE @BAAAM

BRA @GAME

# BAAAAM
	#Oklart
	# Add points
	# Alive > 0 (1) ?!?!?!?!?!!?!?

# I/O Interupt
	#Oklart
