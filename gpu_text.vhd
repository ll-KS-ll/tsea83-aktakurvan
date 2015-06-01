library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Library for arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


-- ====== Characters module ======
--
-- The characters module is a helper to write characters to the display.
-- By sending x and y coordinates, color to use and the character to display
-- this module writes it to the memory at specified location. This makes it
-- a lot easier to have text in the program.    
--
-- The location to draw a character is set by xpos and ypos. 
-- After a characters has been draw, xpos is incremented by the width
-- of one charecter. This makes it possible to write words by just setting
-- a stort possition and then send all the characters to the character module.
--
-- It takes 35 clock cycles to draw one character.
-- A memory of size 64 acts as a buffer to compensate for slow write times.
-- Thanx to this buffer it's possible to send several charecters in a row and 
-- have all written as soon as possible. 
--
--
-- One letter is 5x7 pixlar in size.
--
--
-- Character: Decimal Hex
--
-- a: 0 00		k: 10 0A		u: 20 14	 	5: 30 	1E  	-: 40		29
-- b: 1 01		l: 11 0B		v: 21 15	 	6: 31 	1F		:: 41		2A
-- c: 2 02		m: 12 0C		w: 22 16	 	7: 32 	20		": 42		2B
-- d: 3 03		n: 13 0D		x: 23 17	 	8: 33 	21		,: 43		2C
-- e: 4 04		o: 14 0E		y: 24 18	 	9: 34 	22		 : 44 	2D
-- f: 5 05		p: 15 0F		z: 25 19	 	0: 35 	23
-- g: 6 06		q: 16 10		1: 26 1A		.: 36 	24
-- h: 7 07		r: 17 11		2: 27 1B	 	!: 37 	25
-- i: 8 08		s: 18 12		3: 28 1C		?: 38		26
-- j: 9 09		t: 19 13		4: 29 1D		_: 39		27
--	 


entity gpu_text is 
  Port  ( clk,rst : in std_logic;
          dbus : in std_logic_vector(31 downto 0);
          FB_o : in std_logic_vector(2 downto 0);
          control_register : in std_logic_vector(31 downto 0);
          xaddress  : out integer;
          yaddress  : out integer;
          to_ram : out std_logic_vector(3 downto 0);
          write_char : out std_logic
        );
end gpu_text;

