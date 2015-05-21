library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- General Registers
entity greg is
        port(
            clk, rst        : in         std_logic;
            dbus            : inout      std_logic_vector(31 downto 0);
            contr_greg      : inout      std_logic_vector(5 downto 0);
            );
end greg;

architecture arch of greg is
        -- Registers
        signal GR0, GR1, GR2, GR3       : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR4, GR5, GR6, GR7       : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR8, GR9, GR10, GR11     : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR12, GR13, GR14, GR15   : std_logic_vector(31 downto 0) := X"0000_0000";

        -- Dbus control
        alias greg_dbus                 : std_logic_vector(1 downto 0)  is contr_greg(5 downto 4);
        -- General Registers control
        alias c_greg                    : std_logic_vector(3 downto 0)  is contr_greg(3 downto 0);

        -- To and from Gregs and Dbus
        process(clk) begin
            if rising_edge(clk) then
                if greg_dbus="01" then
                    case c_greg is
                        when "0000" => dbus <= GR0;
                        when "0001" => dbus <= GR1;
                        when "0010" => dbus <= GR2;
                        when "0011" => dbus <= GR3;
                        when "0100" => dbus <= GR4;
                        when "0101" => dbus <= GR5;
                        when "0110" => dbus <= GR6;
                        when "0111" => dbus <= GR7;
                        when "1000" => dbus <= GR8;
                        when "1001" => dbus <= GR9;
                        when "1010" => dbus <= GR10;
                        when "1011" => dbus <= GR11;
                        when "1100" => dbus <= GR12;
                        when "1101" => dbus <= GR13;
                        when "1110" => dbus <= GR14;
                        when others => dbus <= GR15;
                    end case;
                    contr_greg(5 downto 4) <= "00";
                elsif greg_dbus="10" then
                    case c_greg is
                        when "0000" => GR0 <= dbus;
                        when "0001" => GR1 <= dbus;
                        when "0010" => GR2 <= dbus;
                        when "0011" => GR3 <= dbus;
                        when "0100" => GR4 <= dbus;
                        when "0101" => GR5 <= dbus;
                        when "0110" => GR6 <= dbus;
                        when "0111" => GR7 <= dbus;
                        when "1000" => GR8 <= dbus; 
                        when "1001" => GR9 <= dbus;
                        when "1010" => GR10 <= dbus;
                        when "1011" => GR11 <= dbus;
                        when "1100" => GR12 <= dbus;
                        when "1101" => GR13 <= dbus;
                        when "1110" => GR14 <= dbus;
                        when others => GR15 <= dbus;
                    end case;
                    contr_greg(5 downto 4) <= "00";
                end if;
            end if;       
        end process;

end architecture greg;

