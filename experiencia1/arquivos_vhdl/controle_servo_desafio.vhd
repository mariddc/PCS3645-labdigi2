-----------------Laboratorio Digital--------------------------------------
-- Arquivo   : controle_servo_desafio.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
--------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL de controlador para servo motor
-- 
-- Adaptação do componente controle_servo para maior controle posicional
-- e implementação do código de Gray nessa seleção
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                    Descricao
--     05/09/2023  1.0     Henrique F., Mariana D.  criacao
--------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo_desafio is
  port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      posicao  : in  std_logic_vector(2 downto 0);
      controle : out std_logic
  );
end entity controle_servo_desafio;

architecture structural of controle_servo_desafio is

  component circuito_pwm is
    generic (
        conf_periodo, largura_00, largura_01, largura_10, largura_11 : integer
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        largura : in  std_logic_vector(1 downto 0);  
        pwm     : out std_logic
    );
  end component circuito_pwm;

  signal l_pwm, h_pwm : std_logic;

begin

  low_pwm: circuito_pwm 
      generic map (
        conf_periodo => 1000000,
        largura_00 => 0,
        largura_01 => 50000,
        largura_10 => 66666,
        largura_11 => 58333
      )
      port map (
        clock, reset,
        largura => posicao(1 downto 0),
        pwm => l_pwm
      );

  high_pwm: circuito_pwm 
      generic map (
        conf_periodo => 1000000,
        largura_00 => 100000,
        largura_01 => 91666,
        largura_10 => 75000,
        largura_11 => 83333
      )
      port map (
        clock, reset,
        largura => posicao(1 downto 0),
        pwm => h_pwm
      );

  controle <= l_pwm when posicao(2) = '0' else h_pwm;

end structural;