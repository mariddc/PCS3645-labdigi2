library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity downwards_counter is
    generic (constant N: integer := 3);
    port (
        clock  : in  std_logic;
        clear  : in  std_logic;
        count  : in  std_logic;
        enable : in  std_logic;
        D      : in  std_logic_vector (N-1 downto 0);
        Q      : out std_logic_vector (N-1 downto 0) 
    );
end entity downwards_counter;

architecture behavioral of downwards_counter is
    signal IQ : natural;
begin

process(clock, clear, enable, IQ)
    begin
        if (clear = '1') then IQ <= 0;
        elsif (clock'event and clock='1') then
            if (count='1') then
                if (IQ /= 0) then IQ <= IQ - 1;
                end if;
            elsif (enable='1') then IQ <= to_integer(unsigned(D)); 
            else IQ <= IQ;
            end if;
        end if;
        Q <= std_logic_vector(to_unsigned(IQ, Q'length));
    end process;
  
end architecture behavioral;
