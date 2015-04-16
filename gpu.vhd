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
          --adress : in std_logic_vector (20 downto 0);
          --data_in : in std_logic_vector (3 downto 0);
          vga_red, vga_green : out std_logic_vector (2 downto 0);
          vga_blue : out std_logic_vector (2 downto 1);
          hsync, vsync : out std_logic;
          --data_ut : out std_logic_vector (3 downto 0));
end gpu;

architecture Behavioral of gpu is
  signal pixel : std_logic_vector(1 downto 0) := "00";
  signal xctr,yctr : std_logic_vector(9 downto 0) := "0000000000";

  signal hs : std_logic := '1';
  signal vs : std_logic := '1';
  
  --type ram_t is array of (0 to 15) of std_logic_vector (7 downto 0);
  --constant grr : mem_t :=
  --      ("0000000000000000",
  --       "0000000000000000",
  --       "0000000000000000",
  --       "0000000000000110",
  --       "1000100001100000",
  --       "0110000000010000",
  --       "0110000000010001",
  --       "0000000000000000",
  --       "0000000000000000",
  --       "0000000000000000",
  --       "0000000000000110",
  --       "1000100001100000",
  --       "0110000000010000",
  --       "0110000000010001",
  --       "0110000000010000",
  --       "0110000000010001");
  --signal mem: mem_t := grr;
  signal video : std_logic;
begin
  -- GPU clock, 25MHz from 100MHz
  process(clk) begin
     if rising_edge(clk) then
       if rst='1' then
         pixel <= "00";
       else
         pixel <= pixel + 1;
       end if;
     end if;
  end process;

  -- hsync
  process(clk) begin
    if rising_edge(clk) then
      if rst='1' then
         xctr <= "0000000000";
      elsif pixel=3 then
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
      elsif xctr=799 and pixel=0 then
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
  
  --video
  process(clk) begin
    if rising_edge(clk) then
      if pixel=3 then
        if xctr<640 and yctr<480 then
          video <= '1';
        else
          video <= '0';
        end if;
      end if;
    end if;
  end process

  vga_red(2 downto 0) <= (video & video & video);
  vga_green(2 downto 0) <= (video & video & video);
  vga_blue(2 downto 1) <= (video & video);

  -- W/R GPU Memory.
  -- process(clk) begin
  --  if rising_edge(clk) then
  --    if wea='0' then
  --      mem(conv_integer(addra)) <= dataina;
  --    end if;
  --    if web='0' then
  --      mem(conv_integer(addrb)) <= datainb;
  --    end if;
  --    datauta <= mem(conv_integer(addra));
  --    datautb <= mem(conv_integer(addrb));
  --  end if;
  --end process;
  
end Behavioral;
