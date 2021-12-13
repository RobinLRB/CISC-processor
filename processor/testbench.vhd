LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY LAB3 IS
  GENERIC (N: integer:=16; M: integer:=3);
END LAB3;

ARCHITECTURE BEHAVE OF LAB3 IS
  COMPONENT CONTROLLER IS
    GENERIC(M: INTEGER:=3; 
          N: INTEGER:=16 
          );
   PORT(DIN,in_ext_mem: IN std_logic_vector(15 downto 0);
        DOUT,A_OUT: OUT std_logic_vector(15 downto 0);
        CLOCK_50,RESET,EN_ALU,OE,din_en: IN std_logic;
        Z_FLAG,N_FLAG,O_FLAG: OUT std_logic;
        rd_wr_en: OUT std_logic
        --Input_data: IN std_logic_vector(15 downto 0)
        -- RB_RB: IN std_logic_vector(M-1 downto 0);
       -- WADDR: IN std_logic_vector(M-1 downto 0)
       );
     END COMPONENT;
        
      
      SIGNAL DOUT,A_OUT: std_logic_vector(N-1 downto 0);
      SIGNAL DIN,in_ext_mem: std_logic_vector(15 downto 0);
      SIGNAL RESET,IE,OE,WRITE_EN,Read_B,EN_ALU,BUFF_A,BUFF_B,Z_FLAG,N_FLAG,O_FLAG,din_en: std_logic;
      SIGNAL rd_wr_en: std_logic;
      --SIGNAL RB_RB,WADDR: std_logic_vector(M-1 downto 0);
      SIGNAL CLOCK_50: STD_LOGIC:='0';
      
      BEGIN
        
      MCHAMMER: CONTROLLER
      
      GENERIC MAP(M=>M,
                  N=>N)
      PORT MAP(DIN=>DIN,
               In_ext_mem=>in_ext_mem,
              din_en=>din_en,
              -- wd=>wd,
               DOUT=>DOUT,
               A_OUT=>A_OUT,
               CLOCK_50=>CLOCK_50,
               EN_ALU=>EN_ALU,
               RESET=>RESET,
               Z_FLAG=>Z_FLAG,
               N_FLAG=>N_FLAG,
               O_FLAG=>O_FLAG,
               rd_wr_en=>rd_wr_en,
             OE=>OE);
      --         Input_data=>Input_data);
               
      --RESET <= '0';
    --  Input_data <= "0000000000000101";
    --process(DIN)
      --BEGIN
       -- IF(falling_edge(clock_50)) then
     RESET<= '0'  , '1' after 20 ns, '0' after 22 ns;  
     --, AFTER 1 ns,'0' AFTER 6 ns;   
     DIN <= "1010000000001010","1010001000000011" AFTER 100 ns, "0000010000001000" AFTER 200 ns,"1000000001000000" AFTER 300 ns, "0000010000001000" AFTER 400 ns,"0001010000001000" AFTER 500 ns;
     --"0110011000000000" AFTER 400 ns;
     
     in_ext_mem<="0000000000000000";
     
   --end if;
   --  DIN <=  "1100010000001000";
-- END PROCESS;
      EN_ALU<='1';
      OE<='1';
      din_en<='1';
      PROCESS 
       BEGIN
       CLOCK_50<=not(CLOCK_50);
       WAIT FOR 10 NS;
      END PROCESS;
      
     -- PROCESS(CLOCK_50)
      -- VARIABLE i: INTEGER:=0;
       -- BEGIN
         -- IF (rising_edge(CLOCK_50)) then
          -- WADDR <=  std_logic_vector(TO_UNSIGNED(i,m));
	        -- RB_RB<= WADDR;
	        -- i:=i+1;
	        -- END IF;
	      -- END PROCESS;
END BEHAVE;