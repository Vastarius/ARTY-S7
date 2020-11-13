----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.11.2020 18:16:17
-- Design Name: 
-- Module Name: blink - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_blink is
    Port (  CLK100MHZ : in STD_LOGIC;
    		BTN0 : in STD_LOGIC; -- reset
            LD2 : out STD_LOGIC);
end tb_blink;

architecture Behavioral of tb_blink is

signal clk50MHz : std_logic := '0';
signal led_state : std_logic := '1';
constant max : natural := 50000000;

begin

divider : process(CLK100MHZ) is
begin
	if rising_edge(CLK100MHZ) then
		clk50MHz <= '1';
	end if;	
end process; 			-- divider, asynchronous reset

compteur : process(CLK100MHZ) is
variable counter : integer range 0 to 25000000 := 0;
begin
	if (CLK100MHZ'event and CLK100MHZ = '1') then
		if (counter < max/2) then
			counter := counter + 1;
			LD2 <= '1';	
		elsif (counter < max) then
		  	LD2 <= '0';
		  	counter := counter + 1;
		else
			counter := 0;
			LD2 <= '1';	
		end if;
	end if;
end process; -- compteur


end Behavioral;
