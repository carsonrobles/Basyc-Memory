
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: sseg decoder           --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- decodes 4 bit value to seven segment display
entity sseg_dcdr is
    port (
        dig : in  std_logic_vector (3 downto 0);        -- val input

        seg : out std_logic_vector (7 downto 0)         -- sseg output
    );
end sseg_dcdr;

architecture sseg_dcdr_arc of sseg_dcdr is
begin
    -- decode digits 1, 2, 3, 4; others are blank (invalid)
    case (dig) is
        when "0001" => seg <= "11111001";
        when "0010" => seg <= "10100100";
        when "0011" => seg <= "10110000";
        when "0100" => seg <= "10011001";
        when others => seg <= "11111111";
    end case;
end sseg_dcdr_arc;

