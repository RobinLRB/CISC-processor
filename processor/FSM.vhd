library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity ROM is 
  
  port( DIN  : in std_logic_vector (15 downto 0);
     --   alu_out: in std_logic_vector (15 downto 0);
        Reset, CLOCK_50, Z_FLAG, O_FLAG, N_FLAG,din_en : in std_logic;
        IE, BUFF_B, WRITE_EN, READ_A, READ_B, BUFF_A : out std_logic;
        rd_wr_en:out std_logic;
        Offset,in_data : out std_logic_vector (15 downto 0);
      --  A_OUT : out std_logic_vector (15 downto 0);
        uInstr: out std_logic_vector(2 downto 0);
        WADDR, RA_RA, RB_RB: out std_logic_vector(2 downto 0));
        
end entity ROM;

architecture behav of ROM is
  
     signal A : std_logic_vector(6 downto 0) := (others => '0');
     signal mux_en, mux_out :  std_logic;
     signal mux_sel : std_logic_vector(1 downto 0);
     signal Instr : std_logic_vector(3 downto 0);
    
     
  begin
    
    mux_en <= Din(15) and Din(14);  --branch instruction's first 2 bits can be used to decide if instr is branch 1100 1101 1110 1111
    mux_sel <= Din(13 downto 12); --branch instruction's last 2 bits can be used for selecting flags for A2
    
    A(2) <= Z_FLAG when mux_en = '1' and mux_sel = "00" else
            N_FLAG when mux_en = '1' and mux_sel = "01" else
            O_FLAG when mux_en = '1' and mux_sel = "10" else
            '0';
            
    Instr <= Din (15 downto 12);
	                             
   -- PROCESS(Buff_B)
    -- BEGIN
      -- IF Buff_B='1' THEN
        -- READ_A <= '1';
         --RA_RA <= (others=>'1');
       --end if; 
         
     --END PROCESS;
    
    process(CLOCK_50)
     variable UPC : integer := 0;
     
      begin
    if(rising_edge(CLOCK_50) ) then  
    if (din_en='1') then
      if(RESET = '1') then
      
      IE <= '0';
      BUFF_B <= '0';
      BUFF_A <= '0';
      WRITE_EN <= '0';
      READ_A <= '0';
      READ_B <= '0';
      Offset <= (others => '0');
      uInstr <= (others => '0');
      WADDR <= (others => '0');
      RA_RA <= (others => '0');
      RB_RB <= (others => '0');
      
     
     
      
      elsif((Instr = "0000") or (Instr = "0001") or (Instr = "0010") or (Instr = "0011")
          or (Instr = "0100") or (Instr = "0101") or (Instr = "0110")) then   --Basic ALU operation control logic signals
            
        case UPC is
       
        when 0 =>
        
       
        UPC := UPC+1;
        
        BUFF_A <= '0';
        BUFF_B <= '0';
        
        A(6 downto 3) <= Instr;
       -- Offset <= ("1111" & Din (11 downto 0)); --offset should be sign extended
        WADDR <= Din (11 downto 9);  
        RA_RA <= Din (8 downto 6);
        RB_RB <= Din (5 downto 3);
        WRITE_EN <= '0'; --write should be enabled for writing ALU result back
        READ_A <= '1'; --Readings should be enabled to read register values
        READ_B <= '1';
        uInstr <= Instr(2 downto 0); --ALU Opp code is least 3 bit of Instr
        IE <= '0'; --Input is disabled - 0
        
        when 1 =>   --fetch and exec
        
        
       -- WRITE_EN <= '0'; --write is enabled to write alu value back
       -- IE<='1'; --ENABLE FEEDBACK
        WRITE_EN <= '1';
       -- uinstr<="110";
       -- READ_A<='1';
       -- READ_B<='1';  
        UPC := UPC+1;
      
     
        
        when 2 => --fetch and exec
        uInstr <= "111"; --PC should be increamented by one
       -- BUFF_B <= '1'; --Bypass PC value to input A
		    READ_A <= '1';
        RA_RA <= (others=>'1');
        WADDR <= std_logic_vector(to_unsigned(7, 3)); --PC is in register 7
        WRITE_EN <= '0';
        IE<='0';
         
          -- A(1 downto 0) <= A(1 downto 0) + 1;  --increase uProgram counter
        UPC := UPC+1;
        
      when 3 => 
        WRITE_EN<='1';
        UPC:=UPC+1;
        
        when others => --latch read 
        
       -- A(1 downto 0) <= "00";
       
        -- READ_A<='1';
         --RA_RA<=(OTHERS=>'1');
         UPC := 0;
        -- uinstr<="110";
        -- IE<='0';
         --WADDR <= std_logic_vector(to_unsigned(7, 3));
        WRITE_EN <= '0'; --enable write to write pc val
        --BUFF_B <= '0'; --disable bypassing
        end case;
      
      
      elsif ((Instr = "0111") or (Instr = "1011")) then --NOP and N.U.
     
        C1 : case UPC is
          
        when 0 =>
        
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        IE <= '0';
        uInstr <= "111";  --PC will be incremented by 1
        --BUFF_B <= '1'; --Bypass Register A to pass PC's value
		    READ_A <= '1';
        RA_RA <= (others=>'1');
        WRITE_EN <= '0';  --enable write to write PC's value back
        WADDR <= std_logic_vector(to_unsigned(7, 3)); --PC is in register 7
        
       -- A(1 downto 0) <= A(1 downto 0) + 1;
       
        
        when 1 =>
        WRITE_EN <= '1';
         UPC := UPC+1;
         uInstr <= "110";
        
        when 2 =>
        
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
        when others => --latch read 
        
       -- A(1 downto 0) <= "00";
       -- UPC := 0;
        WRITE_EN <= '0';
        BUFF_B <= '0';
       
        end case C1;
        
        
      elsif (Instr = "1010") then --LDI
        
      C2: case UPC is
         
       when 0 =>
        BUFF_A <= '0'; 
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        IE <= '1'; --Input of reg file will be Offset value so IE should be 1
        in_data <= (DIN(8) &DIN(8) &DIN(8) &DIN(8) &DIN(8) &DIN(8) &DIN(8) & Din (8 downto 0)); --Data is 9 bits and should be sign extended to 16 bits
        A(6 downto 3) <= Instr;
        WADDR <= Din (11 downto 9);
        
       -- BUFF_B <= '1'; --PC counter will be incremented
        READ_A <= '1';
		 -- READ_A <= '1';
        RA_RA <= (others=>'1');
        READ_B <= '0';
        uInstr <= "111"; --mov Data without doing any operation on that
        
        WRITE_EN <= '1'; --to write data to register
            
         
       when 1 =>   --fetch and exec
         WRITE_EN <= '0' ;
         WADDR <= std_logic_vector(to_unsigned(7, 3)); --write incremented pc to pc reg back
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
        when 2 =>
      -- uInstr <="110";
        IE <= '0';
       -- BUFF_B <= '0'; --disable bypassing
        WRITE_EN <= '1';
       

       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
        when others => --load and latch read 
        
      --  A(1 downto 0) <= "00";
        UPC := 0;
       -- READ_A<='0';
        
     --   WRITE_EN <= '1';
        end case C2;
        
     elsif ((Instr = "1100") or (Instr = "1101") or (Instr = "1110")) then --BRZ, BRN, BRO
       
       C3: case UPC is
         
       when 0 =>
         
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
        A(6 downto 3) <= Instr;
        Offset <= (din(11) & din(11) &din(11) &din(11) & Din (11 downto 0));
       -- Offset <= ("0000" & Din (11 downto 0));
        WADDR <= std_logic_vector(to_unsigned(7, 3));
        
        
        if(A(2) = '1') then --if condition is TRUE, then PC will be incremented BY OFFSET
        BUFF_A <= '1';
       
        READ_B <= '1';
        READ_A <= '0';
        RB_RB <= std_logic_vector(to_unsigned(7, 3));
        BUFF_B <= '0';
        uInstr <= "000";
        
        elsif (A(2) = '0') then --if condition is FALSE then PC will be incremented by ONCE
        BUFF_A <= '0';
        BUFF_B <= '1';
		  READ_A <= '1';
         RA_RA <= (others=>'1');
        READ_B <= '0';
      --  READ_A <= '0';
      --  RB_RB <= std_logic_vector(to_unsigned(7, 3));
        uInstr <= "111";
        end if;
         
        WRITE_EN <= '0';
        IE <= '0';
      
       when 1 =>   --fetch and exec
          
       
        WRITE_EN <= '1';
        uinstr<="110";
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
        when 2 =>
        
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
        when others => --load and latch read 
        
       -- A(1 downto 0) <= "00";
        UPC := 0;
        WRITE_EN <= '0';
        BUFF_B <= '0';
        
        end case C3;
        
      elsif(Instr = "1111") then --BRA
      
      C4: case UPC is
      
      when 0 =>
         
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
         A(6 downto 3) <= Instr;
        Offset <= (din(11) & din(11) &din(11) &din(11) & Din (11 downto 0));
        --Offset <= ("1111" & Din (11 downto 0));
        WADDR <= std_logic_vector(to_unsigned(7, 3));
        BUFF_A <= '1';
       -- BUFF_B <= '1';
       -- READ_A <= '1';
		 -- READ_A <= '1';
         --RA_RA <= (others=>'1');
        READ_B <= '1';
        RB_RB <= std_logic_vector(to_unsigned(7, 3));
        uInstr <= "000";
         
        IE <= '0';
        WRITE_EN <= '0';
      
      when 1 =>   --fetch and exec
          
       WRITE_EN <= '1';
       uinstr<="110"; 
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
       
      when 2 =>
        
      --  A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
      when others => --load and latch read 
        
       -- A(1 downto 0) <= "00";
        UPC := 0;
        
        WRITE_EN <= '0';
        BUFF_B <= '0';
        
      end case C4;
      
      
     elsif (Instr = "1001") then --ST
       
       C5: case UPC is
      
      when 0 =>
         
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
      
        A(6 downto 3) <= Instr;
       -- Offset <= (din(11) & din(11) &din(11) &din(11) & Din (11 downto 0));
       -- Offset <= ("1111" & Din (11 downto 0));
