------------------------------------------------------------------
-- Arquivo   : trena_saida_serial_uc.vhd
-- Projeto   : Experiencia 4 - Trena Digital com Saída Serial
------------------------------------------------------------------
-- Descricao : unidade de controle do circuito da experiencia 4
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     21/09/2023  1.0     Henrique F., Mariana D.  versao inicial
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;

entity trena_saida_serial_uc is 
    port (
        -- inputs
        clock        : in std_logic;
        reset        : in std_logic;
        partida      : in std_logic;
        fim_medida   : in std_logic;
        char_enviado : in std_logic;
        dado_enviado : in std_logic;
        -- outputs
        reset_c    : out std_logic;
        transmite  : out std_logic;
        conta_char : out std_logic;
        pronto     : out std_logic;
        -- debug
        db_estado  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture trena_saida_serial_uc_arch of trena_saida_serial_uc is

    type tipo_estado is (inicial, medida, transmissao, proximo, final);
    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

  -- memoria de estado
  process (reset, clock)
  begin
      if reset = '1' then
          Eatual <= inicial;
      elsif clock'event and clock = '1' then
          Eatual <= Eprox; 
      end if;
  end process;

  -- logica de proximo estado
  process (partida, fim_medida, char_enviado, dado_enviado, Eatual) 
  begin

    case Eatual is

      when inicial     =>  if partida='1' then Eprox <= medida;
                           else                Eprox <= inicial;
                           end if;
      when medida      =>  if fim_medida='1' then Eprox <= transmissao;
                           else                   Eprox <= medida;
                           end if;
      when transmissao =>  if char_enviado='1' then Eprox <= proximo;
                           else                     Eprox <= transmissao;
                           end if;
      when proximo     =>  if dado_enviado='1' then Eprox <= final;
                           else                     Eprox <= transmissao;
                           end if;
      -- implicito: when final => Eprox <= inicial;
      when others      =>  Eprox <= inicial;

    end case;

  end process;

  -- logica de saida (Moore)
  with Eatual select
      reset_c    <= '1' when inicial, '0' when others;

  with Eatual select
      transmite  <= '1' when transmissao, '0' when others;

  with Eatual select
      conta_char <= not dado_enviado when proximo, '0' when others;

  with Eatual select
      pronto     <= '1' when final, '0' when others;

  with Eatual select
      db_estado <= "0000" when inicial,
                   "0001" when medida, 
                   "0010" when transmissao, 
                   "0100" when proximo, 
                   "1111" when final,    -- Final
                   "1110" when others;   -- Erro

end architecture;
