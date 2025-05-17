library ieee;
use ieee.std_logic_1164.all;

entity multi_led_switch is
    port (
        SW  : in  std_logic_vector(3 downto 0);   -- 4 switches
        LED : out std_logic_vector(3 downto 0)    -- 4 LEDs
    );
end entity multi_led_switch;

architecture Behavioral of multi_led_switch is
begin
    -- Each LED is controlled directly by its corresponding switch
    LED <= SW;
end architecture Behavioral;
