library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- CPU without support for 2-compliment.
entity cpu is 
	Port( clk, rst : in std_logic;
				-- TODO: Implement an actually working bus.
				bus_in : in std_logic_vector (31 downto 0);
				bus_out : out std_logic_vector (31 downto 0)
		);
end cpu;

architecture arch of cpu is 
	-- CPU registers
	signal IR : std_logic_vector(31 downto 0) := x"00000000";
	signal PC : std_logic_vector(20 downto 0) := '0' & x"00000"; -- PC is the same size as ASR.
	signal ASR : std_logic_vector(20 downto 0) := '0' & x"00000"; -- 21 bits, expand to 32 for simplicity?
	signal AR : std_logic_vector(32 downto 0) := '0' & x"00000000"; -- bit 32 is carry-flag

  signal buss : std_logic_vector(31 downto 0) := x"00000000";  -- buss used inside computer

	signal GR0, GR1, GR2, GR3 : std_logic_vector(31 downto 0) := x"00000000";
	signal GR4, GR5, GR6, GR7 : std_logic_vector(31 downto 0) := x"00000000";
	signal GR8, GR9, GR10, GR11 : std_logic_vector(31 downto 0) := x"00000000";
	signal GR12, GR13, GR14, GR15 : std_logic_vector(31 downto 0) := x"00000000";
	
	-- Flags: Zero, Carry, Loop
	signal Z, C, L : std_logic := '0';

	-- Instructions
	alias OP : std_logic_vector(4 downto 0) is IR(31 downto 27);
	alias GRx : std_logic_vector(1 downto 0) is IR(26 downto 23);
	alias M : std_logic_vector(1 downto 0) is IR(22 downto 21);
	alias ADR : std_logic_vector(20 downto 0) is IR (20 downto 0);

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

		signal uPC, K1, K2 : std_logic_vector(7 downto 0) := x"00";
		signal SuPC : std_logic_vector(7 downto 0) := x"00";
		-- signal LC : std_logic_vector(7 downto 0) := x"00";
		signal uIR : std_logic_vector(27 downto 0) := x"0000000";

		alias ALU : std_logic_vector(3 downto 0) is uIR(25 downto 22);
		alias TB : std_logic_vector(2 downto 0) is uIR(21 downto 19);
		alias FB : std_logic_vector(2 downto 0) is uIR(18 downto 16);
		alias S : std_logic is uIR(15);
		alias P : std_logic is uIR(14);
		alias LC : std_logic_vector(1 downto 0) is uIR(13 downto 12);
		alias SEQ : std_logic_vector(3 downto 0) is uIR(11 downto 8);
		alias uADR : std_logic_vector(7 downto 0) is uIR(7 downto 0); 
