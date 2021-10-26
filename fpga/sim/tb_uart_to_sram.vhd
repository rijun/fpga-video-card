----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 21:12:30
-- Design Name: 
-- Module Name: tb_uart_to_sram - Behavioral
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
use std.env.finish;

entity tb_uart_to_sram is
end entity tb_uart_to_sram;

architecture Behavioral of tb_uart_to_sram is
    component uart_rx is
        generic(
            g_CLKS_PER_BIT : integer := 115 -- Needs to be set correctly
        );
        port(
            i_Clk       : in  std_logic;
            i_RX_Serial : in  std_logic;
            o_RX_DV     : out std_logic;
            o_RX_Byte   : out std_logic_vector(7 downto 0)
        );
    end component uart_rx;

    component concatenator_16 is
        port(
            i_rst  : in  std_logic;
            i_load : in  std_logic;
            i_data : in  std_logic_vector(7 downto 0);
            o_dv   : out std_logic;
            o_data : out std_logic_vector(15 downto 0)
        );
    end component;

    component sram_fsm is
        port(
            i_clk      : in  std_logic;
            i_rst      : in  std_logic;
            i_data     : in  std_logic_vector(15 downto 0);
            i_write    : in  std_logic;
            o_ram_addr : out std_logic_vector(26 downto 0);
            o_ram_data : out std_logic_vector(15 downto 0);
            o_ram_lb   : out std_logic;
            o_ram_ub   : out std_logic;
            o_ram_cen  : out std_logic;
            o_ram_wen  : out std_logic
        );
    end component;

    signal tb_clk               : std_logic := '0';
    signal tb_rst               : std_logic := '0';
    signal tb_tx_data           : std_logic := '1';
    signal tb_rx_data           : std_logic_vector(7 downto 0);
    signal tb_rx_dv             : std_logic;
    signal tb_rx_processed_dv   : std_logic;
    signal tb_rx_processed_data : std_logic_vector(15 downto 0);
    signal tb_ram_addr          : std_logic_vector(26 downto 0);
    signal tb_ram_data          : std_logic_vector(15 downto 0);
    signal tb_ram_lb            : std_logic;
    signal tb_ram_ub            : std_logic;
    signal tb_ram_cen           : std_logic;
    signal tb_ram_wen           : std_logic;

    constant byte_1 : std_logic_vector(7 downto 0) := "01101101";
    constant byte_2 : std_logic_vector(7 downto 0) := "10101111";
    constant byte_3 : std_logic_vector(7 downto 0) := "10111100";
    constant byte_4 : std_logic_vector(7 downto 0) := "11011011";

    procedure wait_clk(constant cycle : in integer) is
    begin
        for i in 0 to cycle - 1 loop
            wait until falling_edge(tb_clk);
        end loop;
    end procedure;
begin
    -- Clock generation @ 100 MHz
    tb_clk <= not tb_clk after 5 ns;

    uart : uart_rx
        generic map(
            g_CLKS_PER_BIT => 109       -- = (100 MHz)/(921600 bit/s)
        )
        port map(
            i_Clk       => tb_clk,
            i_RX_Serial => tb_tx_data,
            o_RX_DV     => tb_rx_dv,
            o_RX_Byte   => tb_rx_data
        );

    concat : concatenator_16
        port map(
            i_rst  => tb_rst,
            i_load => tb_rx_dv,
            i_data => tb_rx_data,
            o_dv   => tb_rx_processed_dv,
            o_data => tb_rx_processed_data
        );

    DUT : sram_fsm
        port map(
            i_clk      => tb_clk,
            i_rst      => tb_rst,
            i_data     => tb_rx_processed_data,
            i_write    => tb_rx_processed_dv,
            o_ram_addr => tb_ram_addr,
            o_ram_data => tb_ram_data,
            o_ram_lb   => tb_ram_lb,
            o_ram_ub   => tb_ram_ub,
            o_ram_cen  => tb_ram_cen,
            o_ram_wen  => tb_ram_wen
        );

    test_vga_controller_wrapper : process
    begin
        -- Reset system
        tb_rst <= '1';
        wait_clk(10);
        tb_rst <= '0';
        wait_clk(10);

        -- Send first byte
        tb_tx_data <= '0';
        wait for 1.085 us;
        for i in 0 to 7 loop
            tb_tx_data <= byte_1(i);
            wait for 1.085 us;
        end loop;
        tb_tx_data <= '1';
        wait for 10.851 us;

        -- Send second byte
        tb_tx_data <= '0';
        wait for 1.085 us;
        for i in 0 to 7 loop
            tb_tx_data <= byte_2(i);
            wait for 1.085 us;
        end loop;
        tb_tx_data <= '1';
        wait for 10.851 us;

        -- Send third byte
        tb_tx_data <= '0';
        wait for 1.085 us;
        for i in 0 to 7 loop
            tb_tx_data <= byte_3(i);
            wait for 1.085 us;
        end loop;
        tb_tx_data <= '1';
        wait for 10.851 us;

        -- Send fourth byte
        tb_tx_data <= '0';
        wait for 1.085 us;
        for i in 0 to 7 loop
            tb_tx_data <= byte_4(i);
            wait for 1.085 us;
        end loop;
        tb_tx_data <= '1';

        wait for 25 us;
        -- Stop simulation
        report "Simulation completed";
        finish;
    end process;
end architecture Behavioral;
