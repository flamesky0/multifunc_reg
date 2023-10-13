--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:41:06 09/20/2023
-- Design Name:   
-- Module Name:   /home/local_admin/Xilinx/14.7/ISE_DS/my_multifunc_register/tb.vhd
-- Project Name:  my_multifunc_register
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: main
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb IS
END tb;
 
ARCHITECTURE behavior OF tb IS 
 	type ports_t is record
		X : std_logic_vector(3 downto 0);
		Z : std_logic_vector(3 downto 0);
		Y : std_logic_vector(2 downto 0);
		rb : std_logic_vector (2 downto 0);
		EN : std_logic;
	end record ports_t;
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT main
    PORT(
         X : IN  std_logic_vector(3 downto 0);
         Z : IN  std_logic_vector(3 downto 0);
         Y : IN  std_logic_vector(2 downto 0);
			rb : in std_logic_vector (2 downto 0);
         EN : IN  std_logic;
         C : IN  std_logic;
         CLR : IN  std_logic;
         Q : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs

	
	signal C : std_logic := '0';
	signal EN : std_logic := '0';
	signal CLR : std_logic := '0';
	signal ports : ports_t := ("0000", "0000", "000", "000", '0');
 	--Outputs
   signal Q : std_logic_vector(3 downto 0);
		
   constant C_period : time := 10 ns;
	

	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: main PORT MAP (
          X => ports.X,
          Z => ports.Z,
          Y => ports.Y,
			 rb => ports.rb,
          EN => ports.EN,
          C => C,
          CLR => CLR,
          Q => Q
        );

   -- Clock process definitions
   C_process : process
   begin
		C <= '0';
		wait for C_period/2;
		C <= '1';
		wait for C_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		CLR <= '1';
      wait for C_period;	
		CLR <= '0';
      wait for C_period;
      -- insert stimulus here
		--			(	X			Z		 Y		 rb	 EN) -- template
		
		-- checking the "000" microoperation (Load X)
		ports <= ("1010", "0100", "000", "000", '1'); -- test 1
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("0101", "0111", "000", "000", '1'); -- test 2
		wait for C_period;
		assert Q = "0101" report "Assertion violation";
		
		ports <= ("1010", "1101", "000", "000", '1'); --test 3
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("1111", "0101", "000", "000", '0'); -- checking with EN = '0'
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		
		
		-- checking the "001" microoperation (managable logic shift right (X2&Z2)
		-- it's not possible to check MSB in Q according to task's 5th clause
		--			(	X			Z		 Y		 rb	 EN) -- template
		ports <= ("0001", "0111", "001", "100", '1'); --shift right 1 bit
		wait for C_period;
		assert Q = "0101" report "Assertion violation";
		
		ports <= ("0100", "0011", "001", "010", '1'); --shift right 2 bits
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("0101", "0111", "000", "000", '1'); -- load
		wait for C_period;
		assert Q = "0101" report "Assertion violation";
		
		ports <= ("0000", "0011", "001", "011", '1'); --shift right 0 bits
		wait for C_period;
		assert Q = "0101" report "Assertion violation";
		
		ports <= ("0000", "0111", "001", "001", '1'); --shift right 1 bit
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("1111", "0101", "010", "000", '0'); -- nothing (checking EN=0)
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("0100", "0111", "001", "100", '1'); --shift right 3 bits
		wait for C_period;
		assert Q = "1000" report "Assertion violation";
		
		
		
		-- checking the "010" microoperation (arithmetic shift left)
		--			(	X			Z		 Y		 rb	 EN) -- template
		ports <= ("1010", "0100", "000", "000", '1'); -- load
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("1111", "0101", "010", "100", '1'); -- test 1
		wait for C_period;
		assert Q = "1100" report "Assertion violation";
		
		ports <= ("1111", "0101", "010", "010", '0'); -- EN=0
		wait for C_period;
		assert Q = "1100" report "Assertion violation";
		
		ports <= ("1111", "0101", "010", "001", '1'); -- shift left 1 bit
		wait for C_period;
		assert Q = "1000" report "Assertion violation";
		
		ports <= ("1111", "0101", "010", "100", '1'); -- shift left 1 bit
		wait for C_period;
		assert Q = "1000" report "Assertion violation";
		
		
		
		-- checking the "011" microperation (masking Q by Z)
		--			(	X			Z		 Y		 rb	 EN) -- template
		ports <= ("1111", "0100", "000", "000", '1'); -- load
		wait for C_period;
		assert Q = "1111" report "Assertion violation";
		
		ports <= ("0000", "0000", "011", "000", '0'); --  EN = 0
		wait for C_period;
		assert Q = "1111" report "Assertion violation";
		
		ports <= ("0000", "1111", "011", "000", '1'); --  Z = 1111
		wait for C_period;
		assert Q = "1111" report "Assertion violation";
		
		ports <= ("0000", "0000", "011", "000", '1'); -- mask by Z
		wait for C_period;
		assert Q = "0000" report "Assertion violation";
		
		
		--checking the "100" microperation (invert Q(3))
		--			(	X			Z		 Y		 rb	 EN) -- template
		ports <= ("1111", "0100", "000", "000", '1'); -- load
		wait for C_period;
		assert Q = "1111" report "Assertion violation";
		
		ports <= ("0111", "1111", "100", "000", '1'); -- test 1
		wait for C_period;
		assert Q = "0111" report "Assertion violation";
		
		ports <= ("0111", "1111", "100", "000", '0'); -- EN = 0
		wait for C_period;
		assert Q = "0111" report "Assertion violation";
		
		ports <= ("0110", "1011", "100", "000", '1'); -- test 2,
		wait for C_period;
		assert Q = "1111" report "Assertion violation";
		
		
		--checking the "101" microoperation (X xor Z)
		--			(	X			Z		 Y		 rb	 EN) -- template
		ports <= ("1111", "1010", "101", "000", '1'); -- test 1
		wait for C_period;
		assert Q = "0101" report "Assertion violation";
		
		ports <= ("0101", "1111", "101", "000", '1'); -- test 2
		wait for C_period;
		assert Q = "1010" report "Assertion violation";
		
		ports <= ("1111", "1010", "101", "000", '1'); -- test 3
		wait for C_period;
		assert Q = "0101" report "Assertion violation";
		
		--checking the "110" and "111" microoperation (sum)
		--			(	X			Z		 Y		 rb	 EN) -- template
		ports <= ("1111", "0100", "000", "000", '1'); -- load
		wait for C_period;
		assert Q = "1111" report "Assertion violation";
		
		ports <= ("0000", "1111", "110", "000", '1'); -- test 1:  0 + 0 = (0000)
		wait for C_period;
		assert Q = "0000" report "Assertion violation";
		
		ports <= ("0001", "0000", "111", "000", '1'); -- test 2: 1 + 8 = (1001)
		wait for C_period;
		assert Q = "1001" report "Assertion violation";
		
		ports <= ("0011", "0011", "111", "000", '1'); -- test 3: 2 + 4 = (0110)
		wait for C_period;
		assert Q = "0110" report "Assertion violation";
		
		CLR <= '1';
		wait for C_period;
		assert Q = "0000" report "Assertion violation";
		
		CLR <= '0';
      wait;
   end process;
END;
