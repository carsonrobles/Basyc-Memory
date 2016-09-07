
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/20/2016 06:57:00 PM --
-- Description: sseg driver sim        --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity sseg_driver_tb is
end sseg_driver_tb;

-- sim architecture
architecture test_bench of sseg_driver_tb is
-- declare module to test
component sseg_driver is
    port (
        clk  : in  std_logic;                           -- clock signal

        data : in  std_logic_vector (15 downto 0);      -- input data

        an   : out std_logic_vector ( 3 downto 0);      -- anode out
        seg  : out std_logic_vector ( 7 downto 0)       -- cathode out
    );
end component sseg_driver;

-- declare test signals to drive module ports
signal data : std_logic_vector (15 downto 0) := x"0000";

signal an   : std_logic_vector ( 3 downto 0);
signal seg  : std_logic_vector ( 7 downto 0);

-- for designs with a clock uncomment the following lines
signal clk : std_logic := '0';

constant CLK_PERIOD : time := 10 ns;

begin
    -- map uut (unit under test) ports to your test signals
    uut: sseg_driver port map (
        -- map ports...
        clk  => clk,
        data => data,
        an   => an,
        seg  => seg
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
        data <= x"0000";
        wait for 100 ns;

        data <= x"1773";
        wait;
    end process;
end test_bench;

