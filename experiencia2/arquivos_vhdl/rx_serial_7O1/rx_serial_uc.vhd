------------------------------------------------------------------
-- Arquivo   : rx_serial_uc.vhd
-- Projeto   : Experiencia 2 - Comunicacao Serial Assincrona
------------------------------------------------------------------
-- Descricao : unidade de controle do circuito da experiencia 2 
-- > implementa superamostragem (sample_tick)
-- > independente da configuracao de transmissao (7O1, 8N2, etc)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     09/09/2023  1.0     Henrique F., Mariana D.  versao inicial
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_uc is 
    port ( 
        clock       : in  std_logic;
        reset       : in  std_logic;
        dado        : in  std_logic;
        bit_tick    : in  std_logic;
        sample_tick : in  std_logic;
        fim         : in  std_logic;
        reset_r     : out std_logic;
        reset_c     : out std_logic;
        conta       : out std_logic;
        desloca     : out std_logic;
        pronto      : out std_logic;
        db_estado   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rx_serial_uc_arch of rx_serial_uc is

    type tipo_estado is (idle, preparacao, recepcao, final);
    signal Eatual, Eprox : tipo_estado;

begin

  process (reset, clock)
  begin
      if reset='1' then
          Eatual <= idle;
      elsif rising_edge(clock) then
          Eatual <= Eprox; 
      end if;
  end process;

  process (dado, fim, sample_tick, bit_tick, Eatual)
  begin

    case Eatual is

      when idle       =>   if dado='0' and sample_tick='1' then Eprox <= preparacao;
                           else                                 Eprox <= idle;
                           end if;

      when preparacao =>   if bit_tick='1' then Eprox <= recepcao;
                           else                 Eprox <= preparacao;
                           end if;

      when recepcao   =>   if    fim='1' then Eprox <= final;
                           else               Eprox <= recepcao;
                           end if;

      when final      =>   Eprox <= idle;

      when others     =>   Eprox <= idle;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      reset_c <= '1' when idle, '0' when others;

  with Eatual select
      reset_r <= '1' when preparacao, '0' when others;

  with Eatual select
      desloca <= '1' when recepcao, '0' when others;

  with Eatual select
      conta <= '1' when recepcao, '0' when others;

  with Eatual select
      pronto <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when idle,
                   "0001" when preparacao, 
                   "0010" when recepcao, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture rx_serial_uc_arch;
