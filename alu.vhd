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
            clk, rst        : in        std_logic;
            dbus            : in        std_logic_vector(31 downto 0);
            aluOut          : out       std_logic_vector(31 downto 0);
            TB_o            : in        std_logic_vector(2 downto 0);
            ALU_o           : in        std_logic_vector(3 downto 0);
            Z, C, L         : out       std_logic
            );
end alu;

architecture arch of alu is
        -- Registers
        signal AR           : std_logic_vector(32 downto 0)     := '0' & X"0000_0000";

begin

        -- Alu Math
        process(clk) begin
            if rising_edge(clk) then
                if rst = '1' then
                    AR <= '0' & X"0000_0000";
                else
                    case ALU_o is
                        -- NOP (no flags)
                        when "0000" => null;-- Undefined
                        -- AR = dbus (no flags)
                        when "0001" => AR <= '0' & dbus;
                        -- AR = dbus' (no flags);
                        when "0010" => AR <= '0' & not dbus;
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
                        when "0110" => AR <= AR and ('0' & dbus);
                                    -- Set Z flag
                                    if (AR and ('0' & dbus))=0 then Z <= '1';
                                    else Z <= '0';
                                    end if;
                        -- AR = AR or dbus (Z)
                        when "0111" => AR <= AR or ('0' & dbus);
                                    -- Set Z flag
                                    if (AR or ('0' & dbus))=0 then Z <= '1';
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
                                    C <= AR(31);
                        -- Increment AR (Z, C)
                        when "1010" => AR <= AR + 1;
                                    -- Set Z flag
                                    Z <= '0';
                                    -- Set C flag
                                    if AR(31 downto 0)=X"FFFF_FFFF" then C <= '1';
                                    else C <= '0';
                                    end if;
                        -- Logic-shift-left 4 bits (Z)
                        when "1011" => AR(31 downto 0) <= AR(27 downto 0) & "0000";
                                    -- Set Z flag
                                    if AR(27 downto 0)=0 then Z <= '1';
                                    else Z <= '0';
                                    end if;
                        -- Logic-shift-left 8 bits (Z)
                        when "1100" => AR(31 downto 0) <= AR(23 downto 0) & "00000000";
                                    -- Set Z flag
                                    if AR(23 downto 0)=0 then Z <= '1';
                                    else Z <= '0';
                                    end if;
                        -- Logic-shift-right (Z, C)
                        when "1101" => AR(31 downto 0) <= '0' & AR(31 downto 1);
                                    -- Set Z flag
                                    if AR(31 downto 1)=0 then Z <= '1';
                                    else Z <= '0';
                                    end if;
                                    -- Set C flag
                                    C <= AR(0);
                        -- Decrement AR (Z)
                        when "1110" => AR <= AR - 1;
                                    -- Set Z flag
                                    if AR(31 downto 0)=X"0000_0001" then Z <= '1';
                                    else Z <= '0';
                                    end if;
                                    -- Set C flag
                                    if AR(31 downto 0)=X"0000_0000" then C <= '1';
                                    else C <= '0';
                                    end if;
                        -- Undefined
                        when others => null;-- Undefined
                    end case;
                end if;
            end if;
        end process;

        -- I/O
        with TB_o select
                aluOut <=   AR(31 downto 0) when "100",
                            (others => 'Z') when others;
                                        
end architecture;
