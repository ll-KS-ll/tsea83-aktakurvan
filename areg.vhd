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
            0000=>x"9A00_03E9",		-- Load border color from PM(1001) into GR10
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
            0015=>x"6D00_03EE",		-- Compare GR13 with PM(1006)
            0016=>x"4000_0013",		-- Branch on Not Equal to address 13
            0017=>x"3000_0017",		-- Branch Always 17 (Ininity loop.)
            1000=>x"0000_0000",		-- Color black
            1001=>x"0000_0001",		-- Color red
            1002=>x"0000_0002",		-- Color blue
            1003=>x"0000_0004",		-- Color green
            1004=>x"0000_00EF",		-- Widht game 239
            1005=>x"0000_00EF",		-- Height game 239
            1006=>x"0000_0000",		-- Constant 0
            1007=>x"0000_013F",	    -- Width screen 319	
            1008=>x"0000_0000",
            1009=>x"0000_0000",

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





 






        
