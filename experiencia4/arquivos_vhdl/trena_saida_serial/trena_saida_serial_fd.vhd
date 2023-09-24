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
        reset_c      : in  std_logic;
        echo         : in  std_logic;
        mensurar     : in  std_logic;
        transmitir   : in  std_logic;
        conta_char   : in  std_logic;
        -- outputs
        trigger      : out std_logic;
        fim_medida   : out std_logic;
        char_enviado : out std_logic;
        dado_enviado : out std_logic;
        -- debug
        db_serial    : out std_logic;
        db_medida    : out std_logic_vector(11 downto 0)
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
            pronto    : out std_logic
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

    component mux_4x1_n is
        generic (constant bits : integer);
        port ( 
            d3      : in  std_logic_vector(bits-1 downto 0);
            d2      : in  std_logic_vector(bits-1 downto 0);
            d1      : in  std_logic_vector(bits-1 downto 0);
            d0      : in  std_logic_vector(bits-1 downto 0);
            sel     : in  std_logic_vector(1 downto 0);
            mux_out : out std_logic_vector(bits-1 downto 0)
        );
    end component;

    signal s_reset       : std_logic;
    signal s_char_select : std_logic_vector(1 downto 0);
    signal s_digit       : std_logic_vector(3 downto 0);
    signal s_ascii_char  : std_logic_vector(6 downto 0);
    signal s_medida      : std_logic_vector(11 downto 0);

begin

    s_reset <= reset or reset_c;

    U1_INTERFACE: interface_hcsr04
        port map (
            clock   => clock,
            reset   => reset,
            medir   => mensurar,
            echo    => echo,
            trigger => trigger,
            medida  => s_medida,
            pronto  => fim_medida
        );

    U2_TX: tx_serial_7O1
        port map (
            clock       => clock,
            reset       => reset,
            partida     => transmitir,
            dados_ascii => s_ascii_char,
            dado_serial => db_serial,
            pronto      => char_enviado
        );

    U3_COUNT: contador_m
        generic map (M => 4, N => 2)
        port map (
            clock => clock,
            zera  => s_reset,
            conta => conta_char,
            Q     => s_char_select,
            fim   => dado_enviado,
            meio  => open
        );

    U4_MUX: mux_4x1_n
        generic map (bits => 4)
        port map (
            d3      => "1111",
            d2      => s_medida(3 downto 0),
            d1      => s_medida(7 downto 4),
            d0      => s_medida(11 downto 8),
            sel     => s_char_select,
            mux_out => s_digit
        );

    s_ascii_char <= "011" & s_digit when s_digit <= "1001" else "0100011";

    db_medida <= s_medida;

end architecture;