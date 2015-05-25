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
            clk, rst        : in        std_logic;
            dbus            : in        std_logic_vector(31 downto 0);
            gregOut         : out       std_logic_vector(31 downto 0);
            FB_o            : in        std_logic_vector(2 downto 0);
            GRx_o            : in        std_logic_vector(3 downto 0)
            );
end greg;

architecture arch of greg is
        -- Registers
        signal GR0, GR1, GR2, GR3       : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR4, GR5, GR6, GR7       : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR8, GR9, GR10, GR11     : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR12, GR13, GR14, GR15   : std_logic_vector(31 downto 0) := X"0000_0000";


begin

        -- Output
        with GRx_o select
                gregOut <=  GR0     when "0000",
                            GR1     when "0001",
                            GR2     when "0010",
                            GR3     when "0011",
                            GR4     when "0100",
                            GR5     when "0101",
                            GR6     when "0110",
                            GR7     when "0111",
                            GR8     when "1000",
                            GR9     when "1001",
                            GR10    when "1010",
                            GR11    when "1011",
                            GR12    when "1100",
                            GR13    when "1101",
                            GR14    when "1110",
                            GR15    when others;


        -- Input
        process(clk) begin
            if rising_edge(clk) then
                if rst = '1' then
                    GR0 <= x"0000_0000";
                    GR1 <= x"0000_0000";
                    GR2 <= x"0000_0000";
                    GR3 <= x"0000_0000";
                    GR4 <= x"0000_0000";
                    GR5 <= x"0000_0000";
                    GR6 <= x"0000_0000";
                    GR7 <= x"0000_0000";
                    GR8 <= x"0000_0000";
                    GR9 <= x"0000_0000";
                    GR10 <= x"0000_0000";
                    GR11 <= x"0000_0000";
                    GR12 <= x"0000_0000";
                    GR13 <= x"0000_003C";
                    GR14 <= x"0000_0000";
                    GR15 <= x"0000_0000";
                elsif FB_o="110" then
                    case GRx_o is
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
                end if;  
            end if;       
        end process;

end architecture;

