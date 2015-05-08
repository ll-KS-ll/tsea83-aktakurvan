library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- Controller
entity controller is
        port( 
            clk, rst        : in        std_logic;
            dbus            : inout     std_logic_vector(31 downto 0);
            -- Finish these, vectors are not final size
            contr_areg      : out       std_logic_vector(1 downto 0);
            contr_alu       : out       std_logic_vector(5 downto 0);
            contr_memory    : out       std_logic_vector(1 downto 0);
            contr_greg      : out       std_logic_vector(5 downto 0);
            Z, C, L         : inout     std_logic;
            );
end controller;

architecture arch of controller is
        --Registers
        signal IR           : std_logic_vector(31 downto 0)     := X"0000_0000";
        signal PC           : std_logic_vector(31 downto 0)     := X"0000_0000";

        --Instructions
        alias OP            : std_logic_vector(4 downto 0)      is IR(31 downto 27);
        alias GRx           : std_logic_vector(3 downto 0)      is IR(26 downto 23);
        alias M             : std_logic_vector(1 downto 0)      is IR(22 downto 21);
        alias ADR           : std_logic_vector(20 downto 0)     is IR(20 downto 0); 

        --Micro-programcounters and K-nets
        signal uPC, SuPC    : std_logic_vector(7 downto 0)      := X"00";
        signal K1, K2       : std_logic_vector(7 downto 0)      := X"00";

        --uIR
        signal uIR          : std_logic_vector(31 downto 0)     := X"0000_0000";
        --alias 
        alias ALU           : std_logic_vector(3 downto 0)      is uIR(25 downto 22);
        alias TB            : std_logic_vector(2 downto 0)      is uIR(21 downto 19); 
        alias FB            : std_logic_vector(2 downto 0)      is uIR(18 downto 16); -- Needs to be used in a process
		alias S             : std_logic                         is uIR(15);
        alias P             : std_logic                         is uIR(14);           -- When '1' PC++
		alias LC            : std_logic_vector(1 downto 0)      is uIR(13 downto 12);
		alias SEQ           : std_logic_vector(3 downto 0)      is uIR(11 downto 8);
		alias uADR          : std_logic_vector(7 downto 0)      is uIR(7 downto 0); 

        -- uMem
	    type uMem_t is array(63 downto 0) of std_logic_vector(27 downto 0); -- Expand to 32 for simplicity.
	    constant uMem : uMem_t := ( -- Memory for microprograming code.
		    x"00F8000", x"008A000", x"0004100", x"0078080",
		    x"00FA080", x"0078000", x"00B8080", x"0240000",
		    x"1184000", x"0138080", x"0380000", x"0880000",
		    x"0130180", x"0380000", x"0A80000", x"0130180",
		    x"0380000", x"0C80000", x"0130800", x"02C0000",
		    x"1040000", x"0118180", x"02C0420", x"1040000",
		    x"0118180", x"0000180", x"0000780", x"0130180",
		    x"0380000", x"0A80180", x"0380000", x"1400000",
		    x"0130180", x"0380000", x"0B40000", x"0130180",
		    x"00B0180", x"0190180", x"0000000", x"0000000",
		    x"0000000", x"0000000", x"0000000", x"0000000",
		    x"0000000", x"0000000", x"0000000", x"0000000",
		    x"0000000", x"0000000", x"0000000", x"0000000",
		    x"0000000", x"0000000", x"0000000", x"0000000",
		    x"0000000", x"0000000", x"0000000", x"0000000",
		    x"0000000", x"0000000", x"0000000", x"0000000"
		    );
begin
        -- K1 - Go to instruction 
        with OP select
            K1 <=   X"0A" when "00000", -- ADD
                    X"0D" when "00001", -- SUB
                    X"10" when "00010", -- AND
	    	        X"13" when "00011", -- BRA
			        X"16" when "00100", -- BNE
			        X"1A" when "00101", -- HALT				       
                    X"1E" when "00110", -- INC
			        X"21" when "00111", -- DEC
			        X"2A" when "01000", -- LOAD
    				X"2B" when "01001", -- STORE
	    			X"00" when "01010",
		    		X"00" when "01011",
			    	X"00" when others;

        -- K2 - Choose adressing mode
        with M select
            K2 <=   X"03" when "00",    -- EA Direct
                    X"04" when "01",    -- EA Imidiate
                    X"05" when "10",    -- EA Indirect
                    X"08" when others;  -- EA Index

        -- uPC / SEQ
        process(clk) begin
            if rising_edge(clk) then
                case SEQ is
                    when "0000" => uPC <= uPC+1;    -- Increment uPC by 1
                    when "0001" => uPC <= K1;       --
                    when "0010" => uPC <= K2;       --
                    when "0011" => uPC <= X"00";    --
                    when "0100" => 
                                if Z='0' then uPC <= uADR;
                                else uPC <= uPC+1;
                                end if;
                    when "0101" => uPC <= uADR;
                    when "0110" => 
                                SuPC <= uPC+1;
                                uPC <= uADR;
                    when "0111" => uPC <= SuPC;
                    when "1000" =>
                                if Z='1' then uPC <= uADR;
                                else uPC <= uPC+1;
                                end if;
                    when "1001" => -- Undefined
                    when "1010" => 
                                if C='1' then uPC <= uADR;
                                else uPC <= uPC+1;
                                end if;
                    when "1011" => -- Undefined
                    when "1100" =>
                                if L='1' then uPC <= uADR;
                                else uPC <= uPC+1;
                                end if;
                    when "1101" =>
                                if C='0' then uPC <= uADR;
                                else uPC <= uPC+1;
                                end if;
                    when "1110" => -- Undefined
                    when "1111" => -- Undefined
                end case;
            end if;
        end process;

        -- PC
        process(clk) begin
            if rising_edge(clk) then
                if P='1' then
                    PC <= PC+1;
                end if;
            end if;
        end process;

        -- Control signals
        process(clk) begin
            if rising_edge(clk) then
                contr_alu(3 downto 0)   <= ALU(3 downto 0);
                contr_greg(3 downto 0)  <= GRx(3 downto 0);
            end if;
        end process;

        -- dbus control
        process(clk) begin
            if rising_edge(clk) then
                case TB is -- To dbus controller
                    when "000" => ;-- NOP
                    when "001" => dbus <= IR;
                    when "010" => ;-- Tell memory to move PM to dbus
                    when "011" => dbus <= PC;
                    when "100" => contr_alu(5 downto 4)     <= "01"; -- Tells ALU to move from AR to dbus! 
                    when "101" => ;-- dbus <= HR (We have HR but not enough contr signals.)
                    when "110" => contr_greg(5 downto 4)    <= "01";-- Tells General Registers to move GRx to dbus
                    when others => dbus <= X"0" & uIR;
                end case;
                case FB is -- From dbus controller
                    when "000" => ;-- NOP
                    when "001" => IR <= dbus;
                    when "010" => ;-- From dbus to memory
                    when "011" => PC <= dbus;
                    when "100" => contr_alu(5 downto 4)     <= "10"; -- Tells ALU to move from dbus to AR!
                    when "101" => ;-- HR <= dbus (we have HR but not enough contr signals
                    when "110" => contr_greg(5 downto 4)    <= "10"; -- Tells General Registers to move from dbus to GRx
                    when others => ;--Tell areg to move from dbus to ASR
                end case
            end if;
        end Process
                                    
end architecture;
