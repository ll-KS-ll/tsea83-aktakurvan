-- TestBench 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture behavior of tb is 
  
  component master
    port(
        clk, rst            : in        std_logic;
        vga_red, vga_green  : out       std_logic_vector (2 downto 0);
        vga_blue            : out       std_logic_vector (2 downto 1);
        hsync, vsync        : out       std_logic
    );
  end component;

   

  -- Internal signals

  signal tb_running : boolean := true;

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal hsync,vsync : std_logic;
  signal vga_red, vga_green : std_logic_vector(2 downto 0);
  signal vga_blue : std_logic_vector(2 downto 1);

begin

  -- Component Instantiation
    m1 : master port map(clk, rst, vga_red, vga_green, vga_blue, hsync, vsync);
 

  -- 100 MHz system clock
  clk_gen : process
  begin
    while tb_running loop -- while tb_running loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
    wait;
  end process;

  

  stimuli_generator : process
    variable i : integer;
  begin
    -- Aktivera reset ett litet tag.
    rst <= '1';
    wait for 50 ns;

    wait until rising_edge(clk);        -- se till att reset släpps synkront
                                        -- med klockan
    rst <= '0';
    report "Reset released" severity note;


    for i in 0 to 50000000 loop         -- Vänta ett antal klockcykler
      wait until rising_edge(clk);
    end loop;  -- i
    
    tb_running <= false;                -- Stanna klockan (vilket medför att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
    wait;
  end process;
      
END;
