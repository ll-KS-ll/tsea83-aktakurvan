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
            -- LOAD BORDER
            0000=>x"9A00_03F7",		-- Load border/sidebar color from PM(1015) into GR10
            0001=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0002=>x"7800_0000",		-- Increase GR8
            0003=>x"6C00_03EC",		-- Compare GR8 with PM(1004)
            0004=>x"4000_0001",		-- Branch on Not Equal to address 0001
            0005=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0006=>x"7900_0000",		-- Increase GR9
            0007=>x"6900_03ED",		-- Compare GR9 with PM(1005)
            0008=>x"4000_0005",		-- Branch on Not Equal to address 0005
            0009=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0010=>x"8800_0000",		-- Decrease GR8
            0011=>x"6800_03EE",		-- Compare GR8 with PM(1006)
            0012=>x"4000_0009",		-- Branch on Not Equal to address 0009
            0013=>x"B800_0000",		-- Write to GPU GR8, GR9, GR10
            0014=>x"8900_0000",		-- Decrease GR9
            0015=>x"6900_03EE",		-- Compare GR9 with PM(1006)
            0016=>x"4000_0013",		-- Branch on Not Equal to address 13
            -- LOAD SIDEBAR
            0017=>x"3000_0017",		-- Branch Always 17 (Ininity loop.)
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
            0049=>x"0000_0000",		--
            --CONSTANTS
            1000=>x"0000_0000",		-- 
            1001=>x"0000_0000",		-- 
            1002=>x"0000_0000",		-- 
            1003=>x"0000_0000",		-- 
            1004=>x"0000_00EF",		-- Widht game 239
            1005=>x"0000_00EF",		-- Height game 239
            1006=>x"0000_0000",		-- Constant 0
            1007=>x"0000_013F",	    -- Width screen 319	
            1008=>x"0000_0000",      -- Color Black
            1009=>x"0000_0001",      -- Color Magenta
            1010=>x"0000_0002",      -- Color Aqua
            1011=>x"0000_0003",      -- Color Green/Lime
            1012=>x"0000_0004",      -- Color Red
            1013=>x"0000_0005",      -- Color Blue
            1014=>x"0000_0006",      -- Color Yellow
            1015=>x"0000_0007",      -- Color DarkGrey
            1016=>x"0000_0008",      -- Color ?
            1017=>x"0000_0009",      -- Color ?
            1018=>x"0000_000A",      -- Color ?
            1019=>x"0000_000B",      -- Color ?
            1020=>x"0000_000C",      -- Color ?
            1021=>x"0000_000D",      -- Color ?
            1022=>x"0000_000E",      -- Color ?
            1023=>x"0000_000F",      -- Color White 
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





 






        
