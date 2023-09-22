------------------------------------------------------------------
-- Arquivo   : trena_saida_serial.vhd
-- Projeto   : Experiencia 4 - Trena Digital com Saída Serial
------------------------------------------------------------------
-- Descricao :  

------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autores                  Descricao
--     21/09/2023  1.0     Henrique F., Mariana D.  versao inicial
------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164;

entity exp4_trena is
    port (
        -- inputs
        clock        : in  std_logic;
        reset        : in  std_logic;
        mensurar     : in  std_logic;
        echo         : in  std_logic;
        -- outputs
        trigger      : out std_logic;
        saida_serial : out std_logic;
        medida0      : out std_logic_vector(6 downto 0);
        medida1      : out std_logic_vector(6 downto 0);
        medida2      : out std_logic_vector(6 downto 0);
        pronto       : out std_logic;
        db_estado    : out std_logic_vector(6 downto 0)
    );
end exp4_trena;

architecture structural of exp4_trena is

    signal 

begin

end architecture;