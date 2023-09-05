-----------------Laboratorio Digital--------------------------------------
-- Arquivo   : circuito_pwm.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
--------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL RTL gera saída digital com modulacao pwm
--
-- parametros de configuracao da saida pwm: conf_periodo e largura_xx
-- (considerando clock de 50MHz ou periodo de 20ns)
--
-- valores default:
-- conf_periodo=1250 gera um sinal periodo de 4 KHz (25us) com clock 50MHz
-- largura_xx controla o tempo de pulso em 1 para diferentes larguras:
-- 00=0 (saida nula), 01=pulso de 1us, 10=pulso de 10us, 11=pulso de 20us
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     26/09/2021  1.0     Edson Midorikawa  criacao
--     24/08/2022  1.1     Edson Midorikawa  revisao
--     08/05/2023  1.2     Edson Midorikawa  revisao do componente
--     17/08/2023  1.3     Edson Midorikawa  revisao do componente
-------------------------------------------------------------------------
--

package types is
	type largura is array(0 to 7) of integer range 0 to 100000;
end package;

library ieee;
use work.types.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_desafio is
  generic (
      conf_periodo : integer := 1000000;
      conf_largura : largura := (0, 50000, 66666, 58333, 100000, 91666, 75000, 83333)
  );
  port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      largura : in  std_logic_vector(2 downto 0);  
      pwm     : out std_logic 
  );
end entity controle_servo_desafio;

architecture rtl of controle_servo_desafio is

  signal contagem     : integer range 0 to conf_periodo-1;
  signal largura_pwm  : integer range 0 to conf_periodo-1;
  signal s_largura    : integer range 0 to conf_periodo-1;
  
begin

  process(clock, reset, s_largura)
  begin
    -- inicia contagem e largura
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
      largura_pwm <= s_largura;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < largura_pwm) then
          pwm  <= '1';
        else
          pwm  <= '0';
        end if;
        -- atualiza contagem e largura
        if(contagem = conf_periodo-1) then
          contagem    <= 0;
          largura_pwm <= s_largura;
        else
          contagem    <= contagem + 1;
        end if;
    end if;
  end process;

  s_largura <= conf_largura(to_integer(unsigned(largura)));

end architecture rtl;