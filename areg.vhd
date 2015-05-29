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
            0000=>x"3000_02BC",		-- Initialize Game (draw game border/sidebar - set player 1/2 startpos/direction - clear board)
            0001=>x"0000_0000",		--
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
            0049=>x"3000_0031",		-- Branch Always 49 (Ininity loop.)
            0070=>x"0000_0000",   -- 
            0071=>x"0000_0000",   -- 
            0072=>x"0000_0000",   -- 
            0073=>x"0000_0000",   -- 
            0074=>x"0000_0000",   -- 
            0075=>x"0000_0000",   -- 
            0076=>x"0000_0000",   -- 
            0077=>x"0000_0000",   -- 
            0078=>x"3000_004E",   -- Branch Always 17 (Ininity loop.)

            -- #####################
            -- ## INITIALIZE GAME ##
            -- #####################
            -- LOAD BORDER
            0700=>x"9A00_03F7",		-- Load border color from PM(1015) into GR10
            0701=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0702=>x"7800_0000",		-- Increase GR8
            0703=>x"6800_03EC",		-- Compare GR8 with PM(1004)
            0704=>x"4000_0001",		-- Branch on Not Equal to address 0001
            0705=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0706=>x"7900_0000",		-- Increase GR9
            0707=>x"6900_03EC",		-- Compare GR9 with PM(1004)
            0708=>x"4000_0005",		-- Branch on Not Equal to address 0005
            0709=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0710=>x"8800_0000",		-- Decrease GR8
            0711=>x"6800_03EE",		-- Compare GR8 with PM(1006)
            0712=>x"4000_0009",		-- Branch on Not Equal to address 0009
            0713=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0714=>x"8900_0000",		-- Decrease GR9
            0715=>x"6900_03EE",		-- Compare GR9 with PM(1006)
            0716=>x"4000_000D",		-- Branch on Not Equal to address 13
            -- LOAD SIDEBAR
            0717=>x"9A00_03F8",		-- Load siderbar color from PM(1016) into GR10
            0718=>x"9900_03EE",   -- Load sidebar ypos start to Gr9 (PM1006)
            0719=>x"9800_03ED",		-- Load sidebar xpos start to GR8 (PM1005)
            0720=>x"B800_0000",		-- Write to GPU
            0721=>x"7800_0000",		-- Inc xPos
            0722=>x"6800_03EF",		-- Cmp xPos to end of screen
            0723=>x"4000_0014",		-- BNE to address 20 if screen end hasnt been reached
            0724=>x"7900_0000",		-- Inc yPos if end of screen has been reached
            0725=>x"6900_03EF",		-- CMP yPos to end of screen
            0726=>x"4000_0013",		-- BNE to address 19 if end has been reached
            -- LOAD PLAYERS
            --  -- Player 1
            0727=>x"9000_03D4",		-- Load xpos
            0728=>x"9100_03D5",		-- Load ypos
            0729=>x"9200_03F5",		-- Load color
            0730=>x"9300_03D6",		-- Load direction
            --  -- Player 2
            0731=>x"9400_03D7",		-- Load xpos
            0732=>x"9500_03D8",		-- Load ypos
            0733=>x"9600_03F1",		-- Load color
            0734=>x"9700_03D9",		-- Load direction
            -- Clear board
            0735=>x"0000_0000",		-- Load gameboard color (black) from PM(1008) into GR10
            0736=>x"0000_0000",   --
            0737=>x"0000_0000",   --
            0738=>x"0000_0000",   --
            0739=>x"0000_0000",   --
            0740=>x"0000_0000",   --
            0741=>x"0000_0000",   --
            0742=>x"0000_0000",   --
            0743=>x"0000_0000",   --
            0744=>x"0000_0000",   --
            0745=>x"0000_0000",   --
            0746=>x"0000_0000",   --
            0747=>x"0000_0000",   --
            0748=>x"0000_0000",   --
            0749=>x"0000_0000",   --
            0750=>x"0000_0000",   --
            0751=>x"3000_0001",		-- Go back to Game

            -- ######################################
            -- ## Calculate next step for player x ##
            -- ######################################
            0800=>x"0000_0000",   --  
            0801=>x"0000_0000",   -- 
            0802=>x"0000_0000",   -- 
            0803=>x"0000_0000",   --
            0804=>x"0000_0000",   -- 
            0805=>x"0000_0000",   --
            0806=>x"0000_0000",   -- 
            0807=>x"0000_0000",   --
            0808=>x"0000_0000",   -- 
            0809=>x"0000_0000",   --
            0810=>x"0000_0000",   -- 
            0811=>x"0000_0000",   --
            0812=>x"0000_0000",   -- 
            0813=>x"0000_0000",   --
            0814=>x"0000_0000",   -- 
            0815=>x"0000_0000",   --
            0816=>x"0000_0000",   -- 
            0817=>x"0000_0000",   --
            0818=>x"0000_0000",   -- 
            0819=>x"0000_0000",   --
            0820=>x"0000_0000",   --
            0821=>x"0000_0000",   -- 
            0822=>x"0000_0000",   --
            0823=>x"0000_0000",   --
            0824=>x"0000_0000",   -- 
            0825=>x"0000_0000",   --
            0826=>x"0000_0000",   --
            0827=>x"0000_0000",   -- 
            0828=>x"0000_0000",   --

            -- ###############
            -- ## CONSTANTS ##
            -- ###############
            0980=>x"0000_001E",   -- Player 1 - start - xpos
            0981=>x"0000_001E",   -- Player 1 - start - ypos
            0982=>x"0000_0003",   -- Player 1 - start - direction
            0983=>x"0000_00D2",   -- Player 2 - start - xpos
            0984=>x"0000_00D2",   -- Player 2 - start - ypos
            0985=>x"0000_0007",   -- Player 2 - start - direction
            0986=>x"0000_0000",   -- 
            0987=>x"0000_0000",   -- 
            0988=>x"0000_0000",   -- 
            0989=>x"0000_0000",   -- 
            0990=>x"0000_0000",   -- 
            0991=>x"0000_0000",   -- 
            0992=>x"0000_0000",   -- 
            0993=>x"0000_0000",   -- 
            0994=>x"0000_0000",   -- 
            0995=>x"0000_0000",   -- 
            0996=>x"0000_0000",   -- 
            0997=>x"0000_0000",   --
            0998=>x"0000_0000",   --           
            0999=>x"0000_0000",
            1000=>x"0000_0000",		-- 
            1001=>x"0000_0000",		-- 
            1002=>x"0000_0000",		-- GameBoard  start  xpos
            1003=>x"0000_0000",		-- Gameboard  end    xpos
            1004=>x"0000_00EF",		-- GameBoard  W/H           239
            1005=>x"0000_00F0",		-- Sidebar    start  xpos   240
            1006=>x"0000_0000",		-- Constant 0
            1007=>x"0000_013F",	  -- Width screen 319	
            1008=>x"0000_0000",   -- Color Black
            1009=>x"0000_0001",   -- Color Magenta
            1010=>x"0000_0002",   -- Color Aqua
            1011=>x"0000_0003",   -- Color Green/Lime
            1012=>x"0000_0004",   -- Color Red
            1013=>x"0000_0005",   -- Color Aqua
            1014=>x"0000_0006",   -- Color Yellow
            1015=>x"0000_0007",   -- Color DarkGrey
            1016=>x"0000_0008",   -- Color DarkGreenGrey
            1017=>x"0000_0009",   -- Color ?
            1018=>x"0000_000A",   -- Color ?
            1019=>x"0000_000B",   -- Color ?
            1020=>x"0000_000C",   -- Color ?
            1021=>x"0000_000D",   -- Color ?
            1022=>x"0000_000E",   -- Color ?
            1023=>x"0000_000F",   -- Color White 
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





 






        
