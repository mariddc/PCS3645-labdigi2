-------------------------------------------------------------------
-- Arquivo   : tx_serial_7O1.vhd
-- Projeto   : Experiencia 4 - Trena Digital com Saída Serial
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 4 
-- > implementa configuracao 7O1 e taxa de 115200 bauds
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     09/09/2021  1.0     Edson Midorikawa         versao inicial
--     31/08/2022  2.0     Edson Midorikawa         revisao do codigo
--     19/09/2022  2.1     Edson Midorikawa         revisao (db_estado)
--     17/08/2023  3.0     Edson Midorikawa         revisao para 7O1
--     13/10/2023  4.0     Henrique F., Mariana D.  remocao de interface
-------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tx_serial_7O1 is
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        partida      : in  std_logic;
        dados_ascii  : in  std_logic_vector(6 downto 0);
        saida_serial : out std_logic;
        pronto       : out std_logic;
        -- debug
        db_partida      : out std_logic;
        db_saida_serial : out std_logic;
        db_estado       : out std_logic_vector(3 downto 0)
    );
end entity;

architecture tx_serial_7O1_arch of tx_serial_7O1 is
     
    component tx_serial_uc 
        port ( 
            clock     : in  std_logic;
            reset     : in  std_logic;
            partida   : in  std_logic;
            tick      : in  std_logic;
            fim       : in  std_logic;
            zera      : out std_logic;
            conta     : out std_logic;
            carrega   : out std_logic;
            desloca   : out std_logic;
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component;

    component tx_serial_7O1_fd
        port (
            clock        : in  std_logic;
            reset        : in  std_logic;
            zera         : in  std_logic;
            conta        : in  std_logic;
            carrega      : in  std_logic;
            desloca      : in  std_logic;
            dados_ascii  : in  std_logic_vector(6 downto 0);
            saida_serial : out std_logic;
            fim          : out std_logic
        );
    end component;
    
    component contador_m
        generic (
            constant M : integer; 
            constant N : integer 
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector(N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;

    signal s_zera, s_conta, s_carrega : std_logic;
    signal s_desloca, s_tick, s_fim, s_saida_serial : std_logic;
    signal s_estado : std_logic_vector(3 downto 0);

begin

    -- unidade de controle
    U1_UC: tx_serial_uc 
           port map (
               clock     => clock, 
               reset     => reset, 
               partida   => partida, 
               tick      => s_tick, 
               fim       => s_fim,
               zera      => s_zera, 
               conta     => s_conta, 
               carrega   => s_carrega, 
               desloca   => s_desloca, 
               pronto    => pronto,
               db_estado => s_estado
           );

    -- fluxo de dados
    U2_FD: tx_serial_7O1_fd 
           port map (
               clock        => clock, 
               reset        => reset, 
               zera         => s_zera, 
               conta        => s_conta, 
               carrega      => s_carrega, 
               desloca      => s_desloca, 
               dados_ascii  => dados_ascii, 
               saida_serial => s_saida_serial, 
               fim          => s_fim
           );

    -- gerador de tick
    U3_TICK: contador_m 
             generic map (
                 M => 434, -- 115200 bauds (434=50M/115200)
                 N => 13
             ) 
             port map (
                 clock => clock, 
                 zera  => s_zera, 
                 conta => '1', 
                 Q     => open, 
                 fim   => s_tick, 
                 meio  => open
             );

    db_partida      <= partida;
    db_saida_serial <= s_saida_serial;
    db_estado       <= s_estado;
 
end architecture;
