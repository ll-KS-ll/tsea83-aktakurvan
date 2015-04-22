-- TestBench Template 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY lab_tb IS
END lab_tb;

ARCHITECTURE behavior OF lab_tb IS 

  -- Component Declaration
  COMPONENT lab
    PORT(
      clk,rst : IN std_logic;
		vgaRed,vgaGreen :OUT std_logic_vector(2 downto 0);
		vgaBlue :OUT std_logic_vector(2 downto 1);      
		ca,cb,cc,cd,ce,cf,cg,dp, Hsync,Vsync: OUT std_logic;       
      an : OUT std_logic_vector(3 downto 0)
      );
  END COMPONENT;

  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';
  SIGNAL ca,cb,cc,cd,ce,cf,cg,dp,Hsync,Vsync : std_logic;
  SIGNAL an :  std_logic_vector(3 downto 0);
  signal tb_running : boolean := true;
  signal vgaRed, vgaGreen : STD_LOGIC_VECTOR (2 downto 0);
  signal vgaBlue : STD_LOGIC_VECTOR (2 downto 1);
BEGIN

  -- Component Instantiation
  uut: lab PORT MAP(
    clk => clk,
    rst => rst,
	 vgaRed => vgaRed,
	 vgaGreen => vgaGreen,
    vgaBlue => vgaBlue,
	 Hsync => Hsync,
	 Vsync => Vsync,
    ca => ca,
    cb => cb,     
    cc => cc,  
    cd => cd,
    ce => ce,
    cf => cf,
    cg => cg,
    dp => dp,
    an => an);


  -- 100 MHz system clock
  clk_gen : process
  begin
    while tb_running loop
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
    end loop;
    wait;
  end process;

  

  stimuli_generator : process
    variable i : integer;
  begin
    -- Aktivera reset ett litet tag.
    rst <= '1';
    wait for 500 ns;

    wait until rising_edge(clk);        -- se till att reset sl�pps synkront
                                        -- med klockan
    rst <= '0';
    report "Reset released" severity note;


    for i in 0 to 50000000 loop         -- V�nta ett antal klockcykler
      wait until rising_edge(clk);
    end loop;  -- i
    
    tb_running <= false;                -- Stanna klockan (vilket medf�r att inga
                                        -- nya event genereras vilket stannar
                                        -- simuleringen).
    wait;
  end process;
      
END;
