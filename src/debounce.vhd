
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

-- debounces a button signal
entity debounce is
    port (
        clk   : in  std_logic;      -- clock signal

        btn_i : in  std_logic;      -- btn input

        btn_d : out std_logic       -- clean btn output
    );
end debounce;

architecture debounce_arch of debounce is

signal shft : std_logic_vector ( 3 downto 0) := "0000";                 -- 4 bit shift register
signal cnt  : std_logic_vector (15 downto 0) := (others => '0');        -- 16 bit counter to induce 'tck' pulse
signal tck  : std_logic;                                                -- tick signal to sample button

begin
    -- output high when shift register is full
    with shft select
        btn_d <= '1' when "1111",
                 '0' when others;

    -- tck high when cnt is full
    with cnt select
        tck <= '1' when x"ffff",
               '0' when others;

    -- handle counter
    -- increment at clk edge, sync reset btn_i
    cnt_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (btn_i = '0') then
                cnt <= x"0000";
            else
               cnt <= cnt + '1';
            end if;
        end if;
    end process cnt_proc;

    -- handle shift register
    -- sample button when tck is high, sync reset btn_i
    shft_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (btn_i = '0') then
                shft <= "0000";
            elsif (tck = '1') then
                shft <= shft(2 downto 0) & '1';
            end if;
        end if;
    end process shft_proc;
end debounce_arch;

