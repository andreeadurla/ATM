--####### MITELU CLAUDIU #######
library IEEE;
use IEEE.std_logic_1164.all;	
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity verificare_sold is
	port(clk: in std_logic;
	enable: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	catozi: out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end entity;

architecture arh_verificare_sold of verificare_sold is

component afisare
	port(clk, reset: in std_logic;
	nr_de_afisat: in std_logic_vector(15 downto 0);
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

--algoritm care transforma un nr din binar in BCD
function to_bcd (bin : std_logic_vector(12 downto 0)) return std_logic_vector is
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
end to_bcd;

	
signal sold: std_logic_vector(15 downto 0);	
signal my_clk: std_logic;	--clk divizat
signal reset: std_logic; -- cand enable este 0 atunci se face reset la afisor

begin 
	
	sold <= to_bcd(date_in_card(4 to 16));	  
	reset <= not enable;
	C2: afisare port map(clk, reset, sold, catozi, anozi); 
	
end architecture;