library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- ALU
entity alu is
        port(
            clk, rst        : in         std_logic;
            dbus            : inout      std_logic_vector(31 downto 0);
            contr_alu       : inout      std_logic_vector(5 downto 0); -- Needs to be six so we can tel AUu when to move to dbus
            Z, C, L         : inout      std_logic
            );
end alu;

architecture arch of alu is
        -- Registers
        signal AR           : std_logic_vector(32 downto 0)     := X"0000_0000";
        signal HR           : std_logic_vector(32 downto 0)     := X"0000_0000";

        -- Dbus control
        alias alu_dbus      : std_logic_vector(1 downto 0)      is contr_alu(5 downto 4);      
        -- Alu control
        alias c_alu         : std_logic_vector(3 downto 0)      is contr_alu(3 downto 0);
        
        -- Alu Math
        process(clk) begin
            if rising_edge(clk) then
                case c_alu is
                    -- NOP (no flags)
                    when "0000" => -- Undefined
                    -- AR = dbus (no flags)
                    when "0001" => AR <= C & dbus;
                    -- AR = dbus' (no flags);
                    when "0010" => AR <= C & not dbus;
                    -- AR = 0 (Z, C)
                    when "0011" => AR <= '0' & X"0000_0000"; -- 33 bits?
                                -- Set Z Flag
                                Z <= '1';
                                -- Set C flag
                                C <= '0';
                    -- AR = AR + dbus (Z, C)
                    when "0100" => AR <= AR + ('0' & dbus);
                                -- Set Z flag
                                if (AR + ('0' & dbus))=0 then Z <= '1';
                                else Z <= '0';
                                end if;
                                -- Set C flag
                                if (AR + ('0' & dbus))>('0' & X"1111_1111") then C <= '1';
                                else C <= '0';
                                end if;
                    -- AR = AR - dbus (Z, C)
                    when "0101" => AR <= AR - ('0' & dbus);
                                -- Set Z flag
                                if (AR - dbus)=0 then Z <= '1';
                                else Z <= '0';
                                end if;
                                -- Set C flag
                                if AR < ('0' & dbus) then C <= '1';
                                else C <= '0';
                                end if;
                    -- AR = AR & dbus (Z)
                    when "0110" => AR <= AR and dbus;
                                -- Set Z flag
                                if (AR and dbus)=0 then Z='1';
                                else Z='0';
                                end if;
                    -- AR = AR or dbus (Z)
                    when "0111" => AR <= AR or ('0' & dbus);
                                -- Set Z flag
                                if (AR or dbus)=0 then Z <= '1';
                                else Z <= '0';
                                end if;
                    -- AR = AR + dbus (no flags);
                    when "1000" => AR <= AR + dbus; -- overflow?
                    -- Logic-shift-left (Z, C)
                    when "1001" => AR(31 downto 0) <= AR(30 downto 0) & '0';
                                -- Set Z flag
                                if AR(30 downto 0)=0 then Z <= '1';
                                else Z <= '0';
                                end if;
                                -- Set C flag
                                C <= AR(31)
                    -- Increment AR (Z, C)
                    when "1010" => AR <= AR+1;
                                -- Set Z flag
                                Z <= '0';
                                -- Set C flag
                                if AR(31 downto 0)=X"FFFF_FFFF" then C <= '1';
                                else C <= '0';
                                end if;
                    -- Undefined
                    when "1011" => -- Undefined
                    -- Undefined
                    when "1100" => -- Undefined
                    -- Logic-shift-right (Z, C)
                    when "1101" => AR(31 downto 0) <= '0' & AR(31 downto 1);
                                -- Set Z flag
                                if AR(31 downto 1)=0 then Z <= '1';
                                else Z <= '0';
                                end if;
                                -- Set C flag
                                C <= AR(0);
                    -- Undefined
                    when "1110" => -- Undefined
                    -- Undefined
                    when others => -- Undefined
                end case;
            end if;
        end process;

        -- dbus controller
        process(clk) begin
            if rising_edge(clk) then
                case alu_dbus
                    when "00" =>    contr_alu(5 downto 4)   <= "00"; -- NOP
                    when "01" =>    dbus                    <= AR;
                                    contr_alu(5 downto 4)   <= "00"; -- Reset
                    when "10" =>    HR      <= dbus;
                                    contr_alu(5 downto 4)   <= "00"; -- Reset
                    when others =>  dbus    <= HR;
                                    contr_alu(5 downto 4)   <= "00"; -- Reset
                end case;
            end if;
        end process;
                                
end architecture alu;
