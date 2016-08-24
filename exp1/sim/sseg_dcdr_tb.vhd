
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/20/2016 06:45:00 PM --
-- Description: sseg decoder sim       --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity sseg_dcdr_tb is
end sseg_dcdr_tb;

-- sim architecture
architecture test_bench of sseg_dcdr_tb is
-- declare module to test
component sseg_dcdr is
    port (
        dig : in  std_logic_vector (3 downto 0);        -- val input

        seg : out std_logic_vector (7 downto 0)         -- sseg output
    );
end component sseg_dcdr;

-- declare test signals to drive module ports
signal dig : std_logic_vector (3 downto 0) := "0000";

signal seg : std_logic_vector (7 downto 0);

begin
    -- map uut (unit under test) ports to your test signals
    uut: sseg_dcdr port map (
        -- map ports...
        dig => dig,
        seg => seg
    );

    stim_proc: process
    begin
        -- assign test signals and use 'wait for 10ns' and 'wait' (after final test)
        dig <= "0001";
        wait for 10 ns;     -- valid

        dig <= "0011";
        wait for 10 ns;     -- valid

        dig <= "1010";
        wait for 10 ns;     -- invalid

        dig <= "0010";
        wait for 10 ns;     -- valid

        dig <= "0110";
        wait for 10 ns;     -- invalid

        dig <= "0000";
        wait;               -- valid
    end process;
end test_bench;

