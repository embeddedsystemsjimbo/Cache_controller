library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity cache_controller is
    Port (
     i_clk : std_logic; 
     i_reset : std_logic; 
     i_adr : in  std_logic_vector(15 downto 0);
     i_data_from_SDRAM : in std_logic_vector(7 downto 0);
     o_data_to_SDRAM: out std_logic_vector(7 downto 0);
     i_data_from_CPU : in std_logic_vector(7 downto 0);
     o_data_to_CPU : out std_logic_vector(7 downto 0);
     i_chip_select: in std_logic;
     i_WEN: in std_logic;
     o_WEN_SDRAM : out std_logic; 
     o_memory_strobe : out std_logic; 
     o_cache_controller_ready: out std_logic; 
     o_adr_SDRAM : out std_logic_vector(15 downto 0);
     o_WEN_SRAM : out std_logic_vector (0 downto 0);
     o_adr_SRAM : out std_logic_vector(7 downto 0);
     o_data_to_SRAM : out std_logic_vector(7 downto 0);
     i_data_from_SRAM : in std_logic_vector(7 downto 0)
     );
end cache_controller;

architecture Behavioral of cache_controller is

-------------------------------------------------------------------------------------------------------------
---TAG parameters
-------------------------------------------------------------------------------------------------------------
signal tag : STD_LOGIC_VECTOR(7 downto 0);
signal index : STD_LOGIC_VECTOR(2 downto 0);
signal offset : STD_LOGIC_VECTOR(4 downto 0); 
	 
-------------------------------------------------------------------------------------------------------------
--SRAM paramenters
-------------------------------------------------------------------------------------------------------------

--There is 8 bit position, each bit position refers to an index value of the SRAM
signal dirtybit : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; --initialize to zero
signal validbit : STD_LOGIC_VECTOR (7 downto 0) := "00000000"; --"                   "
    
--Tag Register Block
-- 8 memory block position w/ 32 words each
type register_type is array(7 downto 0) of STD_LOGIC_VECTOR(7 downto 0);    --create register of index 8 for 8 memory block
signal tag_register_block : register_type:=((others => (others => '0'))); --initialize with zeros
    
-------------------------------------------------------------------------------------------------------------
--SDRAM paramenters
-------------------------------------------------------------------------------------------------------------
    
signal memory_offset: STD_LOGIC_VECTOR(5 downto 0) := "000000";   --one bit larger than required to allow counter logic to be implemented more easily. 
	 
-------------------------------------------------------------------------------------------------------------
--FSM paramenters
-------------------------------------------------------------------------------------------------------------

type state_type is (Wait_1, Wait_2,Preload_TAG_index_offset, Processor_request, Compare_TAG, HIT,
WAIT_data_to_CPU_1, WAIT_data_to_CPU_2, WAIT_data_to_CPU_3, MISS, Write_to_SDRAM_A, Write_to_SDRAM_B, Write_to_SDRAM_C,
Write_from_SDRAM_A, Write_from_SDRAM_B, Write_from_SDRAM_C); --assign states 
signal state : state_type := Wait_1; 


begin


cache_controller_FSM_logic : process(i_clk)

