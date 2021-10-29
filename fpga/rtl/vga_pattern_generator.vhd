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
    port(
        i_clk        : in  std_logic;   -- Clock @ 100 MHz
        i_rst        : in  std_logic;   -- Reset
        i_beam       : in  std_logic;   -- 'Electron' beam on
        -- DDR RAM Signals
        o_ram_addr   : out std_logic_vector(26 downto 0); -- SRAM address
        i_ram_data_r : in  std_logic_vector(15 downto 0); -- SRAM read data
        o_ram_cen    : out std_logic;   -- SRAM chip enable
        i_ram_wen    : in  std_logic;   -- SRAM write enable
        o_ram_oen    : out std_logic;   -- SRAM output enable
        o_ram_ub     : out std_logic;   -- SRAM upper byte
        o_ram_lb     : out std_logic;   -- SRAM lower byte
        -- VGA Signals
        i_pixel_x    : in  std_logic_vector(9 downto 0); -- Pixel coordinate x position
        i_pixel_y    : in  std_logic_vector(8 downto 0); -- Pixel coordinate y position
        o_red        : out std_logic_vector(3 downto 0); -- 4-bit red channel output
        o_green      : out std_logic_vector(3 downto 0); -- 4-bit green channel output
        o_blue       : out std_logic_vector(3 downto 0) -- 4-bit blue channel output
    );
end vga_pattern_generator;

architecture RTL of vga_pattern_generator is
    signal r_red_value   : std_logic_vector(3 downto 0);
    signal r_green_value : std_logic_vector(3 downto 0);
    signal r_blue_value  : std_logic_vector(3 downto 0);
    signal w_reading     : std_logic;
    signal s_read_done   : std_logic;
begin
    -- Show pixel values when output is enabled and no reset
    o_red   <= r_red_value when i_beam = '1' and i_rst = '0' else (others => '0');
    o_green <= r_green_value when i_beam = '1' and i_rst = '0' else (others => '0');
    o_blue  <= r_blue_value when i_beam = '1' and i_rst = '0' else (others => '0');

    read_pixel_value : process(i_rst, i_pixel_x, i_pixel_y, s_read_done, i_ram_wen)
    begin
        if i_rst = '1' then
            o_ram_addr <= (others => 'Z');
            o_ram_cen  <= 'Z';
            o_ram_oen  <= 'Z';
            o_ram_ub   <= 'Z';
            o_ram_lb   <= 'Z';
        else
            if rising_edge(s_read_done) then
                w_reading <= '0';
                
            elsif i_ram_wen = '1' then  -- Prevent reading if write is in progress
                o_ram_addr <= (others => 'Z');
                o_ram_cen  <= '0';
                o_ram_oen  <= '0';
                o_ram_ub   <= '0';
                o_ram_lb   <= '0';
            end if;
        end if;
    end process read_pixel_value;

    read_counter : entity work.counter_up
        generic map(
            c_WIDTH => 5,
            c_MAX   => 21
        )
        port map(
            i_clk => i_clk,
            i_rst => i_rst or not w_reading,
            i_en  => w_reading,
            o_out => s_read_done
        );
end RTL;
