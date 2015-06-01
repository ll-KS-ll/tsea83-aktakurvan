library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithemetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declarartion if instatiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- Adress registers
entity areg is
        port(
            clk, rst        : in        std_logic;           
            dbus            : in        std_logic_vector(31 downto 0);
            aregOut         : out       std_logic_vector(31 downto 0);
            FB_c            : in        std_logic_vector(2 downto 0)
            );
end areg;

architecture arch of areg is
        -- Registeers
        signal ASR          : std_logic_vector(19 downto 0)     := X"00000";

        --PM
        type pMem_t is array(0 to 1023) of std_logic_vector(31 downto 0);

        signal pMem : pMem_t := ( -- Program memory
            -- #########################
            -- ## Main Game functions ##
            -- #########################
            -- Initialize Game
            0000=>x"01F0_02B8",		-- Initialize Gameborder/sidebar
            0001=>x"01F0_02D8",   -- Initialize players
            0002=>x"01F0_02ED",		-- Initialize Player ScoreNumbers
            -- Start New game
            0003=>x"01F0_02F2",   -- Reset playerscores
            0004=>x"01F0_02E1",		-- Clear Board
            0005=>x"01F0_0369",		-- Draw Players
            0006=>x"01F0_027B",		-- Wait a bit before starting game
            0007=>x"01F0_027B",		-- Wait a bit before starting game
            -- One Game cycle     --      
            0008=>x"01F0_0258",   -- Read and set player 1 direction
            0009=>x"0300_01F4",   -- Check collision player 1    
            0010=>x"01F0_0212",   -- Read and set player 2 direction
            0011=>x"0300_000C",   -- Check collision player 2
            0012=>x"0300_028A",   -- Advance player 1 one step
            0013=>x"0300_028E",   -- Advance player 2 one step
            0014=>x"01F0_0292",   -- Check if its time to do holes for the two players, if so do it.
            0015=>x"01F0_0369",   -- Draw players
            0016=>x"01F0_0280",   -- Game Speed
            0017=>x"0300_0008",   -- Loop  
            0018=>x"0000_0000",   --
            0019=>x"0000_0000",   --
            0020=>x"0300_0007",		--
            0021=>x"0000_0000",		--
            0022=>x"0000_0000",		--

            -- ##################################
            -- ## Collision check for player 1 ##
            -- ##################################
            0500=>x"0300_024E",   -- BRA    Set player x to player 1 + one step
            0501=>x"09A0_03F0",   -- LOAD   PM(1008) to GR10    Set GR10 to x"0000_0000"
            0502=>x"0980_03DA",   -- LOAD   PM(0986) to GR8
            0503=>x"0990_03DB",   -- LOAD   PM(0987) to GR9
            0504=>x"0500_0006",   -- WGCR   Set GPUCR to read from gpu
            0505=>x"1680_0000",   -- RGPU   Read from GPU
            0506=>x"06A0_03EE",   -- CMP    If black we can exit collision check
            0507=>x"1500_000A",   -- BEQ    Exit collision check
            0508=>x"0300_020C",   -- BRA    INC player 2 points and start new round(PM(0998) holds player 2 score)
            0509=>x"0000_0000",   --
            0510=>x"0000_0000",   -- 
            0511=>x"0000_0000",   --  #### ERROR SOMEWHERE HERE; stops the game from running. ####
            0512=>x"0000_0000",   -- -- Else, set GPUCR to write to player 2 points
            0513=>x"0000_0000",   -- -- INC player 2 points
            0514=>x"0000_0000",   -- -- New round
            0515=>x"0000_0000",   -- 
            0516=>x"0000_0000",   -- 
            0517=>x"0000_0000",   -- 
            0518=>x"0000_0000",   -- 
            0519=>x"0000_0000",   -- 
            0520=>x"0000_0000",   --
            -- ##############################
            -- ## Increase player 2 points ##
            -- ##############################
            0524=>x"0980_03E6",   -- LOAD     PM(0998) to GR8   Player 2 points
            0525=>x"0780_0000",   -- INC      Inc GR8           INC player 2 points
            0526=>x"0500_0057",   -- WGCR     Set to write to player 2 points
            0527=>x"0080_0000",   -- WGNUM    Write it on screen
            0528=>x"0A80_03E6",   -- STORE    GR8 to PM(0998)   Store player 2 points
            0529=>x"0300_0251",   -- BRA      Reset game board
            
            -- #####################################
            -- ## Read and set player 2 direction ##
            -- #####################################
            0530=>x"0AD0_03D1",   -- STORE    GR13 to PM(0977)  Store player 2 new turn direction
            0531=>x"06D0_03D3",   -- CMP      GR13 to PM(0979)  CMP player 2 new turn direction to current turn direction
            0532=>x"1500_0218",   -- BEQ      Jump to Decide Turn if equal                  
            0533=>x"0980_03D1",   -- LOAD     PM(0977) to GR8   Load new turn direction to  GR8
            0534=>x"0A80_03D3",   -- STORE    GR8 to PM(0979)   Store player 2 current turn direction
            0535=>x"0300_021E",   -- BRA      Jump to 542           
            -- -- Decide Turn
            0536=>x"0980_03CE",   -- LOAD     PM(0974) to GR8   Load player 2 turn state   
            0537=>x"0880_0000",   -- DEC      GR8               DEC it with 1
            0538=>x"0A80_03CE",   -- STORE    GR8 to PM(0974)   Store player 2 turn state
            0539=>x"0680_03EE",   -- CMP      GR8 to PM(1006)   Cmp it to 0  
            0540=>x"1500_021E",   -- BEQ      Turn player and reset turn state (edit direction value)
            0541=>x"0CF0_0000",   -- RSR      Return from subrutine
            -- ## Change direction of player two and reset turn state ##
            0542=>x"0980_03D3",   -- LOAD     PM(0979) to GR8   Load player 2 current turn direction
            0543=>x"0680_03E9",   -- CMP      GR8 to PM(1001)   Check if left turn
            0544=>x"1500_0224",   -- BEQ      Jump to left turn if equal  
            0545=>x"0680_03DF",   -- CMP      GR8 to PM(0991)   Check if right turn 
            0546=>x"1500_022A",   -- BEQ      Jump to right turn if equal
            0547=>x"0300_0230",   -- BRA      Jump to end of function
            -- -- Left turn
            0548=>x"0670_03EE",   -- CMP      GR7 to PM(1006)   Check if 0
            0549=>x"1500_0228",   -- BEQ      Jump to "set to 7"If 0 we need to set to 7
            0550=>x"0870_0000",   -- DEC      Else just dec direction with one
            0551=>x"0300_0230",   -- BRA      Jump to end of function
            0552=>x"0970_03E4",   -- LOAD     PM(0996) to GR7   Set direction to 7      
            0553=>x"0300_0230",   -- BRA      Jump to end of function
            -- -- Right turn
            0554=>x"0670_03E4",   -- CMP      GR7 to PM(0996)   Check if 7
            0555=>x"1500_022E",   -- BEQ      Jump to "set to 0"If 7 we need to set to 0
            0556=>x"0770_0000",   -- INC      Else we just inc direction with one
            0557=>x"0300_0230",   -- BRA      Jump to end of function
            0558=>x"0970_03EE",   -- LOAD     PM(1006) to GR7   Set direction to 0
            0559=>x"0300_0230",   -- BRA      Jump to end of function
            -- -- Reset turn state
            0560=>x"0980_03CF",   -- LOAD     PM(0975) to GR8   Load turn state variable
            0561=>x"0A80_03CE",   -- STORE    GR8 to PM(0974)   Store it into player 2s turn state
            0562=>x"0CF0_0000",   -- RSR      Return from subrutine  

            -- ## Increase player 2 points by one ##
            0570=>x"0300_0251",   -- Start new round
            -- ## Set player x to player 1 + one step ##
            0590=>x"01F0_0352",   -- Set player 1 to player x
            0591=>x"01F0_0320",   -- Advance player x one step
            0592=>x"0300_01F5",   -- Jump back to collision function.
            -- ###############
            -- ## New Round ##
            -- ###############
            0593=>x"01F0_027B",   -- Wait 
            0594=>x"01F0_02D8",   -- Reset player pos/directions
            0595=>x"01F0_02E1",   -- Clear board
            0596=>x"01F0_0369",   -- Draw players
            0597=>x"01F0_027B",   -- Wait
            0598=>x"0300_0008",   -- Jump to game loop
            -- #####################################
            -- ## Read and set player 1 direction ##
            -- #####################################
            0600=>x"0AC0_03D0",   -- STORE    GR12 to PM(0976)  Store player 1 new turn direction
            0601=>x"06C0_03D2",   -- CMP      GR12 to PM(0978)  CMP player 1 new turn direction to current turn direction
            0602=>x"1500_025F",   -- BEQ      Jump to Decide Turn if equal                  
            0603=>x"0980_03D0",   -- LOAD     PM(0976) to GR8   Load new turn direction to  GR8
            0604=>x"0A80_03D2",   -- STORE    GR8 to PM(0978)   Store player 1 current turn direction
            0605=>x"0300_0265",   -- BRA      Jump to 613            
            -- -- Decide Turn
            0607=>x"0980_03CD",   -- LOAD     PM(0973) to GR8   Load player 1 turn state   
            0608=>x"0680_03EE",   -- CMP      GR8 to PM(1006)   Cmp it to 0  
            0609=>x"1500_0265",   -- BEQ      Turn player and reset turn state (edit direction value)
            0610=>x"0880_0000",   -- DEC      GR8               DEC it with 1
            0611=>x"0A80_03CD",   -- STORE    GR8 to PM(0973)   Store player 1 turn state
            0612=>x"0CF0_0000",   -- RSR      Return from subrutine
            -- ## Change direction of player one and reset turn state ##
            0613=>x"0980_03D2",   -- LOAD     PM(0978) to GR8   Load player 1 current turn direction
            0614=>x"0680_03E9",   -- CMP      GR8 to PM(1001)   Check if left turn
            0615=>x"1500_026B",   -- BEQ      Jump to left turn if equal  
            0616=>x"0680_03DF",   -- CMP      GR8 to PM(0991)   Check if right turn 
            0617=>x"1500_0271",   -- BEQ      Jump to right turn if equal
            0618=>x"0300_0277",   -- BRA      Jump to end of function
            -- -- Left turn
            0619=>x"0630_03EE",   -- CMP      GR3 to PM(1006)   Check if 0
            0620=>x"1500_026F",   -- BEQ      Jump to "set to 7"If 0 we need to set to 7
            0621=>x"0830_0000",   -- DEC      Else just dec direction with one
            0622=>x"0300_0277",   -- BRA      Jump to end of function
            0623=>x"0930_03E4",   -- LOAD     PM(0996) to GR3   Set direction to 7      
            0624=>x"0300_0277",   -- BRA      Jump to end of function
            -- -- Right turn
            0625=>x"0630_03E4",   -- CMP      GR3 to PM(0996)   Check if 7
            0626=>x"1500_0275",   -- BEQ      Jump to "set to 0"If 7 we need to set to 0
            0627=>x"0730_0000",   -- INC      Else we just inc direction with one
            0628=>x"0300_0277",   -- BRA      Jump to end of function
            0629=>x"0930_03EE",   -- LOAD     PM(1006) to GR3   Set direction to 0
            0630=>x"0300_0277",   -- BRA      Jump to end of function
            -- -- Reset turn state
            0631=>x"0980_03CF",   -- LOAD     PM(0975) to GR8   Load turn state variable
            0632=>x"0A80_03CD",   -- STORE    GR8 to PM(0973)   Store it into player 1s turn state
            0633=>x"0CF0_0000",   -- RSR      Return from subrutine
            -- ######################
            -- ## Game start delay ##
            -- ######################
            0635=>x"0980_03E8",   -- LOAD   Gamestart delay => GR8
            0636=>x"0880_0000",   -- DEC    GR8
            0637=>x"0680_03EE",   -- CMP    GR8 to 0
            0638=>x"0400_027C",   -- BNE    Jump back to 636 if not equal
            -- -- Back to game
            0639=>x"0CF0_0000",   -- RSR
            -- ################
            -- ## Game speed ##
            -- ################
            0640=>x"0980_03E7",   -- LOAD   Gamespeed => GR8
            0641=>x"0880_0000",   -- DEC    GR8
            0642=>x"0680_03EE",   -- CMP    GR8 to 0
            0643=>x"0400_0281",   -- BNE    Jump back to 641 if not equal
            -- -- Back to game
            0644=>x"0CF0_0000",   -- RSR
            -- ###############################
            -- ## Advance Player 1 one step ##
            -- ###############################
            0650=>x"01F0_0352",   -- JSR    Set player 1 to player x
            0651=>x"01F0_0320",   -- JSR    Advance Player x one step
            0652=>x"01F0_035D",   -- JSR    Set player x to Player 1
            0653=>x"0300_000D",   -- BRA    Jump back to game
            -- ###############################
            -- ## Advance Player 2 one step ##
            -- ###############################
            0654=>x"01F0_0356",   -- JSR    Set player 2 to player x
            0655=>x"01F0_0320",   -- JSR    Advance Player x one step
            0656=>x"01F0_0361",   -- JSR    Set player x to Player 2
            0657=>x"0300_000E",   -- BRA    Jump back to game
            -- ############################
            -- ## Do holes in the snakes ##
            -- ############################
            -- -- Player 1
            0658=>x"0980_03CB",   -- LOAD   PM(0971) to GR8   Load player 1 steps left to hole       
            0659=>x"0680_03EE",   -- CMP    GR8 to PM(1006)   Check if zero
            0660=>x"1500_029B",   -- BEQ    Jump to "Im a hole" if true
            0661=>x"0880_0000",   -- DEC    GR8               Dec it with one otherwise
            0662=>x"0A80_03CB",   -- STORE  GR8 to PM(0971)   Store it back to steps left to hole
            -- -- Player 2
            0663=>x"0CF0_0000",   -- Return to game (player 2 holes not active yet)
            0664=>x"0000_0000",   --
            0665=>x"0000_0000",   --
            0666=>x"0000_0000",   --
            -- ## Im a hole ##
            -- -- Player 1
            0667=>x"0980_03C8",   -- LOAD   PM(0968) to GR8   Load player 1 steps as hole left
            0668=>x"0680_03EE",   -- CMP    GR8 to PM(1006)   Check if zero
            0669=>x"1500_02A2",   -- BEQ    Jump to reset player to normal if true
            0670=>x"0880_0000",   -- DEC    GR8               Dec steps left as hole by 1
            0671=>x"0A80_03C8",   -- STORE  GR8 to PM(0968)   Store it back into PM
            0672=>x"0920_03F0",   -- LOAD   PM(1008) to GR2   Set player 1 color to black
            0673=>x"0300_0297",   -- BRA    Jump to player 2 check
            -- -- -- ## Reset player 1 ##
            0674=>x"0920_03F2",   -- LOAD   PM(1010) to GR2   Set player 1 color to normal again
            0675=>x"0980_03CA",   -- LOAD   PM(0970) to GR8   Load steps left to next hole to GR8
            0676=>x"0A80_03CB",   -- STORE  GR8 to PM(0971)   Store it to player 1 steps left to next hole
            0677=>x"0980_03C7",   -- LOAD   PM(0967) to GR8   Load steps as hole to gr8
            0678=>x"0A80_03C8",   -- STORE  GR8 to PM(0968)   Store it to players steps as hole
            0679=>x"0300_0297",   -- BRA    Jump to player 2 check
            -- ###################################
            -- ## INITIALIZE GAMEBORDER/SIDEBAR ##
            -- ###################################
            -- LOAD SIDEBAR
            0696=>x"0500_0001",   -- WGCR   Set GPU control register to write to GPU
            0697=>x"09A0_03F8",		-- LOAD   siderbar color (DarkGreenGrey) from PM(1016) into GR10
            0698=>x"0990_03EE",   -- LOAD   sidebar ypos start to Gr9 (PM1006)
            0699=>x"0980_03ED",		-- LOAD   sidebar xpos start to GR8 (PM1005)
            0700=>x"0B80_0000",		-- STOREG write to GPU
            0701=>x"0780_0000",		-- INC    xPos
            0702=>x"0680_03EF",		-- CMP    xPos to end of screen
            0703=>x"0400_02BC",		-- BNE    to address 700 if screen end hasnt been reached
            0704=>x"0790_0000",		-- INC    yPos 
            0705=>x"0690_03EF",		-- CMP    yPos to end of screen
            0706=>x"0400_02BB",		-- BNE    to address 699 if end has been reached
            -- LOAD BORDER
            0707=>x"0500_0001",   -- WGCR   Set GPU control register to write to GPU
            0708=>x"0980_03EE",   -- LOAD   Set ypos to 0	PM(1006)
            0709=>x"0990_03EE",   -- LOAD   Set xpos to 0	PM(1006)
            0710=>x"09A0_03F7",		-- LOAD   border color from PM(1015) into GR10
            0711=>x"0B80_0000",		-- STOREG write to GPU
            0712=>x"0780_0000",		-- INC    GR8
            0713=>x"0680_03EC",		-- CMP    GR8 with PM(1004)
            0714=>x"0400_02C7",		-- BNE    to address 0711
            0715=>x"0B80_0000",		-- STOREG write to GPU
            0716=>x"0790_0000",		-- INC    GR9
            0717=>x"0690_03EC",		-- CMP    GR9 with PM(1004)
            0718=>x"0400_02CB",		-- BNE    to address 0715
            0719=>x"0B80_0000",		-- STOREG write to GPU
            0720=>x"0880_0000",		-- DEC    GR8
            0721=>x"0680_03EE",		-- CMP    GR8 with PM(1006)
            0722=>x"0400_02CF",		-- BNE    to address 0719
            0723=>x"0B80_0000",		-- STOREG write to GPU
            0724=>x"0890_0000",		-- DEC    GR9
            0725=>x"0690_03EE",		-- CMP    GR9 with PM(1006)
            0726=>x"0400_02D3",		-- BNE    to address 0723
            -- -- Back to game
            0727=>x"0CF0_0000",   -- RSR
            -- #############################
            -- ## SET PLAYERS INIT VALUES ##
            -- #############################
            --  -- Player 1
            0728=>x"0900_03D4",		-- LOAD   xpos
            0729=>x"0910_03D5",		-- LOAD   ypos
            0730=>x"0920_03F2",		-- LOAD   color
            0731=>x"0930_03D6",		-- LOAD   direction
            --  -- Player 2
            0732=>x"0940_03D7",		-- LOAD   xpos
            0733=>x"0950_03D8",		-- LOAD   ypos
            0734=>x"0960_03F1",		-- LOAD   color
            0735=>x"0970_03D9",		-- LOAD   direction
            0736=>x"0CF0_0000",   -- RSR
            -- #################
            -- ## Clear board ##
            -- #################
            -- -- Set GPUCR
            0737=>x"0500_0007",   -- WGCR   Set so CPU writes to GPU
            -- -- Clear Board
            0738=>x"09A0_03F0",		-- LOAD   gameboard color (black) from PM(1008) into GR10
            0739=>x"0990_03EA",   -- LOAD   gameboard start ypos from PM(1002) into GR9
            0740=>x"0980_03EA",   -- LOAD   gameboard start xpos from PM(1002) into GR8
            0741=>x"0B80_0000",   -- STOREG write to GPU
            0742=>x"0780_0000",   -- INC    xPos
            0743=>x"0680_03EB",   -- CMP    xPos to end of GameBoard PM(1003)
            0744=>x"0400_02E5",   -- BNE    to address 741 if end of GameBoard hasnt been reached
            0745=>x"0790_0000",   -- INC    yPos 
            0746=>x"0690_03EB",   -- CMP    yPos to end of GameBoard PM(1003)
            0747=>x"0400_02E4",   -- BNE    to address 740 if end hasnt been reached
            -- -- Back to game
            0748=>x"0CF0_0000",		-- RSR    
            -- #################################
            -- ## Enable Player Score Numbers ##
            -- #################################
            0749=>x"0500_003B",   -- WGCR   Enable Two players score, and set to write color to Player 1
            0750=>x"0020_0000",   -- WGNUM  Set player 1 score color
            0751=>x"0500_0077",   -- WGCR   Set to write color to Player 2
            0752=>x"0060_0000",   -- WGNUM  Set player 2 score color
            -- -- Back to game
            0753=>x"0CF0_0000",   -- RSR
            -- #########################
            -- ## Reset player scores ##
            -- #########################
            -- -- Reset score in PM
            0754=>x"0980_03EE",   -- LOAD   0 => GR8  
            0755=>x"0A80_03E5",   -- STORE  0 => Player 1   Score
            0756=>x"0A80_03E6",   -- STORE  0 => Player 2   Score   
            0757=>x"0500_0017",   -- WGCR   Set to write to Player 1 score on screen
            0758=>x"0080_0000",   -- WGNUM
            0759=>x"0500_0057",   -- WGCR   Set to write to Player 2 score on screen
            0760=>x"0080_0000",   -- WGNUM
            -- -- Back to game
            0761=>x"0CF0_0000",   -- RSR
            -- ##################################################
            -- ## Store Player x to Player x in Program Memory ##            
            -- ##################################################
            0796=>x"0A80_03DA",   -- STORE xpos to PM(0986)
            0797=>x"0A90_03DB",   -- STORE ypos to PM(0987)
            0798=>x"0AA0_03DC",   -- STORE direction to PM(0988)
            -- -- Back to game
            0799=>x"0CF0_0000",   -- RSR
            -- ######################################
            -- ## Calculate next step for player x ##
            -- ######################################
            -- -- N
            0800=>x"06A0_03DD",   -- CMP    Direction to N 
            0801=>x"0400_0324",   -- BNE    Jump to next check if not N
            0802=>x"0890_0000",   -- DEC    ypos
            0803=>x"0300_031C",   -- BRA    Store Player x
            -- -- NE
            0804=>x"06A0_03DE",   -- CMP    Direction to NE
            0805=>x"0400_0329",   -- BNE    Jump to next check if not NE
            0806=>x"0780_0000",   -- INC    xpos
            0807=>x"0890_0000",   -- DEC    ypos  
            0808=>x"0300_031C",   -- BRA    Store Player x
            -- -- E
            0809=>x"06A0_03DF",   -- CMP    Direction to E
            0810=>x"0400_032D",   -- BNE    Jump to next check if not E
            0811=>x"0780_0000",   -- INC    xpos
            0812=>x"0300_031C",   -- BRA    Store Player x
            -- -- SE
            0813=>x"06A0_03E0",   -- CMP    Direction to SE
            0814=>x"0400_0332",   -- BNE    Jump to next check if not SE
            0815=>x"0780_0000",   -- INC    xpos
            0816=>x"0790_0000",   -- INC    ypos
            0817=>x"0300_031C",   -- BRA    Store Player x
            -- -- S
            0818=>x"06A0_03E1",   -- CMP    Direction to S
            0819=>x"0400_0336",   -- BNE    Jump to next check if not S
            0820=>x"0790_0000",   -- INC    ypos
            0821=>x"0300_031C",   -- BRA    Store Player x
            -- -- SW
            0822=>x"06A0_03E2",   -- CMP    Direction to SW
            0823=>x"0400_033B",   -- BNE    Jump to next check if not SW
            0824=>x"0880_0000",   -- DEC    xpos
            0825=>x"0790_0000",   -- INC    ypos
            0826=>x"0300_031C",   -- BRA    Store Player x
            -- -- W
            0827=>x"06A0_03E3",   -- CMP    Direction to W
            0828=>x"0400_033F",   -- BNE    Jump to NW if not W
            0829=>x"0880_0000",   -- DEC    xpos
            0830=>x"0300_031C",   -- BRA    Store Player x
            -- -- NW
            0831=>x"0880_0000",   -- DEC    xpos
            0832=>x"0890_0000",   -- DEC    ypos
            0833=>x"0300_031C",   -- BRA    Store Player x
            -- ###################################
            -- ## Set Player 1 or 2 to Player x ##
            -- ###################################
            -- -- Player 1
            0850=>x"0A00_03DA",   -- STORE xpos to PM(0986)
            0851=>x"0A10_03DB",   -- STORE ypos to PM(0987)
            0852=>x"0A30_03DC",   -- STORE direction to PM(0988)
            0853=>x"0300_0359",   -- BRA 857
            -- -- Player 2
            0854=>x"0A40_03DA",   -- STORE xpos to PM(0986) 
            0855=>x"0A50_03DB",   -- STORE ypos to PM(0987)
            0856=>x"0A70_03DC",   -- STORE direction to PM(0988)
            -- -- LOAD Player x
            0857=>x"0980_03DA",   -- LOAD xpos to GR8
            0858=>x"0990_03DB",   -- LOAD ypos to GR9
            0859=>x"09A0_03DC",   -- LOAD direction GR10
            -- -- Back to game
            0860=>x"0CF0_0000",   -- RSR
            -- ####################################
            -- ## Load Player x to Player 1 or 2 ##
            -- ####################################
            -- -- Player 1
            0861=>x"0900_03DA",   -- LOAD xpos from PM(0986)
            0862=>x"0910_03DB",   -- LOAD ypos from PM(0987)
            0863=>x"0930_03DC",   -- LOAD direction from PM(0988)
            -- -- Back to game
            0864=>x"0CF0_0000",   -- RSR 
            -- -- Player 2 
            0865=>x"0940_03DA",   -- LOAD xpos from PM(0986)
            0866=>x"0950_03DB",   -- LOAD ypos from PM(0987)
            0867=>x"0970_03DC",   -- LOAD direction from PM(0988)
            -- -- Back to game
            0868=>x"0CF0_0000",   -- RSR
            
            -- ##################
            -- ## Draw Players ##
            -- ##################
            -- -- Set GPUCR
            0873=>x"0500_0007",   -- WGCR   Set so CPU writes to GPU
            -- -- Player 1
            0874=>x"0B00_0000",   -- STOREG write to GPU
            -- -- Player 2
            0875=>x"0B40_0000",   -- STOREG write to GPU
            -- Back to Game
            0876=>x"0CF0_0000",   -- RSR    
            -- ###########################
            -- ## CONSTANTS & Variables ##
            -- ###########################
            0967=>x"0000_0002",   -- Gap Wideness
            0968=>x"0000_0002",   -- Player 1   gap     state           
            0969=>x"0000_0002",   -- Player 2   gap     state
            0970=>x"0000_0023",   -- Distance Between holes
            0971=>x"0000_000D",   -- Player 1   hole    steps left to hole-time
            0972=>x"0000_0008",   -- Player 2   hole    steps left to hole-time
            0973=>x"0000_0003",   -- Player 1   turn    state
            0974=>x"0000_0003",   -- Player 2   turn    state
            0975=>x"0000_0003",   -- Turn sharpness variable
            0976=>x"0000_0000",   -- Player 1   new     turn direction
            0977=>x"0000_0000",   -- Player 2   new     turn direction
            0978=>x"0000_0000",   -- Player 1   current turn direction
            0979=>x"0000_0000",   -- Player 2   current turn direction
            0980=>x"0000_001E",   -- Player 1   start   xpos
            0981=>x"0000_001E",   -- Player 1   start   ypos
            0982=>x"0000_0003",   -- Player 1   start   direction
            0983=>x"0000_00D2",   -- Player 2   start   xpos
            0984=>x"0000_00D2",   -- Player 2   start   ypos
            0985=>x"0000_0007",   -- Player 2   start   direction
            0986=>x"0000_0000",   -- Player x   current xpos
            0987=>x"0000_0000",   -- Player x   current ypos
            0988=>x"0000_0000",   -- Player x   current direction
            0989=>x"0000_0000",   -- Direction  N       0
            0990=>x"0000_0001",   -- Direction  NE      1
            0991=>x"0000_0002",   -- Direction  E       2
            0992=>x"0000_0003",   -- Direction  SE      3
            0993=>x"0000_0004",   -- Direction  S       4
            0994=>x"0000_0005",   -- Direction  SW      5
            0995=>x"0000_0006",   -- Direction  W       6
            0996=>x"0000_0007",   -- Direction  NW      7
            0997=>x"0000_0000",   -- Player 1   current Score
            0998=>x"0000_0000",   -- Player 2   current Score
            0999=>x"0006_1A80",   -- GameSpeed          500000
            1000=>x"0098_9680",		-- GameStart  delay   10000000
            1001=>x"0000_0001",		-- Constant                 1
            1002=>x"0000_0001",		-- GameBoard  start  x/ypos 1
            1003=>x"0000_00EE",		-- GameBoard  end    x/ypos 238
            1004=>x"0000_00EF",		-- GameBorder W/H    x/ypos 239
            1005=>x"0000_00F0",		-- Sidebar    start  xpos   240
            1006=>x"0000_0000",		-- Constant                 0
            1007=>x"0000_013F",	  -- GameScreen end    x/ypos 319	
            1008=>x"0000_0000",   -- Color      Black
            1009=>x"0000_0001",   -- Color      Magenta
            1010=>x"0000_0002",   -- Color      Aqua
            1011=>x"0000_0003",   -- Color      Green/Lime
            1012=>x"0000_0004",   -- Color      Red
            1013=>x"0000_0005",   -- Color      Blue
            1014=>x"0000_0006",   -- Color      Yellow
            1015=>x"0000_0007",   -- Color      DarkGrey
            1016=>x"0000_0008",   -- Color      DarkGreenGrey
            1017=>x"0000_0009",   -- Color      ?
            1018=>x"0000_000A",   -- Color      ?
            1019=>x"0000_000B",   -- Color      ?
            1020=>x"0000_000C",   -- Color      ?
            1021=>x"0000_000D",   -- Color      ?
            1022=>x"0000_000E",   -- Color      ?
            1023=>x"0000_000F",   -- Color      White 
            others => x"0000_0000"
        );

begin
       
        -- Memory Control
        process(clk) begin
            if rising_edge(clk) then
                if rst = '1' then
                    ASR <= X"00000";
                else
                    case FB_c is
                        when "010" => pMem(conv_integer(ASR))   <= dbus;
                        when "111" => ASR                       <= dbus(19 downto 0); -- ASR is only 21. 
                        when others => null;
                    end case;
                end if;
            end if;
        end process;

        -- Outsignal is always what ASR points to in memory.
        aregOut <= pMem(conv_integer(ASR));

end architecture ;





 






        
