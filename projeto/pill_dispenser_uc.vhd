library ieee;
use std_logic_1164.all;

entity pill_dispenser_uc is
    port (
        clock    : in std_logic;
        reset    : in std_logic;
        timeout  : in std_logic;
        detected : in std_logic;
        -- debug
        db_state : out std_logic_vector(3 downto 0);
    );
end entity;

architecture fsm_arch of pill_dispenser_uc is
    type state is (idle, verification, dispense);
    signal current_state, next_state : state;
begin

    -- state
    process (reset, clock)
    begin
        if reset = '1' then
            current_state <= idle;
        elsif clock'event and clock = '1' then
            current_state <= next_state;
        end if;
    end process;

    -- next state
    process (current_state, detected, timeout)
    begin
      case current_state is
        when idle           =>  if detected='1' then next_state <= dispense;   -- <= verification
                                else                 next_state <= idle;
                                end if;
        when verification   =>  if timeout='0'     then next_state <= verification;
                                elsif detected='0' then next_state <= idle;
                                else                    next_state <= dispense;
                                end if;
        when dispense       =>  next_state <= idle;
        when others         =>  next_state <= idle;
      end case;
    end process;

  -- saidas de controle
  with current_state select 
      zera   <= '1' when inicial, '0' when others;
  with current_state select
      conta  <= '1' when espera, '0' when others;
  with current_state select
      medir  <= '1' when medida, '0' when others;
  with current_state select
      avanca <= '1' when posicionamento, '0' when others;

  with current_state select
      db_state <= "0000" when idle, 
                  "0001" when verification, 
                  "0010" when dispense,
                  "0011" when interrompido,
                  "0100" when espera, 
                  "0101" when medida,
                  "0110" when transmissao,
                  "0111" when posicionamento,
                  "1110" when others; -- Erro

end architecture;