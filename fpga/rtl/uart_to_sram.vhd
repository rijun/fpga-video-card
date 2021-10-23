----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2021 00:14:30
-- Design Name: 
-- Module Name: uart_to_sram - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_to_sram is
    port(
        i_clk      : in  std_logic;
        i_rst      : in  std_logic;
        i_rx_data  : in  std_logic_vector(7 downto 0);
        i_rx_dv    : in  std_logic;
        o_ram_addr : out std_logic_vector(26 downto 0);
        o_ram_data : out std_logic_vector(15 downto 0);
        o_ram_lb   : out std_logic;
        o_ram_ub   : out std_logic;
        o_ram_cen  : out std_logic;
        o_ram_wen  : out std_logic
    );
end uart_to_sram;

architecture Behavioral of uart_to_sram is
    type state_type is (t_IDLE, t_WAIT, t_WRITE);
    signal state         : state_type                    := t_IDLE;
    signal next_state    : state_type                    := t_IDLE;
    signal addr          : unsigned(26 downto 0)         := (others => '0');
    signal rx_buffer     : std_logic_vector(15 downto 0) := (others => '0');
    signal first_byte_recv : std_logic := '0';
    signal write_counter : unsigned(4 downto 0)          := (others => '0');
    signal rx_timeout    : unsigned(11 downto 0)         := (others => '1');
begin
    state_storage : process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            state <= t_IDLE;
        elsif rising_edge(i_clk) then
            state <= next_state;
        end if;
    end process state_storage;

    state_transition_logic : process(state, i_rx_dv, rx_counter, write_counter, rx_timeout)
    begin
        case state is
            when t_IDLE =>
                if (i_rx_dv = '1') then
                    next_state <= t_WAIT;
                else
                    next_state <= t_IDLE;
                end if;
            when t_WAIT =>
                if (rx_counter(1) = '1') then
                    next_state <= t_WRITE;
                elsif (rx_timeout = 0) then
                    next_state <= t_IDLE;
                else
                    next_state <= t_WAIT;
                end if;
            when t_WRITE =>
                if (write_counter < 26) then
                    next_state <= t_WRITE;
                else
                    next_state <= t_WAIT;
                end if;
        end case;
    end process state_transition_logic;

    output_logic : process(state, addr, rx_buffer, write_counter)
    begin
        case state is
            when t_WRITE =>
                o_ram_addr <= std_logic_vector(addr);
                o_ram_data <= rx_buffer;
                o_ram_lb   <= '0';
                o_ram_ub   <= '0';
                o_ram_cen  <= '0';
                o_ram_wen  <= '0';

                if (write_counter = 26 - 1) then
                    rx_counter <= (others => '0');
                    addr       <= addr + 1;
                end if;
            when others =>
                o_ram_addr <= (others => '0');
                o_ram_data <= (others => '0');
                o_ram_lb   <= '1';
                o_ram_ub   <= '1';
                o_ram_cen  <= '1';
                o_ram_wen  <= '1';
        end case;

        if (state = t_IDLE) then
            addr <= (others => '0');
        end if;
    end process output_logic;

    -- Timer process for various timers
    timer_proc : process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            write_counter <= (others => '0');
            rx_timeout    <= (others => '1');
            if (state = t_WAIT) then
                rx_timeout <= rx_timeout - 1;
            end if;
            if (state = t_WRITE) then
                write_counter <= write_counter + 1;
            end if;
        end if;
    end process timer_proc;

    -- Process to store RX data when received
    rx_store_proc : process(i_rx_dv)
    begin
        if (rising_edge(i_rx_dv) and rx_counter(1) /= '1') then
            rx_buffer  <= rx_buffer(7 downto 0) & i_rx_data;
            if (rx_counter(0) = '0') then
                rx_counter(0) <= '1';
            else
                 rx_counter(1) <= '1';
             end if;
        end if;
    end process rx_store_proc;

end Behavioral;
