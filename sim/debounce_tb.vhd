
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/16/2016 11:59:00 AM --
-- Description: button debouncer tb    --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity sim is
end sim;

-- sim architecture
architecture test_bench of sim is
-- declare module to test
component debounce is
    port (
        -- clock signal
        clk : in  std_logic;

        -- btn input
        btn_i : in  std_logic;

        -- clean btn output
        btn_d : out std_logic
    );
end component debounce;

-- declare test signals to drive module ports
signal btn_i : std_logic;

signal btn_d : std_logic;

-- for designs with a clock uncomment the following lines
signal clk : std_logic := '0';

constant CLK_PERIOD : time := 10 ns;

begin
    -- map uut (unit under test) ports to your test signals
    uut: debounce port map (
        -- map ports...
        clk   => clk,
        btn_i => btn_i,
        btn_d => btn_d
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
        btn_i <= '0';
        wait for 2 ns;

        btn_i <= '1';
        wait for 2 ns;

        btn_i <= '0';
        wait for 2 ns;

        btn_i <= '1';
        wait for 2 ns;

        btn_i <= '0';
        wait for 2 ns;

        btn_i <= '1';
        wait for 2 ns;

        btn_i <= '0';
        wait for 2 ns;

        btn_i <= '1';
        wait for 20 ns;

        btn_i <= '0';
        wait for 2 ns;

        btn_i <= '1';
        wait for 50 ns;
    end process;
end test_bench;

