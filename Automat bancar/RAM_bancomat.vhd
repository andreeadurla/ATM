--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity RAM_bancomat is
	port(clk: in std_logic;
	ADR: in std_logic_vector(2 downto 0); 
	CS: in std_logic;		
	WR: in std_logic;
	D_IN: in std_logic_vector(5 downto 0);
	D_OUT: out std_logic_vector(5 downto 0));  
end entity;

architecture A_RAM_bancomat of RAM_bancomat is
type MEM is array(0 to 5) of std_logic_vector(5 downto 0);
signal M: MEM := ("010110", "010111", "000110", "010010", "010110", "000001");
--bancnota de 5 euro, 10 euro, 20 euro, 50 euro, 100 euro, 200 euro	

begin
	process (clk, ADR, CS, WR, D_IN)
	begin
		if clk = '1' and clk'event then
			if CS = '0' then
				D_OUT <= "000000";
			else
				if WR = '0'	then
					case ADR is
						when "000" => D_OUT <= M(0);	
						when "001" => D_OUT <= M(1);
						when "010" => D_OUT <= M(2);
						when "011" => D_OUT <= M(3);
						when "100" => D_OUT <= M(4);	
						when "101" => D_OUT <= M(5);
						when others => D_OUT <= "000000";
					end case;
				else
					case ADR is
						when "000" => M(0) <= D_IN;	
						when "001" => M(1) <= D_IN;
						when "010" => M(2) <= D_IN;
						when "011" => M(3) <= D_IN;	
						when "100" => M(4) <= D_IN;
						when "101" => M(5) <= D_IN;
						when others => D_OUT <= "000000";
					end case;
				end if;
			end if;	
		end if;
	end process;  
	
end architecture;