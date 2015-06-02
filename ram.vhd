library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Library arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ====== RAM module ======
--
-- The RAM module is the memory of the GPU.
--
-- Both read and write can be done from the RAM. 
-- Write operations is done synchronously while read access is done asynchronously
-- so that block RAMs is used. It's possible to write and read simultaneously.
-- Therefore read and write accesss uses different address signals.  
--
-- Reading takes one clock cycle before it is read. 
--
-- The memory can store 320x240 pixels. One pixel is 4 bits large and is used to
-- selcet the color to output to the screen.
--
-- Internally the memory is devided into block RAMs at a size of 4x4096. This is
-- because the Nexys 3 only has block RAMs up to this size. There is 20 internal
-- block RAMs to create one big memory in a size of 4x81920. Not all space is used, 
-- only 320x240 pixels are displayed. The actually used size is 4x76800.
--
-- The internall memory is linear but x,y coordinates is used to address pixels in
-- the memory.
--
-- To write to the memory specify the xadress, yadress and set write enabled.
-- To read from memory specify the rxadress, ryadress.
-- 

entity ram is
port (
        clk       : in std_logic;   -- System clock 
        xaddress  : in integer;     -- Write x address
        yaddress  : in integer;     -- Write y address
        rxaddress : in integer;     -- Read x address
        ryaddress : in integer;     -- Read y address 
        we        : in std_logic;   -- Write Enable
        data_i    : in std_logic_vector(3 downto 0);  -- Data in from the GPU
        data_o    : out std_logic_vector(3 downto 0)  -- Data out to the GPU
     );
end ram;

architecture Behavioral of ram is
  
  -- Constant of the height for one ram block.
  constant ram_heigth : integer := 4096;

  -- Ram layout 
  subtype tmp is std_logic_vector(3 downto 0);
  type ram_t is array (0 to 4095) of tmp;

  -- 20 diffrent ram blocks to create one big storage.
  signal ram0 : ram_t := (others => "0000");
  signal ram1 : ram_t := (others => "0000");
  signal ram2 : ram_t := (others => "0000");
  signal ram3 : ram_t := (others => "0000");
  signal ram4 : ram_t := (others => "0000");
  signal ram5 : ram_t := (others => "0000");
  signal ram6 : ram_t := (others => "0000");
  signal ram7 : ram_t := (others => "0000");
  signal ram8 : ram_t := (others => "0000");
  signal ram9 : ram_t := (others => "0000");
  signal ram10 : ram_t := (others => "0000");
  signal ram11 : ram_t := (others => "0000");
  signal ram12 : ram_t := (others => "0000");
  signal ram13 : ram_t := (others => "0000");
  signal ram14 : ram_t := (others => "0000");
  signal ram15 : ram_t := (others => "0000");
  signal ram16 : ram_t := (others => "0000");
  signal ram17 : ram_t := (others => "0000");
  signal ram18 : ram_t := (others => "0000");
  signal ram19 : ram_t := (others => "0000");

  -- Use block ram in the FPGA.
  attribute ram_style: string;
  attribute ram_style of ram0 : signal is "block";
  attribute ram_style of ram1 : signal is "block";
  attribute ram_style of ram2 : signal is "block";
  attribute ram_style of ram3 : signal is "block";
  attribute ram_style of ram4 : signal is "block";
  attribute ram_style of ram5 : signal is "block";
  attribute ram_style of ram6 : signal is "block";
  attribute ram_style of ram7 : signal is "block";
  attribute ram_style of ram8 : signal is "block";
  attribute ram_style of ram9 : signal is "block";
  attribute ram_style of ram10 : signal is "block";
  attribute ram_style of ram11 : signal is "block";
  attribute ram_style of ram12 : signal is "block";
  attribute ram_style of ram13 : signal is "block";
  attribute ram_style of ram14 : signal is "block";
  attribute ram_style of ram15 : signal is "block";
  attribute ram_style of ram16 : signal is "block";
  attribute ram_style of ram17 : signal is "block";
  attribute ram_style of ram18 : signal is "block";
  attribute ram_style of ram19 : signal is "block";

  -- Linear memory positions to read and write to/from.
  signal memoryPos : integer := 0;  -- Write
  signal rmemoryPos : integer := 0; -- Read

  -- Control signals for the 20 block rams.
  signal wRam : integer := 0; -- Selects ram to use for writing
  signal rRam : integer := 0; -- Selctts ram to use for reading
  signal wPos : integer := 0; -- Position in a block ram, writing
  signal rPos : integer := 0; -- Position in a block ram, reading

  signal test : integer := 0;

