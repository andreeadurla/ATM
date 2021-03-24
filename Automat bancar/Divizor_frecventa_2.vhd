--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity div_frec_2 is
	port(clk_placa, reset: in std_logic;
	clk_div: out std_logic);
end entity;

architecture arh_div_frec_2 of div_frec_2 is  
signal num: std_logic_vector(26 downto 0) := (others => '0');

begin
	process(clk_placa, reset)
	begin
		if reset = '1' then
			num <= (others => '0');
		elsif clk_placa = '1' and clk_placa'event then
			num <= num+1;
			clk_div <= num(26);
		end if;
	end process; 
end architecture;