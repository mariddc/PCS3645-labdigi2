library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity sonar_fd is
    port (
        -- inputs
        clock          : in  std_logic;
        reset          : in  std_logic;
        echo           : in  std_logic;
        zera           : in  std_logic;
        medir          : in  std_logic;
        conta          : in  std_logic;
        avanca         : in  std_logic;
        entrada_serial : in std_logic;
        -- outputs
        pwm          : out std_logic;
        trigger      : out std_logic;
        saida_serial : out std_logic;
        pronto       : out std_logic;
        fim_timer    : out std_logic;
        modo         : out std_logic_vector(1 downto 0);
        -- debug
        -- controle --
        db_pwm          : out std_logic;
        db_posicao      : out std_logic_vector(2 downto 0);
        -- transmissor --
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado_tx    : out std_logic_vector(3 downto 0);
        -- trena --
        db_trigger      : out std_logic;
        db_echo         : out std_logic;
        db_estado_trena : out std_logic_vector(3 downto 0);
        db_medida       : out std_logic_vector(11 downto 0);
        -- interface --
        db_mensurar     : out std_logic;
        db_estado_interface : out std_logic_vector(3 downto 0)
    );
end entity;

architecture df_arch of sonar_fd is

    component controle_servo is
        port (
            -- inputs
            clock      : in  std_logic;
            reset      : in  std_logic;
            posicao    : in  std_logic_vector(2 downto 0);
            --output
            pwm        : out std_logic;
            -- debug
            db_pwm     : out std_logic;
            db_posicao : out std_logic_vector(2 downto 0)
        );
    end component;      

    component trena_saida_serial is
        port (
            -- inputs
            clock        : in  std_logic;
            reset        : in  std_logic;
            angle_data   : in  std_logic_vector(23 downto 0);
            mensurar     : in  std_logic;
            echo         : in  std_logic;
            -- outputs
            trigger      : out std_logic;
            saida_serial : out std_logic;
            pronto       : out std_logic;
            -- debug
            db_medida       : out std_logic_vector(11 downto 0);
            db_mensurar     : out std_logic;
            db_partida      : out std_logic;
            db_saida_serial : out std_logic;
            db_trigger      : out std_logic;
            db_echo         : out std_logic;
            db_estado       : out std_logic_vector(3 downto 0);
            db_estado_tx    : out std_logic_vector(3 downto 0);
            db_estado_interface : out std_logic_vector(3 downto 0)
        );
    end component;

    component rx_serial_7O1 is
        generic (constant samples : natural := 16);
        port (
            clock             : in  std_logic;
            reset             : in  std_logic;
            dado_serial       : in  std_logic;
            dado_recebido     : out std_logic_vector(6 downto 0);
            paridade_recebida : out std_logic;
            pronto            : out std_logic;
            db_dado_serial    : out std_logic;
            db_estado         : out std_logic_vector(3 downto 0)
        );
    end component;

    component contador_m is
        generic (constant M, N : integer);
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector(N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;

    component rom_angulos_8x24 is
        port (
            endereco : in  std_logic_vector(2 downto 0);
            saida    : out std_logic_vector(23 downto 0)
        ); 
    end component;

    component contadorg_updown_m is
        generic (constant M: integer);
        port (
            clock  : in  std_logic;
            zera_as: in  std_logic;
            zera_s : in  std_logic;
            conta  : in  std_logic;
            Q      : out std_logic_vector(natural(ceil(log2(real(M))))-1 downto 0);
            inicio : out std_logic;
            fim    : out std_logic;
            meio   : out std_logic 
       );
    end component;

    component registrador_n is
        generic (
            constant N: integer);
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector (N-1 downto 0);
            Q      : out std_logic_vector (N-1 downto 0) 
        );
    end component;

    signal s_posicao    : std_logic_vector(2 downto 0);
    signal s_angle_data : std_logic_vector(23 downto 0);

    signal s_not_conta, s_enable, s_zera : std_logic;
    signal s_ascii_recebido, s_ascii_registrado : std_logic_vector(6 downto 0);

    signal s_modo : std_logic_vector(1 downto 0) := "00";

begin

    s_not_conta <= not conta;

    with s_ascii_recebido select 
        s_enable <= '1' when "1101001" | "1110010", -- i or r 
                    '0' when others;

    with s_ascii_registrado select
        s_modo <= "00" when "1110010" | "0000000", -- r
                  "01" when "1101001", -- i
                  s_modo when others;


    ROM: rom_angulos_8x24
        port map (
            endereco => s_posicao,
            saida    => s_angle_data
        );

    SWEEP: contadorg_updown_m
        generic map (M => 8)
        port map (
            clock   => clock,
            zera_as => reset,
            zera_s  => zera,
            conta   => avanca,
            Q       => s_posicao,
            inicio  => open,
            fim     => open,
            meio    => open
        );

    SERVO_CONTROLLER: controle_servo
        port map (
            clock      => clock,
            reset      => reset,
            posicao    => s_posicao,
            pwm        => pwm,
            db_pwm     => db_pwm,
            db_posicao => db_posicao
        );

    MEASUREMENT: trena_saida_serial
        port map (
            clock           => clock,
            reset           => reset,
            angle_data      => s_angle_data,
            mensurar        => medir,
            echo            => echo,
            trigger         => trigger,
            saida_serial    => saida_serial,
            pronto          => pronto,
            db_medida       => db_medida,
            db_mensurar     => db_mensurar,
            db_partida      => db_partida,
            db_saida_serial => db_saida_serial,
            db_trigger      => db_trigger,
            db_echo         => db_echo,
            db_estado       => db_estado_trena,
            db_estado_tx    => db_estado_tx,
            db_estado_interface => db_estado_interface
        );

    RECEIVER: rx_serial_7O1
        port map (
            clock             => clock,
            reset             => reset,
            dado_serial       => entrada_serial,
            dado_recebido     => s_ascii_recebido,
            paridade_recebida => open,
            pronto            => open,
            db_dado_serial    => open,
            db_estado         => open
        );

    TIMER: contador_m
        generic map (M => 100000000, N => 27)   -- 10000 / 100000000 (200us / 2s)
        port map (
            clock => clock,
            zera  => s_not_conta,
            conta => conta,
            Q     => open,
            fim   => fim_timer,
            meio  => open
        );


    REG_MODO: registrador_n
        generic map (N => 7)
        port map (
            clock  => clock,
            clear  => s_zera,
            enable => s_enable,
            D      => s_ascii_recebido,
            Q      => s_ascii_registrado
        );
		  
		s_zera <= zera or reset;		  
		modo <= s_modo;

end architecture;