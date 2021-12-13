LIBRARY ieee;
use ieee.std_logic_1164.all;
-- USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY CONTROLLER IS
GENERIC(M: INTEGER:=3; 
         N: INTEGER:=16 
                   );
                      
  PORT(DIN,in_ext_mem: IN std_logic_vector(15 downto 0);
          DOUT,A_OUT: OUT std_logic_vector(15 downto 0);
          CLOCK_50,RESET,EN_ALU,OE, din_en: IN std_logic;
          Z_FLAG,N_FLAG,O_FLAG: OUT std_logic;
          rd_wr_en: OUT std_logic
        );
         END CONTROLLER;
         
  ARCHITECTURE BEHAVE OF CONTROLLER IS
     COMPONENT DATAPATH2 IS
    Generic (M: Integer:=3;
              N: Integer:=16);
              
    Port (Input_data : IN std_logic_vector(15 downto 0);
            IE, OE : IN std_logic;
             WADDR : IN std_logic_vector(M-1 downto 0);
             Write_EN :IN std_logic;
             RA_RA : IN std_logic_vector(M-1 downto 0);
             RB_RB : IN std_logic_vector(M-1 downto 0);
             Read_A : IN std_logic;
             Read_B : IN std_logic;
             OP_ALU : IN std_logic_vector (2 downto 0);
             Output_data,A_OUT : OUT std_logic_vector(15 downto 0);
             ZFlag, NFlag, OFlag : OUT std_logic;
             CLOCK_50, RESET, EN_ALU : IN std_logic;
             Offset: IN std_logic_vector(15 downto 0);
             Buff_A,Buff_B: IN std_logic);
      END COMPONENT;         
     
     
     COMPONENT ROM IS
     port( DIN: in std_logic_vector (15 downto 0);
         --  alu_out: in std_logic_vector (15 downto 0);
           Reset, CLOCK_50, Z_FLAG, O_FLAG, N_FLAG,din_en : in std_logic;
           IE, BUFF_B, WRITE_EN, READ_A, READ_B, BUFF_A: out std_logic;
           rd_wr_en: out std_logic;
           Offset,in_data : out std_logic_vector (15 downto 0);
         --  A_OUT : out std_logic_vector (15 downto 0);
           uInstr: out std_logic_vector(2 downto 0);
           WADDR, RA_RA, RB_RB: out std_logic_vector(M-1 downto 0));
           END COMPONENT;
           
SIGNAL RA,RB: std_logic_vector(M-1 downto 0);
SIGNAL READA,READB,IE,BUFF_A,BUFF_B,WRITE_EN: std_logic;
SIGNAL UINSTR: std_logic_vector(2 downto 0);
SIGNAL Offset,input_data,output: std_logic_vector(15 downto 0);
SIGNAL mux_input: std_logic_vector(15 downto 0);
SIGNAL i_p: std_logic_vector(15 downto 0);
SIGNAL aout: std_logic_vector(15 downto 0);
SIGNAL ZFLAG,NFLAG,OFLAG,rd_wr_en_sig: std_logic;
SIGNAL WADDR: std_logic_vector(M-1 downto 0);


    BEGIN
DATAMAPPING: DATAPATH2 
  GENERIC MAP(M=>M,
               N=>N)
    PORT MAP (
               Input_data=>mux_input,
               IE=>IE,
               OE=>OE,
               WRITE_EN=>WRITE_EN,
               RA_RA=>RA,
               RB_RB=>RB,
               Read_A=>READA,
               Read_b=>READB,
               OP_ALU=>UINSTR,
               Output_data=>OUtput,
               A_OUT=>AOUT,
               ZFLAG=>ZFLAG,
               NFLAG=>NFLAG,
               OFLAG=>OFLAG,
               CLOCK_50=>CLOCK_50,
               RESET=>RESET,
               EN_ALU=>EN_ALU,
               Offset=> Offset,
               Buff_A=>BUFF_A,
               Buff_B=>BUFF_B,
               WADDR=>WADDR);
              
ROMMAPPING: ROM
    PORT MAP(DIN=>DIN,
 --    A_OUT=>AOUT_ld_st,
  --    alu_out=>output,
      rd_wr_en=>rd_wr_en_sig,
    din_en=>din_en,
    in_data=>i_p,
    RESET=>RESET,
    CLOCK_50=>CLOCK_50,
    Z_FLAG=>ZFLAG,
    N_FLAG=>NFLAG,
    O_FLAG=>OFLAG,
    IE=>IE,
    BUFF_B=>BUFF_B,
    WRITE_EN=>WRITE_EN,
    READ_A=>READA,
    READ_B=>READB,
    BUFF_A=>BUFF_A,
    Offset=>Offset,
    uInstr=>UINSTR,
    WADDR=>WADDR,
    RA_RA=>RA,
    RB_RB=>RB);
    
 --   DIN<=DIN;
    DOUT <=output;
 -- A_OUT<=AOUT_ld_st when ((DIN AND "1000111111111111") OR (DIN AND "1001111111111111") = DIN ) else aout;
      A_OUT<= OUTPUT when (DIN (15 downto 12)= "1000" or DIN (15 downto 12)="1001") else aout;   
      rd_wr_en<=rd_wr_en_sig;
      mux_input<= in_ext_mem when (rd_wr_en_sig='0') else i_p;
      
       Z_FLAG<=ZFLAG;
       N_FLAG<=NFLAG;
       O_FLAG<=OFLAG;
       END ARCHITECTURE; 