architecture arch of gpu_text is 
  -- Map important bits in control register.
  alias char_flag : std_logic is control_register(8);
	alias mode : std_logic_vector(1 downto 0) is control_register(10 downto 9);

  -- Integers for indexing pixel in letter.
  signal x_char, y_char : integer := 0;
  -- Integers for indexing memory.
  signal xpos : std_logic_vector(8 downto 0) := '0' & x"00";
  signal ypos : std_logic_vector(7 downto 0) := x"00";
  signal color : std_logic_vector(3 downto 0) := x"0";
  -- Flag if a letter should be written to memory.
  signal draw : std_logic := '0';
  -- Flag for signaling auto increment of xpos.
  signal auto_inc_x : std_logic := '0';
  
  -- ====== BUFFER ======
  -- Buffer used to store characters untill they have been written to memory.
  type buf_t is array(0 to 63) of std_logic_vector(26 downto 0); -- 27 bits
  signal buf : buf_t := (others => (others => '0'));
  -- Buffer counteres.
  signal buf_free : std_logic_vector(5 downto 0) := "000000"; -- Points to next free slot.
  signal buf_draw : std_logic_vector(5 downto 0) := "000000"; -- Points to char to draw.
  -- Register for current characeter to draw at xpos, ypos in color.
  signal buf_line : std_logic_vector(26 downto 0);
  alias x_mem : std_logic_vector(8 downto 0) is buf_line(26 downto 18);
  alias y_mem : std_logic_vector(7 downto 0) is buf_line(17 downto 10);
  alias pixel : std_logic_vector(3 downto 0) is buf_line(9 downto 6);
  alias char : std_logic_vector(5 downto 0) is buf_line(5 downto 0);


	-- Constant tiles describing all letters.
	type letter_tile_t is array(0 to 6) of std_logic_vector(0 to 4);
  constant a : letter_tile_t := (
    "01110", "10001", "10001", "10001", "11111", "10001", "10001"
  );
  constant b : letter_tile_t := (
    "11110", "10001", "10001", "11110", "10001", "10001", "11110"
  );
  constant c : letter_tile_t := (
    "01110", "10001", "10000", "10000", "10000", "10001", "01110"
  );
  constant d : letter_tile_t := (
    "11110", "10001", "10001", "10001", "10001", "10001", "11110"
  );
  constant e : letter_tile_t := (
    "11111", "10000", "10000", "11110", "10000", "10000", "11111"
  );
  constant f : letter_tile_t := (
    "11111", "10000", "10000", "11110", "10000", "10000", "10000"
  );
  constant g : letter_tile_t := (
    "01110", "10001", "10000", "10000", "10011", "10001", "01110"
  );
  constant h : letter_tile_t := (
    "10001", "10001", "10001", "11111", "10001", "10001", "10001"
  );
  constant i : letter_tile_t := (
    "11111", "00100", "00100", "00100", "00100", "00100", "11111"
  );
  constant j : letter_tile_t := (
    "01111", "00001", "00001", "00001", "10001", "10001", "01110"
  );
  constant k : letter_tile_t := (
    "10001", "10010", "10100", "11000", "10100", "10010", "10001"
  );
  constant l : letter_tile_t := (
    "10000", "10000", "10000", "10000", "10000", "10000", "11111"
  );
  constant m : letter_tile_t := (
    "10001", "11011", "10101", "10001", "10001", "10001", "10001"
  );
  constant n : letter_tile_t := (
    "10001", "10001", "11001", "10101", "10011", "10001", "10001"
  );
  constant o : letter_tile_t := (
    "01110", "10001", "10001", "10001", "10001", "10001", "01110"
  );
  constant p : letter_tile_t := (
    "11110", "10001", "10001", "11110", "10000", "10000", "10000"
  );
  constant q : letter_tile_t := (
    "01110", "10001", "10001", "10001", "10101", "10010", "01101"
  );
  constant r : letter_tile_t := (
    "11110", "10001", "10001", "11110", "10001", "10001", "10001"
  );
  constant s : letter_tile_t := (
    "01110", "10001", "10000", "01110", "00001", "10001", "01110"
  );
  constant t : letter_tile_t := (
    "11111", "00100", "00100", "00100", "00100", "00100", "00100"
  );
  constant u : letter_tile_t := (
    "10001", "10001", "10001", "10001", "10001", "10001", "01110"
  );
  constant v : letter_tile_t := (
    "10001", "10001", "10001", "10001", "10001", "01010", "00100"
  );
  constant w : letter_tile_t := (
    "10001", "10001", "10001", "10001", "10101", "11011", "10001"
  );
  constant x : letter_tile_t := (
    "10001", "10001", "01010", "00100", "01010", "10001", "10001"
  );
  constant y : letter_tile_t := (
    "10001", "10001", "10001", "01010", "00100", "00100", "00100"
  );
  constant z : letter_tile_t := (
    "11111", "00001", "00010", "00100", "01000", "10000", "11111"
  );
  constant one : letter_tile_t := (
    "00100", "01100", "10100", "00100", "00100", "00100", "11111"
  );
  constant two : letter_tile_t := (
    "01110", "10001", "00001", "01110", "10000", "10000", "01111"
  );
  constant three : letter_tile_t := (
    "11110", "00001", "00001", "01110", "00001", "00001", "11110"
  );
  constant four : letter_tile_t := (
    "10001", "10001", "10001", "01111", "00001", "00001", "00001"
  );
  constant five : letter_tile_t := (
    "01111", "10000", "10000", "01110", "00001", "10001", "01110"
  );
  constant six : letter_tile_t := (
    "01110", "10001", "10000", "11110", "10001", "10001", "01110"
  );
  constant seven : letter_tile_t := (
    "11110", "00001", "00001", "00001", "00001", "00001", "00001"
  );
  constant eight : letter_tile_t := (
    "01110", "10001", "10001", "01110", "10001", "10001", "01110"
  );
  constant nine : letter_tile_t := (
    "01110", "10001", "10001", "01111", "00001", "10001", "01110"
  );
  constant zero : letter_tile_t := (
    "01110", "10001", "10011", "10101", "11001", "10001", "01110"
  );
  constant dot : letter_tile_t := (
    "00000", "00000", "00000", "00000", "00000", "00000", "10000"
  );
  constant blargh : letter_tile_t := ( -- Blargh is "!"
  	"10000", "10000", "10000", "10000", "10000", "00000", "10000"
  );

  -- Array with all letters.
  type letters_t is array(0 to 37) of letter_tile_t;
  constant letters : letters_t := (a, b, c, d, e, f, 
  																g, h, i, j, k, l,
  																m, n, o, p, q, r,
  																s, t, u, v, w, x,
  																y, z, one, two, three,
  																four, five, six, seven,
  																eight, nine, zero, dot,
  																blargh);
