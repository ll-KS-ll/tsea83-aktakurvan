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
            dbus            : inout     std_logic_vector(31 downto 0);
            contr_areg      : inout     std_logic_vector(1 downto 0)
            );
end areg;

architecture arch of areg is
        -- Registeers
        signal ASR          : std_logic_vector(20 downto 0)     := X"000_000";

        -- Dbus control
        alias areg_dbus     : std_logic_vector(1 downto 0)      is contr_areg(1 downto 0);

        --PM
        type pMem_t is array(0 to 1024) of std_logic_vector(31 downto 0);
        signal pMem : pMem_t := ( -- Program memory
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
            x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000"
        );

begin
       
        -- Memory Control
        process(clk) begin
            if rising_edge(clk) then
                case areg_dbus is
                    when "00" =>    contr_areg                      <= "00"; -- NOP
                    when "01" =>    dbus                            <= pMem(conv_integer(ASR));
                                    contr_areg                      <= "00";
                    when "10" =>    pMem(conv_integer(ASR))         <= dbus; -- Move to ASR and store it;
                                    contr_areg                      <= "00";
                    when others =>  ASR                             <= dbus; -- From dbus to ASR
                                    contr_areg                      <= "00";
                end case;
            end if;
        end process;

end architecture ; -- arch





 






        
