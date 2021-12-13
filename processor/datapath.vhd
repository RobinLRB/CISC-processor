LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- USE ieee.numeric_std.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY Datapath2 IS
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
END Datapath2;

ARCHITECTURE data_flow OF Datapath2 IS
  
  COMPONENT ALU_NEW1 IS
    GENERIC(N:integer:=16);
    PORT( OP: IN std_logic_vector(2 downto 0);
          A,B: IN std_logic_vector(15 downto 0);
          reset,EN,clk: IN std_logic;
          Y,ADDRESS,OUTPUT: OUT std_logic_vector(15 downto 0);
          Z_FLAG,N_FLAG,O_FLAG: OUT std_logic);
  END COMPONENT;
  
COMPONENT REG_FILE IS
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
	END COMPONENT;
	
	SIGNAL sum_out,OUTPUT: std_logic_vector(15 downto 0);
	SIGNAL QA_A,QB_B: std_logic_vector(N-1 downto 0);
	SIGNAL mux_A,mux_B: std_logic_vector(15 downto 0);
	SIGNAL Mux_in: std_logic_vector(15 downto 0);
 -- SIGNAL ReadA: std_logic;
 -- SIGNAL RA_RA: std_logic_vector(N-1 downto 0);
	
	BEGIN
	
 Mux_in <= Input_data when (IE = '1') else
             Sum_out  when (IE = '0');
	  
  ALUmapping: ALU_NEW1
              generic map(N => N)
              port map(A => mux_A,
                       B => QB_B,
                       clk => CLOCK_50,
                       RESET => RESET,
                       en => EN_ALU,
                       OP => OP_ALU,
                       Y => Sum_out,
                       ADDRESS=>A_OUT,
                       Z_flag => ZFlag,
                       N_flag => NFlag,
                       O_flag => OFlag,
	                     OUTPUT=>OUTPUT);
  
    RFmapping: REG_FILE
             generic map(M => M,
                         N => N)
             port map(Clock => CLOCK_50,
                      Reset => RESET,
                      WD => Mux_in,
                      WAddr => WADDR,
                      Wrt => Write_EN,
                      RA => RA_RA,
                      ReadA => Read_A,
                      RB => RB_RB,
                      ReadB => Read_B,
                      QA => QA_A,
                      QB => QB_B);
                      
--  PROCESS(Buff_B)
  --    BEGIN
  
  --IF Buff_B='1' THEN
       --ReadA <= '1';
       --RA <= (others=>'1');
    --  mux_B <= Offset;
    --else
      -- mux_B <= QB_B;
    --END IF;
  --END PROCESS;
 
  --  PROCESS(clock_50)
   --   BEGIN
   --     if rising_edge (clock_50) then
 --   IF Buff_A = '1' THEN
 --    mux_A <= Offset;
 --   else
 --    mux_A <= QA_A;
--  END IF;
--end if;
-- END PROCESS; 

mux_A <= Offset when (Buff_A = '1') else QA_A;
Output_data <= OUTPUT when (OE = '1') else (others => 'Z');

END data_flow;