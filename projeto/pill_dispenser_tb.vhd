library ieee;
use ieee.std_logic_1164.all;
use work.pill_package.CONTAINERS;

entity pill_dispenser_tb is
end entity;

architecture tb of pill_dispenser_tb is
  
    component pill_dispenser is
        port (
            clock     : in  std_logic;
            reset     : in  std_logic;
            db_switch : in  std_logic_vector(1 downto 0);
            echo      : in  std_logic;
            serial    : in  std_logic;
            pwm       : out std_logic_vector(CONTAINERS-1 downto 0);
            trigger   : out std_logic;
            alert     : out std_logic;
            -- debug
            db_reset   : out std_logic;
            db_pwm     : out std_logic;
            db_echo    : out std_logic;
            db_trigger : out std_logic;
            db_state       : out std_logic_vector(6 downto 0);
            db_measurement : out std_logic_vector(20 downto 0)
        );
    end component;
  
    signal clock_in         : std_logic := '0';
    signal reset_in         : std_logic := '0';
    signal db_switch_in     : std_logic_vector(1 downto 0) := "00";
    signal echo_in          : std_logic := '0';
    signal serial_in        : std_logic := '1';
    signal pwm_out          : std_logic_vector(CONTAINERS-1 downto 0) := (others => '0');
    signal trigger_out      : std_logic := '0';
    signal alert_out        : std_logic := '0';

  -- Configurações do clock
  constant clock_period  : time      := 20 ns;            -- 50MHz clock
  constant bit_period    : time      := 434*clock_period; -- 115.200 bauds
  signal keep_simulating : std_logic := '0';              -- limits the simulation
  
  -- Array de posicoes de teste
  type serial_test_type is record
      id    : natural; 
      char  : std_logic_vector(7 downto 0);     
  end record;

  -- fornecida tabela com 2 posicoes (comentadas 6 posicoes)
  type serial_test_array is array (natural range <>) of serial_test_type;
  constant serial_test : serial_test_array :=
      ( 
        ( 1, "00000001" ), 
        ( 2, "10000011" ),
        ( 3, "10010111" ),
        ( 4, "10000110" )
      );

  signal case_id : natural;

    procedure UART_WRITE_BYTE (
        data_in           : in  std_logic_vector(7 downto 0);
        signal serial_out : out std_logic
    ) is
    begin

        -- send start bit
        serial_out <= '0';
        wait for bit_period;

        -- envia 8 bits seriais
        for j in 0 to 7 loop
            serial_out <= data_in(j);
            wait for bit_period;
        end loop;

        -- envia 2 Stop Bits
        serial_out <= '1';
        wait for 2*bit_period;

    end UART_WRITE_BYTE;

begin

  clock_in <= (not clock_in) and keep_simulating after clock_period/2;
  
  -- Conecta DUT (Device Under Test)
  DUT: pill_dispenser
        port map( 
            clock          => clock_in,
            reset          => reset_in,
            db_switch      => db_switch_in,
            echo           => echo_in,
            serial         => serial_in,
            pwm            => pwm_out,
            trigger        => trigger_out,
            alert          => alert_out,
            -- debug
            db_reset       => open,
            db_pwm         => open,
            db_echo        => open,
            db_trigger     => open,
            db_state       => open,
            db_measurement => open
        );

  -- geracao dos sinais de entrada (estimulos)
  STIMULUS: process is
  begin
  
    assert false report "Inicio das simulacoes" severity note;
    keep_simulating <= '1';

    ---- reset ----
    reset_in <= '1'; 
    wait for 2 us;
    reset_in <= '0';
    -- check that the system doesn't trigger anything without external stimulus 
    wait for 10 us;
    wait until falling_edge(clock_in);

    ---- loop different dosages for the same container
    for i in serial_test'range loop
        case_id <= serial_test(i).id;

        assert false report "Dosage " & integer'image(case_id) severity note;

        UART_WRITE_BYTE (data_in => serial_test(i).char, serial_out => serial_in);
        serial_in <= '1';
        wait for 100 ms;
    end loop;

    -- tests termination
    assert false report "End of simulation" severity note;
    keep_simulating <= '0';
    
    wait; -- simu end: awaits indefinitely
  end process;

end architecture;
