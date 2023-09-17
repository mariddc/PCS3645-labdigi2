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
        pronto  : out std_logic
    );
end entity interface_hcsr04;

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

begin
    BCD: contador_bcd_3digitos
        port map (
            clock   => clock, 
            zera    => reset,
            conta   => pulso,
            digito0 => digito0,
            digito1 => digito1,
            digito2 => digito2,
            fim     => fim
        )

    M: contador_m 
        generic map (
            M => 2941,
            N => 12
        )
        port map (
            clock => clock,
            zera  => 
            conta => 
            Q     => open,
            fim   => open,
            meio  => tick
        )

end architecture estrutural;
   