--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.std_logic_1164.all;	
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.tip_nou.all;

entity depunere is
	port(clk, enable, enter, reset: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	sw: in std_logic_vector(5 downto 0);
	in_bancomat: in tip;
	date_out_card: out std_logic_vector(0 to 16);
	out_bancomat: out tip;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end entity;

architecture arh_depunere of depunere is   

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

--algoritm care transforma un nr din binar in BCD
function to_bcd1 (bin : std_logic_vector(5 downto 0)) return std_logic_vector is
	variable i : integer:=0;
	variable bcd : std_logic_vector(7 downto 0) := (others => '0');
	variable bint : std_logic_vector(5 downto 0) := bin;

	begin
	for i in 0 to 5 loop  --repetam de 6 ori
	bcd(7 downto 1) := bcd(6 downto 0);  --shiftam bitii
	bcd(0) := bint(5);
	bint(5 downto 1) := bint(4 downto 0);
	bint(0) :='0';
	
	if(i < 5 and bcd(3 downto 0) > "0100") then --adunam 3 daca cifra in BCD este mai mare decat 4
	bcd(3 downto 0) := bcd(3 downto 0) + "0011";
	end if;
	
	if(i < 5 and bcd(7 downto 4) > "0100") then --adunam 3 daca cifra in BCD este mai mare decat 4
	bcd(7 downto 4) := bcd(7 downto 4) + "0011";
	end if;
	
	end loop;
	return bcd;
end to_bcd1;

function to_bcd2 (bin : std_logic_vector(12 downto 0)) return std_logic_vector is
	variable i : integer:=0;
	variable bcd : std_logic_vector(15 downto 0) := (others => '0');
	variable bint : std_logic_vector(12 downto 0) := bin;

	begin
	for i in 0 to 12 loop  --repetam de 13 ori
	bcd(15 downto 1) := bcd(14 downto 0);  --shiftam bitii
	bcd(0) := bint(12);
	bint(12 downto 1) := bint(11 downto 0);
	bint(0) :='0';
	
	
	if(i < 12 and bcd(3 downto 0) > "0100") then --adunam 3 daca cifra in BCD este mai mare decat 4
	bcd(3 downto 0) := bcd(3 downto 0) + "0011";
	end if;
	
	if(i < 12 and bcd(7 downto 4) > "0100") then --adunam 3 daca cifra in BCD este mai mare decat 4
	bcd(7 downto 4) := bcd(7 downto 4) + "0011";
	end if;
	
	if(i < 12 and bcd(11 downto 8) > "0100") then  --adunam 3 daca cifra in BCD este mai mare decat 4
	bcd(11 downto 8) := bcd(11 downto 8) + "0011";
	end if;	 
	
	if(i < 12 and bcd(15 downto 12) > "0100") then  --adunam 3 daca cifra in BCD este mai mare decat 4
	bcd(15 downto 12) := bcd(15 downto 12) + "0011";
	end if;
	
	end loop;
	return bcd;
end to_bcd2;

signal nr: tip := ("000000", "000000", "000000", "000000", "000000", "000000");
--nr(0) -> bancnote de 5;
--nr(1) -> bancnote de 10;...

signal suma_depusa: std_logic_vector(0 to 12) := (others => '0'); 
signal my_clk: std_logic;  --clk divizat

signal to_display: std_logic_vector(15 downto 0); --nr de bancnote afisat in BCD
signal reset_int: std_logic;

begin
		
	reset_int <= reset or (not enable);
	div_frecventa2: div_frec_2 port map(clk_placa => clk, reset => reset_int, clk_div => my_clk);
	
	process(my_clk, reset)
	variable aux_sum: std_logic_vector(0 to 12) := (others => '0');
	begin
		if reset = '1' then
			suma_depusa <= (others => '0');
			aux_sum := (others => '0');
			nr <= (others => "000000");	
			to_display <= (others => '0');
		else
			if my_clk = '1' and my_clk'event then
				if enable = '1' then
					if enter = '0' then 
						if sw(0) = '1' then
							nr(0) <= nr(0)+1;
							to_display(7 downto 0) <= to_bcd1(nr(0))+1; --nr de bancnote de 5 euro in bcd
							aux_sum := aux_sum+ "0000000000101";--5
							to_display(11 downto 8)	<= "1010"; --"-"
							to_display(15 downto 12) <= "0001";
						elsif sw(1) = '1' then
							nr(1) <= nr(1)+1; 
							to_display(7 downto 0) <= to_bcd1(nr(1))+1; --nr de bancnote de 10 euro in bcd
							aux_sum := aux_sum+ "0000000001010";--10 
							to_display(11 downto 8)	<= "1010"; --"-"
							to_display(15 downto 12) <= "0010";
						elsif sw(2) = '1' then
							nr(2) <= nr(2)+1;
							to_display(7 downto 0) <= to_bcd1(nr(2))+1; --nr de bancnote de 10 euro in bcd
							aux_sum := aux_sum+ "0000000010100";--20
							to_display(11 downto 8)	<= "1010"; --"-"
							to_display(15 downto 12) <= "0011";
						elsif sw(3) = '1' then
							nr(3) <= nr(3)+1;
							to_display(7 downto 0) <= to_bcd1(nr(3))+1; --nr de bancnote de 50 euro in bcd
							aux_sum := aux_sum+ "0000000110010";--50
							to_display(11 downto 8)	<= "1010"; --"-"
							to_display(15 downto 12) <= "0100";
						elsif sw(4) = '1' then
							nr(4) <= nr(4)+1; 
							to_display(7 downto 0) <= to_bcd1(nr(4))+1; --nr de bancnote de 100 euro in bcd
							aux_sum := aux_sum+ "0000001100100";--100
							to_display(11 downto 8)	<= "1010"; --"-"
							to_display(15 downto 12) <= "0101";
						elsif sw(5) = '1' then
							nr(5) <= nr(5)+1; 
							to_display(7 downto 0) <= to_bcd1(nr(5))+1; --nr de bancnote de 200 euro in bcd
							aux_sum := aux_sum+ "0000011001000";--200
							to_display(11 downto 8)	<= "1010"; --"-"
							to_display(15 downto 12) <= "0110";
						else
							aux_sum := aux_sum;
							nr <= nr;
							to_display <= to_bcd2(suma_depusa);
						end if;
					else  
						to_display <= to_bcd2(suma_depusa);
						nr <= (others => "000000");
					end if;	
				suma_depusa <= aux_sum;
				else
					suma_depusa <= (others => '0');
					nr <= (others => "000000");
					to_display <= (others => '1'); 
					aux_sum := (others => '0');
				end if;
			end if;	
		end if;
	end process;
	
	C2: afisare port map(clk, reset_int, to_display, catozi, anozi);
	
	date_out_card(0 to 3) <= date_in_card(0 to 3);
	date_out_card(4 to 16) <= date_in_card(4 to 16)+suma_depusa; --noul sold
	
   for1: for k in 0 to 5 generate  
      out_bancomat(k) <= nr(k)+ in_bancomat(k);	--nr bancnote dupa depunere
   end generate for1;
	
end architecture;	
	