library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity gpu_display_numbers is 
  Port  ( clk,rst : in std_logic;
          dbus : in std_logic_vector(31 downto 0);
          FB_o : in std_logic_vector(2 downto 0);
          rxaddress  : in integer;
          ryaddress  : in integer;
          output_number : out std_logic
        );
end gpu_display_numbers;

architecture arch of gpu_display_numbers is

  -- Select wich numbers to display or none.
  --signal numbers_activated : std_logic_vector(2 downto 0) := "000";
  -- Number to currently write to display.
  signal current_seleced_number : std_logic_vector(2 downto 0) := "100"; -- bit 2 toggles unselected.  
  signal x_num, y_num : integer := 0; -- Col and row in digit.
  signal digit : std_logic_vector(3 downto 0); -- One single digit of the number;
  signal selected_digit : std_logic := '0'; -- Which digit is active/supposed to be drawn.

  --constant x_num_loc : integer := 280; -- Left corner of digits
  --constant y_num_loc : integer := 32;  -- Left corner of digits
  --constant w_num : integer := 4;       -- Width of digit
  --constant h_num : integer := 7;       -- Height of digit
  --constant py_num : integer := 10;     -- Padding y-led between digits 
  --constant px_num : integer := 2;      -- Padding x-led between digits 
  
  -- Numbers to display
  type number_t is array(0 to 3) of std_logic_vector(7 downto 0); -- 4 diffrent numbers upto 99.
  --signal display_numbers : number_t := (others => (others => '0'));
  signal display_numbers : number_t := (x"34", x"78", x"91", x"65"); -- BCD

  -- Bus stuff
  --  alias bus_number : std_logic_vector(6 downto 0) is dbus(6 downto 0);
  --  alias bus_current_seleced_number : std_logic_vector(1 downto 0) is dbus(11 downto 10);
  --  alias bus_activate_number_code : std_logic_vector(2 downto 0) is dbus(31 downto 29);

  -- Number tile constants.
  type number_tile_t is array(0 to 6) of std_logic_vector(0 to 3);
  constant zero : number_tile_t := (
    "1111", "1001", "1001", "1001", "1001", "1001", "1111"
  );
  constant one : number_tile_t := (
    "0001", "0001", "0001", "0001", "0001", "0001", "0001"
  );
  constant two : number_tile_t := (
    "1111", "0001", "0001", "1111", "1000", "1000", "1111"
  );
  constant three : number_tile_t := (
    "1111", "0001", "0001", "1111", "0001", "0001", "1111"
  );
  constant four : number_tile_t := (
    "1001", "1001", "1001", "1111", "0001", "0001", "0001"
  );
  constant five : number_tile_t := (
    "1111", "1000", "1000", "1111", "0001", "0001", "1111"
  );
  constant six : number_tile_t := (
    "1111", "1000", "1000", "1111", "1001", "1001", "1111"
  );
  constant seven : number_tile_t := (
    "1111", "0001", "0001", "0001", "0001", "0001", "0001"
  );
  constant eight : number_tile_t := (
    "1111", "1001", "1001", "1111", "1001", "1001", "1111"
  );
  constant nine : number_tile_t := (
    "1111", "1001", "1001", "1111", "0001", "0001", "1111"
  );
  type numbers_t is array(0 to 9) of number_tile_t;
  constant numbers : numbers_t := (zero, one, two, three, four, five, six, seven, eight, nine);

begin 

--	process(clk) begin
--    if rising_edge(clk) then
--      if rst = '1' then
--        -- Reset
--      elsif FB_o="101" then
--        -- Display number
--        if not activate_number_code = '000' then
--          numbers_activated <= activate_number_code;
--        end if;
--        display_numbers(conv_integer(current_seleced_number)) <= number;
--    end if;
--  end process;

	-- Set number do draw right now or none.
  current_seleced_number <= "100" when rxaddress >= 284 and 
                                       rxaddress <  286 else
                            "000" when rxaddress >= 280 and 
                                       rxaddress <  290 and 
                                       ryaddress >= 32 and 
                                       ryaddress <  39 else
                            "001" when rxaddress >= 280 and 
                                       rxaddress <  290 and 
                                       ryaddress >= 49 and
                                       ryaddress <  56 else
                            "010" when rxaddress >= 280 and 
                                       rxaddress <  290 and 
                                       ryaddress >= 66 and
                                       ryaddress <  73 else
                            "011" when rxaddress >= 280 and 
                                       rxaddress <  290 and 
                                       ryaddress >= 83 and
                                       ryaddress <  90 else
                            "100";

  selected_digit <= '0' when rxaddress >= 286 else '1';

  -- Cal
  with selected_digit select
    x_num <= rxaddress - 280 when '1',
             rxaddress - 286 when others; 
  with current_seleced_number select 
    y_num <= ryaddress - 32 when "000",
             ryaddress - 49 when "001",
             ryaddress - 66 when "010",
             ryaddress - 83 when others; 

  with selected_digit select
    digit <= display_numbers(conv_integer(current_seleced_number(1 downto 0)))(7 downto 4) when '1',
             display_numbers(conv_integer(current_seleced_number(1 downto 0)))(3 downto 0) when others;

  -- Deside if gpu memory or number should be drawn.
  with current_seleced_number(2) select
    --output_number <= numbers(0)(y_num)(x_num) when '0',
    output_number <= numbers(conv_integer(digit))(y_num)(x_num) when '0',
                     '0' when others;  

--with numbers_activated select
--  output_number <=  
--    when "100" => -- One number
--    
--    when "101" => -- Two numbers
--
--    when"110" => -- Three numbers

--    when"111" => -- Four numbers
--
--    when"001" => -- Deactivate
--        numbers_activated <= "000";
--
--    when others => "000";



end architecture; -- arch
