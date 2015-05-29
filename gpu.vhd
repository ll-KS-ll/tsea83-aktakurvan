library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.STD_LOGIC_NUMERIC.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity gpu is 
  Port  ( clk,rst           : in std_logic;
          dbus              : in std_logic_vector(31 downto 0);
          gpuOut            : out std_logic_vector(31 downto 0);
          FB_c              : in std_logic_vector(2 downto 0);
          TB_c              : in std_logic_vector(2 downto 0);
          vgaRed, vgaGreen  : out std_logic_vector (2 downto 0);
          vgaBlue           : out std_logic_vector (2 downto 1);
          hsync, vsync      : out std_logic
        );
end gpu;

-- ====== Info ======
-- GPU displays at a resolution of 640x480.
-- The memory contains 320x240 (76800) pixles that are displayed.
-- These can be writen and read through x and y coordinates.
-- The memory internal is a long row of 4 bits arrays.
--
-- When reading and writing to GPU Memory, the data on the bus is split into sections.
-- 
-- The last 4 bits is the data (color) to read or to be writen.
-- Bit 11-4, 8 bits (256) is used to index rows in memory.
-- Bit 20-12, 9 (512) is used to index columns in memory.
-- Bit 31 is used to signal read or write. 1 for read, 0 for write.
--
-- GM: [f--- ---- ---x xxxx xxxx yyyy yyyy cccc]
-- 
-- 

architecture Behavioral of gpu is
  component ram
      port (
          clk       : in std_logic;
          xaddress  : in integer;
          yaddress  : in integer;
          rxaddress  : in integer;
          ryaddress  : in integer;
          we        : in std_logic;
          read_access : in std_logic;
          data_i    : in std_logic_vector(3 downto 0);
          data_o    : out std_logic_vector(3 downto 0)
          );
  end component;

  component gpu_display_numbers is 
    port ( 
      clk, rst : in std_logic;
      dbus : in std_logic_vector(31 downto 0);
      FB_o : in std_logic_vector(2 downto 0);
      control_register : in std_logic_vector(31 downto 0);
      rxaddress  : in integer;
      ryaddress  : in integer;
      output_number : out std_logic;
      number_pixel : out std_logic_vector(3 downto 0)
    );
  end component;

  -- VGA
  signal mod_4 : std_logic_vector(1 downto 0) := "00";
  signal xctr,yctr : std_logic_vector(10 downto 0) := "00000000000";
  signal hs : std_logic := '1';
  signal vs : std_logic := '1';

  alias rad : std_logic_vector(8 downto 0) is yctr(9 downto 1);
  alias kol : std_logic_vector(8 downto 0) is xctr(9 downto 1);
  alias xpix : std_logic_vector(1 downto 0) is xctr(1 downto 0);
  alias ypix : std_logic_vector(1 downto 0) is yctr(1 downto 0);
  
  -- Display number
  signal output_number : std_logic := '0';
  signal number_pixel : std_logic_vector(3 downto 0) := x"F";

  -- Control register
  signal control_register : std_logic_vector(31 downto 0) := x"0000_0000";
  alias we : std_logic is control_register(0);
  alias num_flag : std_logic is control_register(4);

  --RAM
  signal xaddress  : integer := 0;
  signal yaddress  : integer := 0;
  signal rxaddress  : integer := 0;
  signal ryaddress  : integer := 0;
  signal to_ram    : std_logic_vector(3 downto 0);
  signal from_ram    : std_logic_vector(3 downto 0);
  signal read_access : std_logic := '0';
  -- Memory/Bus
  alias data : std_logic_vector(3 downto 0) is dbus(3 downto 0);
  signal video : std_logic_vector (3 downto 0) := "0000"; -- Color from memory.

  -- Color palette
  type color_t is array (0 to 15) of std_logic_vector (7 downto 0);
  constant colors : color_t := -- "rrrgggbb"
    ( x"00", -- Black       0
      x"E3", -- Magenta     1
      x"1F", -- Aqua        2
      x"1C", -- Green/Lime  3
      x"E0", -- Red         4
      x"03", -- Blue        5
      x"FC", -- Yellow      6
      x"49", -- DarkGrey    7 
      x"00",
      x"00",
      x"00",
      x"00",
      x"00",
      x"00",
      x"00",
      x"FF"); -- White      F


begin

  -- Select mem or nums.
  with TB_c select
    gpuOut <= x"0000_000" & from_ram when "111",
              control_register when "101",
              (others => 'Z') when others; 


  -- GPU clock, 25MHz from 100MHz
  process(clk) begin
     if rising_edge(clk) then
       if rst='1' then
         mod_4 <= "00";
       else
         mod_4 <= mod_4 + 1;
       end if;
     end if;
  end process;

  -- hsync
  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
         xctr <= "00000000000";
      elsif mod_4=3 then
        if xctr=799 then
          xctr <= "00000000000";
        else
          xctr <= xctr + 1;
        end if;
      end if;
      -- 
      if xctr=656 then
        hs <= '0';
      elsif xctr=752 then
        hs <= '1';
      end if;
    end if;
  end process;

  -- vsync
  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
        yctr <= "00000000000";
      elsif xctr=799 and mod_4=0 then
        if yctr=520 then
          yctr <= "00000000000";
        else
          yctr <= yctr + 1;
        end if;
        --
        if yctr=490 then
          vs <= '0';
        elsif  yctr=492 then
          vs <= '1';
        end if;
      end if;
    end if;
  end process;
  hsync <= hs;
  vsync <= vs;


  process(clk) begin
    if rising_edge(clk) then
      case FB_c is
        when "100" => -- GPU
                if num_flag = '0' then
                  yaddress <= conv_integer(dbus(11 downto 4));
                  xaddress <= conv_integer(dbus(20 downto 12));
                  if we = '1' then
                    to_ram <= data;
                  else
                    read_access <= '1';
                  end if;
                end if;
        when "101" => -- Control register
                control_register <= dbus;
        when others => read_access <= '0';
      end case;
    end if;
  end process;

  ryaddress <= conv_integer(rad);
  rxaddress <= conv_integer(kol);

  -- R GPU Memory.
  process(clk) begin
    if rising_edge(clk) then
       if mod_4=3 then
          if xctr<640 and yctr<480 then
              if output_number = '0' then
                video <= from_ram;
              else 
                video <= number_pixel;
              end if;
          else
              video <= x"0";        
          end if;
        end if;
    end if;
  end process;

  -- Color
  vgaRed(2 downto 0) <= colors(conv_integer(video))(7 downto 5);
  vgaGreen(2 downto 0) <= colors(conv_integer(video))(4 downto 2);
  vgaBlue(2 downto 1) <= colors(conv_integer(video))(1 downto 0);

  comp_ram : ram port map (
      clk       =>  clk,
      xaddress  =>  xaddress,
      yaddress  =>  yaddress,
      rxaddress  =>  rxaddress,
      ryaddress  =>  ryaddress,
      we        =>  we,
      read_access => read_access,
      data_i    =>  to_ram,
      data_o    =>  from_ram
      );

  comp_num : gpu_display_numbers port map (
      clk       =>  clk,
      rst       => rst,
      dbus      => dbus,
      FB_o      => FB_c,
      control_register => control_register,
      rxaddress  =>  rxaddress,
      ryaddress  =>  ryaddress,
      output_number => output_number,
      number_pixel => number_pixel
    );
  
end Behavioral;
