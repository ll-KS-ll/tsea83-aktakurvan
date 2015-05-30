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
            FB_c            : in        std_logic_vector(2 downto 0);
            GRx_c           : in        std_logic_vector(3 downto 0);
            txd             : in        std_logic;
            seg             : out       std_logic_vector(7 downto 0);
            an              : out       std_logic_vector(3 downto 0)
            );
end greg;

architecture arch of greg is
        component uart 
            port(
                clk, rst    : in    std_logic;
                txd         : in    std_logic;
                uartOut     : out   std_logic_vector(7 downto 0);
                seg         : out   std_logic_vector(7 downto 0);
                an          : out   std_logic_vector(3 downto 0)
                );
        end component;  
        -- Registers
        signal GR0, GR1, GR2, GR3       : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR4, GR5, GR6, GR7       : std_logic_vector(31 downto 0) := X"0000_0000";
	    signal GR8, GR9, GR10, GR11     : std_logic_vector(31 downto 0) := X"0000_0000";
        -- GR12-14 is for UART ONLY, 15 is special
	    signal GR12, GR13, GR14         : std_logic_vector(31 downto 0) := X"0000_0000";
        signal Subroutine               : std_logic_vector(31 downto 0) := X"0000_0000";
        signal uartOut                  : std_logic_vector(7 downto 0);


begin

        -- Output
        with GRx_c select
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
                            Subroutine when others;


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
                    Subroutine <= x"0000_0000";
                elsif FB_c="110" then
                    case GRx_c is
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
                        when others => Subroutine <= dbus; -- GR12-14 is only modified by UART (hence they are missing here)
                    end case;
                end if;  
            end if;       
        end process;
        
        --Uart To GR12-14
        process(clk) begin
            if rising_edge(clk) then
                case uartOut is
                    -- Player 1
                    when x"00" => GR12 <= x"0000_0001"; -- Left turn(Q)
                    when x"01" => GR12 <= x"0000_0000"; -- Stop turn(W)
                    when x"02" => GR12 <= x"0000_0002"; -- Right turn(E)
                    -- Player 2
                    when x"04" => GR13 <= x"0000_0001"; -- Left turn(I)
                    when x"05" => GR13 <= x"0000_0000"; -- Stop turn(O)
                    when x"06" => GR13 <= x"0000_0002"; -- Right turn(P)
                    -- Player 3 (isn't implemented in the game) 
                    when x"2A" => GR14 <= x"0000_0001"; -- Left turn(V)
                    when x"32" => GR14 <= x"0000_0000"; -- Stop turn(B)
                    when x"31" => GR14 <= x"0000_0002"; -- Right turn(N)
                    when others => null;
                end case;
            end if;
        end process;



--Instantiate UART
    uart_comp : uart port map (
        clk         => clk,
        rst         => rst,
        txd         => txd,
        uartOut     => uartOut,
        seg         => seg,
        an          => an
        );

end architecture;