begin 
	-- K1 - Go to asembler instruction.
	with OP select
	K1 <=	x"00" when "00000", -- Change x"0000" to instruction in uMem.
				x"00" when "00001",
				x"00" when "00010",
				x"00" when "00011",
				x"00" when "00100",
				x"00" when "00101",
				x"00" when "00110",
				x"00" when "00111",
				x"00" when "01000",
				x"00" when "01001",
				x"00" when "01010",
				x"00" when "01011",
				x"00"	when others;

	-- K2 - Choose adressing method.
	with M select
	K2 <=	x"00" when "00",  -- Change x"0000" to adressing method in uMem.
				x"00" when "01",
				x"00" when "10",
				x"00" when "11";
	
	-- ALU
	process(clk) begin  
		if rising_edge(clk) then
			case ALU is
        -- NOP (No flags)
				when "0000" =>	-- NOP, do nothinhg.
				
        -- AR = buss (No flags)
				when "0001" => AR <= C & buss;
				
        -- AR = buss' (No flags)
				when "0010" => AR <= C & not buss;
				
        -- AR = 0 (Z, C flags)
				when "0011" => AR <= '0' & x"00000000";
											 Z <= '1';
											 C <= '0';
				
        -- AR = AR + buss (Z, C flags)
				when "0100" => AR <= AR + ('0' & buss);
											 if (AR + ('0' & buss))=0 then Z <= '1';
																								else Z <= '0';
											 end if;
											 if (AR + ('0' & buss))>('0' & x"11111111") then C <= '1';
											 																							else C <= '0';
											 end if;
				
        -- AR = AR - buss (Z, C flags)
				when "0101" => AR <= AR - ('0' & buss);
											 if (AR - buss)=0 then Z <= '1';
											 				 else Z <= '0';
											 end if;
											 if AR < ('0' & buss) then C <= '1';
											 											else C <= '0';
											 end if;

        -- AR = AR & buss (Z-flag)
				when "0110" => AR(31 downto 0) <= AR(31 downto 0) and buss(31 downto 0);
											 if (AR(31 downto 0) and buss(31 downto 0))=0 then Z <= '1';
											 				 																			else Z <= '0';
											 end if;

        -- AR = AR or buss (Z-flag)
				when "0111" => AR <= AR or ('0' & bus_in);
											 if (AR or buss)=0 then Z <= '1';
											 									 else Z <= '0';
											 end if;

        -- AR = AR + buss (no flags)
				when "1000" => AR(31 downto 0) <= AR(31 downto 0) + bus_in(31 downto 0);
				
        -- Logic shift left (Z, C flags)
				when "1001" => AR(31 downto 0) <= AR(30 downto 0) & '0';
											 if AR(30 downto 0)=0 then Z <= '1';
											 				 							else Z <= '0';
											 end if;
											 C <= AR(31);

				-- Increment AR (Z, C)
				when "1010" => AR <= AR + 1;
											 Z <= '1';
											 if AR(31 downto 0)=x"FFFFFFFF" then C <= '1';
											 									 							else C <= '0';
											 end if;

				-- Undefined
				when "1011" => -- Undefined
				
				-- Undefined
				when "1100" => -- Undefined
				
				-- Logic shift right (Z, C flags)
				when "1101" => AR(31 downto 0) <= '0' & AR(31 downto 1);
											 if AR(31 downto 1)=0 then Z <= '1';
											 											else Z <= '0';
											 end if;
											 C <= AR(0);

				-- Undefined
				when "1110" => -- Undefined
				
				-- Undefined
				when "1111" => -- Undefined
 			
 			end case;
		end if;
	end process; 

	-- uPC / SEQ
	process(clk) begin
		if rising_edge(clk) then
			case SEQ is
				when "0000" => uPC <= uPC + 1;
				
				when "0001" => uPC <= K1;
				
				when "0010" => uPC <= K2;
				
				when "0011" => uPC <= x"00";

				when "0100" => if Z='0' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				when "0101" => uPC <= uADR;
				
				when "0110" => SuPC <= uPC + 1;
											 uPC <= uADR;
				
				when "0111" => uPc <= SuPC;

				when "1000" => if Z='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;
				
				when "1001" => -- Undefined
				
				when "1010" => if C='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;
				
				when "1011" => -- Undefined
				
				when "1100" => if L='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				when "1101" => if C='0' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				when "1110" => -- Undefined

				when "1011" => -- Undefined

				when "1111" => -- Undefined

 			end case;
		end if;
	end process;

	-- TB 
	process(clk) begin
		if rising_edge(clk) then
			case TB is 
				when "000" => -- Nope  
				when "001" => buss <= IR;
				when "010" => buss <= bus_in;
				when "011" => buss <= PC;
				when "100" => buss <= AR(31 downto 0);
				when "101" => -- buss <= HR;
        when "110" => -- handled in another process
				when others => buss <= "0000" & uIR; -- 111
			end case ;
		end if;
	end process;
	
	-- FB
	process(clk) begin
		if rising_edge(clk) then
			case FB is 
				when "000" => -- Nope  
				when "001" => IR <= buss;
				when "010" => bus_out <= buss;
				when "011" => PC <= buss;
				when "100" => -- undefined
				when "101" => -- HR <= buss;
        when "110" => -- handled in another process 
				when others => ASR <= buss; -- 111
			end case ;
		end if;
	end process;

	-- PC
	process(clk) begin
		if rising_edge(clk) then
			if P='1' then
				PC <= PC + 1;
			end if;
		end if;
	end process;

	-- Mux for all GR
    -- Dependent: GRx    
    -- GRx = 0000 gives GR0
    process(clk) begin
        if rising_edge(clk) then
            if TB="110" then
                case GRx is
                    when "0000" => buss <= GR0;
                    when "0001" => buss <= GR1;
                    when "0010" => buss <= GR2;
                    when "0011" => buss <= GR3;
                    when "0100" => buss <= GR4;
                    when "0101" => buss <= GR5;
                    when "0110" => buss <= GR6;
                    when "0111" => buss <= GR7;
                    when "1000" => buss <= GR8;
                    when "1001" => buss <= GR9;
                    when "1010" => buss <= GR10;
                    when "1011" => buss <= GR11;
                    when "1100" => buss <= GR12;
                    when "1101" => buss <= GR13;
                    when "1110" => buss <= GR14;
                    when others => buss <= GR15;
                end case;
            elsif FB="110" then
                case GRx is
                    when "0000" => GR0 <= buss;
                    when "0001" => GR1 <= buss;
                    when "0010" => GR2 <= buss;
                    when "0011" => GR3 <= buss;
                    when "0100" => GR4 <= buss;
                    when "0101" => GR5 <= buss;
                    when "0110" => GR6 <= buss;
                    when "0111" => GR7 <= buss;
                    when "1000" => GR8 <= buss; 
                    when "1001" => GR9 <= buss;
                    when "1010" => GR10 <= buss;
                    when "1011" => GR11 <= buss;
                    when "1100" => GR12 <= buss;
                    when "1101" => GR13 <= buss;
                    when "1110" => GR14 <= buss;
                    when others => GR15 <= buss;
                end case;
            end if;
        end if;       
    end process;

end architecture ; -- arch
