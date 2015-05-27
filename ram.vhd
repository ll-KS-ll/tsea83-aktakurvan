library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ram is
port (
        clk       : in std_logic;
        xaddress  : in integer;
        yaddress  : in integer;
        rxaddress  : in integer;
        ryaddress  : in integer;
        we        : in std_logic;
        data_i    : in std_logic_vector(1 downto 0);
        data_o    : out std_logic_vector(1 downto 0)
     );
end ram;

architecture Behavioral of ram is

--Declaration of type and signal of a 256 element RAM
--with each element being 8 bit wide.
subtype tmp is std_logic_vector(1 downto 0);
type ram_t is array (0 to 8191) of tmp;

  signal ram0 : ram_t := (others => "00");
  signal ram1 : ram_t := (others => "00");
  signal ram2 : ram_t := (others => "00");
  signal ram3 : ram_t := (others => "00");
  signal ram4 : ram_t := (others => "00");
  signal ram5 : ram_t := (others => "00");
  signal ram6 : ram_t := (others => "00");
  signal ram7 : ram_t := (others => "00");
  signal ram8 : ram_t := (others => "00");
  signal ram9 : ram_t := (others => "00");

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


  signal memoryPos : integer := 0;
  signal rmemoryPos : integer := 0;

  signal wRam : integer := 0;
  signal rRam : integer := 0;
  signal wPos : integer := 0;
  signal rPos : integer := 0;

begin

  --rmemoryPos <= ryaddress*320 + rxaddress;
  
  memoryPos <=  yaddress*320 + xaddress;
  rmemoryPos <= ryaddress*320 + rxaddress;
    
  wRam  <=  0 when memoryPos<8192   else
            1 when memoryPos<8192*2 else
            2 when memoryPos<8192*3 else
            3 when memoryPos<8192*4 else
            4 when memoryPos<8192*5 else
            5 when memoryPos<8192*6 else
            6 when memoryPos<8192*7 else
            7 when memoryPos<8192*8 else
            8 when memoryPos<8192*9 else
            9;

  rRam  <=  0 when rmemoryPos<8192   else
            1 when rmemoryPos<8192*2 else
            2 when rmemoryPos<8192*3 else
            3 when rmemoryPos<8192*4 else
            4 when rmemoryPos<8192*5 else
            5 when rmemoryPos<8192*6 else
            6 when rmemoryPos<8192*7 else
            7 when rmemoryPos<8192*8 else
            8 when rmemoryPos<8192*9 else
            9;
      
   wPos  <=  memoryPos-8192*wRam;

--process for read and write operation.
PROCESS(clk)
BEGIN
    if(rising_edge(clk)) then
        if(we='1') then
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
              when others => ram9(wPos) <= data_i;
            end case;
        end if;
        rPos  <= rmemoryPos-8192*rRam;
    end if;
END PROCESS;

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
              ram9(rPos) when others;  

end Behavioral;
