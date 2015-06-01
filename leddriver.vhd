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
	signal segments : STD_LOGIC_VECTOR (7 downto 0);
	signal counter_r :  unsigned(17 downto 0) := "000000000000000000";
	signal v : STD_LOGIC_VECTOR (7 downto 0);
  --signal dp : std_logic;
begin
  -- decimal point not used
  --dp <= '1';
  seg <= segments;
     
   with counter_r(17 downto 16) select
     v <= value when "00",
          value when others;

   process(clk) begin
     if rising_edge(clk) then 
       counter_r <= counter_r + 1;
        

       case v is
          when B"0111_0001" => segments <= "01000000";
          when B"0111_0111" => segments <= "10110000";
          when B"0110_0101" => segments <= "10000110";
          when B"0110_0010" => segments <= "10000000";
          when B"0110_1001" => segments <= "11111001";
          when B"0110_1111" => segments <= "11000000";
          when B"0111_0000" => segments <= "10001100";
          when others => segments <= "10001110";
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

