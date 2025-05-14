library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity traffic_light_controller is
    Port (
        clk       : in STD_LOGIC;  -- 50 MHz clock input
        reset     : in STD_LOGIC;  -- Reset button
        ns_lights : out STD_LOGIC_VECTOR(2 downto 0); -- North-South lights (Red, Yellow, Green)
        ew_lights : out STD_LOGIC_VECTOR(2 downto 0)  -- East-West lights (Red, Yellow, Green)
    );
end traffic_light_controller;

architecture Behavioral of traffic_light_controller is
    type state_t is (S0, S1, S2, S3); -- State encoding
    signal current_state, next_state : state_t;

    signal clk_divider : STD_LOGIC_VECTOR(25 downto 0) := (others => '0'); -- 26-bit counter for 50 MHz to 1 Hz
    signal slow_clk    : STD_LOGIC := '0';

    signal timer       : INTEGER range 0 to 15 := 0; -- 4-bit counter for state duration
begin

    -- Clock Divider: Generate 1 Hz slow clock from 50 MHz clock
    process (clk, reset)
    begin
        if reset = '1' then
            clk_divider <= (others => '0');
            slow_clk <= '0';
        elsif rising_edge(clk) then
            if clk_divider = "11000011010100000000000000" then -- 25_000_000 in binary
                clk_divider <= (others => '0');
                slow_clk <= not slow_clk;
            else
                clk_divider <= clk_divider + 1;
            end if;
        end if;
    end process;

    -- State Transition Process
    process (slow_clk, reset)
    begin
        if reset = '1' then
            timer <= 0;
            current_state <= S0;
        elsif rising_edge(slow_clk) then
            if timer = 5 then -- 5 seconds for Green, 2 seconds for Yellow
                timer <= 0;
                current_state <= next_state;
            else
                timer <= timer + 1;
            end if;
        end if;
    end process;

    -- Next State Logic
    process (current_state)
    begin
        case current_state is
            when S0 => next_state <= S1; -- NS Green → NS Yellow
            when S1 => next_state <= S2; -- NS Yellow → EW Green
            when S2 => next_state <= S3; -- EW Green → EW Yellow
            when S3 => next_state <= S0; -- EW Yellow → NS Green
            when others => next_state <= S0;
        end case;
    end process;

    -- Output Logic
    process (current_state)
    begin
        case current_state is
            when S0 => -- NS Green, EW Red
                ns_lights <= "001"; -- Green
                ew_lights <= "100"; -- Red
            when S1 => -- NS Yellow, EW Red
                ns_lights <= "010"; -- Yellow
                ew_lights <= "100"; -- Red
            when S2 => -- NS Red, EW Green
                ns_lights <= "100"; -- Red
                ew_lights <= "001"; -- Green
            when S3 => -- NS Red, EW Yellow
                ns_lights <= "100"; -- Red
                ew_lights <= "010"; -- Yellow
            when others =>
                ns_lights <= "100"; -- Default to Red
                ew_lights <= "100"; -- Default to Red
        end case;
    end process;

end Behavioral;
