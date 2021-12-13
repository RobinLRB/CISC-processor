library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


entity REG_FILE is
	Generic (
		N	: integer:=16;
		M : integer:=3
	);
	Port ( 
		Clock 	: in  STD_LOGIC;
  		    Reset 	: in  STD_LOGIC;
		WD 	: in  STD_LOGIC_VECTOR (N-1 downto 0);
		WAddr	: in  STD_LOGIC_VECTOR (M - 1 downto 0);
		Wrt	: in  STD_LOGIC;
		RA 	: in  STD_LOGIC_VECTOR(M-1 downto 0);
		ReadA 	: in STD_LOGIc;
		RB : in STD_LOGIC_VECTOR(M-1 downto 0);
		ReadB : in STD_LOGIC;
		QA,QB : out STD_LOGIC_VECTOR(N-1 downto 0) 
	);
end REG_FILE;
 
architecture Behavioral of REG_FILE is
	type RF_Array is array ((2 ** M) - 1 downto 0) of STD_LOGIC_VECTOR (N - 1 downto 0);
	signal RF : RF_Array;
begin
 
	WITH  ReadA
	 select QA <= RF(conv_integer(RA)) when'1',
	            conv_std_logic_vector(0,n) when others;
	          --    (others=>'0') when others;
	-- QA<= RF (conv_integer(RA)) when (ReadA='1') else conv_std_logic_vector(0,n);            
	
	WITH  ReadB  
	select QB <= RF(conv_integer(RB)) when'1',
	             conv_std_logic_vector(0,n) when others;
	             -- (others=>'0') when others;
	            
	
	process (clock)
	begin
		if rising_edge (clock) then
			if Reset = '1' then
				-- Clear Memory on Reset
				for i in RF'Range loop
					RF(i) <= (others => '0');
				end loop;
			elsif Wrt = '1' then

				RF(conv_integer(WAddr)) <= WD;
				end if;
			end if;
	
	end process;
 
end architecture;