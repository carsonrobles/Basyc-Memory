
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/16/2016 11:59:00 AM --
-- Description: button debouncer       --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- outputs a random 2-bit number
entity rand is
    port (
        clk : in  std_logic;

        num : out std_logic_vector (1 downto 0)         -- random output between 0 and 3
    );
end rand;

architecture rand_arc of rand is

-- continuously counts
signal cnt : std_logic_vector (1 downto 0) := "00";

begin
    -- assign random output to cnt, appears random if sample periods are spread out
    num <= cnt;

    -- increments cnt
    cnt_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            cnt <= cnt + 1;
        end if;
    end process cnt_proc;
end rand_arc;

