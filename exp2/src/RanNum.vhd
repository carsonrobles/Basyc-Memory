----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2015 01:59:05 PM
-- Design Name: 
-- Module Name: RanNum - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RanNum is
    port (
      clk : in std_logic;
      --random_num : out std_logic_vector (7 downto 0)   --output vector            
      rand : out std_logic_vector (1 downto 0)
    );
end RanNum;

architecture Behavioral of RanNum is

signal random_num : std_logic_vector (7 downto 0);

begin
    rand <= random_num(1 downto 0);

    process(clk)
    variable rand_temp : std_logic_vector(7 downto 0):=(7 => '1',others => '0');
    variable temp : std_logic := '0';
    begin
        if(rising_edge(clk)) then
            temp := rand_temp(7) xor rand_temp(6);
            rand_temp(7 downto 1) := rand_temp(6 downto 0);
            rand_temp(0) := temp;
        end if;
    random_num <= rand_temp;
end process;
end Behavioral;

