library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- Buss Mux

entity mux is
        port(
            clk, rst                : in        std_logic;
            aluOut, controllerOut   : in        std_logic_vector(31 downto 0);
            gregOut, aregOut        : in        std_logic_vector(31 downto 0);
            gpuOut                  : in        std_logic_vector(31 downto 0);
            TB_o                    : in        std_logic_vector(2 downto 0);
            dbus                    : out       std_logic_vector(31 downto 0)
            );
end mux;

architecture arch of mux is
begin
    -- dbus depends on what TB from controller say it should be. TB_o is clocked from TB,
    -- so this doesn't have to be.
    with TB_o select
            dbus <= controllerOut   when "001",
                    aregOut         when "010",
                    controllerOut   when "011",
                    aluOut          when "100",
                    -- aluOut          when "101", -- HR
                    gregOut         when "110",
                    gpuOut          when "111",
                    (others => 'Z') when others;

end architecture;
        
