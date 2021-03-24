--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.std_logic_1164.all;	
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity schimbare_pin is
	port(clk, enable, enter: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	sw: in std_logic_vector(3 downto 0);
	date_out_card: out std_logic_vector(0 to 16));
end entity;

architecture arh_schimbare_pin of schimbare_pin is

begin 
	
	process(clk)
	begin
		if clk = '1' and clk'event then
			if enable = '1' and enter = '1' then
				date_out_card(4 to 16) <= date_in_card(4 to 16);
				date_out_card(0 to 3) <= sw; --noul pin
			else
				date_out_card <= date_in_card;
			end if;	
		end if;
	end process;
	
end architecture;