
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/20/2016 07:25:00 PM --
-- Description: led driver             --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity led_driver is
    port (
        clk : in  std_logic;

        en  : in  std_logic;

        led : out std_logic_vector (15 downto 0)
    );
end led_driver;

architecture led_driver_arc of led_driver is

signal s_in  : std_logic                      := '1';
signal tck   : std_logic                      := '0';
signal cnt_p : std_logic_vector ( 3 downto 0) := x"0";
signal led_l : std_logic_vector ( 7 downto 0) := x"00";
signal led_r : std_logic_vector ( 7 downto 0) := x"00";
signal cnt   : std_logic_vector (22 downto 0) := (others => '0');

begin
    -- assign both halves to led when enabled
    with en select
        led <= led_l & led_r when '1',
               x"0000"       when others;

    -- inc when enabled
    cnt_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                cnt <= cnt + 1;
            else
                cnt <= (others => '0');
            end if;
        end if;
    end process cnt_proc;

    -- inc when enabled
    cnt_p_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                if (tck = '1') then
                    cnt_p <= cnt_p + 1;
                end if;
            else
                cnt_p <= (others => '0');
            end if;
        end if;
    end process cnt_p_proc;

    -- pulse tck when cnt == 0
    tck_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (cnt = x"0") then
                tck <= '1';
            else
                tck <= '0';
            end if;
        end if;
    end process tck_proc;

    -- handle s_in (pulse) signal
    s_in_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (cnt_p < "0011") then
                s_in <= '1';
            else
                s_in <= '0';
            end if;
        end if;
    end process s_in_proc;

    -- shift in s_in signal
    led_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (tck = '1') then
                led_l <= led_l(6 downto 0) & s_in;
                led_r <= s_in & led_r(7 downto 1);
                --led_l(7) <= led_l(6);
                --led_l(6) <= led_l(5);
                --led_l(5) <= led_l(4);
                --led_l(4) <= led_l(3);
                --led_l(3) <= led_l(2);
                --led_l(2) <= led_l(1);
                --led_l(1) <= led_l(0);
                --led_l(0) <= s_in;
            end if;
        end if;
    end process led_proc;
end led_driver_arc;

