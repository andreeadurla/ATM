--####### DURLA ANDREEA #######
library IEEE;
use IEEE.std_logic_1164.all;	
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.tip_nou.all;

entity retragere is
	port(clk, enable, enter, reset: in std_logic;
	date_in_card: in std_logic_vector(0 to 16); 
	in_bancomat: in tip;
	sw: in std_logic_vector (4 downto 0); 
	date_out_card: out std_logic_vector(0 to 16);
	out_bancomat: out tip;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end entity;

architecture arh_retragere of retragere is

component suma_introdusa
	port(clk, enable, reset: in std_logic;
	sw: in std_logic_vector(3 downto 0);
	suma_bani: out natural;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

component afisare
	port(clk, reset: in std_logic;
	nr_de_afisat: in std_logic_vector(15 downto 0);
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

component retragere_banc 
	port(clk, enable, reset: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	sum: in natural; 
	in_bancomat: in tip;
	date_out_card: out std_logic_vector(0 to 16);
	out_bancomat: out tip;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

signal nr, nr_introdus: natural; --suma de bani predefinita sau introdusa
signal enable_ret_banc, enable_afis_sum, enable_sum_pred: std_logic := '0';
signal catozi_afis, catozi_ret, catozi_sum_pred: std_logic_vector(6 downto 0);
signal anozi_afis, anozi_ret, anozi_sum_pred: std_logic_vector(3 downto 0);
signal reset_op: std_logic;	
signal nr_afisat: std_logic_vector(15 downto 0); --daca se alege suma predefinita, o afisam

begin
	
	process(clk, reset)
	begin 
		if reset = '1' then	
			enable_afis_sum <= '0';
			enable_ret_banc <= '0';
			enable_sum_pred <= '0';
			nr <= 0;
		else
			if clk = '1' and clk'event then
				if enable = '1' then 
					if enter = '0' then
						if sw(4) = '1' then
							enable_afis_sum <= '1';
							nr <= nr_introdus;	 
						elsif sw(3) = '1' then
							nr <= 500;	 --suma predefinita	
							nr_afisat <= x"0500";
							enable_sum_pred <= '1';
						elsif sw(2) = '1' then
							nr <= 200; 	 --suma predefinita
							nr_afisat <= x"0200";
							enable_sum_pred <= '1';
						elsif sw(1) = '1' then
							nr <= 100;	 --suma predefinita	
							nr_afisat <= x"0100";
							enable_sum_pred <= '1';
						elsif sw(0) = '1' then
							nr <= 50; --suma predefinita 
							nr_afisat <= x"0050";
							enable_sum_pred <= '1';
						else 
							nr <= 0;
						end if;
					else 
						enable_afis_sum <= '0';
						enable_sum_pred <= '0';
						enable_ret_banc <= '1';
					end if;
				else
					enable_afis_sum <= '0';
					enable_ret_banc <= '0';
					enable_sum_pred <= '0';
					nr <= 0;
				end if;	
			end if;
		end if;
	end process; 
	
	process(clk)
	begin
		if clk = '1' and clk'event then
			if enable_afis_sum = '1' then --afisam suma introdusa
				catozi <= catozi_afis;
				anozi <= anozi_afis;
			elsif enable_sum_pred = '1' then  --afisam suma predefinita
				catozi <= catozi_sum_pred;
				anozi <= anozi_sum_pred;
			elsif enable_ret_banc = '1' then --afisam bancnotele retrase
				catozi <= catozi_ret;
				anozi <= anozi_ret;	
			else
				catozi <= "1111111";
				anozi <= "1111";
			end if;
		end if;
	end process;
	
		
	reset_op <= reset or (not enable); --resetam componentele
	C1: afisare port map(clk, reset_op, nr_afisat, catozi_sum_pred, anozi_sum_pred);
	C2: suma_introdusa port map(clk, enable_afis_sum, reset_op, sw(3 downto 0), nr_introdus, catozi_afis, anozi_afis); 
	C3: retragere_banc port map(clk, enable_ret_banc, reset_op, date_in_card, nr, in_bancomat, date_out_card, out_bancomat, catozi_ret, anozi_ret);
end architecture;