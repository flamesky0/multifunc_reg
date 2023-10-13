---------------------------------------------------------------------------------
-- Company: MEPhI
-- Engineer:  Mikhail Ivashinenko
-- 
-- Create Date:    10:22:23 09/20/2023 
-- Design Name: 
-- Module Name:    main - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
entity ks is
	port( X : in STD_LOGIC_VECTOR (3 downto 0);
			Z : in STD_LOGIC_VECTOR (3 downto 0);
			Q : out STD_LOGIC_VECTOR (3 downto 0)
			);
end ks;

architecture Behavioral of ks is
	signal a : integer;
	signal b : integer;
begin
	with X select
		a <=  0 when "0000",
				1 when "0001"|"0010"|"0100"|"0101"|"1000"|"1001"|"1010"|"1011",
				2 when "0011"|"0110"|"1100"|"1101",
				3 when "0111"|"1110",
				4 when "1111";
	with Z select
		b <=  0 when "1111",
				2 when "0010"|"0101"|"0110"|"0111"|"1010"|"1011"|"1101"|"1110",
				4 when "0011"|"0100"|"1001"|"1100",
				6 when "0001"|"1000",
				8 when "0000";
	Q <= std_logic_vector(to_unsigned(a+b, 4));
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity sh_r is
	port( input : in std_logic_vector (3 downto 0);
			rb : in std_logic_vector (2 downto 0);
			x2 : in std_logic;
			z2 : in std_logic;
			output : out std_logic_vector (3 downto 0)
			);
end sh_r;

architecture Behavioral of sh_r is
	signal num : std_logic_vector(1 downto 0);
begin
	num <= x2&z2;
	with num select
		output <=	input when "00",
						rb(0)&input(3 downto 1) when "01",
						rb(1 downto 0)&input(2 downto 1) when "10",
						rb (2 downto 0)&input(2) when "11";
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sh_l is
	port( input : in std_logic_vector (3 downto 0);
			output : out std_logic_vector (3 downto 0)
			);
end sh_l;

architecture Behavioral of sh_l is
begin
	output(3) <= input(3);
	output(2) <= input(1);
	output(1) <= input(0);
	output(0) <= '0';
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity main is
    Port ( X : in  STD_LOGIC_VECTOR (3 downto 0);
           Z : in  STD_LOGIC_VECTOR (3 downto 0);
           Y : in  STD_LOGIC_VECTOR (2 downto 0);
			  rb : in std_logic_vector (2 downto 0);
           EN : in  STD_LOGIC;
           C : in  STD_LOGIC;
           CLR : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (3 downto 0));
end main;

architecture Behavioral of main is
	component ks
		port( X : in STD_LOGIC_VECTOR (3 downto 0);
			Z : in STD_LOGIC_VECTOR (3 downto 0);
			Q : out STD_LOGIC_VECTOR (3 downto 0)
			);
	end component;
	
	component sh_l
		port (input : in std_logic_vector (3 downto 0);
				output : out std_logic_vector (3 downto 0)
				);
	end component;
	
	component sh_r
		port (input : in std_logic_vector (3 downto 0);
				rb : in std_logic_vector (2 downto 0);
				x2 : in std_logic;
				z2 : in std_logic;
				output : out std_logic_vector (3 downto 0)
				);
	end component;
	
	signal Qb : STD_LOGIC_VECTOR (3 downto 0);
	signal Qks : STD_LOGIC_VECTOR (3 downto 0);
	signal Qsh_l : std_logic_vector (3 downto 0);
	signal Qsh_r : std_logic_vector (3 downto 0);

begin
	ks1: ks port map(X => X, Z => Z, Q => Qks);
	sh_l1: sh_l port map(input => Qb, output => Qsh_l);
	sh_r1: sh_r port map(input => Qb, rb => rb, x2 => x(2), z2 => z(2), output => Qsh_r);
	
	process(C, CLR) is
	begin
		if (CLR = '1') then
			Qb <= "0000";
		elsif rising_edge(C) and EN = '1' then
			case Y is
				when "000" => Qb <= X;
				when "001" => Qb <= Qsh_r;
				when "010" => Qb <= Qsh_l;
				when "011" => Qb <= Qb and Z;
				when "100" => Qb(3) <= not Qb(3);
				when "101" => Qb <= X xor Z;
				when "110"|"111" => Qb <= Qks;
				when others => Qb <= "ZZZZ";
			end case;
		end if;
	end process;
	Q <= Qb;
end Behavioral;