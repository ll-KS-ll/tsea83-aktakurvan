library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

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
	signal PC : std_logic_vector(20 downto 0) := x"0000"; -- PC is the same size as ASR.
	signal ASR : std_logic_vector(20 downto 0); -- 21 bits, expand to 32 for simplicity?
	signal AR, HR : std_logic_vector(31 downto 0) := x"00000000"; 
	
	signal GR0, GR1, GR2, GR3 : std_logic_vector(31 downto 0) := x"00000000";
	signal GR4, GR5, GR6, GR7 : std_logic_vector(31 downto 0) := x"00000000";
	signal GR8, GR9, GR10, GR11 : std_logic_vector(31 downto 0) := x"00000000";
	signal GR12, GR13, GR14, GR15 : std_logic_vector(31 downto 0) := x"00000000";
	
	-- Flags
	signal Z, N, C, O, L : std_logic := '0';

	-- Instructions
	alias OP : std_logic_vector(4 downto 0) is IR(31 downto 27);
	alias GRx : std_logic_vector(1 downto 0) is IR(26 downto 25);
	alias GRx2 : std_logic_vector(1 downto 0) is IR(24 downto 23);
	alias M : std_logic_vector(1 downto 0) is IR(22 downto 21);
	alias ADR : std_logic_vector(20 downto 0) is IR (20 downto 0);

	-- uMem
	type uMem_t is array(63 downto 0) of std_logic_vector(27 downto 0); -- Expand to 32 for simplicity.
	constant uMem : uMem_t := ( -- Memory for microprograming code.
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
		x"0000000", x"0000000", x"0000000", x"0000000",
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
				-- Completed
				when "0000" =>	-- NOP, do nothinhg.
				
				-- Completed
				when "0001" => AR <= bus_in;
				
				-- Completed
				when "0010" => AR <= not bus_in;
				
				-- Completed
				when "0011" => AR <= x"00000000";
											 Z <= '1';
											 N <= '0';
				
				-- TODO: Add code for flags.
				when "0100" => AR <= AR + bus_in;
											 -- Z <= '1' when AR=0 else '0';
											 -- N <= '1' when AR(31)='1' else '0';
											 if (AR + bus_in)=0 then Z <= '1';
																				else Z <= '0';
											 end if;
											 if AR(31)='1' then N <= '1'; -- broken
											 							 else N <= '0';
											 end if;
				
				-- TODO: Add code for flags.
				when "0101" => AR <= AR - bus_in;
											 --Z <= '1' when AR=0 else '0';
											 --N <= '1' when AR(31)='1' else '0';
											 if (AR - bus_in)=0 then Z <= '1';
											 				 else Z <= '0';
											 end if;
											 if AR(31)='1' then N <= '1'; -- broken
											 							 else N <= '0';
											 end if;

				-- Completed
				when "0110" => AR <= AR and bus_in;
											 --Z <= '1' when AR=0 else '0';
											 --N <= '1' when AR(31)='1' else '0';
											 if (AR and bus_in)=0 then Z <= '1';
											 				 else Z <= '0';
											 end if;
											 if (AR(31) and bus_in(31))='1' then N <= '1';
											 							 								else N <= '0';
											 end if;

				-- Completed
				when "0111" => AR <= AR or bus_in;
											 --Z <= '1' when AR=0 else '0';
											 --N <= '1' when AR(31)='1' else '0';
											 if (AR or bus_in)=0 then Z <= '1';
											 									 else Z <= '0';
											 end if;
											 if (AR(31) or bus_in(31))='1' then N <= '1';
											 														 else N <= '0';
											 end if;

				-- Completed
				when "0111" => AR <= AR + bus_in; -- No flags.
				
				-- Completed
				when "1001" => AR(31 downto 0) <= AR(30 downto 0) & '0'; -- Shift Left Logic.
											 --Z <= '1' when AR(30 downto 0)=0 else '0';
											 --N <= '1' when AR(30)='1' else '0';
											 C <= AR(31);
											 if AR(30 downto 0)=0 then Z <= '1';
											 				 							else Z <= '0';
											 end if;
											 if AR(30)='1' then N <= '1';
											 							 else N <= '0';
											 end if;

				-- Unusefull
				when "1010" => -- ARHR << 1  Not usefull for us. 
				
				-- Unusefull
				when "1011" => -- AR >> 1 (arithmetic). Not usefull for us.
				
				-- Unusefull
				when "1100" => -- ARHR >> 1 (arithmetic).   Not usefull for us.
				
				-- Completed
				when "1101" => AR(31 downto 0) <= '0' & AR(31 downto 1); -- Shift Right Logic.
											 --Z <= '1' when AR(31 downto 1)=0 else '0'; 
											 if AR(31 downto 1)=0 then Z <= '1';
											 											else Z <= '0';
											 end if;
											 N <= '0';
											 C <= AR(0);
				
				-- Unusefull
				when "1110" => -- Rotate AR left. - Ehm rotate?
				
				-- Unusefull
				when "1111" => -- Rotate ARHR left.  Not usefull for us.
 			
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

				when "0100" => --uPC <= uADR when Z='0' else (uPc + 1);
											 if Z='0' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				when "0101" => uPC <= uADR;
				
				when "0110" => SuPC <= uPC + 1;
											 uPC <= uADR;
				
				when "0111" => uPc <= SuPC;

				when "1000" => --uPC <= uADR when Z='1' else (uPc + 1);
											 if Z='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;
				
				when "1001" => --uPC <= uADR when N='1' else (uPc + 1);
											 if N='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;
				
				when "1010" => --uPC <= uADR when C='1' else (uPc + 1);
											 if C='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;
				
				when "1011" => --uPC <= uADR when O='1' else (uPc + 1);
											 if O='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;
				
				when "1100" => --uPC <= uADR when L='1' else (uPc + 1);
											 if L='1' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				when "1010" => --uPC <= uADR when C='0' else (uPc + 1);
											 if C='0' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				when "1011" => --uPC <= uADR when O='0' else (uPc + 1);
											 if O='0' then uPC <= uADR;
											 					else uPC <= uPC + 1;
											 end if;

				-- TODO: Add HALT execute code.
				when "1111" => uPC <= x"00";

 			end case;
		end if;
	end process;

	-- TB 
	process(clk) begin
		if rising_edge(clk) then
			case TB is 
				when "000" => -- Nope  
				when "001" => bus_out <= IR;
				when "010" => -- bus_out <= PM:
				when "011" => bus_out <= PC;
				when "100" => bus_out <= AR;
				when "101" => bus_out <= HR;
				when "110" => bus_out <= GRx;
				when "111" => bus_out <= "0000" & uIR;
			end case ;
		end if;
	end process;
	
	-- FB
	process(clk) begin
		if rising_edge(clk) then
			case TB is 
				when "000" => -- Nope  
				when "001" => IR <= bus_in;
				when "010" => -- PM <= bus_in;
				when "011" => PC <= bus_in;
				when "100" => -- undefined
				when "101" => HR <= bus_in;
				when "110" => GRx <= bus_in;
				when "111" => ASR <= bus_in;
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

end architecture ; -- arch