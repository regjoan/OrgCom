library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trafficlight_main is
    port(
        clr: in std_logic;
        clk: in std_logic;
        mode: in std_logic;
        condition : in std_logic_vector(1 downto 0); -- 2 bit cukup untuk manual mode (0: all red, 1: NS green, 2: EW green)
        green: out std_logic_vector(1 downto 0);    -- [1]=NS, [0]=EW
        yellow: out std_logic_vector(1 downto 0);
        red: out std_logic_vector(1 downto 0)
    );
end entity trafficlight_main;

architecture behavior of trafficlight_main is
    component lightcounter is
        port(
            clr: in std_logic;
            clk: in std_logic;
            switch: in std_logic_vector(1 downto 0);
            status: out std_logic
        );
    end component;

    type stateType is (NS_GREEN, NS_YELLOW, EW_GREEN, EW_YELLOW, ALL_RED);
    signal state, nextState: stateType;
    signal status: std_logic := '0';
    signal switch : std_logic_vector(1 downto 0) := "00";
begin
    timer: lightcounter port map(
        clr    => clr,
        clk    => clk,
        switch => switch,
        status => status
    );

    seq: process (clr, mode, clk, condition, state)
        variable cond_int : integer range 0 to 2;
    begin
        cond_int := to_integer(unsigned(condition));
        if mode = '0' then
            if clr = '1' then
                state <= NS_GREEN;
            elsif rising_edge(clk) and status = '1' then
                state <= nextState;
            end if;
        elsif mode = '1' then
            case cond_int is
                when 0 => state <= ALL_RED;
                when 1 => state <= NS_GREEN;
                when 2 => state <= EW_GREEN;
                when others => state <= ALL_RED;
            end case;
        end if;
    end process;

    comb: process (state)
    begin
        switch <= "00";
        case state is
            when NS_GREEN =>
                green  <= "10";  -- NS
                yellow <= "00";
                red    <= "01";  -- EW
                switch <= "10";  -- timer untuk green
                nextState <= NS_YELLOW;
            when NS_YELLOW =>
                green  <= "00";
                yellow <= "10";  -- NS
                red    <= "01";  -- EW
                switch <= "01";  -- timer untuk yellow
                nextState <= EW_GREEN;
            when EW_GREEN =>
                green  <= "01";  -- EW
                yellow <= "00";
                red    <= "10";  -- NS
                switch <= "10";
                nextState <= EW_YELLOW;
            when EW_YELLOW =>
                green  <= "00";
                yellow <= "01";  -- EW
                red    <= "10";  -- NS
                switch <= "01";
                nextState <= NS_GREEN;
            when ALL_RED =>
                green  <= "00";
                yellow <= "00";
                red    <= "11";
                nextState <= NS_GREEN;
        end case;
    end process;

end architecture;
