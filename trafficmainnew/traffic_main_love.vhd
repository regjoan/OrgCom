library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity trafficlight_main is
    port(
        clr      : in std_logic;
        clk      : in std_logic;
        mode     : in std_logic;
        condition: in std_logic_vector(1 downto 0); -- 2 bits for manual
        LEDR     : out std_logic_vector(2 downto 0) -- Physical LEDs
    );
end entity trafficlight_main;

architecture behavior of trafficlight_main is
    component lightcounter is
        port(
            clr   : in std_logic;
            clk   : in std_logic;
            switch: in std_logic_vector(1 downto 0);
            status: out std_logic
        );
    end component;

    type stateType is (NS_GREEN, NS_YELLOW, EW_GREEN, EW_YELLOW, ALL_RED);
    signal state, nextState: stateType;
    signal status: std_logic := '0';
    signal switch : std_logic_vector(1 downto 0) := "00";
    signal NS_lamp, EW_lamp: std_logic_vector(1 downto 0); -- [1]=red, [0]=green
    signal yellow_active: std_logic := '0';
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
        NS_lamp <= "00";
        EW_lamp <= "00";
        yellow_active <= '0';
        case state is
            when NS_GREEN =>
                NS_lamp <= "01"; -- NS green
                EW_lamp <= "10"; -- EW red
                switch <= "10";
                nextState <= NS_YELLOW;
            when NS_YELLOW =>
                NS_lamp <= "10"; -- NS yellow (show as red for LED)
                EW_lamp <= "10"; -- EW red
                yellow_active <= '1';
                switch <= "01";
                nextState <= EW_GREEN;
            when EW_GREEN =>
                NS_lamp <= "10"; -- NS red
                EW_lamp <= "01"; -- EW green
                switch <= "10";
                nextState <= EW_YELLOW;
            when EW_YELLOW =>
                NS_lamp <= "10"; -- NS red
                EW_lamp <= "10"; -- EW yellow (show as red for LED)
                yellow_active <= '1';
                switch <= "01";
                nextState <= NS_GREEN;
            when ALL_RED =>
                NS_lamp <= "10"; -- NS red
                EW_lamp <= "10"; -- EW red
                nextState <= NS_GREEN;
        end case;
    end process;

    -- Map to physical LEDs
    -- LEDR(0) = NS lamp (green = '1', yellow/red = '0')
    -- LEDR(1) = EW lamp (green = '1', yellow/red = '0')
    -- LEDR(2) = yellow_active or "all red"
    LEDR(0) <= NS_lamp(0);    -- green for NS
    LEDR(1) <= EW_lamp(0);    -- green for EW
    LEDR(2) <= yellow_active; -- lights up when yellow phase active

end architecture;
