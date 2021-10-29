----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2021 00:15:44
-- Design Name: 
-- Module Name: video_card - RTL
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

entity video_card is
    port(
        -- System inputs
        sys_clk     : in  std_logic;
        resetn      : in  std_logic;
        -- UART input
        uart_txd_in : in  std_logic;
        -- VGA outputs
        vga_r       : out std_logic_vector(3 downto 0);
        vga_g       : out std_logic_vector(3 downto 0);
        vga_b       : out std_logic_vector(3 downto 0);
        vga_hs      : out std_logic;
        vga_vs      : out std_logic
    );
end video_card;

architecture RTL of video_card is
    signal clk_100        : std_logic;  -- 100 MHz clock
    signal clk_25         : std_logic;  --  25 MHz clock
    signal rst            : std_logic;  -- Global reset
    signal r_horz_counter : std_logic_vector(9 downto 0);
    signal r_vert_counter : std_logic_vector(9 downto 0);
    signal r_display_en   : std_logic;
    signal r_pixel_x      : std_logic_vector(9 downto 0);
    signal r_pixel_y      : std_logic_vector(8 downto 0);
    signal w_ram_addr     : std_logic_vector(26 downto 0);
    signal w_ram_data_r   : std_logic_vector(15 downto 0);
    signal w_ram_cen      : std_logic;
    signal w_ram_wen      : std_logic;
    signal w_ram_oen      : std_logic;
    signal w_ram_lb       : std_logic;
    signal w_ram_ub       : std_logic;
begin
    rst <= not resetn;

    vga_counter : entity work.vga_counter
        port map(
            i_clk     => clk_25,
            i_resetn  => resetn,
            o_h_count => r_horz_counter,
            o_v_count => r_vert_counter
        );

    vga_synchronizer : entity work.vga_synchronizer
        port map(
            i_clk     => clk_25,
            i_rst     => rst,
            i_h_count => r_horz_counter,
            i_v_count => r_vert_counter,
            o_h_sync  => vga_hs,
            o_v_sync  => vga_vs,
            o_beam    => r_display_en,
            o_pixel_x => r_pixel_x,
            o_pixel_y => r_pixel_y
        );

    vga_pattern_generator : entity work.vga_pattern_generator
        port map(
            i_clk        => clk_100,
            i_rst        => resetn,
            i_beam       => r_display_en,
            o_ram_addr   => w_ram_addr,
            i_ram_data_r => w_ram_data_r,
            o_ram_cen    => w_ram_cen,
            i_ram_wen    => w_ram_wen,
            o_ram_oen    => w_ram_oen,
            o_ram_ub     => w_ram_ub,
            o_ram_lb     => w_ram_lb,
            i_pixel_x    => r_pixel_x,
            i_pixel_y    => r_pixel_y,
            o_red        => vga_r,
            o_green      => vga_g,
            o_blue       => vga_b
        );
end RTL;
