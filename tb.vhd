-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture behavior of tb is 
  
  component alu 
    port(
      clk, rst        : in         std_logic;
      dbus            : inout      std_logic_vector(31 downto 0);
      contr_alu       : inout      std_logic_vector(5 downto 0); -- Needs to be six so we can tel AUu when to move to dbus
      Z, C, L         : inout      std_logic
    );
  end component;

  component controller
    port( 
      clk, rst        : in        std_logic;
      dbus            : inout     std_logic_vector(31 downto 0);
      contr_areg      : out       std_logic_vector(1 downto 0);
      areg_store      : out       std_logic_vector(20 downto 0);
      contr_alu       : out       std_logic_vector(5 downto 0);
      contr_greg      : out       std_logic_vector(5 downto 0);
      Z, C, L         : inout     std_logic    
    );
  end component;

  component greg
    port(
      clk, rst        : in         std_logic;
      dbus            : inout      std_logic_vector(31 downto 0);
      contr_greg      : inout      std_logic_vector(5 downto 0)
    );
  end component;

  component areg
    port(
      clk, rst        : in        std_logic;
      dbus            : inout     std_logic_vector(31 downto 0);
      contr_areg      : inout     std_logic_vector(1 downto 0)
    );
  end component;

  component gpu
    port(
      clk,rst : in std_logic;
      --adress : in std_logic_vector (20 downto 0);
      --data_in : in std_logic_vector (3 downto 0);
      --data_ut : out std_logic_vector (3 downto 0);
      vga_red, vga_green : out std_logic_vector (2 downto 0);
      vga_blue : out std_logic_vector (2 downto 1);
      hsync,vsync : out std_logic);
    );
  end component;    

  -- Internal signals

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  signal dbus : std_logic_vector(31 downto 0);
  signal contr_alu : std_logic_vector(5 downto 0);
  signal contr_areg : std_logic_vector(1 downto 0);
  signal contr_greg : std_logic_vector(5 downto 0);
  signal areg_store : std_logic_vector(20 downto 0);
  signal Z, C, L : std_logic
  signal hsync,vsync : std_logic;
  signal vga_red, vga_green : std_logic_vector(2 downto 0);
  signal vga_blue : std_logic_vector(2 downto 1);

begin

  -- Component Instantiation
    
  -- ALU 
  alu0: alu port map(clk, rst, dbus, contr_alu, Z, C, L);

  -- Controller
  controller0: controller port map (clk, rst, dbus, contr_areg, contr_store, contr_alu, 
      contr_greg, Z, C, L);

  greg0: greg port map(clk, rst, dbus, contr_greg);

  areg0: areg port map(clk,rst,dbus, contr_areg);

  -- GPU
  gpu0: gpu port map(clk, rst, vga_red, vga_green, vga_blue, hsync, vsync);

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
