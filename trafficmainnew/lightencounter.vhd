library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lightcounter is
    port (
        clr   : in std_logic;
        clk   : in std_logic;
        switch: in std_logic_vector(1 downto 0);
        status: out std_logic
    );
end entity lightcounter;

architecture count_arch of lightcounter is
    signal waitingTime : integer := 10;
    signal yellowTime  : integer := 5;
    signal counter     : integer := 0;
begin
    timer: process(clr, clk)
    begin
        if rising_edge(clk) then
            if clr = '1' then
                counter <= 0;
                status  <= '0';
            elsif switch = "10" then
                if counter < waitingTime then
                    counter <= counter + 1;
                    status  <= '0';
                else
                    status  <= '1';
                    counter <= 0;
                end if;
            elsif switch = "01" then
                if counter < yellowTime then
                    counter <= counter + 1;
                    status  <= '0';
                else
                    status  <= '1';
                    counter <= 0;
                end if;
            else
                counter <= 0;
                status  <= '0';
            end if;
        end if;
    end process;
end architecture;
