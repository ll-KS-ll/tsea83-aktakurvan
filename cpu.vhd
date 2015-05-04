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
	Port( clk, rst : std_logic;
				buss : std_logic_vector (31 downto 0)

		);
end cpu;

architecture arch of cpu is 
	-- CPU registers
	signal IR : std_logic_vector(31 downto 0);
	signal PC : std_logic_vector(20 downto 0) := x"0000"; -- PC is the same size as ASR.
	signal ASR : std_logic_vector(20 downto 0); -- 21 bits, expand to 32 for simplicity?
	signal AR, HR : std_logic_vector(31 downto 0);
	
	signal GR0, GR1, GR2, GR3 : std_logic_vector(31 downto 0);
	signal GR4, GR5, GR6, GR7 : std_logic_vector(31 downto 0);
	signal GR8, GR9, GR10, GR11 : std_logic_vector(31 downto 0);
	signal GR12, GR13, GR14, GR15 : std_logic_vector(31 downto 0);
	
	-- Flags
	signal Z, N, C, O, L : std_logic := 0;

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

		signal uPC, K1, K2 : std_logic_vector(7 downto 0);
		-- signal SuPC : std_logic_vector(15 downto 0);
		-- signal LC : std_logic_vector(7 downto 0);
		signal uIR : std_logic_vector(27 downto 0);

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
				when "0000" =>	-- NOP, do nothinhg.
				when "0001" => AR <= buss;
				when "0010" => -- buss' - Not buss?
				when "0011" => -- 0 - AR = 0?
				when "0100" => AR <= AR + buss;
				when "0101" => AR <= AR - buss;
				when "0110" => AR <= AR and buss;
				when "0111" => AR <= AR or buss;
				when "0111" => AR <= AR + buss; -- No flags.
				when "1001" => AR <= AR sll 1; -- Shift Left Logic.
				when "1010" => -- ARHR << 1 - Ehm.. dafuq?
				when "1011" => AR <= AR sra 1; -- Shift Right Arithmetic.
				when "1100" => -- ARHR >> 1 (arithmetic) - Ehm.. dafuq?
				when "1101" => AR <= AR srl 1; -- Shift Right Logic.
				when "1110" => -- Rotate AR left. - Ehm rotate?
				when "1111" => -- Rotate ARHR left. - Ehm.. dafuq?
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
				when "0011" => uPC <= 0;
				when "0101" => uPC <= uADR;
				when "0110" => -- uJSR uADR - ehm..??
				when "0111" => -- uRTS - ehm..??
				when "1000" => -- Jump if Z=1
				when "1001" => -- Jump if N=1
				when "1010" => -- Jump if C=1
				when "1011" => -- Jump if O=1
				when "1100" => -- Jump if L=1
				when "1111" => -- HALT
 			end case;
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