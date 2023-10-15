library ieee;
use ieee.std_logic_1164.all;

entity sonar is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        ligar        : in  std_logic;
        echo         : in  std_logic;
        db_key       : in  std_logic_vector(1 downto 0);
        trigger      : out std_logic;
        pwm          : out std_logic;
        saida_serial : out std_logic;
        fim_posicao  : out std_logic;
        medida0      : out std_logic_vector(6 downto 0);
        medida1      : out std_logic_vector(6 downto 0);
        medida2      : out std_logic_vector(6 downto 0);
        posicao      : out std_logic_vector(6 downto 0);
        db_estado       : out std_logic_vector(6 downto 0);
        -- LEDs e Analog Discovery CH
        db_reset        : out std_logic;
        db_pwm          : out std_logic;
        db_medir        : out std_logic;
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_trigger      : out std_logic;
        db_echo         : out std_logic
    );
end entity;

architecture rtl of sonar is

    component sonar_fd is
        port (
            -- inputs
            clock       : in  std_logic;
            reset       : in  std_logic;
            echo        : in  std_logic;
            zera        : in  std_logic;
            medir       : in  std_logic;
            conta       : in  std_logic;
            avanca      : in  std_logic;
            -- outputs
            pwm         : out std_logic;
            trigger     : out std_logic;
            serial      : out std_logic;
            pronto      : out std_logic;
            fim_timer   : out std_logic;
            -- debug
            db_pwm          : out std_logic;
            db_posicao      : out std_logic_vector(2 downto 0);
            db_medida       : out std_logic_vector(11 downto 0);
            db_mensurar     : out std_logic;
            db_partida      : out std_logic;
            db_saida_serial : out std_logic;
            db_trigger      : out std_logic;
            db_echo         : out std_logic;
            db_estado_trena : out std_logic_vector(3 downto 0);
            db_estado_tx    : out std_logic_vector(3 downto 0);
            db_estado_interface : out std_logic_vector(3 downto 0)
        );
    end component;

    component sonar_uc is
        port (
            -- inputs
            clock       : in  std_logic;
            reset       : in  std_logic;
            ligar       : in  std_logic;
            fim_timer   : in  std_logic;
            transmitido : in  std_logic;
            -- sinais de controle
            zera        : out std_logic;
            medir       : out std_logic;
            conta       : out std_logic;
            avanca      : out std_logic;
            -- debug
            db_estado   : out std_logic_vector(3 downto 0)
        );
    end component;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    component mux_4x1_n is
        generic (constant bits: integer);
        port( 
            d3      : in  std_logic_vector(bits-1 downto 0);
            d2      : in  std_logic_vector(bits-1 downto 0);
            d1      : in  std_logic_vector(bits-1 downto 0);
            d0      : in  std_logic_vector(bits-1 downto 0);
            sel     : in  std_logic_vector(1 downto 0);
            mux_out : out std_logic_vector(bits-1 downto 0)
        );
    end component;

    signal s_zera, s_medir, s_conta, s_avanca, s_pronto, s_fim_timer : std_logic;

    signal s_posicao : std_logic_vector(2 downto 0);
    signal s_posicao_ext : std_logic_vector(3 downto 0);
    
    signal s_estado, s_estado_trena, s_estado_interface, s_estado_tx : std_logic_vector(3 downto 0);
    signal s_medida : std_logic_vector(11 downto 0);

begin

    s_posicao_ext <= '0' & s_posicao;

    FD: sonar_fd
        port map (
            -- inputs
            clock       => clock,
            reset       => reset,
            echo        => echo,
            zera        => s_zera,
            medir       => s_medir,
            conta       => s_conta,
            avanca      => s_avanca,
            -- outputs
            pwm         => pwm,
            trigger     => trigger,
            serial      => saida_serial,
            pronto      => s_pronto,
            fim_timer   => s_fim_timer,
            -- debug
            db_pwm          => db_pwm,
            db_posicao      => s_posicao,
            db_medida       => s_medida,
            db_mensurar     => db_medir,
            db_partida      => db_partida,
            db_saida_serial => db_saida_serial,
            db_trigger      => db_trigger,
            db_echo         => db_echo,
            db_estado_trena => s_estado_trena,
            db_estado_tx    => s_estado_tx,
            db_estado_interface => s_estado_interface
        );

    UC: sonar_uc
        port map (
            -- inputs
            clock       => clock,
            reset       => reset,
            ligar       => ligar,
            fim_timer   => s_fim_timer,
            transmitido => s_pronto,
            -- sinais de controle
            zera        => s_zera,
            medir       => s_medir,
            conta       => s_conta,
            avanca      => s_avanca,
            -- debug
            db_estado   => s_estado
        );

    MUX_DB: mux_4x1_n
        generic map (bits => 4)
        port map (
            d0 => s_estado,
            d1 => s_estado_trena,
            d2 => s_estado_interface,
            d3 => s_estado_tx,
            sel => db_key,
            mux_out => s_estado
        );

    HEX0: hexa7seg
        port map (hexa => s_medida(3 downto 0), sseg => medida0);

    HEX1: hexa7seg
        port map (hexa => s_medida(7 downto 4), sseg => medida1);

    HEX2: hexa7seg
        port map (hexa => s_medida(11 downto 8), sseg => medida2);

    HEX4: hexa7seg
        port map (hexa => s_posicao_ext, sseg => posicao);

    HEX5: hexa7seg
        port map (hexa => s_estado, sseg => db_estado);

    fim_posicao <= s_pronto;

    db_reset <= reset;

end architecture;