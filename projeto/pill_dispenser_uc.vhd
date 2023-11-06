library ieee;
use ieee.std_logic_1164.all;

entity pill_dispenser_uc is
    port (
        clock          : in  std_logic;
        reset          : in  std_logic;
        check_timeout  : in  std_logic;
        safety_timeout : in  std_logic;
        detected       : in  std_logic;
        -- control
        count    : out std_logic;
        move     : out std_logic;
        discount : out std_logic;
        -- debug
        db_state : out std_logic_vector(3 downto 0)
    );
end entity;

architecture fsm_arch of pill_dispenser_uc is
    type state is (idle, check, dispense, countdown, await);
    signal current_state, next_state : state;
begin

    -- state
    process (reset, clock)
    begin
        if reset='1' then
            current_state <= idle;
        elsif clock'event and clock='1' then
            current_state <= next_state;
        end if;
    end process;

    -- next state
    process (current_state, detected, check_timeout, safety_timeout)
    begin
      case current_state is
        when idle      =>  if detected='1' then next_state <= check;
                           else                 next_state <= idle;
                           end if;
        when check     =>  if detected='0'         then next_state <= idle;
                           elsif check_timeout='1' then next_state <= dispense;
                           else                         next_state <= check;
                           end if;
        when dispense  =>  if detected='0'          then next_state <= idle;
                           elsif safety_timeout='1' then next_state <= await;
                           else                          next_state <= dispense;
                           end if;
        when await     =>  if safety_timeout='1' then next_state <= countdown;
                           else                       next_state <= await;
                           end if;
        when countdown =>  next_state <= dispense;
        when others    =>  next_state <= idle;
      end case;
    end process;

  -- control signals
  with current_state select
      count    <= '1' when check | dispense | await, '0' when others;
  with current_state select
      move     <= '1' when dispense, '0' when others;
  with current_state select
      discount <= '1' when countdown, '0' when others;

  with current_state select
      db_state <= "0000" when idle, 
                  "0001" when check,
                  "0010" when dispense,
                  "0011" when countdown, 
                  "0100" when await, 
                  "1110" when others; -- Error

end architecture;