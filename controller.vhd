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
            dbus            : in        std_logic_vector(31 downto 0);
            Z, C, L         : in        std_logic;
            controllerOut   : out       std_logic_vector(31 downto 0);
            TB_c            : out       std_logic_vector(2 downto 0);
            FB_c            : out       std_logic_vector(2 downto 0);
            GRx_c           : out       std_logic_vector(3 downto 0);
            ALU_c           : out       std_logic_vector(3 downto 0)
            );
end controller;

architecture arch of controller is
      
        --Registers
        signal IR           : std_logic_vector(31 downto 0)     := X"0000_0000";
        signal PC           : std_logic_vector(31 downto 0)     := X"0000_0000";

        -- IR [0000 0000 0000 0000 0000 0000 0000 0000]
        --     MMOO OOOO GGGG AAAA AAAA AAAA AAAA AAAA   

        --Instructions
        alias M             : std_logic_vector(1 downto 0)      is IR(31 downto 30);
        alias OP            : std_logic_vector(5 downto 0)      is IR(29 downto 24);
        alias GRx           : std_logic_vector(3 downto 0)      is IR(23 downto 20);
        alias ADR           : std_logic_vector(19 downto 0)     is IR(19 downto 0); 

        --Micro-programcounters and K-nets
        signal uPC, SuPC    : std_logic_vector(7 downto 0)      := X"00";
        signal K1, K2       : std_logic_vector(7 downto 0)      := X"00";

        --uIR
        signal uIR          : std_logic_vector(31 downto 0)     := X"0000_0000";
        --alias 
        alias ALU           : std_logic_vector(3 downto 0)      is uIR(25 downto 22);
        alias TB            : std_logic_vector(2 downto 0)      is uIR(21 downto 19); 
        alias FB            : std_logic_vector(2 downto 0)      is uIR(18 downto 16); 
		    alias S             : std_logic                         is uIR(15);
        alias P             : std_logic                         is uIR(14);           -- When '1' PC++
		    alias LC            : std_logic_vector(1 downto 0)      is uIR(13 downto 12);
		    alias SEQ           : std_logic_vector(3 downto 0)      is uIR(11 downto 8);
		    alias uADR          : std_logic_vector(7 downto 0)      is uIR(7 downto 0); 

        -- uMem
	    type uMem_t is array(0 to 127) of std_logic_vector(31 downto 0); -- Expand to 32 for simplicity.
	    constant uMem : uMem_t := ( -- Memory for microprograming code.
		    x"001F_0000", -- Hämtfas
            x"0011_4000", -- 
            x"0000_8200", -- Decide EA  
            x"000F_0100", -- EA Direct   
            x"001F_0100", -- EA Imediate
            x"000F_0000", -- EA Indirect
            x"0017_0100", --
            x"0048_0000", --
            x"0230_8000", -- EA Indexed (Fel, väljer Gr3) 
            x"0027_0100", -- 
            x"0034_0300", -- WGNUMS     0A
            x"001E_0000", -- JSR        0B
            x"000B_0300", -- 
            x"0070_0000", -- AND        0D
		    x"0190_0000", --  
            x"0026_0300", -- 
            x"000B_0300", -- BRA        10
		    x"0208_0813", -- BNE        11
            x"0000_0300", -- 
            x"000B_0300", --  
            x"000D_0300", -- WGCR       14
            x"0070_0000", -- CMP        15
            x"0150_0300", -- 
            x"0070_0000", -- INC        17
            x"0280_0000", --  
            x"0026_0300", -- 
		    x"0070_0000", -- DEC        1A
            x"03A8_0000", -- 
            x"0026_0300", -- 
            x"0016_0300", -- LOAD       1D
		    x"0032_0300", -- STORE      1E
            x"0070_0000", -- SGPU       1F
            x"0300_0E00", -- 
            x"0130_0000", --
		    x"02C0_0E00", --
            x"0130_0000", --
            x"0024_0300", --
            x"0033_0300", -- RSR        25
            x"0070_0000", -- OR         26
            x"01D0_0000", --
		    x"0026_0300", -- 
            x"002E_0300", -- RGCR       29
            x"0070_0000", -- ADD        2A
            x"0110_0000", --
		    x"0026_0300", --
            x"0070_0000", -- SUB        2D
            x"0150_0000", --
            x"0026_0300", --
		    x"0070_0000", -- LSL        30 
            x"0240_0000", --
            x"0026_0300", --
            x"0070_0000", -- LSL 4      33
		    x"02C0_0000", --
            x"0026_0300", --
            x"0070_0000", -- LSL 8      36         
            x"0300_0000", --
		    x"0026_0300", -- 
            x"0070_0000", -- LSR        39
            x"0340_0000", --
            x"0026_0300", --
            x"0208_093E", -- BEQ        3C
            x"0000_0300", --
            x"000B_0300", --
            x"0070_0000", -- RGPU       3F
            x"0300_0E00", --
            x"0130_0E00", --
            x"0024_0000", --
            x"003E_0300", --
            others => x"0000_0000"
		    );
