library ieee;
use ieee.std_logic_1164.all;

entity uart_7O1 is
    port (
        clock             : in  std_logic;
        reset             : in  std_logic;
        -- Transmissor (tx)
        transmite_dado : in  std_logic;
        dados_ascii    : in  std_logic_vector(6 downto 0);
        pronto_tx      : out std_logic;
        saida_serial   : out std_logic;
        -- Receptor (rx)
        entrada_serial    : in  std_logic;
        dado_recebido     : out std_logic_vector(6 downto 0);
        pronto_rx         : out std_logic;
        paridade_recebida : out std_logic
    );
end entity;

architecture uart_7O1_arch of uart_7O1 is

begin

    TX: entity work.tx_serial_7O1(tx_serial_7O1_arch)
        port map (
            clock => clock, reset => reset, partida => transmite_dado, dados_ascii => dados_ascii,
            saida_serial => saida_serial, pronto => pronto_tx, db_clock => open, db_estado => open,
            db_partida => open, db_saida_serial => open, db_tick => open
        );

    RX: entity work.rx_serial_7O1(rx_serial_7O1_arch)
        port map (
            clock => clock, reset => reset, dado_serial => entrada_serial, db_dado_recebido => dado_recebido,
            dado_recebido0 => open, dado_recebido1 => open, paridade_recebida => paridade_recebida,
            pronto_rx => pronto_rx
        );

end architecture;