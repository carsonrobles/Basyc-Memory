
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/19/2016 05:00:00 PM --
-- Description: random num test bench  --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity rand_tb is
end rand_tb;

-- sim architecture
architecture test_bench of rand_tb is
-- declare module to test
component rand is
    port (
        clk : in  std_logic;

        num : out std_logic_vector (1 downto 0)         -- random output between 0 and 3
    );
end component rand;

-- declare test signals to drive module ports
signal num : std_logic_vector (1 downto 0);

-- for designs with a clock uncomment the following lines
signal clk : std_logic := '0';

constant CLK_PERIOD : time := 10 ns;

begin
    -- map uut (unit under test) ports to your test signals
    uut: rand port map (
        -- map ports...
        clk => clk,
        num => num
    );

    -- for designs with a clock uncomment the following lines
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        -- assign test signals and use 'wait for 10ns' and 'wait' (after final test)
        wait;
    end process;
end test_bench;