begin
	
	process(clk) begin
		if rising_edge(clk) then
			if rst = '1' then
        -- Reset
				draw <= '0';
        xpos <= (others => '0');
        ypos <= (others => '0');
        color <= (others => '0');
        auto_inc_x <= '0';
        buf_free <= (others => '0');
        buf_draw <= (others => '0');
        buf <= (others => (others => '0'));
      -- Get data from bus.
      elsif FB_o="100" then
        if char_flag = '1' then
          case mode is
            -- xpos
            when "00" =>  xpos <= dbus(8 downto 0);
                          auto_inc_x <= '0';
            -- ypos
            when "01" =>  ypos <= dbus(7 downto 0);
            -- color
            when "10" =>  color <= dbus(3 downto 0);
            -- char
            when others =>  -- Write data into next free buffer slot.
                            buf(conv_integer(buf_free))(5 downto 0) <= dbus(5 downto 0);
                            buf(conv_integer(buf_free))(17 downto 10) <= ypos;
                            buf(conv_integer(buf_free))(9 downto 6) <= color;
                            -- xpos
                            if auto_inc_x = '1' then
                              buf(conv_integer(buf_free))(26 downto 18) <= xpos + 6;
                              xpos <= xpos + 6;
                            else
                              buf(conv_integer(buf_free))(26 downto 18) <= xpos;
                            end if;
                            
                            if draw = '0' then
                              buf_line <= buf(conv_integer(buf_free));
                            end if;
                            -- Point to next free buffer slot.
                            buf_free <= buf_free + 1;
                            draw <= '1';
                            auto_inc_x <= '1';
          end case;         
        end if;
      --  Write character to ram
      elsif draw = '1' then
        if letters(conv_integer(char))(y_char)(x_char) = '1' then
          xaddress <= conv_integer(x_mem);
          yaddress <= conv_integer(y_mem);
          to_ram <= pixel;
          write_char <= '1';
        else
          write_char <= '0';
        end if;       
        
        x_char <= x_char + 1;
        x_mem <= x_mem + 1;
        
        if x_char = 4 then
          x_char <= 0;
          x_mem <= x_mem - 4;
          
          y_char <= y_char + 1;
          y_mem <= y_mem + 1;

          if y_char = 6 then
            -- Completed drawing of a character.
            buf_line <= buf(conv_integer(buf_draw));
            buf_draw <= buf_draw + 1;
            x_char <= 0;
            y_char <= 0;
            -- If draw and free points to the same slot, there is nothing left to draw.
            if buf_draw + 1 = buf_free then
              draw <= '0';
              write_char <= '0';
            end if;
          end if;

        end if;
      end if;
		end if;
	end process;

end architecture ; 