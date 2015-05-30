library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity leddriver is
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           value : in  STD_LOGIC_VECTOR (7 downto 0));
end leddriver;

architecture Behavioral of leddriver is
	signal segments : STD_LOGIC_VECTOR (6 downto 0);
	signal counter_r :  unsigned(17 downto 0) := "000000000000000000";
	signal v : STD_LOGIC_VECTOR (7 downto 0);
        signal dp : std_logic;
begin
  -- decimal point not used
  dp <= '1';
  seg <= (dp & segments);
     
   with counter_r(17 downto 16) select
     v <= value when "00",
          value when others;

   process(clk) begin
     if rising_edge(clk) then 
       counter_r <= counter_r + 1;
       case v is -- 1:or släcker 0:or tänder
         when "0000_0000" => segments <= "0000001"; -- 0
         when "0001_0000" => segments <= "0000001"; -- 0
         when "0010_0000" => segments <= "0000001"; -- 0
         when "0011_0000" => segments <= "0000001"; -- 0
         when "0100_0000" => segments <= "0000001"; -- 0
         when "0101_0000" => segments <= "0000001"; -- 0
         when "0110_0000" => segments <= "0000001"; -- 0
         when "0111_0000" => segments <= "0000001"; -- 0
         when "1000_0000" => segments <= "0000001"; -- 0
         when "1001_0000" => segments <= "0000001"; -- 0
         when "1010_0000" => segments <= "0000001"; -- 0
         when "1011_0000" => segments <= "0000001"; -- 0
         when "1100_0000" => segments <= "0000001"; -- 0
         when "1101_0000" => segments <= "0000001"; -- 0
         when "1110_0000" => segments <= "0000001"; -- 0
         when "1111_0000" => segments <= "0000001"; -- 0
         when "0000_0001" => segments <= "1001111"; -- 1
         when "0000_0010" => segments <= "0010010"; -- 2
         when "0000_0011" => segments <= "0000110"; -- 3
         when "0000_0100" => segments <= "1001100"; -- 4
         when "0000_0101" => segments <= "0100100"; -- 5
         when "0000_0110" => segments <= "0100000"; -- 6
         when "0000_0111" => segments <= "0001111"; -- 7
         when "0000_1000" => segments <= "0000000"; -- 8
         when "0000_1001" => segments <= "0000100"; -- 9
         when "0000_1010" => segments <= "0001000"; -- A
         when "0000_1011" => segments <= "1100000"; -- B
         when "0000_1100" => segments <= "0110001"; -- C
         when "0000_1101" => segments <= "1000010"; -- D
         when "0000_1110" => segments <= "0110000"; -- E
         when "0010_0100" => segments <= "0000110"; -- Bokstaven E
         when others => segments <= "0111000";      -- F
       end case;
      
       case counter_r(17 downto 16) is
         when "00" => an <= "0111";
         when "01" => an <= "1011";
         when "10" => an <= "1101";
         when others => an <= "1110";
       end case;
     end if;
   end process;
	
end Behavioral;

