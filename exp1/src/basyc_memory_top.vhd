
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
entity basyc_memory_top is
    port (
        clk : in  std_logic;                            -- clock input
        rst : in  std_logic;                            -- reset signal

        an  : out std_logic_vector ( 3 downto 0);       -- anode out
        seg : out std_logic_vector ( 7 downto 0);       -- cathode out

        led : out std_logic_vector (15 downto 0)        -- led out
    );
end basyc_memory_top;

architecture basyc_memory_top_arc of basyc_memory_top is

-- declare seven segment driver
component sseg_driver is
    port (
        clk  : in  std_logic;                           -- clock signal

        en   : in  std_logic;                           -- enable signal
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

-- declare led driver
component led_driver is
    port (
        clk : in  std_logic;                        -- clock signal

        en  : in  std_logic;                        -- pattern plays when enable is high

        led : out std_logic_vector (15 downto 0)    -- pattern output
    );
end component led_driver;

-- state type definition
type state_t is (idle, write, delay, win);

-- present and next state signals
signal fsm, fsm_d : state_t                        := idle;

-- game signals
signal tck        : std_logic;
signal lvl_c      : std_logic_vector ( 2 downto 0) := "000";
signal cnt_d      : std_logic_vector (26 downto 0) := (others => '0');

-- sseg enable
signal ss_en      : std_logic                      := '0';

-- sseg data
signal ss_dat     : std_logic_vector (15 downto 0) := (others => '0');

-- led win enable
signal led_en     : std_logic                      := '0';

-- ram signals
signal wr_en      : std_logic                      := '0';
signal d_in       : std_logic_vector ( 1 downto 0);
signal d_out      : std_logic_vector ( 1 downto 0);
signal addr       : std_logic_vector ( 2 downto 0);

begin
    -- instantiate sseg_driver
    ss_d : sseg_driver port map (
        clk  => clk,
        en   => ss_en,
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
        addr  => addr,
        d_out => d_out
    );

    -- instantiate led driver
    ld : led_driver port map (
        clk => clk,
        en  => led_en,
        led => led
    );

    -- assign data sent to sseg
    ss_dat <= "11111111111100" & d_out;

    -- select address to ram
    with wr_en select
        addr <= lvl_c     when '1',
                lvl_c - 1 when others;

    -- assign wr_en signal high when in write state
    with fsm select
        wr_en <= '1' when write,
                 '0' when others;

    -- assign sseg enable signal
    with fsm select
        ss_en <= '1' when delay,
                 '0' when others;

    -- assign led enable signal when in win state
    with fsm select
        led_en <= '1' when win,
                  '0' when others;

    -- assign tick signal to pulse every second
    --with cnt_d(2 downto 0) select             -- uncomment for sim
    with cnt_d select
        --tck <= '1' when "111",                -- uncomment for sim
        tck <= '1' when x"5f5e101",
               '0' when others;

    -- handle counter when in delay
    cnt_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            -- increment counter when in delay, clear otherwise
            if (fsm = delay) then
                cnt_d <= cnt_d + 1;
            else
                cnt_d <= (others => '0');
            end if;
        end if;
    end process cnt_proc;

    -- handle level: inc after write signal asserted
    lvl_proc : process (clk, wr_en)
    begin
        if (rising_edge(clk)) then
            -- inc lvl_c when moving out of write state
            if (wr_en = '1') then
                lvl_c <= lvl_c + 1;
            end if;
        end if;
    end process lvl_proc;

    -- present state gets next state
    fsm_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            fsm <= fsm_d;
        end if;
    end process fsm_proc;

    -- combinatorial fsm logic
    comb_proc : process (fsm, rst, tck, lvl_c)
    begin
        case (fsm) is
            when idle  =>
                -- stay in idle until rst asserted
                if (rst = '1') then
                    fsm_d <= write;
                else
                    fsm_d <= idle;
                end if;
            when write =>
                -- transition to delay state
                fsm_d <= delay;
            when delay =>
                -- stay in delay until tck signal
                if (tck = '1') then
                    if (lvl_c = "000") then
                        fsm_d <= win;
                    else
                        fsm_d <= write;
                    end if;
                else
                    fsm_d <= delay;
                end if;
            when win =>
                fsm_d <= win;
        end case;
    end process comb_proc;
end basyc_memory_top_arc;

