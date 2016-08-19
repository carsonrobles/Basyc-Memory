
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: top level module       --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- top level module for Basyc Memory game
entity basyc_memory_top is
    port (
        clk : in  std_logic;                            -- clock input
        rst : in  std_logic;                            -- reset signal

        btn : in  std_logic_vector ( 3 downto 0);        -- user input buttons

        an  : out std_logic_vector ( 3 downto 0);        -- anode out
        seg : out std_logic_vector ( 7 downto 0);        -- cathode out

        led : out std_logic_vector (15 downto 0)        -- led out
    );
end basyc_memory_top;

architecture basyc_memory_top_arc of basyc_memory_top is

begin

end basyc_memory_top_arc;

