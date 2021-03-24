--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RAM_card is
	port(clk: in std_logic;
	ADR: in std_logic_vector(1 downto 0); --ADR = id-ul cardului
	CS: in std_logic;		
	WR: in std_logic;
	D_IN: in std_logic_vector(0 to 16);	--primii 4 biti pentru pin, urmatorii 16 pentru suma
	D_OUT: out std_logic_vector(0 to 16));   --primii 4 biti pentru pin, urmatorii 16 pentru suma
end entity;

architecture A_RAM_card of RAM_card is

type MEM is array(0 to 3) of std_logic_vector(0 to 16);
signal M: MEM := ("00010001000001000", "00110000100111011", "10010001101000011", "11100000010010001");
--initializarea
--format: ID|PIN|SUMA 
-- 0|0001|520,  1|0011|315,   2|1001|835,   3|1110|145

begin
	process (clk, ADR, CS, WR, D_IN)
	begin
		if clk = '1' and clk'event then
			if CS = '0' then
				D_OUT <= "00000000000000000";
			else
				if WR = '0'	then
					case ADR is
						when "00" => D_OUT <= M(0);	
						when "01" => D_OUT <= M(1);
						when "10" => D_OUT <= M(2);
						when "11" => D_OUT <= M(3);
						when others => D_OUT<= "00000000000000000";
					end case;
				else
					case ADR is
						when "00" => M(0) <= D_IN;	
						when "01" => M(1) <= D_IN;
						when "10" => M(2) <= D_IN;
						when "11" => M(3) <= D_IN;
						when others => D_OUT<= "00000000000000000";
					end case;
				end if;
			end if;
		end if;
	end process;
end architecture;