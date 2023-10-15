library ieee;
use ieee.std_logic_1164.all;

entity sonar_uc is
    port (
        -- inputs
        clock       : in  std_logic;
        reset       : in  std_logic;
        ligar       : in  std_logic;
        fim_timer   : in  std_logic;
        transmitido : in  std_logic;
        -- sinais de controle
        zera        : out std_logic;
        medir       : out std_logic;
        conta       : out std_logic;
        avanca      : out std_logic;
        -- debug
        db_estado   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm_arch of sonar_uc is
    type tipo_estado is (idle, inicial, espera, medida, transmissao,posicionamento);
    signal Eatual, Eprox: tipo_estado;
begin

    -- estado
    process (reset, ligar, clock)
    begin
        if (reset = '1' or ligar = '0') then
            Eatual <= idle;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox;
        end if;
    end process;

    -- logica de proximo estado
    process (ligar, fim_timer, transmitido, Eatual)
    begin
      case Eatual is
        when idle           =>  if ligar='1' then Eprox <= inicial;
                                else              Eprox <= idle;
                                end if;
        when inicial        =>  Eprox <= espera;
        when espera         =>  if fim_timer='1' then Eprox <= medida;
                                else                  Eprox <= espera;
                                end if;
        when medida         =>  Eprox <= transmissao;
        when transmissao    =>  if transmitido='1' then Eprox <= posicionamento;
                                else                    Eprox <= transmissao;
                                end if;
        when posicionamento =>  Eprox <= espera;
        when others         =>  Eprox <= inicial;
      end case;
    end process;

  -- saidas de controle
  with Eatual select 
      zera   <= '1' when inicial, '0' when others;
  with Eatual select
      conta  <= '1' when espera, '0' when others;
  with Eatual select
      medir  <= '1' when medida, '0' when others;
  with Eatual select
      avanca <= '1' when posicionamento, '0' when others;

  with Eatual select
      db_estado <= "0000" when idle, 
                   "0001" when inicial, 
                   "0010" when espera, 
                   "0011" when medida,
                   "0100" when transmissao,
                   "0101" when posicionamento,
                   "1110" when others; -- Erro

end architecture;