library ieee;
use ieee.std_logic_1164.all;
use work.pill_package.all;

entity pill_dispenser is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        db_switch : in  std_logic_vector(1 downto 0);
        echo      : in  std_logic;
        serial    : in  std_logic;
        pwm       : out std_logic_vector(CONTAINERS-1 downto 0);
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
    signal s_trigger : std_logic;
    signal s_pwm     : std_logic_vector(CONTAINERS-1 downto 0);
    signal s_state, dispenser_state, rx_state, sensor_state : std_logic_vector(3 downto 0);

    -- data flow and control unit signals
    signal s_safety_end, s_check_end, s_count : std_logic;
    signal s_move, s_discount, s_alert        : std_logic;
    
    -- debug auxiliary signal
    signal s_measurement : std_logic_vector(11 downto 0);

    component pill_dispenser_fd is
        port (
            clock      : in  std_logic;
            reset      : in  std_logic;
            serial     : in  std_logic;
            echo       : in  std_logic;
            count      : in  std_logic;
            move       : in  std_logic;
            discount   : in  std_logic;
            -- outputs
            trigger    : out std_logic;
            check_end  : out std_logic;
            safety_end : out std_logic;
            pwm        : out std_logic_vector(CONTAINERS-1 downto 0);
            alert      : out std_logic;
            -- debug
            db_measurement : out std_logic_vector(11 downto 0);
            -- states
            rx_state     : out std_logic_vector(3 downto 0);
            sensor_state : out std_logic_vector(3 downto 0)
        );
    end component;

    component pill_dispenser_uc is
        port (
            clock          : in  std_logic;
            reset          : in  std_logic;
            check_timeout  : in  std_logic;
            safety_timeout : in  std_logic;
            detected       : in  std_logic;
            -- control
            count          : out std_logic;
            move           : out std_logic;
            discount       : out std_logic;
            -- debug
            db_state       : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    DF: pill_dispenser_fd
        port map (
            clock          => clock,
            reset          => reset,
            serial         => serial,
            echo           => echo,
            count          => s_count,
            move           => s_move,       
            discount       => s_discount,           
            -- outputs
            trigger        => s_trigger,
            check_end      => s_check_end,
            safety_end     => s_safety_end,    
            pwm            => s_pwm,
            alert          => s_alert,
            -- debug
            db_measurement => s_measurement,
            -- states
            rx_state       => rx_state,
            sensor_state   => sensor_state
        );

    UC: pill_dispenser_uc
        port map (
            clock          => clock,
            reset          => reset,
            check_timeout  => s_check_end,
            safety_timeout => s_safety_end,
            --!! colocar s_alert em and com detecção do sensor de objeto próximo !!--
            detected       => s_alert,
            -- control
            count          => s_count,
            move           => s_move,
            discount       => s_discount,
            -- debug
            db_state       => dispenser_state
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

    -- outputs
    trigger    <= s_trigger;
    pwm        <= s_pwm;
    alert      <= s_alert;

    -- debug
    db_reset   <= reset;
    db_pwm     <= s_pwm(0);
    db_echo    <= echo;
    db_trigger <= s_trigger;

end architecture;