begin
        -- K1 - Go to instruction 
        with OP select

            K1 <=   X"0A" when "000000", -- WGNUMS     0
                    X"0B" when "000001", -- JSR        1
                    X"0D" when "000010", -- AND        2
	    	            X"10" when "000011", -- BRA        3
			              X"11" when "000100", -- BNE        4
			              X"14" when "000101", -- WGCR       5		       
                    X"15" when "000110", -- CMP        6
			              X"17" when "000111", -- INC        7
			              X"1A" when "001000", -- DEC        8
    				        X"1D" when "001001", -- LOAD       9
	    			        X"1E" when "001010", -- STORE      A
		    		        X"1F" when "001011", -- SGPU       B
                    x"25" when "001100", -- RSR        C
                    x"26" when "001101", -- OR         D
                    x"29" when "001110", -- RGCR       E
                    x"2A" when "001111", -- ADD        F
                    x"2D" when "010000", -- SUB        10
                    x"30" when "010001", -- LSL        11
                    x"33" when "010010", -- LSL4       12
                    x"36" when "010011", -- LSL8       13
                    x"39" when "010100", -- LSR        14
                    x"3C" when "010101", -- BEQ        15
                    x"3F" when "010110", -- RGPU       16
                    X"1D" when others; -- Default to LOAD when not implemented. 


        -- K2 - Choose adressing mode   
        with M select
            K2 <=   X"03" when "00",    -- EA Direct
                    X"04" when "01",    -- EA Imidiate
                    X"05" when "10",    -- EA Indirect
                    X"08" when others;    -- EA Index

        -- uPC / SEQ
        process(clk) begin
            if rising_edge(clk) then
                if rst = '1' then
                    uPC <= x"00";
                    SuPC <= x"00";
                else 
                    case SEQ is
                        when "0000" => uPC <= uPC+1;    -- Increment uPC by 1
                        when "0001" => uPC <= K1;       --
                        when "0010" => uPC <= K2;       --
                        when "0011" => uPC <= X"00";    --
                        when "0100" => 
                                    if Z='0' then uPC <= uADR;
                                    else uPC <= uPC+1;
                                    end if;
                        when "0101" => 
                                    uPC <= uADR;
                        when "0110" => 
                                    SuPC <= uPC+1;
                                    uPC <= uADR;
                        when "0111" => 
                                    uPC <= SuPC;                                    
                        when "1000" =>
                                    if Z='0' then uPC <= uADR; -- Jump if Z=0
                                    else uPC <= uPC+1;
                                    end if;
                        when "1001" => 
                                    if Z='1' then uPC <=uADR; -- Jump if Z=1
                                    else uPC <= uPC+1;
                                    end if;
                        when "1010" => 
                                    if C='1' then uPC <= uADR;
                                    else uPC <= uPC+1;
                                    end if;
                        when "1011" => null; -- Undefined
                        when "1100" => 
                                    if L='1' then uPC <= uADR;
                                    else uPC <= uPC+1;
                                    end if;
                        when "1101" =>
                                    if C='0' then uPC <= uADR;
                                    else uPC <= uPC+1;
                                    end if;
                        when "1110" => 
                                    --GRx <= GRx+1;
                                    uPC <= uPC+1;
                        when others => null; -- Undefined
                    end case;
                end if;
            end if;
        end process;

        -- uIR
        uIR <= uMem(conv_integer(uPC));

        -- PC
        process(clk) begin
            if rising_edge(clk) then
                if rst='1' then
                    PC <= x"0000_0000";                
                elsif P='1' then
                    PC <= PC+1;
                elsif FB="011" then
                    PC <= x"000" & dbus(19 downto 0);
                end if;
            end if;
        end process;

        -- FB and TB are clocked so we dont need to clock TBo and FBo
        TB_c <= TB;
        FB_c <= FB;
        GRx_c <= GRx;
        ALU_c <= ALU;

        -- From controller to buss
        with TB select
            controllerOut <=    IR when "001",
                                PC when "011",
                                (others => 'Z') when others;

        -- IR
        process(clk) begin
          if rising_edge(clk) then
              if FB="001" then
                 IR <= dbus;
              end if;
              if SEQ="1110" then
                GRx <= GRx+1;
              end if;
          end if;
        end process;        
                              
                                    
end architecture;