--		    BUFF_B <= '0';
        READ_A <= '1';
        READ_B <= '0';
        RA_RA <= Din (11 downto 9);
        uInstr <= "110"; --move value of register 1 
--       WADDR<= wd ;
--       BUFF_A <= '0';


--        IE <= '0';
--        WRITE_EN <= '0';
        
      when 1 =>   --fetch and exec
      --  wd<='0';
    --    A_OUT<=alu_out;
        RA_RA <= Din (8 downto 6);
     --   uInstr <= "110"; --move value of register 2 
   --     BUFF_A <= '0';
     --   BUFF_B <= '0';
       -- IE <= '0';  
        --A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
      when 2=>
      UPC := UPC+1;
      rd_wr_en<='1';
      
      
      when 3 =>
--        WRITE_EN <= '1';
        uInstr <= "111";  --PC will be incremented by 1
--        BUFF_B <= '1'; --Bypass Register A to pass PC's value
		    READ_A <= '1';
        RA_RA <= (others=>'1');
       rd_wr_en<='X';
       
       -- A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        
      when others => --load and latch read 
        
        WADDR <= std_logic_vector(to_unsigned(7, 3)); --PC is in register 7
--        uinstr<="110";
        WRITE_EN <= '1';  --enable write to write PC's value back
       -- A(1 downto 0) <= "00";
        UPC := 0;
 
      end case C5;
      
     elsif (Instr = "1000") then --LD
       
      -- A(1 downto 0) <= A(1 downto 0) + 1;
      -- uPC := uPC+1;
      
      C6: case UPC is
      
      when 0 =>
        
        --A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        A(6 downto 3) <= Instr;
      --  Offset <= ("1111" & Din (11 downto 0));
       
        READ_A <= '1'; --read address from register 2
        READ_B <= '0';
        RA_RA <= Din (8 downto 6);
        uInstr <= "110"; --move value of register 2 
       
        BUFF_A <= '0';
        BUFF_B <= '0';
        IE <= '0';
        WRITE_EN <= '0';
        
      --   A_OUT<=alu_out AFTER 21 ns;
      
        
        
        when 1 =>   --fetch and exec
    --     RA_RA<=din(11 downto 9) ; 
