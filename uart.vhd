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
           datareg : out std_logic_vector(7 downto 0);
            seg : out std_logic_vector(7 downto 0);
            an : out std_logic_vector(3 downto 0));
end uart;

architecture Behavioral of uart is
    -- leddriver used for testing, temporary
    component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  STD_LOGIC_VECTOR(7 downto 0);
           an : out  STD_LOGIC_VECTOR (3 downto 0);
           value : in  STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    signal tal : std_logic_vector(15 downto 0) := X"0000";
    signal pos : std_logic_vector(1 downto 0) := "00";
    --
    signal txd1,txd2 : std_logic; --insignalsvippor
    signal sp,lp : std_logic; --shiftpulse, loadpulse
    signal running : std_logic; -- if running or not
    signal pulsenr : std_logic_vector(3 downto 0) := B"0000"; --current pulse number
    signal clknr : std_logic_vector(9 downto 0) := B"00000_00000"; --current clk number
    signal shiftreg : std_logic_vector(9 downto 0) := B"0_0000_0000_0"; -- 10 bit skiftregister
    
    constant ENDCLK : std_logic_vector(9 downto 0) := B"1101100011"; --867
    constant MIDCLK : std_logic_vector(9 downto 0) := B"0110110010"; --434
    constant ENDPULSE : std_logic_vector(3 downto 0) := B"1010"; --10
begin

        -- Synced flipflops for the recieved signal from keyboard
    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then
                txd1 <= '1';
                txd2 <= '1';
            else
                txd1 <= txd;
                txd2 <= txd1;
            end if;
        end if;
    end process;

    --uart controller
    process(clk) begin
        if rising_edge(clk) then
            if running='1' then --uart is running        
                if rst='1' then --reset uart
                    running <= '0';
                elsif pulsenr/=ENDPULSE then --recieve the 8 data bits
                    clknr <= clknr+1;
                    if clknr=MIDCLK then --shift in data bit
                        sp <= '1';
                        pulsenr <= pulsenr+1;
                    elsif clknr=ENDCLK then --reset clk number
                        clknr <= (others => '0');
                    else
                        sp <= '0';
                    end if;
                elsif pulsenr=ENDPULSE and clknr=ENDCLK then -- send out data
                    lp <= '1';
                    running <= '0';
                else
                    sp <= '0';
                    clknr <= clknr+1;
                end if;
            else --uart is idle
                if txd2='0' then --startbit is recieved
                    running <= '1';
                    clknr <= clknr+1;
                else
                    sp <= '0';
                    lp <= '0';
                    running <= '0';
                    clknr <= (others => '0');
                    pulsenr <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    --10 bit shiftregister
    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then
                shiftreg <= (others => '0');
            elsif sp='1' then
                shiftreg(9 downto 0) <= txd2 & shiftreg(9 downto 1); -- shift in data bit
            end if;
        end if;
    end process;

    -- dataregister
    process (clk) begin
        if rising_edge(clk) then
            if rst='1' then
                datareg <= (others => '0');
            elsif lp='1' then
                datareg(7 downto 0) <= shiftreg(8 downto 1); -- set dataregister
            end if;
        end if;
    end process;



    --- FOR TESTING ONLY

    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then
                pos <= "00";
            else
                pos <= pos + lp;
            end if;
        end if;
    end process;

    process(clk) begin
        if rising_edge(clk) then
            if rst='1' then
                tal <= X"0000";
            elsif lp='1' then
                if pos=0 then
                    tal(15 downto 0) <= shiftreg(4 downto 1) & tal(11 downto 0);
                elsif pos=1 then
                    tal(15 downto 0) <= tal(15 downto 12) & shiftreg(4 downto 1) & tal(7 downto 0);
                elsif pos=2 then
                    tal(15 downto 0) <= tal(15 downto 8) & shiftreg(4 downto 1) & tal(3 downto 0);
                else
                    tal(15 downto 0) <= tal(15 downto 4) & shiftreg(4 downto 1);
                end if;
            else
                tal <= tal;
            end if;
        end if;
    end process;


    -- leddriver from lab4 (uart), used for testing the uart implementation
    led: leddriver port map(clk, rst, seg, an, tal);
end Behavioral;
