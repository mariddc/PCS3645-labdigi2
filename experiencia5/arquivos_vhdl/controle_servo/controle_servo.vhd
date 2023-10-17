-----------------Laboratorio Digital--------------------------------------
-- Arquivo   : controle_servo.vhd
-- Projeto   : Experiencia 5 - Sistema de Sonar
--------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL de controlador para servo motor
-- 
-- Adaptação do componente controle_servo para maior controle posicional
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                    Descricao
--     05/09/2023  1.0     Henrique F., Mariana D.  criacao
--     13/10/2023  2.0     Henrique F., Mariana D.  refatoracao
--------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
      clock      : in  std_logic;
      reset      : in  std_logic;
      posicao    : in  std_logic_vector(2 downto 0);
      pwm        : out std_logic;
      db_pwm     : out std_logic;
      db_posicao : out std_logic_vector(2 downto 0)
  );
end entity;

architecture structural of controle_servo is

  constant control_period : natural := 1000000;

  signal s_pwm : std_logic;

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
        conf_periodo => control_period,
        largura_00 => 35000,
        largura_01 => 45700,
        largura_10 => 56450,
        largura_11 => 67150
      )
      port map (
        clock, reset,
        largura => posicao(1 downto 0),
        pwm => l_pwm
      );

  high_pwm: circuito_pwm 
      generic map (
        conf_periodo => control_period,
        largura_00 => 77850,
        largura_01 => 88550,
        largura_10 => 99300,
        largura_11 => 110000
      )
      port map (
        clock, reset,
        largura => posicao(1 downto 0),
        pwm => h_pwm
      );

  s_pwm <= l_pwm when posicao(2) = '0' else h_pwm;

  pwm <= s_pwm;

  -- debug
  db_pwm     <= s_pwm;
  db_posicao <= posicao;

end structural;