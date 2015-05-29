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
            0000=>x"1F00_02BC",		-- Initialize Game (draw game border/sidebar - set player 1/2 startpos/direction - clear board - Draw pl. init pos)
            0001=>x"3000_0001",		-- BRA (Infinity loop.)
            0002=>x"0000_0000",		--
            0003=>x"0000_0000",		--
            0004=>x"0000_0000",		--
            0005=>x"0000_0000",		--
            0006=>x"0000_0000",		--
            0007=>x"0000_0000",		--
            0008=>x"0000_0000",		--
            0009=>x"0000_0000",		--
            0010=>x"0000_0000",		--
            0011=>x"0000_0000",		--
            0012=>x"0000_0000",		--
            0013=>x"0000_0000",		--
            0014=>x"0000_0000",		--
            0015=>x"0000_0000",		--
            0016=>x"0000_0000",		--
            0017=>x"0000_0000",		--
            0018=>x"0000_0000",		--
            0019=>x"0000_0000",		--
            0020=>x"0000_0000",		--
            0021=>x"0000_0000",		--
            0022=>x"0000_0000",		--
            0023=>x"0000_0000",		--
            0024=>x"0000_0000",		--
            0025=>x"0000_0000",		--
            0026=>x"0000_0000",		--
            0027=>x"0000_0000",		--
            0028=>x"0000_0000",		--
            0029=>x"0000_0000",		--
            0030=>x"0000_0000",		--
            0031=>x"0000_0000",		--
            0032=>x"0000_0000",		--
            0033=>x"0000_0000",		--
            0034=>x"0000_0000",		--
            0035=>x"0000_0000",		--
            0036=>x"0000_0000",		--
            0037=>x"0000_0000",		--
            0038=>x"0000_0000",		--
            0039=>x"0000_0000",		--
            0040=>x"0000_0000",		--
            0041=>x"0000_0000",		--
            0042=>x"0000_0000",		--
            0043=>x"0000_0000",		--
            0044=>x"0000_0000",		--
            0045=>x"0000_0000",		--
            0046=>x"0000_0000",		--
            0047=>x"0000_0000",		--
            0048=>x"0000_0000",		--
            0049=>x"3000_0031",		-- BRA    49 (Ininity loop.)

            -- #####################
            -- ## INITIALIZE GAME ##
            -- #####################
            -- LOAD BORDER
            0700=>x"9A00_03F7",		-- LOAD   border color from PM(1015) into GR10
            0701=>x"B800_0000",		-- STOREG write to GPU
            0702=>x"7800_0000",		-- INC    GR8
            0703=>x"6800_03EC",		-- CMP    GR8 with PM(1004)
            0704=>x"4000_02BD",		-- BNE    to address 0701
            0705=>x"B800_0000",		-- STOREG write to GPU
            0706=>x"7900_0000",		-- INC    GR9
            0707=>x"6900_03EC",		-- CMP    GR9 with PM(1004)
            0708=>x"4000_02C1",		-- BNE    to address 0705
            0709=>x"B800_0000",		-- STOREG write to GPU
            0710=>x"8800_0000",		-- DEC    GR8
            0711=>x"6800_03EE",		-- CMP    GR8 with PM(1006)
            0712=>x"4000_02C5",		-- BNE    to address 0709
            0713=>x"B800_0000",		-- STOREG write to GPU
            0714=>x"8900_0000",		-- DEC    GR9
            0715=>x"6900_03EE",		-- CMP    GR9 with PM(1006)
            0716=>x"4000_02C9",		-- BNE    to address 713
            -- LOAD SIDEBAR
            0717=>x"9A00_03F8",		-- LOAD   siderbar color from PM(1016) into GR10
            0718=>x"9900_03EE",   -- LOAD   sidebar ypos start to Gr9 (PM1006)
            0719=>x"9800_03ED",		-- LOAD   sidebar xpos start to GR8 (PM1005)
            0720=>x"B800_0000",		-- STOREG write to GPU
            0721=>x"7800_0000",		-- INC    xPos
            0722=>x"6800_03EF",		-- CMP    xPos to end of screen
            0723=>x"4000_02D0",		-- BNE    to address 720 if screen end hasnt been reached
            0724=>x"7900_0000",		-- INC    yPos 
            0725=>x"6900_03EF",		-- CMP    yPos to end of screen
            0726=>x"4000_02CF",		-- BNE    to address 719 if end has been reached
            -- LOAD PLAYERS
            --  -- Player 1
            0727=>x"9000_03D4",		-- LOAD   xpos
            0728=>x"9100_03D5",		-- LOAD   ypos
            0729=>x"9200_03F2",		-- LOAD   color
            0730=>x"9300_03D6",		-- LOAD   direction
            --  -- Player 2
            0731=>x"9400_03D7",		-- LOAD   xpos
            0732=>x"9500_03D8",		-- LOAD   ypos
            0733=>x"9600_03F1",		-- LOAD   color
            0734=>x"9700_03D9",		-- LOAD   direction
            -- Clear board
            0735=>x"9A00_03F0",		-- LOAD   gameboard color (black) from PM(1008) into GR10
            0736=>x"9900_03EA",   -- LOAD   gameboard start ypos from PM(1002) into GR9
            0737=>x"9800_03EA",   -- LOAD   gameboard start xpos from PM(1002) into GR8
            0738=>x"B800_0000",   -- STOREG write to GPU
            0739=>x"7800_0000",   -- INC    xPos
            0740=>x"6800_03EB",   -- CMP    xPos to end of GameBoard PM(1003)
            0741=>x"4000_02E2",   -- BNE    to address 738 if end of GameBoard hasnt been reached
            0742=>x"7900_0000",   -- INC    yPos 
            0743=>x"6900_03EB",   -- CMP    yPos to end of GameBoard PM(1003)
            0744=>x"4000_02E1",   -- BNE    to address 737 if end hasnt been reached
            -- -- Draw Players init pos
            0745=>x"B000_0000",   --
            0746=>x"B400_0000",   --
            -- Go back to game
            0747=>x"CF00_0000",		-- RSR    Go back to Game

            -- ######################################
            -- ## Calculate next step for player x ##
            -- ######################################
            -- -- N
            0800=>x"6A00_03DD",   -- CMP    Direction to N 
            0801=>x"4000_0324",   -- BNE    Jump to next check if not N
            0802=>x"8900_0000",   -- DEC    ypos
            0803=>x"3000_0365",   -- BRA    Store Player x
            -- -- NE
            0804=>x"6A00_03DE",   -- CMP    Direction to NE
            0805=>x"4000_0329",   -- BNE    Jump to next check if not NE
            0806=>x"7800_0000",   -- INC    xpos
            0807=>x"8900_0000",   -- DEC    ypos  
            0808=>x"3000_0365",   -- BRA    Store Player x
            -- -- E
            0809=>x"6A00_03DF",   -- CMP    Direction to E
            0810=>x"4000_032D",   -- BNE    Jump to next check if not E
            0811=>x"7800_0000",   -- INC    xpos
            0812=>x"3000_0365",   -- BRA    Store Player x
            -- -- SE
            0813=>x"6A00_03E0",   -- CMP    Direction to SE
            0814=>x"4000_0332",   -- BNE    Jump to next check if not SE
            0815=>x"7800_0000",   -- INC    xpos
            0816=>x"7900_0000",   -- INC    ypos
            0817=>x"3000_0365",   -- BRA    Store Player x
            -- -- S
            0818=>x"6A00_03E1",   -- CMP    Direction to S
            0819=>x"4000_0336",   -- BNE    Jump to next check if not S
            0820=>x"7900_0000",   -- INC    ypos
            0821=>x"3000_0365",   -- BRA    Store Player x
            -- -- SW
            0822=>x"6A00_03E2",   -- CMP    Direction to SW
            0823=>x"4000_033B",   -- BNE    Jump to next check if not SW
            0824=>x"8800_0000",   -- DEC    xpos
            0825=>x"7900_0000",   -- INC    ypos
            0826=>x"3000_0365",   -- BRA    Store Player x
            -- -- W
            0827=>x"6A00_03E3",   -- CMP    Direction to W
            0828=>x"4000_033F",   -- BNE    Jump to NW if not W
            0829=>x"8800_0000",   -- DEC    xpos
            0830=>x"3000_0365",   -- BRA    Store Player x
            -- -- NW
            0831=>x"7800_0000",   -- DEC    xpos
            0832=>x"7900_0000",   -- DEC    ypos
            0833=>x"3000_0365",   -- BRA    Store Player x

            -- ###################################
            -- ## Set Player 1 or 2 to Player x ##
            -- ###################################
            -- -- Player 1
            0850=>x"A000_03DA",   -- STORE xpos to PM(0986)
            0851=>x"A100_03DB",   -- STORE ypos to PM(0987)
            0852=>x"A300_03DC",   -- STORE direction to PM(0988)
            0853=>x"3000_0359",   -- BRA 857
            -- -- Player 2
            0854=>x"A400_03DA",   -- STORE xpos to PM(0986) 
            0855=>x"A500_03DB",   -- STORE ypos to PM(0987)
            0856=>x"A700_03DC",   -- STORE direction to PM(0988)
            -- -- LOAD Player x
            0857=>x"9800_03DA",   -- LOAD xpos to GR8
            0858=>x"9900_03DB",   -- LOAD ypos to GR9
            0859=>x"9A00_03DC",   -- LOAD direction GR10
            -- -- Back to game
            0860=>x"CF00_0000",   -- RSR
            -- ####################################
            -- ## Load Player x to Player 1 or 2 ##
            -- ####################################
            -- -- Player 1
            0861=>x"9000_03DA",   -- LOAD xpos from PM(0986)
            0862=>x"9100_03DB",   -- LOAD ypos from PM(0987)
            0863=>x"9300_03DC",   -- LOAD direction from PM(0988)
            -- -- Back to game
            0864=>x"CF00_0000",   -- RSR 
            -- -- Player 2 
            0865=>x"9400_03DA",   -- LOAD xpos from PM(0986)
            0866=>x"9500_03DB",   -- LOAD ypos from PM(0987)
            0867=>x"9700_03DC",   -- LOAD direction from PM(0988)
            -- -- Back to game
            0868=>x"CF00_0000",   -- RSR
            -- ##################################################
            -- ## Store Player x to Player x in Program Memory ##            
            -- ##################################################
            0869=>x"A800_03DA",   -- STORE xpos to PM(0986)
            0870=>x"A900_03DB",   -- STORE ypos to PM(0987)
            0871=>x"AA00_03DC",   -- STORE direction to PM(0988)
            -- -- Back to game
            0872=>x"CF00_0000",   -- RSR

            -- ##################
            -- ## Draw Players ##
            -- ##################
            -- -- Player 1
            0873=>x"B000_0000",   -- STOREG write to GPU
            -- -- Player 2
            0874=>x"B400_0000",   -- STOREG write to GPU
            -- Back to Game
            0875=>x"CF00_0000",   -- RSR    

            -- ###############
            -- ## CONSTANTS ##
            -- ###############
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
            0997=>x"0000_0000",   --
            0998=>x"0000_0000",   --           
            0999=>x"0000_0000",   --
            1000=>x"0000_0000",		-- 
            1001=>x"0000_0000",		-- 
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





 






        
