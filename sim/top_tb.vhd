
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 11:00:00 PM --
-- Description: top test bench         --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- empty sim entity because it does not connect to anything on the board
entity top_tb is
end top_tb;

-- sim architecture
architecture test_bench of top_tb is
component basyc_memory_top is
    port (
        clk : in  std_logic;                            -- clock input
        rst : in  std_logic;                            -- reset signal

        btn : in  std_logic_vector ( 3 downto 0);       -- button inputs

        an  : out std_logic_vector ( 3 downto 0);       -- anode out
        seg : out std_logic_vector ( 7 downto 0);       -- cathode out

        led : out std_logic_vector (15 downto 0)        -- led out
    );
end component basyc_memory_top;

-- declare test signals to drive module ports
signal rst : std_logic;
signal btn : std_logic_vector ( 3 downto 0);
signal an  : std_logic_vector ( 3 downto 0);
signal seg : std_logic_vector ( 7 downto 0);
signal led : std_logic_vector (15 downto 0);

-- for designs with a clock uncomment the following lines
signal clk : std_logic := '0';

constant CLK_PERIOD : time := 10 ns;

begin
    -- map uut (unit under test) ports to your test signals
    uut: basyc_memory_top port map (
        -- map ports...
        clk => clk,
        rst => rst,
        btn => btn,
        an  => an,
        seg => seg,
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
        rst <= '0';
        btn <= "0100";
        wait for 100 ns;

        rst <= '1';
        btn <= "0000";
        wait for 600 ns;

        rst <= '0';
        btn <= "1000";
        wait for 100 ns;

        rst <= '0';
        btn <= "0001";
        wait for 100 ns;

        rst <= '0';
        btn <= "0010";
        wait for 100 ns;

        rst <= '0';
        btn <= "1000";
        wait for 100 ns;

        wait;
    end process;
end test_bench;

