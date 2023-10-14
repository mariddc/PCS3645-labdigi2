-------------------------------------------------------------------
-- Arquivo   : interface_hcsr04.vhd
-- Projeto   : Experiencia 5 - Sistema de sonar
--------------------------------------------------------------------
-- Descricao : entidade principal do circuito de interface com
--             sensor de distancia
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                   Descricao
--     16/09/2023  1.0     Henrique F., Mariana D.   versao inicial
--     13/10/2023  1.1     Henrique F., Mariana D.   depuracao
--------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;


entity interface_hcsr04 is
    port (
        clock     : in  std_logic;
        reset     : in  std_logic;
        medir     : in  std_logic;
        echo      : in  std_logic;
        trigger   : out std_logic;
        medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
        pronto    : out std_logic;
        db_reset  : out std_logic;
        db_medir  : out std_logic;
        db_estado : out std_logic_vector(3 downto 0)
    );
end entity interface_hcsr04;

architecture estrutural of interface_hcsr04 is

    component interface_hcsr04_fd is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            gera      : in  std_logic;
            pulso     : in  std_logic;
            registra  : in  std_logic;
            zera      : in  std_logic;
            trigger   : out std_logic;
            fim_medida: out std_logic;
            distancia : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            db_tick   : out std_logic
        );
    end component;

    component interface_hcsr04_uc is 
        port ( 
            clock      : in  std_logic;
            reset      : in  std_logic;
            medir      : in  std_logic;
            echo       : in  std_logic;
            fim_medida : in  std_logic;
            zera       : out std_logic;
            gera       : out std_logic;
            registra   : out std_logic;
            pronto     : out std_logic;
            db_estado  : out std_logic_vector(3 downto 0) 
        );
    end component;

    -- sinais de controle
    signal s_gera, s_registra, s_zera, s_fim_medida: std_logic;

    -- saidas do circuito
    signal s_trigger, s_pronto : std_logic;    
    signal s_medida : std_logic_vector(11 downto 0);

begin

    FD: interface_hcsr04_fd 
        port map (
            clock       => clock,
            reset       => reset,
            gera        => s_gera,
            pulso       => echo,
            registra    => s_registra,
            zera        => s_zera,
            trigger     => s_trigger,
            fim_medida  => s_fim_medida,
            distancia   => s_medida,
            db_tick     => open
        );

    UC: interface_hcsr04_uc
        port map (
            clock       => clock,
            reset       => reset,
            medir       => medir,
            echo        => echo,
            fim_medida  => s_fim_medida,
            zera        => s_zera,
            gera        => s_gera,
            registra    => s_registra,
            pronto      => s_pronto,
            db_estado   => db_estado
        );

    -- saidas do circuito
    trigger     <= s_trigger;
    pronto      <= s_pronto;
    medida      <= s_medida;

    -- debug
    db_reset <= reset;
    db_medir <= medir;

end architecture estrutural;
   