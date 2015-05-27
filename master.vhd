library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity master is
    port(
          -- UCF SIGNALS
          clk, rst            : in        std_logic;
          vgaRed, vgaGreen    : out       std_logic_vector (2 downto 0);
          vgaBlue             : out       std_logic_vector (2 downto 1);
          hsync, vsync        : out       std_logic
        );
end master;

architecture behaviour of master is

--Instantiate CPU component
  component cpu 
    port (
          clk, rst       : in     std_logic;
          gpu_dbus       : in     std_logic_vector(31 downto 0);
          gpuTakeBus     : out    std_logic_vector(2 downto 0);
          cpuOut         : out    std_logic_vector(31 downto 0)
         );
  end component;
--Instantiate GPU component
  component gpu
    port (
          clk,rst             : in    std_logic;
          dbus                : in    std_logic_vector(31 downto 0);
          FB_c                : in    std_logic_vector(2 downto 0);
          gpuOut              : out   std_logic_vector(31 downto 0);
          vgaRed, vgaGreen  : out   std_logic_vector (2 downto 0);
          vgaBlue            : out   std_logic_vector (2 downto 1);
          hsync, vsync        : out   std_logic
         );
   end component;

    -- Signals between components
    signal  gpuToCpu        : std_logic_vector(31 downto 0);
    signal  FB_gpu          : std_logic_vector(2 downto 0);
    signal  cpuToGpu        : std_logic_vector(31 downto 0);

begin
--Instatiate the CPU component
    comp_cpu : cpu port map (
      clk         =>  clk,
      rst         =>  rst,
      gpu_dbus    =>  gpuToCpu,
      gpuTakeBus  =>  FB_gpu,
      cpuOut      =>  cpuToGpu
      );
--Instantiate the GPU component
    comp_gpu : gpu port map (
      clk         =>  clk,
      rst         =>  rst,
      dbus        =>  cpuToGpu,
      FB_c        =>  FB_gpu,
      gpuOut      =>  gpuToCpu,
      vgaRed      =>  vgaRed,
      vgaGreen    =>  vgaGreen,
      vgaBlue     =>  vgaBlue,
      hsync       =>  hsync,
      vsync       =>  vsync
      );  
end;
