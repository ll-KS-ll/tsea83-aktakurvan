# sPosX/sPosY are start positions.
# p1 is player 1's color/id.
#
# GR0 - head x
# GR1 - head y
# GR2 - dir
# GR3 - misc
#
# Working registers:
# GR12, GR13, GR14, GR15
#
# Input uses interupts. Changes dir (GR2) to change players direction.
#
# Colors in PM:
# Black - PM(1000)
# Red   - PM(1001)
# Blue  - PM(1002)
# Green - PM(1003)

# Numbers in PM:
# Loop counts:
# 239 - Width of gameplan - xPos - PM(1004)
# 239 - Height of gameplan - yPos - PM(1005)
# 0 - Just a zero - PM(1006)


#---------------------------------------#
#----------# Init gameplan #------------#
#---------------------------------------#

## DRAW BORDERS ##
# Save 239 and 239 somewhere in PM
# Border is xPos 0->239 and yPos 0->239
# GR12 is xPos
# GR13 is yPos
# GR14 is color
# GR15
1=>LOAD GR14, PM(1001)      ; Set border color
## DRAW TOP BORDER
2=>SGPU GR12, GR13, GR14    ; Load to gpu memory
3=>INC GR12
4=>CMP GR12, PM(1004)
5=>BNE 2                    ; Jump back to row 3 if not finished
## DRAW RIGHT BORDER
6=>SGPU GR12, GR13, GR14    ; Load to gpu memory
7=>INC GR13
8=>CMP GR13, PM(1005)
9=>BNE 6                    ; Jump back to row 6 if not finished
## DRAW BOTTOM BORDER
10=>SGPU GR12, GR13, GR14   ; Load to gpu memory
11=>DEC GR12
12=>CMP GR12, PM(1006)
13=>BNE 10                  ; Jump back to row 10 if not finished
## DRAW LEFT BORDER
14=>SGPU GR12, GR13, GR14   ; Load to gpu memory
15=>DEC GR13
16=>CMP GR13, PM(1006)
17=>BNE 14                  ; Jump back to row 14 if not finished
## BORDERS DRAWN ##

18=>BRA 18                    ; Pauses


# Init
LOAD sPosX GR0
LOAD sPosY GR1
# Write to GPU
STOREG p1 GR0 GR1


# Move
@GAME
INCR GR0
INCR GR1
STOREG p1 GR0 GR1

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
