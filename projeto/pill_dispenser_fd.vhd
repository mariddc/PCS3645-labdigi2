library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use ieee.math_real.all;
use work.pill_package.all;

entity pill_dispenser_fd is
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
end entity;

architecture df_arch of pill_dispenser_fd is

    constant pwm_period : natural := 1_000_000;

    -- 2 seconds timer [100_000_000 / 12] (real/simu)
    constant check_timeout       : natural := 100_000_000;
    constant check_timeout_bits  : natural := natural(ceil(log2(real(check_timeout))));
    
    -- 500 milliseconds delay [25_000_000 / 4] (real/simu)
    constant safety_timeout      : natural := 25_000_000;
    constant safety_timeout_bits : natural := natural(ceil(log2(real(safety_timeout))));

    -- dosage and containers
    signal s_dosage          : std_logic_vector(6 downto 0);
    signal containers_enable : std_logic_vector(containers_range);
    signal pill_containers   : pill_count;

    -- auxiliary signals
    signal s_pwm, s_count_reset : std_logic;
    signal width                : std_logic_vector(1 downto 0);

begin

    s_count_reset <= not count;
    --!! apenas teste !!--
    width         <= "11" when move='1' else "00";

    PWM_CIRCUIT: circuito_pwm
        generic map (
            conf_periodo => pwm_period, 
            largura_00   => 0,
            largura_01   => 25_000,
            largura_10   => 50_000,
            largura_11   => 75_000
        )
        port map (
            clock   => clock,
            reset   => reset,
            largura => width,  
            pwm     => s_pwm
        );

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

    --!! TODO !!--
    HCSR04: interface_hcsr04
        port map (
            clock     => clock,
            reset     => reset,
            medir     => '0',
            echo      => echo,
            trigger   => trigger,
            medida    => db_measurement,
            pronto    => open,
            db_reset  => open,
            db_medir  => open,
            db_estado => sensor_state
        );

    CHECK_TIMER: contador_m
        generic map (M => check_timeout, N => check_timeout_bits)
        port map (
            clock => clock,
            zera  => s_count_reset,
            conta => count,
            Q     => open,
            fim   => check_end,
            meio  => open
        );

    SAFETY_TIMER: contador_m
        generic map (M => safety_timeout, N => safety_timeout_bits)
        port map (
            clock => clock,
            zera  => s_count_reset,
            conta => count,
            Q     => open,
            fim   => safety_end,
            meio  => open
        );

    -- 4 bits to identify the container (6 downto 3) and
    -- the 3 least significant bits to indicate the proper dosage of the container (2 downto 0)
    CONTAINERS: for i in pill_containers'range generate
        containers_enable(i) <= '1' when i = to_integer(unsigned(s_dosage(6 downto 3))) else '0';
        pwm(i) <= '0' when pill_containers(i) = "000" else s_pwm;

        PILL_COUNT: downwards_counter
            generic map (N => 3)
            port map (
                clock  => clock,
                clear  => reset,
                count  => discount,   
                enable => containers_enable(i),
                D      => s_dosage(2 downto 0),
                Q      => pill_containers(i)
            );
    end generate;

    alert <= '0' when pill_containers = (pill_containers'range => (others => '0')) else '1'; 

end architecture;