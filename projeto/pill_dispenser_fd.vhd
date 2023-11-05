library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.pill_package.all;

entity pill_dispenser_fd is
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        serial  : in  std_logic;
        echo    : in  std_logic;
        trigger : out std_logic;
        alert   : out std_logic;
        -- debug
        db_measurement : out std_logic_vector(11 downto 0);
        -- states
        rx_state     : out std_logic_vector(3 downto 0);
        sensor_state : out std_logic_vector(3 downto 0)
    );
end entity;

architecture df_arch of pill_dispenser_fd is

    signal s_dosage : std_logic_vector(6 downto 0);
    signal containers_enable : std_logic_vector(containers_range);
    signal pill_containers   : pill_count;

begin

    RX: rx_serial_7O1
        port map (
            clock             => clock,
            reset             => reset,
            dado_serial       => serial,
            dado_recebido     => s_dosage,
            paridade_recebida => open,
            pronto            => open,
            db_dado_serial    => open,
            db_estado         => rx_state
        );

    HCSR04: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => ,
            echo      => echo,
            trigger   => trigger,
            medida    => db_measurement,
            pronto    => ,
            db_reset  => open,
            db_medir  => open,
            db_estado => sensor_state
        );

    -- 4 bits to identify the container (6 downto 3) and
    -- the 3 least significant bits to indicate the proper dosage of the container (2 downto 0)
    CONTAINERS: for i in pill_containers'range generate
        containers_enable(i) <= '1' when i = to_integer(unsigned(s_dosage(6 downto 3))) else '0';

        PILL_COUNT: downwards_counter
            generic map (N => 3)
            port map (
                clock  => clock,
                clear  => reset,
                count  => '1',   
                enable => containers_enable(i),
                D      => s_dosage(2 downto 0),
                Q      => pill_containers(i)
            );
    end generate;



end architecture;