--        READ_A <= '1'; --disable reading
       -- DIN CLOCK_50 Z_FLAG O_FLAG N_FLAG Reset BUFF_B WRITE_EN BUFF_A IE Offset uInstr WADDR
        IE <= '1'; --Enable inport for the data coming from memory
         WADDR <= Din (11 downto 9);  --this is destination register r1
          WRITE_EN<='1';
          rd_wr_en<='0';
           
          
          
        UPC := UPC+1;
        
      when 2=>
        UPC:=UPC+1;
        WRITE_EN <= '0';
        
        when 3 =>   
      --  WRITE_EN <= '1'; --enable write
        --A(1 downto 0) <= A(1 downto 0) + 1;
        UPC := UPC+1;
        uInstr <= "111";  --PC will be incremented by 1
        BUFF_B <= '1'; --Bypass Register A to pass PC's value
		    READ_A <= '1';
        RA_RA <= (others=>'1');
        
        
        
       
              rd_wr_en<='X';
       
        
        when others => --load and latch read 
        WADDR <= std_logic_vector(to_unsigned(7, 3)); --PC is in register 7 
        WRITE_EN <= '1';
        IE <= '0';
        BUFF_B <= '0'; 
        UPC := 0;
      
    end case C6;
  end if;
      end if;
  end if;
        
    end process;
    
  end architecture behav;