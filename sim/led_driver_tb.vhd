
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/16/2016 11:59:00 AM --
-- Description: led driver tb          --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity led_driver_tb is
end led_driver_tb;

-- sim architecture
architecture test_bench of led_driver_tb is
-- declare module to test
component led_driver is
    port (
        clk : in  std_logic;

        en  : in  std_logic;

        led : out std_logic_vector (15 downto 0)
    );
end component led_driver;

-- declare test signals to drive module ports
signal en  : std_logic;

signal led : std_logic_vector (15 downto 0);

-- for designs with a clock uncomment the following lines
signal clk : std_logic := '0';

constant CLK_PERIOD : time := 10 ns;

begin
    -- map uut (unit under test) ports to your test signals
    uut: led_driver port map (
        -- map ports...
        clk => clk,
        en  => en,
        led => led
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
        en <= '1';
        wait for 500 ns;
    end process;
end test_bench;

