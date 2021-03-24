library IEEE;
use IEEE.std_logic_1164.all;  
use IEEE.std_logic_unsigned.all;

entity suma_introdusa is
	port(clk, enable, reset: in std_logic;
	sw: in std_logic_vector(3 downto 0);
	suma_bani: out natural;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end entity;

architecture arh_suma_introdusa of suma_introdusa is

component div_frec_2
	port(clk_placa, reset: in std_logic;
	clk_div: out std_logic);
end component;	  

component afisare
	port(clk, reset: in std_logic;
	nr_de_afisat: in std_logic_vector(15 downto 0);
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

signal my_clk: std_logic; --clk divizat
signal nr: std_logic_vector(15 downto 0) := (others => '0');
type tip1 is array(0 to 3) of natural;
signal suma: tip1 := (others => 0); --mii, sute, zeci, unitati

begin
	
	divizor_frecventa: div_frec_2 port map(clk_placa => clk, reset => reset, clk_div => my_clk);
	
	process(my_clk, reset)
	begin
		if reset = '1' then
			nr <= (others => '0');
			suma(0) <= 0;  
			suma(1) <= 0;
			suma(2) <= 0;
			suma(3) <= 0;
		elsif my_clk = '1' and my_clk'event then
			if enable = '1' then 
				if sw(0) = '1' then	 --unitati
					if nr(3 downto 0) = "1001" then
						nr(3 downto 0) <= nr(3 downto 0);
						suma(0) <= suma(0);
					else
						nr(3 downto 0) <= nr(3 downto 0)+1;
						suma(0) <= suma(0)+1;
					end if;
				else
					nr(3 downto 0) <= nr(3 downto 0);
					suma(0) <= suma(0);
				end if;
				
				if sw(1) = '1' then	 --zeci
					if nr(7 downto 4) = "1001" then
						nr(7 downto 4) <= nr(7 downto 4);
						suma(1) <= suma(1);
					else
						nr(7 downto 4) <= nr(7 downto 4)+1;
						suma(1) <= suma(1)+10;
					end if;
				else
					nr(7 downto 4) <= nr(7 downto 4);
					suma(1) <= suma(1);
				end if;
			
				if sw(2) = '1' then	 --sute
					if nr(11 downto 8) = "1001" then
						nr(11 downto 8) <= nr(11 downto 8);	
						suma(2) <= suma(2);
					else
						nr(11 downto 8) <= nr(11 downto 8)+1;
						suma(2) <= suma(2)+100;
					end if;
				else
					nr(11 downto 8) <= nr(11 downto 8);
					suma(2) <= suma(2);
				end if;	 
				
				if sw(3) = '1' then	--mii
					if nr(15 downto 12)= "1001" then
						nr(15 downto 12) <= nr(15 downto 12);
						suma(3) <= suma(3);
					else
						nr(15 downto 12) <= nr(15 downto 12)+1;	 
						suma(3) <= suma(3)+1000;
					end if;
				else
					nr(15 downto 12) <= nr(15 downto 12);
					suma(3) <= suma(3);
				end if;	
			else 
				nr <= (others => '0');
				suma(0) <= 0;  
				suma(1) <= 0;
				suma(2) <= 0;
				suma(3) <= 0;
			end if;
		end if;
	end process; 
	
	suma_bani <= suma(0)+suma(1)+suma(2)+suma(3);
	
	C1: afisare port map(clk, reset, nr, catozi, anozi);
end architecture;
