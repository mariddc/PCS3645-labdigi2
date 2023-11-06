library ieee;
use ieee.std_logic_1164.all;

package pill_package is
    constant CONTAINERS : natural range 1 to 16 := 1;

    subtype containers_range is natural range 0 to CONTAINERS-1;
    type pill_count is array (containers_range) of std_logic_vector(2 downto 0);

    component downwards_counter is
        generic (constant N: integer);
        port (
            clock  : in  std_logic;
            clear  : in  std_logic;
            count  : in  std_logic;
            enable : in  std_logic;
            D      : in  std_logic_vector(N-1 downto 0);
            Q      : out std_logic_vector(N-1 downto 0) 
        );
    end component downwards_counter;

    component circuito_pwm is
        generic (
            conf_periodo           : integer; 
            largura_00, largura_01 : integer;
            largura_10, largura_11 : integer
        );
        port (
            clock   : in  std_logic;
            reset   : in  std_logic;
            largura : in  std_logic_vector(1 downto 0);  
            pwm     : out std_logic 
        );
      end component circuito_pwm;

    component contador_m is
        generic (constant M, N : integer);
        port (
            clock : in  std_logic;
            zera  : in  std_logic;
            conta : in  std_logic;
            Q     : out std_logic_vector(N-1 downto 0);
            fim   : out std_logic;
            meio  : out std_logic
        );
    end component contador_m;

    component interface_hcsr04 is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            medir     : in  std_logic;
            echo      : in  std_logic;
            trigger   : out std_logic;
            medida    : out std_logic_vector(11 downto 0);
            pronto    : out std_logic;
            db_reset  : out std_logic;
            db_medir  : out std_logic;
            db_estado : out std_logic_vector(3 downto 0)
        );
    end component interface_hcsr04;

    component rx_serial_7O1 is
        generic (constant samples : natural := 16);
        port (
            clock             : in  std_logic;
            reset             : in  std_logic;
            dado_serial       : in  std_logic;
            dado_recebido     : out std_logic_vector(6 downto 0);
            paridade_recebida : out std_logic;
            pronto            : out std_logic;
            db_dado_serial    : out std_logic;
            db_estado         : out std_logic_vector(3 downto 0)
        );
    end component rx_serial_7O1;

    component hexa7seg is
        port (
            hexa : in  std_logic_vector(3 downto 0);
            sseg : out std_logic_vector(6 downto 0)
        );
    end component hexa7seg;
        
end package;