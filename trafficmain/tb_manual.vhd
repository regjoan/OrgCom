library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all ;

entity tb_manual is
end tb_manual ; 

architecture test of tb_manual is
    component trafficlight_main
        port (
            clr      : in std_logic;
            clk      : in std_logic;
            mode     : in std_logic;
            condition: in std_logic_vector(2 downto 0);
            green    : out std_logic_vector(3 downto 0);
            yellow   : out std_logic_vector(3 downto 0);
            red      : out std_logic_vector(3 downto 0)
        );
    end component;

    signal clk, clr, mode: std_logic;
    signal condition: std_logic_vector(2 downto 0) := (others => '0');
    signal green: std_logic_vector(3 downto 0);
    signal yellow: std_logic_vector(3 downto 0);
    signal red: std_logic_vector(3 downto 0);
    constant period: time := 100 ps;
begin
    main: trafficlight_main port map (
        clr      => clr,
        clk      => clk,
        mode     => mode,
        condition=> condition,
        green    => green,
        yellow   => yellow,
        red      => red
    );

    clk_process: process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

    tb_manual: process
    begin
        -- Condition 0 -> State S8
        clr <= '0';
        mode <= '1';
        condition <= "000";
        wait for period;
        assert green = "0000" report "State salah pada condition ke-0" severity error;
        assert yellow = "0000" report "State salah pada condition ke-0" severity error;
        assert red = "1111" report "State salah pada condition ke-0" severity error;
        
        -- Condition 1 -> State S0
        clr <= '0';
        mode <= '1';
        condition <= "001";
        wait for period;
        assert green = "1000" report "State salah pada condition ke-1" severity error;
        assert yellow = "0000" report "State salah pada condition ke-1" severity error;
        assert red = "0111" report "State salah pada condition ke-1" severity error;

        -- Condition 2 -> State S2
        clr <= '0';
        mode <= '1';
        condition <= "010";
        wait for period;
        assert green = "0100" report "State salah pada condition ke-2" severity error;
        assert yellow = "0000" report "State salah pada condition ke-2" severity error;
        assert red = "1011" report "State salah pada condition ke-2" severity error;

        -- Condition 3 -> State S4
        clr <= '0';
        mode <= '1';
        condition <= "011";
        wait for period;
        assert green = "0010" report "State salah pada condition ke-3" severity error;
        assert yellow = "0000" report "State salah pada condition ke-3" severity error;
        assert red = "1101" report "State salah pada condition ke-3" severity error;

        -- Condition 4 -> State S6
        clr <= '0';
        mode <= '1';
        condition <= "100";
        wait for period;
        assert green = "0001" report "State salah pada condition ke-4" severity error;
        assert yellow = "0000" report "State salah pada condition ke-4" severity error;
        assert red = "1110" report "State salah pada condition ke-4" severity error;

        wait;
    end process;
end architecture;
