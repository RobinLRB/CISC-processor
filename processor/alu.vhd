library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;


ENTITY ALU_NEW1 IS 
GENERIC(N:integer:=16);
PORT( OP: IN std_logic_vector(2 downto 0);
      A,B: IN std_logic_vector(15 downto 0);
      reset,EN,clk: IN std_logic;
      Y,ADDRESS,OUTPUT: OUT std_logic_vector(15 downto 0);
      Z_FLAG,N_FLAG,O_FLAG: OUT std_logic);
END ALU_NEW1;

ARCHITECTURE BEHAVIORAL OF ALU_NEW1 IS
--SIGNAL reset,EN:  std_logic;  
--SIGNAL CLK: STD_LOGIC:='0';
--SIGNAL OP:  std_logic_vector(2 downto 0);  
--SIGNAL A,B: std_logic_vector(15 downto 0);  
SIGNAL C,X: std_logic_vector(15 downto 0); 
SIGNAL O_ADD,O_S: std_logic;
BEGIN
  PROCESS(A,B,OP,C,reset,clk,EN)
    BEGIN
    IF (reset='1') THEN
     C <= (OTHERS =>'0');
     X <= (OTHERS =>'0');
     ELSIF(rising_edge(clk) AND EN='1') THEN
     
   --  C <= (OTHERS =>'0');
   --  X <= (OTHERS =>'0');
    C1: CASE OP IS
      WHEN "000"=> C <= A + B;
      WHEN "001"=> C <= A + NOT(B)+1;
      WHEN "010"=> C <= A AND B;
      WHEN "011"=> C <= A OR B;
      WHEN "100"=> C <= A XOR B;
      WHEN "101"=> C <= NOT A;  
      WHEN "110"=> C <= A;
      WHEN "111"=> X <= A + 1;
      WHEN OTHERS => NULL;
    END CASE C1;
END IF;

END PROCESS;

ADDRESS<=X;

OUTPUT<=C;
Y<=X WHEN (OP="111") ELSE C;
 Z_FLAG <= '1' WHEN (C="0") ELSE '0';
 N_FLAG <= '1' WHEN (C(N-1)='1') ELSE '0';
 O_ADD <= '1' WHEN ((OP="000") AND ((A(N-1)=B(N-1)) AND (C(N-1)/=A(N-1)))) ELSE '0';
 O_S <= '1' WHEN ((OP="001") AND ((A(N-1)=NOT(B(N-1))) AND (C(N-1)/=A(N-1)))) ELSE '0'; 
 O_FLAG <= O_ADD OR O_S;
 
 
-- a<= "0000000000000110" after 100 ns;
-- b<= "0000000000000111" after 100 ns;
-- op<="001" after 100 ns;
-- RESET<= '0', '1' after 20 ns, '0' after 22 ns; 
-- EN<= '1';
--  PROCESS 
--       BEGIN
--       CLK<=not(CLK);
--       WAIT FOR 10 NS;
--      END PROCESS;
 
END BEHAVIORAL; 