begin

       if rising_edge(i_clk) then
            
            if i_reset = '1' then
            
                state <= Wait_1;   
        
            else
                
                case(state) is								--NOTE .. the reason for Wait_1 and Wait_2
					 
		   WHEN Wait_1 =>							--CPU needs to see o_cache_controller_ready <='0' for 2 clock cyles mutiple clock cycles to begin
																		--before it can receive a o_cache_controller_ready <='1' trigger
			 o_cache_controller_ready <='0'; 
								
			 state <= Wait_2; 
            
                   WHEN Wait_2 =>
								
			state <= Processor_request;
							
		   WHEN Processor_request =>
                        
                        o_WEN_SRAM <= "0";             --reset parameters...make debug easier<--
                        o_WEN_SDRAM <= '0';
                        tag <= "00000000";             
                        index <= "000";              
                        offset <= "00000"; 
                        memory_offset <= "000000";     -- counter for SDRAM to SRAM and SRAM to SDRAM writing
                         
                        o_cache_controller_ready <='1';  -- cache controller ready...request new address from CPU
                        
                        if(i_chip_select = '1') then                    
                            state <= Preload_TAG_index_offset;
                        end if;
                     
		    WHEN Preload_TAG_index_offset => 

                        o_cache_controller_ready <= '0';         --set "o_cache_controller_ready <= "0" which signifies cache controller processing command...do not update address
                        tag <= i_adr(15 downto 8);               --determine WORD ADDRESS REGISTER FIELDS <--
                        index <= i_adr(7 downto 5);              --
                        offset <= i_adr(4 downto 0);             --                                       <-- 
                        
			--preload address from CPU TO SRAM, DO NOT include offset---determined at time of transfer 
                        
			o_adr_SRAM(7 downto 5) <= i_adr(7 downto 5); --same as preloading index
                        o_adr_SDRAM(15 downto 5) <= i_adr(15 downto 5); --preload address from CPU TO SDRAM  tag + index, DO NOT include offset---determined at time of transfer 

                        state <= Compare_TAG; 
						  
                     WHEN Compare_TAG =>

                        --compare input address tag & index to current values in SRAM
                        
			if((validbit(to_integer(unsigned(index))) = '1') AND (tag_register_block(to_integer(unsigned(index)))= tag )) then
                                
                           state <= HIT; -- TAG found 
                                
                        else                  
                       
                           state <= MISS; --address not found
                                
                        end if;
                
                     WHEN HIT =>   --TAG found
                
                        if (i_WEN ='1') then --write to data already in SRAM -- request from CPU
                    
                           dirtybit(to_integer(unsigned(index))) <= '1';    -- because write operation modifies data , we must identify block as modified to maintain memory coherency
                       
                           validbit(to_integer(unsigned(index))) <= '1';    -- block set valid after SDRAM to SRAM write procedure to mark content in block
                    
                           -- send data to CPU, address already partially determined in Preload_TAG_index_offset state only "offset required" 
                           
			   o_data_to_SRAM <= i_data_from_CPU;  
                           
                           o_adr_SRAM(4 downto 0) <= offset; 
                           
                           o_WEN_SRAM <= "1"; --set SRAM for write mode
                       
                           state <= Wait_1;     
                    
                        elsif(i_WEN ='0') then --read block and send to CPU
                    
                           -- address already partially determined in Preload_TAG_index_offset state only "offset required" 
                           o_adr_SRAM(4 downto 0) <= offset; 
									
			   o_WEN_SRAM <= "0"; -- set SRAM for read mode
                    
                           state <= WAIT_data_to_CPU_1; 
                    
                        end if;         
                    
		     WHEN WAIT_data_to_CPU_1 =>			-- 2 clock delay required for SRAM to transfer appropriate data from given address
                        
			state <= WAIT_data_to_CPU_2;

                     WHEN WAIT_data_to_CPU_2 =>
                        
			state <= WAIT_data_to_CPU_3;

                     WHEN WAIT_data_to_CPU_3 =>
                            
			o_data_to_CPU <= i_data_from_SRAM; 	-- data now available to send to CPU,
                           
			state <= Wait_1;

                     WHEN MISS => --TAG not found
            
                        if(((validbit(to_integer(unsigned(index)))) = '1') AND ((dirtybit(to_integer(unsigned(index))))= '1')) then -- cache dadta for address modified, update SDRAM first
                    
                            -- we need to write back to the original address, not the current address, thus we need to preload old tag found at current index location
                            -- by default SDRAM address defaults to non-writeback write of read request
                            -- we need to preload old address and update cache controller SDRAM output address-->req. (old tag) + (current index) + (index ="00000")  
                            --NOTE: 
                            -- current index still valid, no need to update (why ? conflict in currently with this index location)
                            -- since we must rewrite entire 32 byte memory block in SRAM at the current index location, we prep SRAM by zeroing out offset now since SRAM has 2 clock output delay

                           o_adr_SDRAM(15 downto 8) <= tag_register_block(to_integer(unsigned(index)));  --copy old tag to current SDRAM output address
         
			   state <= Write_to_SDRAM_A; 
                
                        else   -- address in cache not present, add data corresponding to address in SDRAM
                
                           state <= Write_from_SDRAM_A; 
                
                        end if;
								
                     WHEN Write_to_SDRAM_A =>  -- sent address to SRAM and SDRAM
                 
                        if(memory_offset > "011111") then  -- 32 words per block to write "Memory Strobe" every other i_clk  as per manual
                    
                           memory_offset <= "000000";      -- reset memory offset to 0, start position
                    
                           o_adr_SDRAM(4 downto 0) <= "00000"; -- optional 
			   o_adr_SRAM(4 downto 0) <= "00000"; 
									
			   o_memory_strobe <= '0'; 
                    
                           o_WEN_SDRAM <= '0';
                           
                           dirtybit(to_integer(unsigned(index))) <= '0'; -- old modified block copied to SDRAM at original memory address, free to overwrite data in SRAM now
                    
                           state <= Preload_TAG_index_offset;  --now safe to reload process current address/data 
                    
                        else 
                           
			   o_memory_strobe <= '0';
        
                           --address already partially preloaded during during Compare_TAG/MISS state, w/o offset 
                                 
			   o_adr_SDRAM(4 downto 0) <= memory_offset(4 downto 0);  --start with address offset 0000 for DRAM write operation  
                            
                           --determine SRAM address to output to SDRAM
                           --tag + index  not required because it doesn't change---already preloaded in tag_compare/MISS state
                        
                           o_adr_SRAM(4 downto 0) <= memory_offset(4 downto 0); --iterate through block by incrementing offset
                                                                 
                           memory_offset <= memory_offset + "000001";  --increment to memory offset to next word 
                            
                           state <= Write_to_SDRAM_B;
                         
						end if;
                     
		    WHEN Write_to_SDRAM_B =>	--wait on SRAM to provided data ... 2 clock cycle delay between sending address and receiving data

			state <= Write_to_SDRAM_C;
                      
		    WHEN Write_to_SDRAM_C =>  -- data from SRAM available...send to SDRAM
							
			o_memory_strobe <= '1'; 
									
			o_WEN_SRAM <= "0";      
                            
			o_WEN_SDRAM <= '1';     -- prepare DRAM for writing 
									
			o_data_to_SDRAM <= i_data_from_SRAM; -- send data from SRAM to SDRAM
									
			state <= Write_to_SDRAM_A;
							
                     WHEN Write_from_SDRAM_A =>
            
                        if(memory_offset > "011111") then   -- 32 words per block to write "Memory Strobe" every other i_clk  as per specifications
									
			   memory_offset <= "000000";         -- reset memory offset to 0, start position 
									
                           validbit(to_integer(unsigned(index)))<= '1'; -- block write complete, tag register complete, now valid
                    
                           tag_register_block(to_integer(unsigned(index))) <= tag; --writing block complete, update tag
                           
                           o_adr_SDRAM(4 downto 0) <= "00000"; --optional 
			   o_adr_SRAM(4 downto 0) <= "00000"; 
									
			   o_WEN_SRAM <= "0";
                            
                           o_memory_strobe <= '0';
                            
                           state <= HIT;
                        
                         else
                              
			   o_memory_strobe <= '0';
										
                           o_adr_SDRAM(4 downto 0) <= memory_offset(4 downto 0); 
                                
                           o_adr_SRAM(4 downto 0) <= memory_offset(4 downto 0);
                                
                           o_WEN_SRAM <= "1"; -- prepare SRAM for writting 
                                
                           memory_offset <= memory_offset + "000001"; -- increment to memory offset to next word 
                              
			   state <= Write_from_SDRAM_B; 
										
                         end if;
								
                     WHEN Write_from_SDRAM_B => --wait on SRAM to process data ... 2 clock cycle delay between sending address and receiving data
						  
		     	state <= Write_from_SDRAM_C; 
						  
		     WHEN Write_from_SDRAM_C => 	-- data from SDRAM able to be input into SRAM
								
		     	o_memory_strobe <= '1'; 
								
			o_WEN_SRAM <= "1";
								
			o_WEN_SDRAM <= '0'; 
								
			o_data_to_SRAM <= i_data_from_SDRAM;  --sent data from SDRAM to SRAM
								
			state <= Write_from_SDRAM_A;
                              
                     WHEN others => 
                 
                        state <= Wait_1 ;
             
             end case;
            
            end if; 
       end if; 
                                 
end process cache_controller_FSM_logic; 

end Behavioral;






