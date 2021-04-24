 library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity seven_segment is
port(
		clk 		 : in std_logic;			-- clock 50 MHz
		reset		 : in std_logic;			-- reset key_0 button on the FPGA board
		key_1		 : in std_logic;			-- Push button key_1 on the FPGA board
		HEX0		 : out std_logic_vector(6 downto 0); -- seven_segment display of the Digit 1
		HEX1		 : out std_logic_vector(6 downto 0); -- seven_segment display of the Digit 2	
		HEX2		 : out std_logic_vector(6 downto 0); -- seven_segment display of the Digit 3	
		HEX3		 : out std_logic_vector(6 downto 0)	 -- seven_segment display of the Digit 4

);
end seven_segment;

architecture rtl of seven_segment is 

----------------Signals--------------------------

Type statemachinetype is (DIGIT_1, DIGIT_2, DIGIT_3, DIGIT_4);	
constant Debounceperiod  : integer := 25000000;
signal Debouncecount     : integer;
signal sync : std_logic_vector (1 downto 0);
signal sync_key_1 : std_logic;
signal key_1_Debounce : std_logic;	
signal key_1_Debounce_delay : std_logic;	

signal HEX0_int : std_logic_vector(6 downto 0); 
signal HEX1_int : std_logic_vector(6 downto 0); 
signal HEX2_int : std_logic_vector(6 downto 0); 
signal HEX3_int : std_logic_vector(6 downto 0); 
signal state 	 : statemachinetype;
signal HEX0numbertodisplay : integer;
signal HEX1numbertodisplay : integer;
signal HEX2numbertodisplay : integer;
signal HEX3numbertodisplay : integer;
signal fallingedgeon_key_1 : std_logic;
signal Digit1 : integer;
signal Digit2 : integer;
signal Digit3 : integer;
signal Digit4 : integer;
signal period_counter : integer;

begin
-------------------------------------------------------------

	HEX0 <= HEX0_int;
	HEX1 <= HEX1_int;
	HEX2 <= HEX2_int;
	HEX3 <= HEX3_int;
	sync_key_1 <=sync(1); 
	
	synchronised_key_1 : process(reset,clk)
		begin
			if reset = '0' then 
				sync <= "11";
			elsif rising_edge(clk) then
				sync(0)<= key_1;
				sync(1)<= sync(0);
			end if;
		end process;
------------------------------------------------------------

	Debounce : process(reset,clk)
		begin
			if reset = '0' then 
			Debouncecount <= 0;
			key_1_Debounce<= '1';
				
			elsif rising_edge(clk) then
			
			if sync_key_1 = '0' then 
				
				if Debouncecount < Debounceperiod then 
					Debouncecount <= Debouncecount+1;
				end if;
							
			else
			
				if Debouncecount > 0 then 
					Debouncecount <= Debouncecount - 1;
				end if;
			end if;
			
			if Debouncecount =  Debounceperiod then 
				key_1_Debounce<= '0';
				elsif Debouncecount = 0 then
				key_1_Debounce<= '1';
			end if;
	
			end if;
		end process;
-----------------------------------------------------------	


	Detectfallingedge : process(reset,clk)
		begin
			if reset = '0' then 
				key_1_Debounce_delay <='1';
				fallingedgeon_key_1	<='0';
			elsif rising_edge(clk) then
				key_1_Debounce_delay <= key_1_Debounce;
				
					if key_1_Debounce ='0' AND key_1_Debounce_delay = '1' then 
						fallingedgeon_key_1<= 	'1';
					else
						fallingedgeon_key_1<= 	'0';
					end if;
			
			end if;
		end process;
-------------------------------------------------------------
	
	countbuttonpress : process(reset,clk)
		begin
			if reset = '0' then 
				Digit1 <= 0;
				Digit2 <= 0;
				Digit3 <= 0;
				Digit4 <= 0;
			elsif rising_edge(clk) then
				if fallingedgeon_key_1 = '1' then 
					if Digit1 < 9 then
						Digit1<= Digit1 +1; 
					else 
						Digit1<= 0;  
						
						if Digit2 < 9 then
							Digit2<= Digit2 +1; 
					else 
						Digit2<= 0;  
						
							if Digit3 < 9 then
								Digit3<= Digit3 +1; 
					else 
						Digit3<= 0;  
						
						if Digit4 < 9 then
							Digit4<= Digit4 +1; 
					else 
						Digit4<= 0;  
						end if;
						end if;
						end if;
						end if;
						end if;
		
			end if;
		end process;
