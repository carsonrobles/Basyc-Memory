
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: sseg driver            --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- decodes 4 bit value to seven segment display
entity sseg_driver is
    port (
        clk  : in  std_logic;                           -- clock signal

        data : in  std_logic_vector (31 downto 0);      -- input data

        an   : out std_logic_vector (3 downto 0);       -- anode out
        seg  : out std_logic_vector (7 downto 0)        -- cathode out
    );
end sseg_driver;

architecture sseg_driver_arc of sseg_dcdr is

begin

end sseg_driver_arc;

