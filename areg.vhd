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
            FB_o            : in        std_logic_vector(2 downto 0)
            );
end areg;

architecture arch of areg is
        -- Registeers
        signal ASR          : std_logic_vector(20 downto 0)     := '0' & X"000_000";

        --PM
        type pMem_t is array(0 to 1023) of std_logic_vector(31 downto 0);

        signal pMem : pMem_t := ( -- Program memory
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            others => x"0000_0000"
        );

begin
       
        -- Memory Control
        process(clk) begin
            if rising_edge(clk) then
                case FB_o is
                    when "010" => pMem(conv_integer(ASR))   <= dbus;
                    when "111" => ASR                       <= dbus(20 downto 0); -- ASR is only 21. 
                    when others => null;
                end case;
            end if;
        end process;

        -- Outsignal is always what ASR points to in memory.
        aregOut <= pMem(conv_integer(ASR));

end architecture ;





 






        