------------------------------------------------------------
	Decoder_HEX0 : process(reset,clk)
		begin
			if reset = '0' then
				HEX0_int <= "0000001";
			elsif rising_edge(clk) then 
			
			case HEX0numbertodisplay is 
				when 0 => HEX0_int <= "1000000"; --0
				when 1 => HEX0_int <= "1111001"; --1	
				when 2 => HEX0_int <= "0100100"; --2 
				when 3 => HEX0_int <= "0110000"; --3 
				when 4 => HEX0_int <= "0011001"; --4 
				when 5 => HEX0_int <= "0010010"; --5 
				when 6 => HEX0_int <= "0000010"; --6 
				when 7 => HEX0_int <= "1111000"; --7 
				when 8 => HEX0_int <= "0000000"; --8
				when 9 => HEX0_int <= "0010000"; --9 
				when others => HEX0_int <= "1111111"; --null
				
				end case;
			end if;
		end process;
------------------------------------------------------------
	Decoder_HEX1 : process(reset,clk)
		begin
			if reset = '0' then
				HEX1_int<= "0000001";
			elsif rising_edge(clk) then 
			
			case HEX1numbertodisplay is 
				when 0 => HEX1_int <= "1000000"; --0
				when 1 => HEX1_int <= "1111001"; --1	
				when 2 => HEX1_int <= "0100100"; --2
				when 3 => HEX1_int <= "0110000"; --3
				when 4 => HEX1_int <= "0011001"; --4
				when 5 => HEX1_int <= "0010010"; --5
				when 6 => HEX1_int <= "0000010"; --6
				when 7 => HEX1_int <= "1111000"; --7
				when 8 => HEX1_int <= "0000000"; --8
				when 9 => HEX1_int <= "0010000"; --9
				when others => HEX1_int <= "1111111"; --null
				
				end case;
			end if;
		end process;
------------------------------------------------------------
	Decoder_HEX2 : process(reset,clk)
		begin
			if reset = '0' then
				HEX2_int<= "0000001";
			
			elsif rising_edge(clk) then 
			
			case HEX2numbertodisplay is 
				when 0 => HEX2_int <= "1000000"; --0
				when 1 => HEX2_int <= "1111001"; --1	
				when 2 => HEX2_int <= "0100100"; --2
				when 3 => HEX2_int <= "0110000"; --3
				when 4 => HEX2_int <= "0011001"; --4
				when 5 => HEX2_int <= "0010010"; --5
				when 6 => HEX2_int <= "0000010"; --6
				when 7 => HEX2_int <= "1111000"; --7
				when 8 => HEX2_int <= "0000000"; --8
				when 9 => HEX2_int <= "0010000"; --9
				when others => HEX2_int <= "1111111"; --null
				
				end case;
			end if;
		end process;
------------------------------------------------------------
	Decoder_HEX3 : process(reset,clk)
		begin
			if reset = '0' then
				HEX3_int<= "0000001";
			
			elsif rising_edge(clk) then 
			
			case HEX3numbertodisplay is 
				when 0 => HEX3_int <= "1000000"; --0
				when 1 => HEX3_int <= "1111001"; --1	
				when 2 => HEX3_int <= "0100100"; --2
				when 3 => HEX3_int <= "0110000"; --3
				when 4 => HEX3_int <= "0011001"; --4
				when 5 => HEX3_int <= "0010010"; --5
				when 6 => HEX3_int <= "0000010"; --6
				when 7 => HEX3_int <= "1111000"; --7
				when 8 => HEX3_int <= "0000000"; --8
				when 9 => HEX3_int <= "0010000"; --9
				when others => HEX3_int <= "1111111"; --null
				
				end case;
			end if;
		end process;
------------------------------------------------------------

	Statemachine : process(reset,clk)
		begin
			if reset = '0' then 
				state <= DIGIT_1;
				period_counter <= 0;
			elsif rising_edge(clk) then
				case state is 
				when DIGIT_1 =>
						HEX0numbertodisplay<= Digit1;
						
						period_counter <= period_counter+1;
						
						if period_counter = 50000 then 
						state <= DIGIT_2;
						period_counter <= 0;
						end if; 
						
				when DIGIT_2 =>
						HEX1numbertodisplay<= Digit2;
						
						period_counter <= period_counter+1;
						
						if period_counter = 50000 then 
						state <= DIGIT_3;
						period_counter <= 0;
						end if; 
						
				
				when DIGIT_3 =>
						HEX2numbertodisplay<= Digit3;
						
						period_counter <= period_counter+1;
						
						if period_counter = 50000 then 
						state <= DIGIT_4;
						period_counter <= 0;
						end if; 
						
				
				when DIGIT_4 =>
						HEX3numbertodisplay<= Digit4;
						
						period_counter <= period_counter+1;
						
						if period_counter = 50000 then 
						state <= DIGIT_1;
						period_counter <= 0;
						end if; 
						
				
				when others => 
					state <= DIGIT_1;  
					
				end case;
			end if;
		end process;
-------------------------------------------------------------
end rtl;