begin

  -- Convert x,y coordinats to a linear position in the memory. 
  memoryPos <=  yaddress*320 + xaddress;
  rmemoryPos <= ryaddress*320 + rxaddress;
  
  -- Select block ram to use for writing
  wRam  <=  0 when memoryPos<ram_heigth   else
            1 when memoryPos<ram_heigth*2 else
            2 when memoryPos<ram_heigth*3 else
            3 when memoryPos<ram_heigth*4 else
            4 when memoryPos<ram_heigth*5 else
            5 when memoryPos<ram_heigth*6 else
            6 when memoryPos<ram_heigth*7 else
            7 when memoryPos<ram_heigth*8 else
            8 when memoryPos<ram_heigth*9 else
            9 when memoryPos<ram_heigth*10 else
            10 when memoryPos<ram_heigth*11 else
            11 when memoryPos<ram_heigth*12 else
            12 when memoryPos<ram_heigth*13 else
            13 when memoryPos<ram_heigth*14 else
            14 when memoryPos<ram_heigth*15 else
            15 when memoryPos<ram_heigth*16 else
            16 when memoryPos<ram_heigth*17 else
            17 when memoryPos<ram_heigth*18 else
            18 when memoryPos<ram_heigth*19 else
            19;

  -- Select block ram to use for reading
  test  <=  0 when rmemoryPos<ram_heigth   else
            1 when rmemoryPos<ram_heigth*2 else
            2 when rmemoryPos<ram_heigth*3 else
            3 when rmemoryPos<ram_heigth*4 else
            4 when rmemoryPos<ram_heigth*5 else
            5 when rmemoryPos<ram_heigth*6 else
            6 when rmemoryPos<ram_heigth*7 else
            7 when rmemoryPos<ram_heigth*8 else
            8 when rmemoryPos<ram_heigth*9 else
            9 when rmemoryPos<ram_heigth*10 else
            10 when rmemoryPos<ram_heigth*11 else
            11 when rmemoryPos<ram_heigth*12 else
            12 when rmemoryPos<ram_heigth*13 else
            13 when rmemoryPos<ram_heigth*14 else
            14 when rmemoryPos<ram_heigth*15 else
            15 when rmemoryPos<ram_heigth*16 else
            16 when rmemoryPos<ram_heigth*17 else
            17 when rmemoryPos<ram_heigth*18 else
            18 when rmemoryPos<ram_heigth*19 else
            19;
  
  -- Convert memory position into positon in the block ram
  wPos  <=  memoryPos-ram_heigth*wRam;

-- Process write operation.
PROCESS(clk)
BEGIN
    if(rising_edge(clk)) then
        -- Write if write enbled.
        if(we='1') then
            -- Write to the memory
            case wRam is             
              when 0 => ram0(wPos) <= data_i;
              when 1 => ram1(wPos) <= data_i;
              when 2 => ram2(wPos) <= data_i;
              when 3 => ram3(wPos) <= data_i;
              when 4 => ram4(wPos) <= data_i;
              when 5 => ram5(wPos) <= data_i;
              when 6 => ram6(wPos) <= data_i;
              when 7 => ram7(wPos) <= data_i;
              when 8 => ram8(wPos) <= data_i;
              when 9 => ram9(wPos) <= data_i;
              when 10 => ram10(wPos) <= data_i;
              when 11 => ram11(wPos) <= data_i;
              when 12 => ram12(wPos) <= data_i;
              when 13 => ram13(wPos) <= data_i;
              when 14 => ram14(wPos) <= data_i;
              when 15 => ram15(wPos) <= data_i;
              when 16 => ram16(wPos) <= data_i;
              when 17 => ram17(wPos) <= data_i;
              when 18 => ram18(wPos) <= data_i;
              when others => ram19(wPos) <= data_i;
            end case;
        end if;

        -- Read
        rRam <= test;
        rPos  <= rmemoryPos-ram_heigth*rRam;
    end if;
END PROCESS;

  -- Read from the memory
  with rRam select             
    data_o <= ram0(rPos) when 0,
              ram1(rPos) when 1,
              ram2(rPos) when 2,  
              ram3(rPos) when 3,  
              ram4(rPos) when 4,  
              ram5(rPos) when 5,  
              ram6(rPos) when 6,  
              ram7(rPos) when 7,  
              ram8(rPos) when 8,
              ram9(rPos) when 9, 
              ram10(rPos) when 10,
              ram11(rPos) when 11,
              ram12(rPos) when 12,  
              ram13(rPos) when 13,  
              ram14(rPos) when 14,  
              ram15(rPos) when 15,  
              ram16(rPos) when 16,  
              ram17(rPos) when 17,  
              ram18(rPos) when 18,
              ram19(rPos) when others;  

end Behavioral;
