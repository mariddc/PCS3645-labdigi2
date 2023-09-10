------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1_fd.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
-- > implementa configuracao 7O1
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     09/09/2023  1.0     Henrique F., Mariana D.  versao inicial
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_7O1_fd is
    generic (
        constant samples       : natural := 16;
        constant samples_width : natural := 4
    );
    port (
        clock        : in  std_logic;
        reset        : in  std_logic;
        reset_c      : in  std_logic;
        reset_r      : in  std_logic;
        conta        : in  std_logic;
        sample_tick  : in  std_logic;
        dado_serial  : in  std_logic;
        desloca      : in  std_logic;
        pronto       : in  std_logic;
        fim          : out std_logic;
        bit_tick     : out std_logic;
        paridade     : out std_logic;
        dado_deserializado : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rx_serial_7O1_fd_arch of rx_serial_7O1_fd is
     
    component deslocador_n
    generic (
        constant N : integer
    );
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        carrega        : in  std_logic; 
        desloca        : in  std_logic; 
        entrada_serial : in  std_logic; 
        dados          : in  std_logic_vector(N-1 downto 0);
        saida          : out std_logic_vector(N-1 downto 0)
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
    
    signal s_fim, count_bit, s_bit_pulse, s_bit_tick : std_logic;
    signal s_dado : std_logic_vector(8 downto 0);

    -- inicialização do sinal de saída
    signal s_paridade : std_logic := '0';
    signal s_deserializado : std_logic_vector(6 downto 0) := (others => '0');

begin

    SHIFTER: deslocador_n 
        generic map (
            N => 9
        )
        port map (
            clock          => clock, 
            reset          => reset, 
            carrega        => '0', 
            desloca        => desloca,
            entrada_serial => dado_serial,
            dados          => (others => '0'),
            saida          => s_dado
        );

    DATA_COUNTER: contador_m 
        generic map (
            M => 10, -- 7 data bits + parity + stop bit (range 0 to 10-1)
            N => 4
        ) 
        port map (
            clock => clock, 
            zera  => reset_c, 
            conta => count_bit, 
            Q     => open, 
            fim   => s_fim,
            meio  => open
        );

    BIT_TICKER: contador_m 
        generic map (
            M => samples, 
            N => samples_width
        ) 
        port map (
            clock => clock, 
            zera  => reset_c, 
            conta => sample_tick, 
            Q     => open, 
            fim   => open, 
            meio  => s_bit_pulse
        );

    ED: entity work.edge_detector(behavioral)
        port map (clock => clock, signal_in => s_bit_pulse, output => s_bit_tick);

    fim <= s_fim;
    
    count_bit <= conta and s_bit_tick;
    bit_tick <= s_bit_tick;

    paridade <= s_paridade;
    dado_deserializado <= s_deserializado;

    DESERIALIZAED_R: process (clock, pronto, s_dado) is
    begin
      if (reset_r='1') then
        s_paridade <= '0';
        s_deserializado <= (others => '0');
      elsif (rising_edge(clock) and pronto='1') then
        s_paridade <= s_dado(7);
        s_deserializado <= s_dado(6 downto 0);
      end if;
    end process;
    
end architecture;

