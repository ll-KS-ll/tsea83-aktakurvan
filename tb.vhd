-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb IS
END tb;

ARCHITECTURE behavior OF tb IS 

  -- Component Declaration
  COMPONENT CPU
    PORT(
      clk, rst : in std_logic;
        bus_in : in std_logic_vector (31 downto 0);
        bus_out : out std_logic_vector (31 downto 0)
    );
  END COMPONENT;

  COMPONENT GPU
    PORT(
      clk,rst : in std_logic;
      --adress : in std_logic_vector (20 downto 0);
      --data_in : in std_logic_vector (3 downto 0);
      --data_ut : out std_logic_vector (3 downto 0);
      vga_red, vga_green : out std_logic_vector (2 downto 0);
      vga_blue : out std_logic_vector (2 downto 1);
      Hsync, Vsync : out std_logic);
    );
  END COMPONENT;    

  -- Internal signals

  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';
  SIGNAL Hsync,Vsync : std_logic;
  SIGNAL bus_in :  std_logic_vector(31 downto 0);
  SIGNAL bus_out : std_logic_vector(31 downto 0);
  -- SIGNAL tb_running : boolean := true;
  SIGNAL vgaRed, vgaGreen : STD_LOGIC_VECTOR (2 downto 0);
  SIGNAL vgaBlue : STD_LOGIC_VECTOR (2 downto 1);
BEGIN

  -- Component Instantiation
    
    -- ALU 
    alu0: alu PORT MAP(clk,rst,bus_in,bus_out);

    -- GPU
    gpu0: gpu PORT MAP(clk, rst, vgaRed, vgaGreen, vgaBlue, Hsync, Vsync);

  -- 100 MHz system clock
  clk_gen : process
  begin
    while true loop -- while tb_running loop
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
    wait for 500 ns;

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
