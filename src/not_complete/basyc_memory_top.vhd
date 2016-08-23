
-----------------------------------------
--                                     --
-- Engineer:    Carson Robles          --
-- Create Date: 08/18/2016 10:00:00 PM --
-- Description: top level module       --
--                                     --
-----------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- top level module for Basyc Memory game
entity basyc_memory_top is
    port (
        clk : in  std_logic;                            -- clock input
        rst : in  std_logic;                            -- reset signal

        btn : in  std_logic_vector ( 3 downto 0);       -- user input buttons

        an  : out std_logic_vector ( 3 downto 0);       -- anode out
        seg : out std_logic_vector ( 7 downto 0);       -- cathode out

        led : out std_logic_vector (15 downto 0)        -- led out
    );
end basyc_memory_top;

architecture basyc_memory_top_arc of basyc_memory_top is

-- declare debouncer
component debounce is
    port (
        clk   : in  std_logic;      -- clock signal

        btn_i : in  std_logic;      -- btn input

        btn_d : out std_logic       -- clean btn output
    );
end component debounce;

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

-- state type definition
type state_t is (idle, disp, ram_w, delay, b_in, comp, lose, win);

-- present and next state signals
signal fsm, fsm_d : state_t                        := idle;

-- high when a button is pushed
signal b_act      : std_logic;

-- button value 0-3
signal b_val      : std_logic_vector (1 downto 0);

-- clean debounced button signals
signal rst_d      : std_logic;
signal btn_d      : std_logic_vector (3 downto 0);

-- push signals
signal psh        : std_logic;
signal psh_z      : std_logic;

-- game lvl registers
signal lvl_c      : std_logic_vector (2 downto 0)  := "000";
signal lvl_g      : std_logic_vector (2 downto 0)  := "001";
signal uin_c      : std_logic_vector (2 downto 0)  := "000";

-- ram signals
signal wr_en      : std_logic                      := '0';
signal d_in       : std_logic_vector (1 downto 0);
signal d_out      : std_logic_vector (1 downto 0);

-- delay counter
signal cnt_d      : std_logic_vector (17 downto 0) := (others => '0');

-- delay tick
signal tck        : std_logic;

begin
    -- instantiate debouncers
    dbr : debounce port map (
        clk   => clk,
        btn_i => rst,
        btn_d => rst_d
    );

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

    -- instantiate ram
    mem : ram port map (
        clk   => clk,
        wr_en => wr_en,
        d_in  => d_in,
        addr  => lvl_c,
        d_out => d_out
    );

    -- create write enable strobe
    wr_en <= (fsm = ram_w);

    -- create tck pulse
    tck   <= (cnt_d = x"0");

    -- assign active signal
    b_act <= btn_d(0) or btn_d(1) or btn_d(2) or btn_d(3);

    -- pulse psh signal for one clock
    psh   <= (not psh_z) and b_act;

    -- shift in clean push signal
    psh_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            psh_z <= b_act;
        end if;
    end process psh_proc;

    -- btn encoder
    btn_proc : process (btn_d)
    begin
        case (btn_d) is
            when "0001" =>
                b_val <= "00";

            when "0010" =>
                b_val <= "01";

            when "0100" =>
                b_val <= "10";

            when "1000" =>
                b_val <= "11";
            when others =>
                b_val <= "00";
        end case;
    end process btn_proc;

    st_proc : process (clk)
    begin
        if (fsm = idle) then
            lvl_c <= "000";
            lvl_g <= "001";
            cnt_d <= (others => '0');
        elsif (fsm = delay) then
            cnt_d <= cnt_d + 1;
        elsif (fsm = b_in) then
        end if;
    end process st_proc;

    -- ----- FSM LOGIC ----- --

    -- present state gets next state
    fsm_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            fsm <= fsm_d;
        end if;
    end process fsm_proc;

    -- combinatorial fsm logic
    comb_proc : process (fsm, rst_d)
    begin
        case (fsm) is
            when idle  =>
                -- stay in idle until rst asserted
                if (rst = '1') then
                    fsm_d <= disp;
                else
                    fsm_d <= idle;
                end if;
            when disp  =>
                -- transition to ram_w state
                fsm_d <= ram_w;
            when ram_w =>
                -- transition to delay state
                fsm_d <= delay;
            when delay =>
                -- stay in delay until tck signal
                if (tck = '1') then
                    -- if current level equals game level switch to user input state otherwise disp new num
                    if (lvl_c = lvl_g) then
                        fsm_d <= b_in;
                    else
                        fsm_d <= disp;
                    end if;
                else
                    fsm_d <= delay;
                end if;
            when b_in  =>
                -- if all buttons low stay in b_in
                if (b_act = '1') then
                    fsm_d <= b_in;
                else
                    fsm_d <= comp;
                end if;
            when comp  =>
                -- if correct button and not at end go to b_in, if incorrect lose
                if (d_out = b_val) then
                    if (lvl_c = lvl_g) then
                        fsm_d <= win;
                    else
                        fsm_d <= b_in;
                    end if;
                else
                    fsm_d <= lose;
                end if;
            when lose  =>
                -- stay in lose until rst asserted
                if (rst = '1') then
                    fsm_d <= idle;
                else
                    fsm_d <= lose;
                end if;
            when win   =>
                -- stay in win until rst asserted
                if (rst = '1') then
                    fsm_d <= idle;
                else
                    fsm_d <= win;
                end if;
        end case;
    end process comb_proc;
end basyc_memory_top_arc;

