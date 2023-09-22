-------------------------------------------------------------------
-- Arquivo   : interface_hcsr04.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : componente do FD do circuito de interface com
--             sensor de distancia
--             
--             realiza a medida da largura do pulso de echo
--             e o cálculo da distância entre objeto e sensor
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                            Descricao
--     16/09/2023  1.0     Mariana Dutra e Henrique Silva   versao inicial
--
--------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;


entity contador_cm is
    generic (
        constant R : integer := 50;
        constant N : integer := 6
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        pulso   : in  std_logic;
        digito0 : out std_logic_vector(3 downto 0);
        digito1 : out std_logic_vector(3 downto 0);
        digito2 : out std_logic_vector(3 downto 0);
        fim     : out std_logic;
        pronto  : out std_logic;
        db_tick : out std_logic
    );
end entity contador_cm;

architecture estrutural of contador_cm is
    
    component contador_m 
        generic (
            constant M : integer;  
            constant N : integer
        );
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector (N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component;

    component contador_bcd_3digitos
        port ( 
            clock   : in  std_logic;
            zera    : in  std_logic;
            conta   : in  std_logic;
            digito0 : out std_logic_vector(3 downto 0);
            digito1 : out std_logic_vector(3 downto 0);
            digito2 : out std_logic_vector(3 downto 0);
            fim     : out std_logic
        );
    end component;

    component edge_detector
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component;

    signal s_pulso_negado, s_tick : std_logic;

    -- saidas
    signal s_fim_pulso : std_logic;

begin

    s_pulso_negado <= not pulso;

    BCD: contador_bcd_3digitos
        port map (
            clock   => clock, 
            zera    => reset,
            conta   => s_tick,
            digito0 => digito0,
            digito1 => digito1,
            digito2 => digito2,
            fim     => fim
        );

    M: contador_m -- ticks a cada 1 cm
        generic map (
            M => 2941,
            N => 12
        )
        port map (
            clock => clock,
            zera  => reset,
            conta => pulso,
            Q     => open,
            fim   => open,
            meio  => s_tick
        );

    ED: edge_detector
        port map (
            clock       => clock,
            signal_in   => s_pulso_negado,
            output      => s_fim_pulso
        );

    pronto  <= s_fim_pulso;
    db_tick <= s_tick;

end architecture estrutural;
   