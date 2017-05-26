----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:15:22 05/15/2017 
-- Design Name: 
-- Module Name:    ctlalea - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ctlalea is
    Port ( CLK : in STD_LOGIC;
			  lidiOPin : in  STD_LOGIC_VECTOR (7 downto 0);
           lidiBin : in  STD_LOGIC_VECTOR (15 downto 0);
           lidiCin : in  STD_LOGIC_VECTOR (15 downto 0);
           diexOPin : in  STD_LOGIC_VECTOR (7 downto 0);
           diexAin : in  STD_LOGIC_VECTOR (15 downto 0);
			  diexBin : in  STD_LOGIC_VECTOR (15 downto 0);
           exmemOPin : in  STD_LOGIC_VECTOR (7 downto 0);
           exmemAin : in  STD_LOGIC_VECTOR (15 downto 0);
           memreOPin : in  STD_LOGIC_VECTOR (7 downto 0);
           memreAin : in  STD_LOGIC_VECTOR (15 downto 0);
           ipENout : out  STD_LOGIC;
			  ipLOADout : out  STD_LOGIC;
			  ipDINout : out  STD_LOGIC_VECTOR (15 downto 0);
           lidiNOPout : out  STD_LOGIC);
end ctlalea;

architecture Behavioral of ctlalea is
	signal lire : STD_LOGIC :='0';
	signal ecrire_diex : STD_LOGIC :='0';
	signal ecrire_exmem: STD_LOGIC :='0';
	signal ecrire_memre : STD_LOGIC :='0';
	signal alea : STD_LOGIC_VECTOR (1 downto 0) := "00";
	signal change : STD_LOGIC :='0';
	signal prevalea : STD_LOGIC_VECTOR (1 downto 0) := "00";
	signal salea : STD_LOGIC_VECTOR (1 downto 0) := "00";
	signal jump : STD_LOGIC := '0';
	signal sjump : STD_LOGIC := '0';
	signal NOPcounter: STD_LOGIC := '0';
begin

lire <= '1' when ((lidiOPin = x"01") or (lidiOPin = x"02") or (lidiOPin = x"03") or (lidiOPin = x"04")
						or (lidiOPin = x"05") or (lidiOPin = x"07") or (lidiOPin = x"08") 
						or (lidiOPin = x"0F") or (lidiOPin = x"10"))
		  else '0';

ecrire_diex <= '1' when ((diexOPin = x"01") or (diexOPin = x"02") or (diexOPin = x"03") or (diexOPin = x"04")
						or (diexOPin = x"05") or (diexOPin = x"06") or (diexOPin = x"07"))
					else '0';

ecrire_exmem <= '1' when ((exmemOPin = x"01") or (exmemOPin = x"02") or (exmemOPin = x"03") or (exmemOPin = x"04")
						or (exmemOPin = x"05") or (exmemOPin = x"06") or (exmemOPin = x"07"))
					else '0';

ecrire_memre <= '1' when ((memreOPin = x"01") or (memreOPin = x"02") or (memreOPin = x"03") or (memreOPin = x"04")
						or (memreOPin = x"05") or (memreOPin = x"06") or (memreOPin = x"07"))
					else '0';

jump <= '1' when ((diexOPin = x"0E") 
				or (diexOPin = x"0F" and diexBin = x"0000" and CLK='0')
				or (diexOPin = x"10" and CLK='0'))
			else '0';
					
alea <= "11" when( (lire = '1') and (ecrire_diex = '1') and ((lidiBin = diexAin) or (lidiCin = diexAin))) else
		"10" when( (lire = '1') and (ecrire_exmem = '1') and ((lidiBin = exmemAin) or (lidiCin = exmemAin))) else
		"01" when(( (lire = '1') and (ecrire_memre = '1') and ((lidiBin = memreAin) or (lidiCin = memreAin))) or ( jump = '1'))else
		"00";

ch: process (alea, CLK) is
begin
	if ((alea /= prevalea) and (alea /="00")) then
		change <= '1';
	else
		change <= '0';
	end if;
	prevalea <= alea;
end process;

ipDINout  <= diexAin;

ctl: process (change, CLK) is
begin
  if (change'event and change = '1') then
		if (not (alea="00")) then
			salea <= alea;
			sjump <= jump;
			if (jump = '1') then
				ipLOADout <= '1';
			else
				ipLOADout <= '0';
			end if;
		end if;
  end if;
  
  if (CLK'event and CLK = '1') then 
		if (salea = "00") then
			ipLOADout <= '0';
			ipENout <= '0';
			if (NOPcounter /= '1') then
				lidiNOPout <= '0';
			end if;
			NOPcounter <= '0';
		else
			if (sjump = '1') then
				ipLOADout <= '1';
			else
				ipENout <= '1';
				ipLOADout <= '0';
			end if;
			lidiNOPout <= '1';
			salea <=  salea - "01";
			NOPcounter <= '1';
		end if;
  elsif falling_edge(CLK) then
		-- front descendant
		ipLOADout <= '0';
		if ((sjump = '1') and (NOPcounter = '0')) then
			lidiNOPout <= '0';
		end if;
  end if;
  
end process;
end Behavioral;
