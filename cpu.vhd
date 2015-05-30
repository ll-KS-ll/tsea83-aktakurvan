library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- Top module(CPU)
entity cpu is
    port( 
        clk, rst        : in    std_logic;
        gpu_dbus        : in    std_logic_vector(31 downto 0);
        gpuTakeBus      : out   std_logic_vector(2 downto 0);
        gpu_tb         : out    std_logic_vector(2 downto 0);
        cpuOut          : out   std_logic_vector(31 downto 0);
        txd             : in    std_logic;
        seg             : out   std_logic_vector(7 downto 0);
        an              : out   std_logic_vector(3 downto 0)
        );
end cpu;

architecture behaviour of cpu is
    -- Signals between components
    signal  Z_o, C_o, L_o   : std_logic;
    signal  FB_c            : std_logic_vector(2 downto 0);
    signal  TB_c            : std_logic_vector(2 downto 0);
    signal  GRx_c           : std_logic_vector(3 downto 0);
    signal  ALU_c           : std_logic_vector(3 downto 0);
    signal  greg_dbus       : std_logic_vector(31 downto 0);
    signal  alu_dbus        : std_logic_vector(31 downto 0);
    signal  areg_dbus       : std_logic_vector(31 downto 0);
    signal  cpu_dbus        : std_logic_vector(31 downto 0);
    signal  cont_dbus       : std_logic_vector(31 downto 0);
    
    
    
    -- Sub-module(controller)
    component controller
      port(
            clk, rst        : in        std_logic;
            dbus            : in        std_logic_vector(31 downto 0);
            Z, C, L         : in        std_logic;
            controllerOut   : out       std_logic_vector(31 downto 0);
            TB_c            : out       std_logic_vector(2 downto 0);
            FB_c            : out       std_logic_vector(2 downto 0);
            GRx_c           : out       std_logic_vector(3 downto 0);
            ALU_c           : out       std_logic_vector(3 downto 0)
          );
    end component;                     
    -- Sub-module(ALU)
    component alu
      port(
            clk, rst        : in        std_logic;
            dbus            : in        std_logic_vector(31 downto 0);
            aluOut          : out       std_logic_vector(31 downto 0);
            TB_c            : in        std_logic_vector(2 downto 0);
            ALU_c           : in        std_logic_vector(3 downto 0);
            Z, C, L         : out       std_logic
            );
    end component;
    -- Sub-Module(General Registers)
    component greg
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
    end component;
    -- Sub-Module(Adress Register/Program Memory)
    component areg
      port(
            clk, rst        : in        std_logic;           
            dbus            : in        std_logic_vector(31 downto 0);
            aregOut         : out       std_logic_vector(31 downto 0);
            FB_c            : in        std_logic_vector(2 downto 0)
          );
    end component;
    -- Sub-Module(Bus mux)
    component mux
      port(
            clk, rst                : in        std_logic;
            aluOut, controllerOut   : in        std_logic_vector(31 downto 0);
            gregOut, aregOut        : in        std_logic_vector(31 downto 0);
            gpuOut                  : in        std_logic_vector(31 downto 0);
            TB_c                    : in        std_logic_vector(2 downto 0);
            dbus                    : out       std_logic_vector(31 downto 0)
          );
    end component;

begin
--Instantiate and do port map for controller
  controller_comp : controller port map (
        clk           =>  clk,
        rst           =>  rst,
        dbus          =>  cpu_dbus,
        Z             =>  Z_o,
        C             =>  C_o,
        L             =>  L_o,
        controllerOut =>  cont_dbus,
        TB_c          =>  TB_c,
        FB_c          =>  FB_c,
        GRx_c         =>  GRx_c,
        ALU_c         =>  ALU_c
        );
--Instantiate and do port map for ALU
  alu_comp : alu port map (
        clk           =>  clk,
        rst           =>  rst,
        dbus          =>  cpu_dbus,
        aluOut        =>  alu_dbus,
        TB_c          =>  TB_c,
        ALU_c         =>  ALU_c,
        Z             =>  Z_o,
        C             =>  C_o,
        L             =>  L_o
        );
--Instantiate and do port map for Greg
  greg_comp : greg port map (
        clk           =>  clk,
        rst           =>  rst,
        dbus          =>  cpu_dbus,
        gregOut       =>  greg_dbus,
        FB_c          =>  FB_c,
        GRx_c         =>  GRx_c,
        txd           =>  txd,
        seg           =>  seg,
        an            =>  an
        );
--Instantiate and do port map for Areg
  areg_comp : areg port map (
        clk           =>  clk,
        rst           =>  rst,
        dbus          =>  cpu_dbus,
        aregOut       =>  areg_dbus,
        FB_c          =>  FB_c
        );
--Instantiate and do port map for Mux
  mux_comp : mux port map (
        clk           =>  clk,
        rst           =>  rst,
        aluOut        =>  alu_dbus,       
        controllerOut =>  cont_dbus,
        gregOut       =>  greg_dbus,
        aregOut       =>  areg_dbus,
        gpuOut        =>  gpu_dbus,
        TB_c          =>  TB_c,
        dbus          =>  cpu_dbus
        );
      
      -- Send dbus out from CPU so GPU can use it.
      cpuOut <= cpu_dbus;
      -- Send TB_c out from CPU so GPU can use it.
      gpuTakeBus <= FB_c;
      gpu_tb <= TB_c;
      
end architecture;
        

