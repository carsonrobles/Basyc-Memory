
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: sseg driver            --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- decodes 4 bit value to seven segment display
entity sseg_driver is
    port (
        clk  : in  std_logic;                           -- clock signal

        data : in  std_logic_vector (15 downto 0);      -- input data

        an   : out std_logic_vector ( 3 downto 0);      -- anode out
        seg  : out std_logic_vector ( 7 downto 0)       -- cathode out
    );
end sseg_driver;

architecture sseg_driver_arc of sseg_dcdr is

-- decodes 4 bit value to seven segment display
component sseg_dcdr is
    port (
        dig : in  std_logic_vector (3 downto 0);        -- val input

        seg : out std_logic_vector (7 downto 0)         -- sseg output
    );
end component sseg_dcdr;

-- tick signal pulses when to switch anodes
signal tck   : std_logic                      := '0';
-- temp anode select signal; ease with active low an signal
signal a_sel : std_logic_vector ( 3 downto 0) := "0001";
-- 4-bit data select
signal d_sel : std_logic_vector ( 3 downto 0) := "0000";
-- counter
signal cnt   : std_logic_vector (15 downto 0) := (others => '0');

begin
    -- instantiate sseg decoder
    sd : sseg_dcdr port map (
        dig => d_sel,
        seg => seg
    );

    -- assign active low an to active high temp signal
    an <= not a_sel;


    -- increment cnt at posedge clk
    cnt_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            cnt <= cnt + 1;
        end if;
    end process tck_proc;

    -- pulse tck signal when cnt overflows
    tck_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (cnt = x"ffff") then
                tck <= '1';
            else
                tck <= '0';
            end if;
        end if;
    end process tck_proc;

    -- iterate over active anodes
    an_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (tck = '1') then
                a_sel(3) <= a_sel(2);
                a_sel(2) <= a_sel(1);
                a_sel(1) <= a_sel(0);
                a_sel(0) <= a_sel(3);
            end if;
        end if;
    end process an_proc;

    -- select window of data to decode
    d_proc : process (clk)
        if (rising_edge(clk)) then
            case (a_sel) is
                when "0001" => d_sel <= data( 3 downto  0);
                when "0010" => d_sel <= data( 7 downto  4);
                when "0100" => d_sel <= data(11 downto  8);
                when "1000" => d_sel <= data(15 downto 12);
                when others => d_sel <= "0000";
            end case;
        end if;
end sseg_driver_arc;

