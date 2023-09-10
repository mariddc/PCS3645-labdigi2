-------------------------------------------------------------------
-- Arquivo   : rx_serial_7O1.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
-------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
-- > implementa configuracao 7O1 e taxa de 115200 bauds
-- >
-- > superamostragem de 16x a taxa de transmissão
-------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor(es)                Descricao
--     09/09/2023  1.0     Henrique F., Mariana D.  versao inicial
-------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity rx_serial_7O1 is
  generic (constant samples : natural := 16);
  port (
      clock             : in  std_logic;
      reset             : in  std_logic;
      dado_serial       : in  std_logic;
      dado_recebido0    : out std_logic_vector(6 downto 0);
      dado_recebido1    : out std_logic_vector(6 downto 0);
      paridade_recebida : out std_logic;
      pronto_rx         : out std_logic;
      db_estado         : out std_logic_vector(6 downto 0)
  );
begin
  assert samples <= 434
  report "Frequência de amostragem deve ser no máximo igual ao clock."
  severity failure;
end entity;

architecture rx_serial_7O1_arch of rx_serial_7O1 is

  component rx_serial_uc is 
    port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        dado        : in  std_logic;
        bit_tick    : in  std_logic;
        sample_tick : in  std_logic;
        fim         : in  std_logic;
        reset_c     : out std_logic;
        reset_r     : out std_logic;
        conta       : out std_logic;
        desloca     : out std_logic;
        pronto      : out std_logic;
        db_estado   : out std_logic_vector(3 downto 0)
    );
  end component;

  component rx_serial_7O1_fd is
    generic (constant samples, samples_width : natural);
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
    
  component edge_detector 
    port (  
        clock     : in  std_logic;
        signal_in : in  std_logic;
        output    : out std_logic
    );
  end component;

  component hexa7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
  end component;

  constant sampling_rate : natural := 434 / samples; -- [16 (oversampling) * 115200 bauds]
  constant samples_width : natural := natural(ceil(log2(real(sampling_rate))));

  signal s_reset_c, s_reset_r, s_conta, s_desloca : std_logic;
  signal s_fim, s_sample, s_tick, s_pronto : std_logic;

  signal s_display, s_estado : std_logic_vector(3 downto 0);
  signal s_dado_recebido : std_logic_vector(6 downto 0);

begin

  s_display <= '0' & s_dado_recebido(6 downto 4);
  pronto_rx <= s_pronto;

  DF: rx_serial_7O1_fd
      generic map (samples, samples_width)
      port map (
        clock => clock, reset => reset, reset_c => s_reset_c, reset_r => s_reset_r, conta => s_conta,
        sample_tick => s_sample, dado_serial => dado_serial, desloca => s_desloca, fim => s_fim, pronto => s_pronto,
        bit_tick => s_tick, paridade => paridade_recebida, dado_deserializado => s_dado_recebido
      );

  CF: rx_serial_uc
      port map (
        clock => clock, reset => reset, dado => dado_serial, bit_tick => s_tick, sample_tick => s_sample,
        fim => s_fim, reset_c => s_reset_c, reset_r => s_reset_r, conta => s_conta, desloca => s_desloca,
        pronto => s_pronto, db_estado => s_estado
      ); 

  SAMPLER: contador_m
      generic map (M => sampling_rate, N => samples_width)
      port map (clock => clock, zera => reset, conta => '1', Q => open, meio => open, fim => s_sample);

  HEX0: hexa7seg port map (hexa => s_dado_recebido(3 downto 0), sseg => dado_recebido0);
    
  HEX1: hexa7seg port map (hexa => s_display, sseg => dado_recebido1);
    
  HEX5: hexa7seg port map (hexa => s_estado, sseg => db_estado);

end rx_serial_7O1_arch;