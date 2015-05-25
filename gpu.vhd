library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity gpu is 
  Port  ( clk,rst : in std_logic;
          dbus : in std_logic_vector(31 downto 0);
          gpuOut : out std_logic_vector(3 downto 0);
          FB_o : in std_logic_vector(2 downto 0);
          vga_red, vga_green : out std_logic_vector (2 downto 0);
          vga_blue : out std_logic_vector (2 downto 1);
          hsync, vsync : out std_logic);
end gpu;

-- ====== Info ======
-- ASR is split in to rows and cols.
-- The first 12 bits is used to index columns in memory.
-- The last 9 bits is used to index rows in memory.
--
-- When writing to memory the 4 lsb is writen to indexed spot.
-- When reading from memory 4 bits is added as lsb on the bus. 


architecture Behavioral of gpu is
  -- VGA
  signal mod_4 : std_logic_vector(1 downto 0) := "00";
  signal xctr,yctr : std_logic_vector(9 downto 0) := "0000000000";
  signal hs : std_logic := '1';
  signal vs : std_logic := '1';
  -- Memmory
  --alias mem_row : std_logic_vector(8 downto 0) is yctr(9 downto 1);
  --alias mem_col : std_logic_vector(8 downto 0) is xctr(9 downto 1);
  --signal pixel : std_logic_vector(3 downto 0) := "0000";
  
  -- Address register
  signal ASR : std_logic_vector(20 downto 0) := '0' & x"00000";
  alias asr_row : std_logic_vector(8 downto 0) is ASR(8 downto 0);
  alias asr_col : std_logic_vector(11 downto 0) is ASR(20 downto 9);

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
  --type ram_t is array (0 to 239) of std_logic_vector (1279 downto 0);
  type ram_t is array (0 to 76799) of std_logic_vector (3 downto 0);
  signal gpu_memory: ram_t := ((others=> (others=>'0'))); -- Init every bit in memory to 1. 
  
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
          --pixel <= mem_col(6 downto 0) & "00"; -- pixel position 
          video <= gpu_memory(conv_integer(xctr+yctr));
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
  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
        ASR <= '0' & x"00000";
      end if;
      if FB_o="101" then
        ASR <= dbus(20 downto 0); -- ASR is only 21-bits
      end if;
    end if;
  end process;

  -- W/R GPU Memory.
  process(clk) begin
    if rising_edge(clk) then
      if FB_o="100" then
        gpu_memory(conv_integer(ASR)) <= dbus(3 downto 0); 
      end if;
      gpuOut(3 downto 0) <= gpu_memory(conv_integer(ASR));
    end if;
  end process;
  
end Behavioral;
