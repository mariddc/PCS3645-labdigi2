library ieee;
use ieee.std_logic_1164.all;
use work.pill_package.hexa7seg;

entity pill_dispenser is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        db_switch : in  std_logic_vector(1 downto 0);
        echo      : in  std_logic;
        serial    : in  std_logic;
        pwm       : out std_logic;
        trigger   : out std_logic;
        alert     : out std_logic;
        -- debug
        db_reset   : out std_logic;
        db_pwm     : out std_logic;
        db_echo    : out std_logic;
        db_trigger : out std_logic;
        db_state       : out std_logic_vector(6 downto 0);
        db_measurement : out std_logic_vector(20 downto 0)
    );
end entity;

architecture rtl of pill_dispenser is

    -- servo, sensor and states (debug)
    signal s_pwm, s_echo, s_trigger : std_logic;
    signal s_state, dispenser_state, rx_state, sensor_state : std_logic_vector(3 downto 0);

    signal s_measurement : std_logic_vector(11 downto 0);

    component pill_dispenser_fd is
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
    end component;

begin

    DF: pill_dispenser_fd
        port map (
            clock          => clock,
            reset          => reset,
            serial         => serial,
            echo           => echo,
            trigger        => trigger,
            alert          => alert,
            db_measurement => s_measurement,
            rx_state       => rx_state,
            sensor_state   => sensor_state
        );

    with db_switch select
        s_state <= dispenser_state when "00",
                   sensor_state    when "01",
                   rx_state        when others;

    HEX5: hexa7seg
        port map (hexa => s_state, sseg => db_state);

    -- measurement displays (HEX0, HEX1, HEX2)
    MEAS: for i in 0 to 2 generate
        HEX_I: hexa7seg
            port map (
                hexa => s_measurement((4*i + 3) downto 4*i),
                sseg => db_measurement((7*i + 6) downto 7*i)
            );
    end generate;

    db_reset   <= reset;
    db_pwm     <= s_pwm;
    db_echo    <= s_echo;
    db_trigger <= s_trigger;

end architecture;