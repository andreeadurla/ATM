--####### DURLA ANDREEA #######
library IEEE;
use IEEE.std_logic_1164.all;

package tip_nou is
type tip is array(0 to 5) of std_logic_vector(5 downto 0);
end package tip_nou;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all; 
use work.tip_nou.all;

entity bancomat is
	port(clk: in std_logic;	
	card_in: in std_logic;  
	sw: in std_logic_vector(5 downto 0);
	enter, reset, continuare, anulare: in std_logic;
	led_card_in, led_corect, led_gresit, led_asteptare, led_optiune, led_chitanta: out std_logic;
	led_depunere, led_retragere, led_sold, led_schimbare_pin: out std_logic;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end bancomat;

architecture arh_bancomat of bancomat is

component depunere
	port(clk, enable, enter, reset: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	sw: in std_logic_vector(5 downto 0);
	in_bancomat: in tip;
	date_out_card: out std_logic_vector(0 to 16);
	out_bancomat: out tip;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

component retragere
	port(clk, enable, enter, reset:in std_logic;
	date_in_card: in std_logic_vector(0 to 16); 
	in_bancomat: in tip;
	sw: in std_logic_vector (4 downto 0); 
	date_out_card: out std_logic_vector(0 to 16);
	out_bancomat: out tip;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

component verificare_sold
	port(clk: in std_logic;
	enable: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	catozi: out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end component;

component schimbare_pin
	port(clk, enable, enter: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	sw: in std_logic_vector(3 downto 0);
	date_out_card: out std_logic_vector(0 to 16));
end component;

component div_frec_3
	port(clk_placa, reset: in std_logic;
	clk_div: out std_logic);
end component; 

component RAM_card
	port(clk: in std_logic;
	ADR: in std_logic_vector(1 downto 0); --ADR = id-ul cardului
	CS: in std_logic;		
	WR: in std_logic;
	D_IN: in std_logic_vector(0 to 16);	--primii 4 biti pentru pin, urmatorii 16 pentru suma
	D_OUT: out std_logic_vector(0 to 16));   --primii 4 biti pentru pin, urmatorii 16 pentru suma
end component;

component RAM_bancomat
	port(clk: in std_logic;
	ADR: in std_logic_vector(2 downto 0); 
	CS: in std_logic;		
	WR: in std_logic;
	D_IN: in std_logic_vector(5 downto 0);
	D_OUT: out std_logic_vector(5 downto 0));  
end component;

signal stari: std_logic_vector(3 downto 0) := "0000";
signal id_card: std_logic_vector(1 downto 0);

signal enable_pin, enable_depunere, enable_retragere, enable_verif_sold, enable_schimbare_pin: std_logic := '0';
signal pin_corect, pin_gresit, stop: std_logic := '0';

signal catozi_dep, catozi_ret, catozi_verif_sold: std_logic_vector(6 downto 0);
signal anozi_dep, anozi_ret, anozi_verif_sold: std_logic_vector(3 downto 0); 

signal reset_initial, reset_op: std_logic;

signal my_clk: std_logic;

signal date_in_card, date_out_card, date_in_dep, date_in_ret, date_in_pin: std_logic_vector(0 to 16); 
signal date_in_banc, date_out_banc, date_in_banc_dep, date_in_banc_ret: tip;
--date_in_... -> ceea ce se introduce in memorie, noua valoare
--date_out_... -> ceea ce se citeste din memorie

type tip1 is array(0 to 5) of std_logic_vector(2 downto 0);
signal adresa: tip1 := ("000", "001", "010", "011", "100", "101"); --adresele bancnotelor din bancomat

signal pin: std_logic_vector(3 downto 0); --pin-ul introdus
signal nr: natural; --nr de incercari ale pin-ului
signal enable: std_logic; --folosit pt a putea citii/scrie din/in memorie

begin
	
	divizor_frec: div_frec_3 port map(clk, '0', my_clk);
	
	process(my_clk, anulare)
	begin
		if anulare = '1' then --anuleaza toate operatiunile
			stari <= "0000";
		else
			if my_clk = '1' and my_clk'event then
				if stari = "0000" then	 --starea de resetare
					enable_pin <= '0';
					enable_depunere <= '0';
					enable_retragere <= '0';
					enable_verif_sold <= '0';
					enable_schimbare_pin <= '0';
					led_card_in <= '0';
					led_corect <= '0';
					led_gresit <= '0';
					led_asteptare <= '0';
					led_optiune <= '0';
					led_chitanta <= '0'; 
					led_depunere <= '0';
					led_retragere <= '0';
					led_sold <= '0';
					led_schimbare_pin <= '0';
					nr <= 0;
					reset_initial <= '1';
			  	    stari <= "0001";
				
				elsif stari = "0001" then  --citire card
					if card_in = '1' then 
						reset_initial <= '0';
						id_card <= sw(1 downto 0);
						led_card_in <= '1';
						stari <= "0010";
					else
						stari <= "0001";	
					end if;	
					
				elsif stari = "0010" then  --verificare pin
					enable_pin <= '1';
						if enter = '1' then
							if pin = date_out_card(0 to 3) then
								led_corect <= '1';
								led_gresit <= '0';
								led_asteptare <= '0';
								stari <= "0011";
							else
								if nr = 2 then 	 --daca pin-ul a fost introdus gresit de 3 ori, cardul este eliminat
									led_gresit <= '1';
									led_asteptare <= '0';
									stari <= "0000";
									nr <= 0;
								else
									nr <= nr+1;
									stari <= "0010";
									led_gresit <= '1';
									led_asteptare <= '0';
								end if;
							end if;
						else 
							led_gresit <= '0';
							led_asteptare <= '1';
							stari <= "0010";
							nr <= nr;
						end if;

					
				elsif stari = "0011" then --meniu 
					enable_pin <= '0';
					enable_depunere <= '0';
					enable_retragere <= '0';
					enable_verif_sold <= '0';
					enable_schimbare_pin <= '0';
					
					led_corect <= '0';
					led_optiune <= '1';
					
					if sw(0) = '1' then
						led_depunere <= '1';
						stari <= "0100";
						
					elsif sw(1) = '1' then
						led_retragere <= '1';
						stari <= "0101";
						
					elsif sw(2) = '1' then
						led_sold <= '1';
						stari <= "0110";
						
					elsif sw(3) = '1' then
						led_schimbare_pin <= '1';
						stari <= "0111";
						
					else
						stari <= "0011";
					end if;	
					
				elsif stari = "0100" then	--depunere
					enable_depunere <= '1';
					led_optiune <= '0';
					if continuare = '1' then
						led_corect <= '1';
						led_depunere <= '0';  
						stari <= "1000";
					else
						stari <= "0100";
					end if;
					
				elsif stari = "0101" then  --retragere
					enable_retragere <= '1';
					led_optiune <= '0';
					if continuare = '1' then
						led_corect <= '1';
						led_retragere <= '0';
						stari <= "1000";
					else
						stari <= "0101";
					end if;	
					
				elsif stari = "0110" then  --verificare sold
					enable_verif_sold <= '1';
					led_optiune <= '0';
					 if continuare = '1' then
						led_corect <= '1';
						led_sold <= '0';
						stari <= "1000";
					else
						stari <= "0110";
					end if;
					 
				elsif stari = "0111" then  --schimbare pin 
					enable_schimbare_pin <= '1';
					led_optiune <= '0';
					if continuare = '1' then
						led_corect <= '1';
						led_schimbare_pin <= '0';
						stari <= "1000";
					else
						stari <= "0111";
					end if;
								
				elsif stari = "1000" then --chitanta
					led_corect <= '0';
					led_optiune <= '0';
					enable_depunere <= '0';
					enable_retragere <= '0';
					enable_verif_sold <= '0';
					enable_schimbare_pin <= '0';

					if enter = '1' then
						if sw(0) = '1' then	 --dorim chitanta
							led_chitanta <= '1';
						else
							led_chitanta <= '0'; --nu dorim chitanta
						end if;
						led_asteptare <= '0';
						stari <= "1001";
					else
						led_asteptare <= '1';
						stari <= "1000";
					end if;	 
					
				elsif stari = "1001" then 
					led_chitanta <= '0';
					if enter = '1' then
						if sw(0) = '0' then --eliminam cardul
							led_card_in <= '0';
							stari <= "0000";
						else
							stari <= "0011"; --alta operatiune
						end if;
						led_asteptare <= '0';
					else
						led_asteptare <= '1';
						stari <= "1001";
					end if;	 
				end if;	
			end if;
		end if;
	end process;
	
	process(clk)
	begin
		if clk = '1' and clk'event then	 
			if stari = "0010" then	 --verificare pin
				pin <= sw(3 downto 0);
				date_in_card <= date_out_card;	--valorile din memorie raman aceleasi
				date_in_banc <= date_out_banc; --valorile din memorie raman aceleasi
				
			elsif stari = "0100" then --depunere
				catozi <= catozi_dep;
				anozi <= anozi_dep;
				date_in_card <= date_in_dep; --se schimba suma din memoria cardului
				date_in_banc <= date_in_banc_dep; --se schimba nr de bancnote din memoria bancomatului
				
			elsif stari = "0101" then  --retragere
				  catozi <= catozi_ret;
				  anozi <= anozi_ret;
				  date_in_card <= date_in_ret; --se schimba suma din memoria cardului
				  date_in_banc <= date_in_banc_ret;	--se schimba nr de bancnote din memoria bancomatului
				  
			elsif stari = "0110" then 	--verificare sold
				   catozi <= catozi_verif_sold;
				   anozi <= anozi_verif_sold;
				   date_in_card <= date_out_card; --valorile din memorie raman aceleasi
				   date_in_banc <= date_out_banc; --valorile din memorie raman aceleasi
				   
			elsif stari = "0111" then --schimbare pin
				date_in_card <= date_in_pin;  --se schimba pin-ul din memoria cardului
				date_in_banc <= date_out_banc; --nr de bancnote din memoria bancomatului ramane acelasi
				
			else
				catozi <= "1111111";
				anozi <= "1111";  
			end if;
		end if;
	end process;
	
	reset_op <= reset or reset_initial;
	C1: depunere port map(clk, enable_depunere, enter, reset_op, date_out_card, sw, date_out_banc, date_in_dep, date_in_banc_dep, catozi_dep, anozi_dep);
	C2: retragere port map(clk, enable_retragere, enter, reset_op, date_out_card, date_out_banc, sw(4 downto 0), date_in_ret, date_in_banc_ret, catozi_ret, anozi_ret);
	C3: verificare_sold port map(clk, enable_verif_sold, date_out_card, catozi_verif_sold, anozi_verif_sold);
	C4: schimbare_pin port map(clk, enable_schimbare_pin, enter, date_out_card, sw(3 downto 0), date_in_pin);
	
	--cand enter = '1' scriem in memorie
	enable <= enable_pin or enable_depunere or enable_retragere or enable_verif_sold or enable_schimbare_pin;
	C5: RAM_card port map(clk, id_card, enable, enter, date_in_card, date_out_card); --memoria cardului
	
	for1: for i in 0 to 5 generate  
      C6: RAM_bancomat port map(clk, adresa(i), enable, enter, date_in_banc(i), date_out_banc(i)); --memoria bancomatului  
   end generate for1;
end architecture;