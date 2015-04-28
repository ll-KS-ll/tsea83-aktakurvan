library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart is
    port ( clk,rst,txd : in std_logic;
           datareg : out std_logic_vector(7 downto 0));
end uart;

architecture Behavioral of uart is
    signal txd1,txd2 : std_logic; --insignalsvippor
    signal sp,lp : std_logic; --shiftpulse, loadpulse
    signal idle : std_logic; -- if running or not
    signal pulsenr : std_logic_vector(3 downto 0) := B"0000"; --current pulse number
    signal clknr : std_logic_vector(9 downto 0) := B"0000000000"; --current clk number
    signal shiftreg : std_logic_vector(9 downto 0) := B"0_0000_0000_0"; -- 10 bit skiftregister
    signal datareg : std_logic_vector(7 downto 0) := B"0000_0000"; -- 8 bit dataregister
begin

constant ENDCLK : integer := 867;
constant MIDCLK : integer := 434;
constant ENDPULSE : integer := 10;

-- Synced flipflops for the recieved signal from keyboard
process(clk) begin
    if rising_edge(clk) then
        if rst='1'; then
            txd1 <= '1';
            txd2 <= '1';
        else
            txd1 <= txd;
            txd2 <= txd1;
        end if;
    end if;
end process;

--uart controller
process(clk) begin
    if rising_edge(clk) then
        if idle='1' then --uart is running        
            if rst='1' then --reset uart
                sp, lp <= '0';
            elsif pulsenr/=ENDPULSE then --recieve the 8 data bits
                --lp <= '0';
                clknr <= clknr+1;
                if clknr=MIDCLK then --shift in data bit
                    sp <= '1';
                    pulsenr <= pulsenr+1;
                elsif clkr=ENDCLK then --reset clk number
                    q <= (others => '0');
                else
                    sp <= '0';
                end if;
            elsif pulsenr=ENDPULSE and clknr=ENDCLK then -- send out data
                lp <= '1';
                idle <= '0';
            else
                clknr <= clknr+1;
            end if;
        else --uart is idle
            if rx2='0' then --startbit is recieved
                idle <= '1'
                clknr <= clknr+1;
            else
                sp, lp, idle <= '0';
                clknr <= (others => '0');
                pulsenr <= (others => '0');
            end if;
        end if;
    end if;
end process;

--10 bit shiftregister
process(clk) begin
    if rising_edge(clk) then
        if rst='1' then
            shiftreg <= (others => '0');
        elsif sp=1 then
            shiftreg(9 downto 0) <= txd2 & shiftreg(9 downto 1); -- shift in data bit
        end if;
    end if;
end process;

-- dataregister
process (clk) begin
    if rising_edge(clk) then
        if rst='1' then
            datareg <= (others => '0');
        elsif lp='1' then
            datareg(7 downto 0) <= shiftreg(8 downto 1); -- set dataregister
        end if;
    end if;
end process;
