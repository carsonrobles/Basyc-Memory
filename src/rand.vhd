
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/16/2016 11:59:00 AM --
-- Description: button debouncer       --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- outputs a random 2-bit number
entity rand is
    port (
        clk : in  std_logic;

        num : out std_logic_vector (1 downto 0)         -- random output between 0 and 3
    );
end rand;

architecture rand_arc of rand is

-- shift reg, start with any non 0 value
signal lfsr : std_logic_vector (3 downto 0) := x"c";

begin
    -- grab 2 least significant bits off of 4 bit lfsr register
    num <= lfsr(1 downto 0);

    lfsr_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            lfsr <= lfsr(2 downto 0) & (lfsr(3) xor lfsr(2));
        end if;
    end process lfsr_proc;
end rand_arc;

