-----------------Laboratorio Digital--------------------------------------
-- Arquivo   : controle_servo.vhd
-- Projeto   : Experiencia 1 - Controle de um servomotor
--------------------------------------------------------------------------
-- Descricao : 
--             codigo VHDL de controlador para servo motor
-- 
-- Implementação do componente circuito_pwm e parametrização para a
-- aplicação esperada (50Hz de sinal de controle e largura de sinais entre
-- 1 e 2ms)
--------------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor                    Descricao
--     03/09/2023  1.0     Henrique F., Mariana D.  criacao
--------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
  port (
      clock    : in  std_logic;
      reset    : in  std_logic;
      posicao  : in  std_logic_vector(1 downto 0);
      controle : out std_logic
  );
end entity controle_servo;

architecture structural of controle_servo is

  component circuito_pwm is
    generic (
        conf_periodo : integer := 1250;
        largura_00   : integer :=    0;
        largura_01   : integer :=   50;
        largura_10   : integer :=  500;
        largura_11   : integer := 1000
    );
    port (
        clock   : in  std_logic;
        reset   : in  std_logic;
        largura : in  std_logic_vector(1 downto 0);  
        pwm     : out std_logic 
    );
  end component circuito_pwm;

begin

  pwm: circuito_pwm 
      generic map (
        conf_periodo => 1000000,
        largura_00 => 0,
        largura_01 => 50000,
        largura_10 => 75000,
        largura_11 => 100000
      )
      port map (
        clock, reset,
        largura => posicao,
        pwm => controle
      );

end structural;