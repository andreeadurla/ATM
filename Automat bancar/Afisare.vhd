--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;  
use IEEE.std_logic_unsigned.all;

entity afisare is
	port(clk, reset: in std_logic;
	nr_de_afisat: in std_logic_vector(15 downto 0);
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end entity;
 
architecture arh_afisare of afisare is 

component div_frec_1
	port(clk_placa, reset: in std_logic;
	clk_div: out std_logic);
end component;	 

signal my_clk: std_logic; --clk divizat	
signal sel: std_logic_vector(3 downto 0); --alege care anod este activat
signal nr: std_logic_vector(3 downto 0) := (others => '0');

begin
	
	divizor_frec1: div_frec_1 port map(clk_placa => clk, reset => reset, clk_div => my_clk);  
	process(my_clk, reset)
	variable cont: natural := 0;
	begin
		if reset = '1' then
			sel <= "1111";
			cont := 0;
		elsif my_clk = '1' and my_clk'event then
			sel <= "1111";
			sel(cont) <= '0';
			if cont = 3 then
				cont := 0; 
			else
				cont := cont+1;
			end if;
		end if;
	end process;
	
	anozi <= sel;

	process(sel)
	begin
		case sel is
			when "1110" => nr <= nr_de_afisat(3 downto 0);
			when "1101" => nr <= nr_de_afisat(7 downto 4);
			when "1011" => nr <= nr_de_afisat(11 downto 8);
			when "0111" => nr <= nr_de_afisat(15 downto 12);
			when others => nr <= "1111";
		end case;
	end process;
			
	process(nr)
	begin	
		case nr is
			when "0000" => catozi <= "0000001"; ---0
			when "0001" => catozi <= "1001111"; ---1
			when "0010" => catozi <= "0010010"; ---2
			when "0011" => catozi <= "0000110"; ---3
			when "0100" => catozi <= "1001100"; ---4
			when "0101" => catozi <= "0100100"; ---5
			when "0110" => catozi <= "0100000"; ---6
			when "0111" => catozi <= "0001111"; ---7
			when "1000" => catozi <= "0000000"; ---8
			when "1001" => catozi <= "0000100"; ---9
			when "1010" => catozi <= "1111110"; ---"-"
			when others => catozi <= "1111111"; 
		end case;  
	end process;

end architecture;