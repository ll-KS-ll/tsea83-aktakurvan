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
            -- #############################
            --        INITIALIZE GAME
            -- #############################
            -- LOAD BORDER
            0000=>x"9A00_03F7",		-- Load border color from PM(1015) into GR10
            0001=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0002=>x"7800_0000",		-- Increase GR8
            0003=>x"6800_03EC",		-- Compare GR8 with PM(1004)
            0004=>x"4000_0001",		-- Branch on Not Equal to address 0001
            0005=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0006=>x"7900_0000",		-- Increase GR9
            0007=>x"6900_03EC",		-- Compare GR9 with PM(1004)
            0008=>x"4000_0005",		-- Branch on Not Equal to address 0005
            0009=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0010=>x"8800_0000",		-- Decrease GR8
            0011=>x"6800_03EE",		-- Compare GR8 with PM(1006)
            0012=>x"4000_0009",		-- Branch on Not Equal to address 0009
            0013=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0014=>x"8900_0000",		-- Decrease GR9
            0015=>x"6900_03EE",		-- Compare GR9 with PM(1006)
            0016=>x"4000_000D",		-- Branch on Not Equal to address 13
            -- LOAD SIDEBAR
            0017=>x"9A00_03F8",		-- Load siderbar color from PM(1016) into GR10
            0018=>x"9900_03EE",   -- Load sidebar ypos start to Gr9 (PM1006)
            0019=>x"9800_03ED",		-- Load sidebar xpos start to GR8 (PM1005)
            0020=>x"B800_0000",		-- Write to GPU
            0021=>x"7800_0000",		-- Inc xPos
            0022=>x"6800_03EF",		-- Cmp xPos to end of screen
            0023=>x"4000_0014",		-- BNE to address 20 if screen end hasnt been reached
            0024=>x"7900_0000",		-- Inc yPos if end of screen has been reached
            0025=>x"6900_03EF",		-- CMP yPos to end of screen
            0026=>x"4000_0013",		-- BNE to address 19 if end has been reached
            -- LOAD PLAYERS
            -- Player 1
            0027=>x"9000_03D4",		-- Load xpos
            0028=>x"9100_03D5",		-- Load ypos
            0029=>x"9200_03F5",		-- Load color
            0030=>x"9300_03D6",		-- Load direction
            -- Player 2
            0031=>x"9400_03D7",		-- Load xpos
            0032=>x"9500_03D8",		-- Load ypos
            0033=>x"9600_03F1",		-- Load color
            0034=>x"9700_03D9",		-- Load direction
            0035=>x"B000_0000",		--
            0036=>x"B400_0000",		--
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
            -- Draw Players current pos on Screen
            0070=>x"0000_0000",   -- 
            0071=>x"0000_0000",   -- 
            0072=>x"0000_0000",   -- 
            0073=>x"0000_0000",   -- 
            0074=>x"0000_0000",   -- 
            0075=>x"0000_0000",   -- 
            0076=>x"0000_0000",   -- 
            0077=>x"0000_0000",   -- 
            0078=>x"3000_004E",   -- Branch Always 17 (Ininity loop.)
            
            --CONSTANTS
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
            1002=>x"0000_0000",		-- 
            1003=>x"0000_0000",		-- 
            1004=>x"0000_00EF",		-- Widht/height game 239
            1005=>x"0000_00F0",		-- Sidebar xPos 240
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





 






        
