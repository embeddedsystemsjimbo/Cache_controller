library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

entity SDRAM_controller is
    Port ( i_adr_DRAM : in  STD_LOGIC_VECTOR (15 downto 0);
           i_WEN_DRAM : in  STD_LOGIC;
           i_clk : in STD_LOGIC; 
		     i_memory_strobe : in  STD_LOGIC;
           i_data: in  STD_LOGIC_VECTOR (7 downto 0);
           o_data : out  STD_LOGIC_VECTOR (7 downto 0));
end SDRAM_controller;

architecture Behavioral of SDRAM_controller is

-- NOTE:1 clock operation. 
-- 2^n -1 position with 16 bits is 2^16 - 1 = 65535 index positions
type RAM_type is array (0 to 65535) of std_logic_vector(7 downto 0);		

signal SDRAM : RAM_type := (4352 => "00000001",				--preload 16 memory addresses with data to aid in debug/simulation 
									 4353 => "00000010",
									 4354 => "00000011",
									 4355 => "00000100",
									 4356 => "00000101",
									 4357 => "00000110",
									 4358 => "00000111",
									 4359 => "00001000", 
									 4360 => "00001001",
									 4361 => "00001010",
									 4362 => "00001011",
									 4363 => "00001100",
									 4364 => "00001101",
									 4365 => "00001110",
									 4366 => "00001111",
									 4367 => "00010000",
									 others=>(others=>'1'));  -- otherwise fill SDRAM index position with "11111111". 

begin

process(i_clk)
begin	

if(rising_edge(i_clk)) then
	if(i_WEN_DRAM='1') then 		--if WEN HIGH, write to SDRAM					
		if(i_memory_strobe='1') then		-- write only when memory strobe is HIGH 
			SDRAM(to_integer(unsigned(i_adr_DRAM(14 downto 0)))) <= i_data; --insert data at address index
		end if; 
	end if;
end if;
end process;

o_data <= SDRAM(to_integer(unsigned(i_adr_DRAM(14 downto 0))));  --read data at address index

end Behavioral;








