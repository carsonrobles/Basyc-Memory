
library ieee;
use ieee.std_logic_1164.all;

entity test_top is
    port (
        clk : in  std_logic;

        led : out std_logic_vector (15 downto 0)
    );
end test_top;

architecture test_top_arc of test_top is

component led_driver is
    port (
        clk : in  std_logic;

        en  : in  std_logic;

        led : out std_logic_vector (15 downto 0)
    );
end component led_driver;

begin
    ld : led_driver port map (
        clk => clk,
        en  => '1',
        led => led
    );
end test_top_arc;

