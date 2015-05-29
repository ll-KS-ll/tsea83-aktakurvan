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

        --Instructions
        alias OP            : std_logic_vector(3 downto 0)      is IR(31 downto 28);
        alias GRx           : std_logic_vector(3 downto 0)      is IR(27 downto 24);
        alias M             : std_logic_vector(3 downto 0)      is IR(23 downto 20);
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
	    type uMem_t is array(0 to 63) of std_logic_vector(31 downto 0); -- Expand to 32 for simplicity.
	    constant uMem : uMem_t := ( -- Memory for microprograming code.
		    x"001F_0000", -- Hämtfas
            x"0011_4000", -- 
            x"0000_8200", -- Decide EA  
            x"000F_0100", -- EA Direct   
            x"001F_4100", -- EA Imediate
            x"000F_0000", -- EA Indirect
            x"0017_0100", --
            x"0048_0000", --
            x"0230_8000", -- EA Indexed (Fel, väljer Gr3) 
            x"0027_0100", -- 
            x"0070_0000", -- ADD
            x"0110_0000", -- 
		    x"0026_0300", -- 
            x"001E_0000", -- JSR
            x"000B_0300", -- 
            x"0000_0000", -- 
		    x"0070_0000", -- AND 
            x"0190_0000", -- 
            x"0026_0300", -- 
            x"000B_0300", -- BRA
		    x"0208_0816", -- BNE
            x"0000_0300", -- 
            x"000B_0300", --  
            x"000D_0300", -- WGCR
		    x"0000_0000", -- 
            x"0070_0000", -- CMP
            x"0150_0300", -- 
            x"0070_0000", -- INC
            x"0280_0000", --  
            x"0026_0300", -- 
		    x"0070_0000", -- DEC
            x"03A8_0000", -- 
            x"0026_0300", -- 
            x"0016_0300", -- LOAD
		    x"0032_0300", -- STORE
            x"0070_0000", -- STOREG
            x"0300_0E00", -- 
            x"0130_0000", --
		    x"02C0_0E00", --
            x"0130_0000", --
            x"0024_0300", --
            x"0033_0300", -- RSR
            x"0070_0000", -- OR 
            x"01D0_0000", --
		    x"0026_0300", -- 
            x"002E_0300", -- RGC    R
            x"0000_0000", 
            x"0000_0000",
		    x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
		    x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
		    x"0000_0000", x"0000_0000", x"0000_0000", x"0000_0000",
		    x"0000_0000", x"0000_0000"
		    );
begin
        -- K1 - Go to instruction 
        with OP select
            K1 <=   X"0A" when "0000", -- ADD        0
                    X"0D" when "0001", -- JSR        1
                    X"10" when "0010", -- AND        2
	    	        X"13" when "0011", -- BRA        3
			        X"14" when "0100", -- BNE        4
			        X"17" when "0101", -- WGCR       5		       
                    X"19" when "0110", -- CMP        6
			        X"1B" when "0111", -- INC        7
			        X"1E" when "1000", -- DEC        8
    				X"21" when "1001", -- LOAD       9
	    			X"22" when "1010", -- STORE      A
		    		X"23" when "1011", -- STOREG     B
                    x"29" when "1100", -- RSR        C
                    x"2A" when "1101", -- OR         D
                    x"2D" when "1110", -- RGCR       F
			    	X"00" when others; -- 

        -- K2 - Choose adressing mode   
        with M select
            K2 <=   X"03" when "0000",    -- EA Direct
                    X"04" when "0001",    -- EA Imidiate
                    X"05" when "0010",    -- EA Indirect
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
                        when "0101" => uPC <= uADR;
                        when "0110" => 
                                    SuPC <= uPC+1;
                                    uPC <= uADR;
                        when "0111" => uPC <= SuPC;
                                    -- Jump if Z=0
                        when "1000" =>
                                    if Z='0' then uPC <= uADR;
                                    else uPC <= uPC+1;
                                    end if;
                                    -- Jump if Z=1
                        when "1001" => 
                                    if Z='1' then uPC <=uADR;
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
