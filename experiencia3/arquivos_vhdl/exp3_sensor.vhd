-------------------------------------------------------------------
-- Arquivo   : interface_hcsr04.vhd
-- Projeto   : Experiencia 3 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : circuito de teste da interface com
--             sensor de distancia
--             
--              saidas nos displays de 7 segmentos
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                            Descricao
--     16/09/2023  1.0     Mariana Dutra e Henrique Silva   versao inicial
--
--------------------------------------------------------------------
--

library IEEE;
use IEEE.std_logic_1164.all;


entity exp3_sensor is
    port (
        clock       : in std_logic;
        reset       : in std_logic;
        medir       : in std_logic;
        echo        : in std_logic;
        trigger     : out std_logic;
        hex0        : out std_logic_vector(6 downto 0); -- digitos da medida
        hex1        : out std_logic_vector(6 downto 0);
        hex2        : out std_logic_vector(6 downto 0);
        pronto      : out std_logic;
        db_medir    : out std_logic;
        db_echo     : out std_logic;
        db_trigger  : out std_logic;
        db_tick     : out std_logic;
        db_estado   : out std_logic_vector(6 downto 0) -- estado da UC
        );
end entity exp3_sensor;

architecture exp3_sensor_arch of exp3_sensor is

    component interface_hcsr04 is 
        port (
            clock     : in std_logic;
            reset     : in std_logic;
            medir     : in std_logic;
            echo      : in std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0); -- 3 digitos BCD
            pronto    : out std_logic;
            db_estado : out std_logic_vector(3 downto 0); -- estado da UC
            --db_fim    : out std_logic;
            db_tick   : out std_logic
        );
    end component;

    component edge_detector is
        port (  
            clock     : in  std_logic;
            signal_in : in  std_logic;
            output    : out std_logic
        );
    end component;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal s_medir : std_logic;
    signal s_estado_in, s_hex0_in, s_hex1_in, s_hex2_in : std_logic_vector(3 downto 0); 
    signal s_medida : std_logic_vector(11 downto 0);

    -- saidas
    signal s_pronto, s_trigger, s_tick : std_logic;
    signal s_estado_sseg, s_hex0_sseg, s_hex1_sseg, s_hex2_sseg : std_logic_vector(6 downto 0);

begin

    s_hex0_in <= s_medida( 3 downto 0);
    s_hex1_in <= s_medida( 7 downto 4);
    s_hex2_in <= s_medida(11 downto 8);

    INT: interface_hcsr04
        port map (
            clock     => clock,   
            reset     => reset,
            medir     => s_medir,
            echo      => echo,
            trigger   => s_trigger,
            medida    => s_medida, 
            pronto    => s_pronto,
            db_estado => s_estado_in,
            db_tick   => s_tick
        );

    DB: edge_detector
        port map (
            clock     => clock,
            signal_in => medir,
            output    => s_medir   
        );

    H0: hexa7seg 
        port map(
            hexa => s_hex0_in,
            sseg => s_hex0_sseg
        );

    H1: hexa7seg 
    port map(
        hexa => s_hex1_in,
        sseg => s_hex1_sseg
    );

    H2: hexa7seg 
    port map(
        hexa => s_hex2_in,
        sseg => s_hex2_sseg
    );

    H5: hexa7seg 
    port map(
        hexa => s_estado_in,
        sseg => s_estado_sseg
    );

    --saidas
    pronto      <= s_pronto;
    trigger     <= s_trigger;
    hex0        <= s_hex0_sseg;
    hex1        <= s_hex1_sseg;
    hex2        <= s_hex2_sseg;
    
    -- saidas de depuracao
    db_medir    <= medir;
    db_echo     <= echo;
    db_estado   <= s_estado_sseg;
    db_tick     <= s_tick;
	 db_trigger  <= s_trigger;

end architecture exp3_sensor_arch;