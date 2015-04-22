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
           sig : out std_logic_vector(7 downto 0));
end uart;

architecture Behavioral of uart is
    signal txd1,txd2 : std_logic; --insignalsvippor
    signal sp,lp : std_logic; --shiftpulse, loadpulse
    signal idle : std_logic; -- if running or not
    signal pulsenr : std_logic_vector(3 downto 0) := "0000";
begin

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

