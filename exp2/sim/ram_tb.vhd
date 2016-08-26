
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/22/2016 06:45:00 PM --
-- Description: ram test bench         --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity ram_tb is
end ram_tb;

-- sim architecture
architecture test_bench of ram_tb is
-- declare module to test
component ram is
    port (
        clk   : in  std_logic;

        wr_en : in  std_logic;
        d_in  : in  std_logic_vector (1 downto 0);
        addr  : in  std_logic_vector (2 downto 0);

        d_out : out std_logic_vector (1 downto 0)
    );
end component ram;

-- declare test signals to drive module ports
signal wr_en : std_logic;
signal d_in  : std_logic_vector (1 downto 0);
signal addr  : std_logic_vector (2 downto 0);

signal d_out : std_logic_vector (1 downto 0);

-- for designs with a clock uncomment the following lines
signal clk : std_logic := '0';

constant CLK_PERIOD : time := 10 ns;

begin
    -- map uut (unit under test) ports to your test signals
    uut: ram port map (
        -- map ports...
        clk   => clk,
        wr_en => wr_en,
        d_in  => d_in,
        addr  => addr,
        d_out => d_out
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
        wr_en <= '0';
        d_in  <= "00";
        addr  <= "000";
        wait for 20 ns;

        wr_en <= '1';
        d_in  <= "10";
        addr  <= "010";
        wait for 10 ns;

        wr_en <= '0';
        wait for 10 ns;

        wr_en <= '0';
        d_in  <= "00";
        addr  <= "000";
        wait for 20 ns;

        wr_en <= '0';
        d_in  <= "00";
        addr  <= "010";
        wait;
    end process;
end test_bench;

