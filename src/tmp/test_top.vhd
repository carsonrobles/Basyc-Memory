
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: top level module       --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- top level module for Basyc Memory game
entity test_top is
    port (
        clk : in  std_logic;                            -- clock input
        rst : in  std_logic;                            -- reset signal

        an  : out std_logic_vector ( 3 downto 0);       -- anode out
        seg : out std_logic_vector ( 7 downto 0);       -- cathode out

        led : out std_logic_vector (15 downto 0)        -- led out
    );
end test_top;

architecture basyc_memory_top_arc of test_top is
--signal clk : std_logic;
-- declare seven segment driver
component sseg_driver is
    port (
        clk  : in  std_logic;                           -- clock signal

        data : in  std_logic_vector (15 downto 0);      -- input data

        an   : out std_logic_vector ( 3 downto 0);      -- anode out
        seg  : out std_logic_vector ( 7 downto 0)       -- cathode out
    );
end component sseg_driver;

-- declare rand
component rand is
    port (
        clk : in  std_logic;

        num : out std_logic_vector (1 downto 0)         -- random output between 0 and 3
    );
end component rand;

-- declare ram
component ram is
    port (
        clk   : in  std_logic;

        wr_en : in  std_logic;
        d_in  : in  std_logic_vector (1 downto 0);
        addr  : in  std_logic_vector (2 downto 0);

        d_out : out std_logic_vector (1 downto 0)
    );
end component ram;

--component clk_div2 is
    --Port (  clk : in std_logic;
           --sclk : out std_logic);
--end component clk_div2;

-- state type definition
type state_t is (idle, write, delay);

-- present and next state signals
signal fsm, fsm_d : state_t                        := idle;

-- game signals
signal tck        : std_logic;
signal lvl_c      : std_logic_vector ( 2 downto 0) := "000";
signal lvl_g      : std_logic_vector ( 2 downto 0) := "001";
signal cnt_d      : std_logic_vector (26 downto 0) := (others => '0');

-- sseg data
signal ss_dat     : std_logic_vector (15 downto 0) := (others => '0');

-- ram signals
signal wr_en      : std_logic;
signal d_in       : std_logic_vector ( 1 downto 0);
signal d_out      : std_logic_vector ( 1 downto 0);

begin
    -- instantiate sseg_driver
    ss_d : sseg_driver port map (
        clk  => clk,
        data => ss_dat,
        an   => an,
        seg  => seg
    );

    -- instantiate rand
    r_gen : rand port map (
        clk => clk,
        num => d_in
    );

    -- instantiate ram
    mem : ram port map (
        clk   => clk,
        wr_en => wr_en,
        d_in  => d_in,
        addr  => lvl_c,
        d_out => d_out
    );

    ss_dat <= "11111111111100" & d_out;

    with fsm select
        led(14 downto 0) <= "111" & x"fff" when idle,
               "000" & x"0f0" when write,
               "000" & x"00f" when delay;
    led(15) <= tck;

    with cnt_d select
        tck <= '1' when x"5f5e100",
               '0' when others;

    st_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (fsm = delay) then
                cnt_d <= cnt_d + 1;
            else
                cnt_d <= (others => '0');
            end if;
        end if;
    end process st_proc;

    -- present state gets next state
    fsm_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            fsm <= fsm_d;
        end if;
    end process fsm_proc;

    -- combinatorial fsm logic
    comb_proc : process (fsm, rst, tck, lvl_c, lvl_g)
    begin
        case (fsm) is
            when idle  =>
                wr_en <= '0';
                -- stay in idle until rst asserted
                if (rst = '1') then
                    fsm_d <= write;
                else
                    fsm_d <= idle;
                end if;
            when write =>
                wr_en <= '1';
                -- transition to delay state
                fsm_d <= delay;
            when delay =>
                wr_en <= '0';
                -- stay in delay until tck signal
                if (tck = '1') then
                    if (lvl_c = lvl_g) then
                        fsm_d <= write;
                    else
                        fsm_d <= write;
                    end if;
                else
                    fsm_d <= delay;
                end if;
        end case;
    end process comb_proc;
end basyc_memory_top_arc;

