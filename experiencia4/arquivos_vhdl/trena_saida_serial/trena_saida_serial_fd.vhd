------------------------------------------------------------------
-- Arquivo   : trena_saida_serial_fd.vhd
-- Projeto   : Experiencia 4 - Trena Digital com Saída Serial
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 4
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     21/09/2023  1.0     Henrique F., Mariana D.  versao inicial
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity trena_saida_serial_fd is
    port (
        -- inputs
        clock        : in  std_logic;
        reset        : in  std_logic;
        echo         : in  std_logic;
        mensurar     : in  std_logic;
        transmitir   : in  std_logic;
        -- outputs
        trigger      : out std_logic;
        fim_medida   : out std_logic;
        char_enviado : out std_logic;
        -- debug
        db_serial    : out std_logic;
    );
end entity;

architecture trena_saida_serial_fd_arch of trena_saida_serial_fd is

    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            medir     : in  std_logic;
            echo      : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0);
            pronto    : out std_logic;
        );
    end component;

    component tx_serial_7O1 is
        port (
            clock       : in  std_logic;
            reset       : in  std_logic;
            partida     : in  std_logic;
            dados_ascii : in  std_logic_vector(6 downto 0);
            dado_serial : out std_logic;
            pronto      : out std_logic
        );
    end component;

    signal 

begin

    U1_INTERFACE: interface_hcsr04
        port map (
            clock   => clock,
            reset   => reset,
            medir   => mensurar
            echo    => echo,
            trigger => trigger,
            medida  => 
            pronto  => fim_medida
        );

    U1_TX: tx_serial_7O1
        port map (
            clock       => clock,
            reset       => reset,
            partida     => transmitir,
            dados_ascii => 
            dado_serial => db_serial,
            pronto      => char_enviado
        );

end architecture;