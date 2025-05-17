library ieee;
use ieee.std_logic_1164.all;

entity led_switch is
    port (
        SW  : in  std_logic;   -- Input switch
        LED : out std_logic    -- Output LED
    );
end entity led_switch;

architecture Behavioral of led_switch is
begin
    -- The LED will turn on when the switch is pressed ('1'), and off when released ('0')
    LED <= SW;
end architecture Behavioral;
