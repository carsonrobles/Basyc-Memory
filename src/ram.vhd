
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/22/2016 06:00:00 PM --
-- Description: ram                    --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- random access memory
entity ram is
    port (
        clk   : in  std_logic;

        wr_en : in  std_logic;
        d_in  : in  std_logic_vector (1 downto 0);
        addr  : in  std_logic_vector (2 downto 0);

        d_out : out std_logic_vector (1 downto 0)
    );
end ram;

architecture ram_arc of ram is

-- define internal ram array type
type ram_t is array (0 to 7) of std_logic_vector (1 downto 0);

-- declare internal memory and initialize to 0
signal mem : ram_t := (others => (others => '0'));

begin
    -- assign d_out to memory at addr
    d_out <= mem(conv_integer(addr));

    -- assign memory at addr to d_in at clk edge when wr_en == 1
    wr_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (wr_en = '1') then
                mem(conv_integer(addr)) <= d_in;
            end if;
        end if;
    end process wr_proc;
end ram_arc;

