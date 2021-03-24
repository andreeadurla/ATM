library IEEE;
use IEEE.std_logic_1164.all;	
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.tip_nou.all;

entity retragere_banc is 
	port(clk, enable, reset: in std_logic;
	date_in_card: in std_logic_vector(0 to 16);
	sum: in natural; 
	in_bancomat: in tip;
	date_out_card: out std_logic_vector(0 to 16);
	out_bancomat: out tip;
	catozi : out std_logic_vector(6 downto 0);
	anozi: out std_logic_vector(3 downto 0));
end entity;

architecture arh_retragere_banc of retragere_banc is

component div_frec_3
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
function to_bcd (bin : std_logic_vector(5 downto 0)) return std_logic_vector is
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
end to_bcd;

type tip1 is array(0 to 5) of natural;
signal val_banc: tip1 := (5, 10, 20, 50, 100, 200);

signal aux_banc: tip; --nr de bancnote de fiecare tip din bancomat dupa fiecare retragere
signal nr_banc: tip := (others => "000000"); --nr de bancnote de fiecare tip retrase

signal i: natural := 5;	--contor 
signal aux_sum: natural := 0; --folosit pt a calcula suma necesara retragerii bancnotelor
signal ok: std_logic := '0'; -- 1 cand s-a terminat algoritmul de retragere

signal my_clk: std_logic; --clk divizat
signal to_display: std_logic_vector(15 downto 0); 

signal reset_intern: std_logic; -- cand enable este 0 atunci se face reset la divizor si la care_anod
signal suma_cont: natural; 	--suma din cont ca numar natural

begin					
	   
   for2: for i in 0 to 5 generate  
      aux_banc(i) <= in_bancomat(i)- nr_banc(i); --nr bancnote dupa retragere
   end generate for2;
   
   out_bancomat <= aux_banc; --nr bancnote dupa retragere 
   
   suma_cont <= to_integer(unsigned(date_in_card(4 to 16)));
   date_out_card(0 to 3) <= date_in_card(0 to 3);
   date_out_card(4 to 16) <= date_in_card(4 to 16)-std_logic_vector(to_unsigned(aux_sum, 13)); --noul sold
   
   --algoritm retragere bani
   process(clk, reset)
   begin 
	   if reset = '1' then
		   nr_banc <= (others => "000000");
		   aux_sum <= 0;
		   ok <= '0';
		   i <= 5; 
	   else
		   if clk = '1' and clk'event then
			   if enable = '1' then 
				   if suma_cont >= sum and sum < 1001 then
					   if sum > aux_sum then
						   if sum >= val_banc(i)+aux_sum then
							   if aux_banc(i) > 0 then
								   aux_sum <= aux_sum+val_banc(i);
								   nr_banc(i) <= nr_banc(i)+1;
							   else
								   if i > 0 then  --daca contorul ajunge sa fie mai mic sau egal cu 0, atunci inseamna ca 
									   i <= i-1;  --nu avem destule bancnote in bancomat si retragem doar cate bancnote avem, ori
								  else			  --suma introdusa nu este multiplu de 5( daca utilizatorul introduce 344, retragem 340).
									  ok <= '1';
								  end if;
							   end if;
							else
								  if i > 0 then
								   	  i <= i-1;
								  else
									  ok <= '1';
								  end if;
							end if;
						else
							aux_sum <= aux_sum;
							ok <= '1'; 	
						end if;
					else
						aux_sum <= 0;	
						ok <= '0';
					end if;
				else
					aux_sum <= 0;
					ok <= '0';
					i <= 5;
				end if;
			end if;	
		end if;
   end process;
   
   --afisare bancnote 
   reset_intern <= reset or (not enable);
   divizor_frec1: div_frec_3 port map(clk, reset_intern, my_clk); 
   
   process(my_clk, ok)
   variable contor: std_logic_vector(3 downto 0) := "0001";
   variable cont: natural := 0;	--contor
   begin 
	   if reset = '1' then
		   contor := "0001";
		   cont := 0;
		   to_display <= x"ffff";
	else
	   if my_clk = '1' and my_clk'event then
			   if ok = '1' then
				   to_display(7 downto 0) <= to_bcd(nr_banc(cont));
				   to_display(11 downto 8) <= "1010"; --"-"  
				   to_display(15 downto 12) <= contor;   
				   if cont = 5 then
					   cont := 0; 
					   contor := "0001";
				   else
				   	   cont := cont+1; 
					   contor := contor+1;
				   end if;
				else
					contor := "0001";
					cont := 0;
				    to_display <= x"aaaa";
				end if;
		end if;
		end if;
	 end process;
	
	 C1: afisare port map(clk, reset_intern, to_display, catozi, anozi); 
    
end architecture;
