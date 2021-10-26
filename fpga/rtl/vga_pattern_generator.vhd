----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2021 14:37:36
-- Design Name: 
-- Module Name: vga_pattern_generator - RTL
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

entity vga_pattern_generator is
    port ( beam       : in std_logic;
           resetn     : in std_logic;
           -- DDR RAM Signals
           ram_addr   : out std_logic_vector (26 downto 0);
           ram_data_r : in std_logic_vector (15 downto 0);
           ram_cen    : out std_logic;
           ram_wen    : out std_logic;
           ram_ub     : out std_logic;
           ram_lb     : out std_logic;
           -- VGA Signals
           pixel_x    : in std_logic_vector (9 downto 0);
           pixel_y    : in std_logic_vector (8 downto 0);
           red        : out std_logic_vector (3 downto 0);
           green      : out std_logic_vector (3 downto 0);
           blue       : out std_logic_vector (3 downto 0) );
end vga_pattern_generator;

architecture RTL of vga_pattern_generator is
    signal rst : std_logic;
begin
    rst <= not resetn;
    red   <= (others => '0');
    green <= (others => '0');
    blue  <= (others => '0');

    pattern_proc: process(beam, pixel_x, pixel_y)
    begin
        ram_addr <= std_logic_vector(unsigned(pixel_x) + unsigned(pixel_y) * 640);
    end process;
end RTL;
