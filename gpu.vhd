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

entity gpu is 
  Port  ( clk,rst : in std_logic;
          dbus : in std_logic_vector(31 downto 0);
          gpuOut : out std_logic_vector(31 downto 0);
          FB_o : in std_logic_vector(2 downto 0);
          vga_red, vga_green : out std_logic_vector (2 downto 0);
          vga_blue : out std_logic_vector (2 downto 1);
          hsync, vsync : out std_logic);
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
  -- VGA
  signal mod_4 : std_logic_vector(1 downto 0) := "00";
  signal xctr,yctr : std_logic_vector(9 downto 0) := "0000000000";
  signal hs : std_logic := '1';
  signal vs : std_logic := '1';
  
  -- Memory/Bus
  alias data : std_logic_vector(3 downto 0) is dbus(3 downto 0);
  alias row : std_logic_vector(7 downto 0) is dbus(11 downto 4);
  alias col : std_logic_vector(8 downto 0) is dbus(20 downto 12);
  alias rw_flag : std_logic is dbus(31);

  -- Color palette
  type color_t is array (0 to 15) of std_logic_vector (7 downto 0);
  constant colors : color_t := -- "rrrgggbb"
    ( x"00", -- Black
      x"E0", -- Red
      x"03", -- Blue
      x"FC", -- Yellow
      x"1C", -- Green/Lime
      x"1F", -- Aqua
      x"E3", -- Magenta
      x"00",  
      x"00",
      x"00",
      x"00",
      x"00",
      x"00",
      x"00",
      x"00",
      x"FF"); -- White
  signal video : std_logic_vector (3 downto 0) := "0000"; -- Color from memory.
  -- GPU RAM
  type ram_t is array (0 to 76799) of std_logic_vector (3 downto 0);
  -- signal gpu_memory: ram_t := ((others=> (others=>'0'))); -- Init every bit in memory to 1. 
  signal gpu_memory: ram_t := ((others=> x"4")); 
  --constant grr : ram_t := 
  --  ('1' when pixel_x <= 320 and pixel_y = 0
  --  '1' when pixel_x = 0 and pixel_y <= 240
  --  '1' when pixel_x = 320 and pixel_y <= 240
  --  '1' when pixel_x <= 320 and pixel_y = 240
  --  others=> (others=>'0'));
  ---signal gpu_memory: ram_t := grr;

  -- Force xilinx to use block RAM.
  attribute ram_style: string;
  attribute ram_style of gpu_memory : signal is "block";
begin
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
         xctr <= "0000000000";
      elsif mod_4=3 then
        if xctr=799 then
          xctr <= "0000000000";
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
        yctr <= "0000000000";
      elsif xctr=799 and mod_4=0 then
        if yctr=520 then
          yctr <= "0000000000";
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
  
  -- Memory
  process(clk) begin
    if rising_edge(clk) then
      -- Following code is out commeted cuz it locks compiling :s
      --if rst = '1' then
      --  video <= x"1"; -- Screen is red when reset is pressed. 
      --  pixel <= "000000000";
      --  gpu_memory <= ((others=> (others=>'1')));
      --els
      if mod_4=3 then
        if xctr<640 and yctr<480 then
          -- yctr / 2 & xctr / 2 
          video <= gpu_memory(conv_integer(yctr(8 downto 1)&xctr(8 downto 1)));
        else
          video <= "0000";
        end if; 
      end if;
    end if;
  end process;

  -- Color
  vga_red(2 downto 0) <= colors(conv_integer(video))(7 downto 5);
  vga_green(2 downto 0) <= colors(conv_integer(video))(4 downto 2);
  vga_blue(2 downto 1) <= colors(conv_integer(video))(1 downto 0);

  -- ASR
  --process(clk) begin
  --  if rising_edge(clk) then
  --    if rst='1' then
  --      ASR <= '0' & x"00000";
  --    end if;
  --    if FB_o="101" then
  --      ASR <= dbus(20 downto 0); -- ASR is only 21-bits
  --    end if;
  --  end if;
  --end process;

  -- W/R GPU Memory.
  process(clk) begin
    if rising_edge(clk) then
      if FB_o="100" then
        if rw_flag = '0' then
          -- Write
          gpu_memory(conv_integer(row&col)) <= data; 
        else 
          -- Read
          gpuOut <= x"0000_000" & gpu_memory(conv_integer(row&col));
          -- Broken, out of LUTs :s
          --gpuOut <= "0000_0000_000" & row & col & gpu_memory(conv_integer(row&col));
        end if;
      end if;
      -- Explination.
      --   0 1 2 3      x   Display structure
      -- 0 a b c d    y d
      -- 1 e f g h 
      -- 2 i j k l 
      -- 3 m n o p 

      -- p  d (x,y)    GPU Memory structure
      -- ----------
      -- 0  a (0,0)
      -- 1  b (1,0)
      -- 2  c (2,0)
      -- 3  d (3,0)
      -- 4  e (0,1)
      -- 5  f (1,1)
      -- 6  g (2,1)
      -- 7  h (3,1)
      -- 8  i (0,2)
      -- 9  j (1,2)
      -- 10 k (2,2)
      -- 11 l (3,2)
      -- 12 m (0,3)
      -- 13 n (1,3)
      -- 14 o (2,3)
      -- 15 p (3,3)

      --  x  y    p      Solution
      -- --------------
      -- 00 00  0000 0
      -- 01 00  0001 1
      -- 10 00  0010 2
      -- 11 00  0011 3
      --      
      -- 00 01  0100 4
      -- 01 01  0101 5
      -- 10 01  0110 6
      -- 11 01  0111 7
      ---
      -- 00 10  1000 8
      -- 01 10  1001 9
      -- 10 10  1010 10
      -- 11 10  1011 11
      ---
      -- 00 11  1100 12
      -- 01 11  1101 13
      -- 10 11  1110 14
      -- 11 11  1111 15
      -- -----------
      -- xx yy  xxyy     General solution
    end if;
  end process;
  
end Behavioral;
