-- TestBench Template 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture behavior of tb is 
  
  component alu 
    port(
      clk, rst        : in        std_logic;
      dbus            : in        std_logic_vector(31 downto 0);
      aluOut          : out       std_logic_vector(31 downto 0);
      TB_o            : in        std_logic_vector(2 downto 0);
      ALU_o           : in        std_logic_vector(3 downto 0);
      Z, C, L         : out       std_logic
    );
  end component;

  component controller
    port( 
      clk, rst        : in     std_logic;
      dbus            : in     std_logic_vector(31 downto 0);
      Z, C, L         : in     std_logic;
      controllerOut   : out    std_logic_vector(31 downto 0);
      TB_o            : out    std_logic_vector(2 downto 0);
      FB_o            : out    std_logic_vector(2 downto 0);
      GRx_o            : out    std_logic_vector(3 downto 0);
      ALU_o           : out    std_logic_vector(3 downto 0)    
    );
  end component;

  component greg
    port(
      clk, rst        : in      std_logic;
      dbus            : in      std_logic_vector(31 downto 0);
      gregOut         : out     std_logic_vector(31 downto 0);
      FB_o            : in      std_logic_vector(2 downto 0);
      GRx_o            : in      std_logic_vector(3 downto 0)
    );
  end component;

  component areg
    port(
      clk, rst        : in     std_logic;
      dbus            : in     std_logic_vector(31 downto 0);
      aregOut         : out    std_logic_vector(31 downto 0);
      FB_o            : in     std_logic_vector(2 downto 0)
    );
  end component;

  component mux is
    port(
      clk, rst                : in        std_logic;
      aluOut, controllerOut   : in        std_logic_vector(31 downto 0);
      gregOut, aregOut        : in        std_logic_vector(31 downto 0);
      gpuOut                  : in        std_logic_vector(3 downto 0);
      TB_o                    : in        std_logic_vector(2 downto 0);
      dbus                    : out       std_logic_vector(31 downto 0)
    );
  end component;

  component gpu
    port(
      clk,rst : in std_logic;
      --adress : in std_logic_vector (20 downto 0);
      --data_in : in std_logic_vector (3 downto 0);
      --data_ut : out std_logic_vector (3 downto 0);
      dbus : in std_logic_vector(31 downto 0);
      gpuOut : out std_logic_vector(3 downto 0);
      FB_o : in std_logic_vector(2 downto 0);
      vga_red, vga_green : out std_logic_vector (2 downto 0);
      vga_blue : out std_logic_vector (2 downto 1);
      hsync,vsync : out std_logic
    );
  end component;    

  -- Internal signals

  signal tb_running : boolean := true;

  signal clk : std_logic := '0';
  signal rst : std_logic := '1';
  
  signal dbus : std_logic_vector(31 downto 0);
  
  signal TB_o : std_logic_vector(2 downto 0);
  signal FB_o : std_logic_vector(2 downto 0);
  signal GRx_o : std_logic_vector(3 downto 0);
  signal ALU_o : std_logic_vector(3 downto 0);
  
  signal aluOut : std_logic_vector(31 downto 0);
  signal controllerOut : std_logic_vector(31 downto 0);
  signal gregOut : std_logic_vector(31 downto 0);
  signal aregOut : std_logic_vector(31 downto 0);
  signal gpuOut : std_logic_vector(3 downto 0);

  signal Z, C, L : std_logic;
  
  signal hsync,vsync : std_logic;
  signal vga_red, vga_green : std_logic_vector(2 downto 0);
  signal vga_blue : std_logic_vector(2 downto 1);

begin

  -- Component Instantiation
    
  -- ALU 
  alu0: alu port map(clk, rst, dbus, aluOut, TB_o, ALU_o, Z, C, L);

  -- Controller
  controller0: controller port map (clk, rst, dbus, Z, C, L, controllerOut, 
      TB_o, FB_o, GRx_o, ALU_o);

  greg0: greg port map(clk, rst, dbus, gregOut, FB_o, GRx_o);

  areg0: areg port map(clk, rst, dbus, aregOut, FB_o);

  mux0: mux port map(clk, rst, aluOut, controllerOut, gregOut, aregOut, gpuOut, TB_o, dbus);

  -- GPU
  gpu0: gpu port map(clk, rst, dbus, gpuOut, FB_o, vga_red, vga_green, vga_blue, hsync, vsync);

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
