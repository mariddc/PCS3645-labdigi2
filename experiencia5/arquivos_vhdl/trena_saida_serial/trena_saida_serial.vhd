------------------------------------------------------------------
-- Arquivo   : trena_saida_serial.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
------------------------------------------------------------------
-- Descricao :  
--      Trena com interface de sensor HCSR-04 para medição de 
--      distancia e envio do dado por porta serial
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     21/09/2023  1.0     Henrique F., Mariana D.  versao inicial
--     14/10/2023  1.1     Henrique F., Mariana D.  refatoracao
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity trena_saida_serial is
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
end trena_saida_serial;

architecture structural of trena_saida_serial is

    component trena_saida_serial_fd is
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            reset_c      : in  std_logic;
            angle_data   : in  std_logic_vector(23 downto 0);
            echo         : in  std_logic;
            mensurar     : in  std_logic;
            transmitir   : in  std_logic;
            conta_char   : in  std_logic;
            trigger      : out std_logic;
            fim_medida   : out std_logic;
            char_enviado : out std_logic;
            dado_enviado : out std_logic;
            -- debug
            db_medida    : out std_logic_vector(11 downto 0);
            -- debug:tx
            db_partida   : out std_logic;
            db_serial    : out std_logic;
            db_estado_tx : out std_logic_vector(3 downto 0);
            -- debug:interface
            db_estado_interface : out std_logic_vector(3 downto 0)
        );
    end component;

    component trena_saida_serial_uc is 
        port (
            clock        : in std_logic;
            reset        : in std_logic;
            partida      : in std_logic;
            fim_medida   : in std_logic;
            char_enviado : in std_logic;
            dado_enviado : in std_logic;
            reset_c    : out std_logic;
            transmite  : out std_logic;
            conta_char : out std_logic;
            pronto     : out std_logic;
            medir      : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0)
        );
    end component;

    signal s_saida_serial, s_fim_medida, s_dado_enviado, s_char_enviado : std_logic;
    signal s_not_mensurar, s_medir, s_reset, s_transmite, s_trigger, s_conta_char : std_logic;

    signal s_estado : std_logic_vector(3 downto 0);
    signal s_medida : std_logic_vector(11 downto 0);

begin

    U1_FD: trena_saida_serial_fd
        port map (
            -- inputs
            clock        => clock,
            reset        => reset,
            reset_c      => s_reset,
            angle_data   => angle_data,
            echo         => echo,
            mensurar     => s_medir,
            transmitir   => s_transmite,
            conta_char   => s_conta_char,
            -- outputs
            trigger      => s_trigger,
            fim_medida   => s_fim_medida,
            char_enviado => s_char_enviado,
            dado_enviado => s_dado_enviado,
            --debug
            db_medida    => db_medida,
            db_partida   => db_partida,
            db_serial    => s_saida_serial,
            db_estado_tx => db_estado_tx,
            db_estado_interface => db_estado_interface
        );

    U2_UC: trena_saida_serial_uc
        port map (
            -- inputs
            clock        => clock,
            reset        => reset,
            partida      => mensurar,
            fim_medida   => s_fim_medida,
            char_enviado => s_char_enviado,
            dado_enviado => s_dado_enviado,
            -- outputs
            reset_c      => s_reset,
            transmite    => s_transmite,
            conta_char   => s_conta_char,
            pronto       => pronto,
            medir        => s_medir,
            -- debug
            db_estado    => s_estado
        );

    saida_serial <= s_saida_serial;
    trigger      <= s_trigger;

    db_saida_serial <= s_saida_serial;
    db_mensurar     <= mensurar;
    db_echo         <= echo;
    db_trigger      <= s_trigger;

end architecture;