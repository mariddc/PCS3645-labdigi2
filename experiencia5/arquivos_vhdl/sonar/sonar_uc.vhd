library ieee;
use ieee.std_logic_1164.all;

entity sonar_uc is
    port (
        -- inputs
        clock       : in  std_logic;
        reset       : in  std_logic;
        ligar       : in  std_logic;
        modo        : in  std_logic_vector(1 downto 0);
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
    type tipo_estado is (idle, inicial, avaliacao, interrompido,
                        espera, medida, transmissao,posicionamento);
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
    process (ligar, modo, fim_timer, transmitido, Eatual)
    begin
      case Eatual is
        when idle           =>  if ligar='1' then Eprox <= inicial;
                                else              Eprox <= idle;
                                end if;
        when inicial        =>  Eprox <= avaliacao;
        when avaliacao      =>  if modo="01" then Eprox <= interrompido;
                                else              Eprox <= espera;
                                end if;
        when interrompido   =>  Eprox <= avaliacao;
        when espera         =>  if fim_timer='1' then Eprox <= medida;
                                else                  Eprox <= espera;
                                end if;
        when medida         =>  Eprox <= transmissao;
        when transmissao    =>  if transmitido='1' then Eprox <= posicionamento;
                                else                    Eprox <= transmissao;
                                end if;
        when posicionamento =>  Eprox <= avaliacao;
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
                   "0010" when avaliacao,
                   "0011" when interrompido,
                   "0100" when espera, 
                   "0101" when medida,
                   "0110" when transmissao,
                   "0111" when posicionamento,
                   "1110" when others; -- Erro

end architecture;