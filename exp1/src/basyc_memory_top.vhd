
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

        btn : in  std_logic_vector ( 3 downto 0);       -- button inputs

        an  : out std_logic_vector ( 3 downto 0);       -- anode out
        seg : out std_logic_vector ( 7 downto 0);       -- cathode out

        led : out std_logic_vector (15 downto 0)        -- led out
    );
end basyc_memory_top;

architecture basyc_memory_top_arc of basyc_memory_top is

-- declare button debouncer
component debounce is
    port (
        clk   : in  std_logic;      -- clock signal

        btn_i : in  std_logic;      -- btn input

        btn_d : out std_logic       -- clean btn output
    );
end component debounce;

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
        addr  : in  std_logic_vector (3 downto 0);

        d_out : out std_logic_vector (1 downto 0) := "11"
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
type state_t is (idle, write, delay, wait_b, comp, win, lose);

-- present and next state signals
signal fsm, fsm_d : state_t                        := idle;

-- game signals
signal tck        : std_logic;
signal lvl_c      : std_logic_vector ( 3 downto 0) := "0000";
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
signal addr       : std_logic_vector ( 3 downto 0);

-- button signals
signal b_act      : std_logic;
signal b_act_z    : std_logic                      := '0';
signal psh        : std_logic;
signal rst_p      : std_logic;
signal rst_d      : std_logic;
signal rst_d_z    : std_logic                      := '0';
signal b_val      : std_logic_vector ( 1 downto 0) := "00";
signal btn_d      : std_logic_vector ( 3 downto 0) := "0000";

-- compare signal
signal cmp        : std_logic;

begin

-- ---------- BTN LOGIC ---------- --

    -- instantiate button debouncers for input buttons
    db0 : debounce port map (
        clk   => clk,
        btn_i => btn(0),
        btn_d => btn_d(0)
    );

    db1 : debounce port map (
        clk   => clk,
        btn_i => btn(1),
        btn_d => btn_d(1)
    );

    db2 : debounce port map (
        clk   => clk,
        btn_i => btn(2),
        btn_d => btn_d(2)
    );

    db3 : debounce port map (
        clk   => clk,
        btn_i => btn(3),
        btn_d => btn_d(3)
    );

    dbr : debounce port map (
        clk   => clk,
        btn_i => rst,
        btn_d => rst_d
    );

    -- assign push to b_act and not b_act_z to get pulse
    psh   <= b_act and (not b_act_z);

    -- assign b_act to or of all clean btn signals
    b_act <= btn_d(0) or btn_d(1) or btn_d(2) or btn_d(3);

    -- assign rst pulse signal edge detector
    rst_p <= rst_d and (not rst_d_z);

    -- one flop delay b_act for edge detect
    btn_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            b_act_z <= b_act;
        end if;
    end process btn_proc;

    -- one flop delay rst edge detect
    rst_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            rst_d_z <= rst_d;
        end if;
    end process rst_proc;

    -- btn to value encoder logic
    val_proc : process (btn_d)
    begin
        case (btn_d) is
            when "0001" => b_val <= "00";
            when "0010" => b_val <= "01";
            when "0100" => b_val <= "10";
            when "1000" => b_val <= "11";
            when others => b_val <= "00";
        end case;
    end process val_proc;

-- ---------- BTN LOGIC ---------- --

-- ---------- RAM LOGIC ---------- --

    -- instantiate ram
    mem : ram port map (
        clk   => clk,
        wr_en => wr_en,
        d_in  => d_in,
        addr  => addr,
        d_out => d_out
    );

    -- select address to ram
    with wr_en select
        addr <= lvl_c     when '1',
                lvl_c - 1 when others;

    -- assign wr_en signal high when in write state
    with fsm select
        wr_en <= '1' when write,
                 '0' when others;

-- ---------- RAM LOGIC ---------- --

-- ---------- SSEG LOGIC ---------- --

    -- instantiate sseg_driver
    ss_d : sseg_driver port map (
        clk  => clk,
        en   => ss_en,
        data => ss_dat,
        an   => an,
        seg  => seg
    );

    -- assign data sent to sseg
    with fsm select
        ss_dat <= "0000100001000111"       when idle,           -- displays "idle"
                  "0100010101100111"       when lose,           -- displays "lose"
                  "11111111111100" & d_out when others;         -- displays number

    -- assign sseg enable signal
    with fsm select
        ss_en <= '1' when delay,
                 '1' when idle,
                 '1' when lose,
                 '0' when others;

-- ---------- SSEG LOGIC ---------- --

-- ---------- LED LOGIC ---------- --
    -- instantiate led driver
    ld : led_driver port map (
        clk => clk,
        en  => led_en,
        led => led
    );
    -- assign led enable signal when in win state
    with fsm select
        led_en <= '1' when win,
                  '0' when others;

-- ---------- LED LOGIC ---------- --

-- ---------- OTHER GAME LOGIC ---------- --

    -- instantiate rand number generator
    r_gen : rand port map (
        clk => clk,
        num => d_in
    );

    -- compare signal high when data out == button value
    cmp_proc : process (d_out, b_val)
    begin
        if (d_out = b_val) then
            cmp <= '1';
        else
            cmp <= '0';
        end if;
    end process cmp_proc;

    -- assign tick signal to pulse every second
    with cnt_d select
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
            if ((wr_en = '1') or (fsm = comp)) then
                lvl_c <= lvl_c + 1;
            elsif ((fsm_d = wait_b) and (fsm = delay)) then
                lvl_c <= "0001";
            elsif (fsm = idle) then
                lvl_c <= "0000";
            end if;
        end if;
    end process lvl_proc;

-- ---------- OTHER GAME LOGIC ---------- --

-- ---------- FSM LOGIC ---------- --

    -- present state gets next state
    fsm_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            fsm <= fsm_d;
        end if;
    end process fsm_proc;

    -- combinatorial fsm logic
    comb_proc : process (fsm, rst_p, tck, lvl_c, psh, b_val, d_out, cmp)
    begin
        case (fsm) is
            when idle =>
                -- stay in idle until rst asserted
                if (rst_p = '1') then
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
                    if (lvl_c = "0000") then
                        fsm_d <= wait_b;
                    else
                        fsm_d <= write;
                    end if;
                else
                    fsm_d <= delay;
                end if;
            when wait_b =>
                if (psh = '1') then
                    fsm_d <= comp;
                else
                    fsm_d <= wait_b;
                end if;
            when comp =>
                -- if not equal lose
                if (cmp = '1') then
                    if (lvl_c = "0000") then
                        fsm_d <= win;
                    else
                        fsm_d <= wait_b;
                    end if;
                else
                    fsm_d <= lose;
                end if;
            when win =>
                -- if reset go to idle
                if (rst_p = '1') then
                    fsm_d <= idle;
                else
                    fsm_d <= win;
                end if;
            when lose =>
                -- if reset go to idle
                if (rst_p = '1') then
                    fsm_d <= idle;
                else
                    fsm_d <= lose;
                end if;
        end case;
    end process comb_proc;

-- ---------- FSM LOGIC ---------- --

end basyc_memory_top_arc;

