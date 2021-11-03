----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2021 21:12:30
-- Design Name: 
-- Module Name: tb_vga_pattern_generator - Behavioral
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

entity tb_vga_pattern_generator is
end entity tb_vga_pattern_generator;

architecture Behavioral of tb_vga_pattern_generator is
    signal tb_clk        : std_logic                     := '0';
    signal tb_rst        : std_logic                     := '0';
    signal tb_ram_addr   : std_logic_vector(26 downto 0);
    signal tb_ram_data   : std_logic_vector(15 downto 0) := (others => '1');
    signal tb_ram_lb     : std_logic;
    signal tb_ram_ub     : std_logic;
    signal tb_ram_cen    : std_logic;
    signal tb_ram_oen    : std_logic;
    signal tb_ram_wen    : std_logic := '1';
    signal tb_horz_count : unsigned(9 downto 0);
    signal tb_vert_count : unsigned(9 downto 0);
    signal tb_red        : std_logic_vector(3 downto 0);
    signal tb_green      : std_logic_vector(3 downto 0);
    signal tb_blue       : std_logic_vector(3 downto 0);

    constant pixel_data : std_logic_vector(15 downto 0) := x"dead";

    procedure wait_clk(constant cycle : in integer) is
    begin
        for i in 0 to cycle - 1 loop
            wait until falling_edge(tb_clk);
        end loop;
    end procedure;
begin
    -- Clock generation @ 100 MHz
    tb_clk <= not tb_clk after 5 ns;

    DUT : entity work.vga_pattern_generator
        port map(
            i_clk        => tb_clk,
            i_rst        => tb_rst,
            o_ram_addr   => tb_ram_addr,
            i_ram_data_r => tb_ram_data,
            o_ram_cen    => tb_ram_cen,
            i_ram_wen    => tb_ram_wen,
            o_ram_oen    => tb_ram_oen,
            o_ram_ub     => tb_ram_ub,
            o_ram_lb     => tb_ram_lb,
            i_horz_count => std_logic_vector(tb_horz_count),
            i_vert_count => std_logic_vector(tb_vert_count),
            o_red        => tb_red,
            o_green      => tb_green,
            o_blue       => tb_blue
        );

    tb_ram_data <= pixel_data after 210 ns when tb_ram_cen = '0' and tb_ram_oen = '0' and tb_ram_lb = '0' and tb_ram_ub = '0' and tb_ram_addr = std_logic_vector(to_unsigned(0, tb_ram_addr'length));

    test_vga_pattern_generator : process
    begin
        -- Reset system
        tb_rst <= '1';
        wait_clk(50);
        tb_rst <= '0';
        wait_clk(100);

        -- Simulate counter
        for y in 0 to 520 loop
            tb_vert_count <= to_unsigned(y, tb_vert_count'length);
            for x in 0 to 799 loop
                tb_horz_count <= to_unsigned(x, tb_horz_count'length);
                wait for 40 ns;
            end loop;
        end loop;

        -- Stop simulation
        report "Simulation completed";
        finish;
    end process test_vga_pattern_generator;
end architecture Behavioral;
