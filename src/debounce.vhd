
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

entity debounce is
    port (
        -- clock signal
        clk : in  std_logic;

        -- btn input
        btn_i : in  std_logic;

        -- clean btn output
        btn_d : out std_logic
    );
end debounce;

architecture debounce_arch of debounce is

-- 3 bit shift register
signal shft : std_logic_vector (2 downto 0);
-- 6 bit counter to induce 'tck' pulse
signal cnt  : std_logic_vector (5 downto 0);
-- tick signal to sample button
signal tck  : std_logic;

begin
    -- output high when shift register == 'b111
    with shft select
        btn_d <= '1' when "111",
                 '0' when others;

    -- tck high when cnt == 'b111111
    with cnt select
        tck <= '1' when "111111",
               '0' when others;

    -- handle counter
    -- increment at clk edge, async reset falling edge btn_i
    cnt_proc : process (clk, btn_i)
    begin
        if (falling_edge(btn_i)) then
            cnt <= "000000";
        elsif (rising_edge(clk)) then
            cnt <= cnt + "000001";
        end if;
    end process cnt_proc;

    -- handle shift register
    -- sample button when tck is high, async reset falling edge btn_i
    shft_proc : process (clk, btn_i)
    begin
        if (falling_edge(btn_i)) then
            shft <= "000";
        elsif (rising_edge(clk)) then
            if (tck = '1') then
                shft(2) <= shft(1);
                shft(1) <= shft(0);
                shft(0) <= '1';
            end if;
        end if;
    end process shft_proc;
end debounce_arch;

