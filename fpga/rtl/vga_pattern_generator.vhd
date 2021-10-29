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
        -- System signals
        i_clk        : in  std_logic;   -- Clock @ 100 MHz
        i_rst        : in  std_logic;   -- Reset
        -- DDR RAM Signals
        o_ram_addr   : out std_logic_vector(26 downto 0); -- SRAM address
        i_ram_data_r : in  std_logic_vector(15 downto 0); -- SRAM read data
        o_ram_cen    : out std_logic;   -- SRAM chip enable
        i_ram_wen    : in  std_logic;   -- SRAM write enable
        o_ram_oen    : out std_logic;   -- SRAM output enable
        o_ram_ub     : out std_logic;   -- SRAM upper byte
        o_ram_lb     : out std_logic;   -- SRAM lower byte
        -- VGA Signals
        i_horz_count : in  std_logic_vector(9 downto 0); -- Horizontal count
        i_vert_count : in  std_logic_vector(9 downto 0); -- Vertical count
        o_red        : out std_logic_vector(3 downto 0); -- 4-bit red channel output
        o_green      : out std_logic_vector(3 downto 0); -- 4-bit green channel output
        o_blue       : out std_logic_vector(3 downto 0) -- 4-bit blue channel output
    );
end vga_pattern_generator;

architecture RTL of vga_pattern_generator is
    constant x_pixel_start : integer := 144;
    constant x_pixel_end   : integer := 783;
    constant y_pixel_start : integer := 31;
    constant y_pixel_end   : integer := 510;

    signal w_h_count       : unsigned(9 downto 0);
    signal w_v_count       : unsigned(9 downto 0);
    signal r_display       : std_logic; -- Display image
    signal r_data_read     : std_logic; -- '1' if data was already read from RAM, else '0'
    signal r_ram_read_addr : unsigned(26 downto 0);
    signal r_reading       : std_logic;
    signal w_read_done     : std_logic;
    signal r_red_value     : std_logic_vector(3 downto 0);
    signal r_green_value   : std_logic_vector(3 downto 0);
    signal r_blue_value    : std_logic_vector(3 downto 0);
begin
    -- Show pixel values when output is enabled and no reset
    o_red   <= r_red_value when r_display = '1' and i_rst = '0' else (others => '0');
    o_green <= r_green_value when r_display = '1' and i_rst = '0' else (others => '0');
    o_blue  <= r_blue_value when r_display = '1' and i_rst = '0' else (others => '0');

    w_h_count <= unsigned(i_horz_count);
    w_v_count <= unsigned(i_vert_count);

    read_pixel_value : process(i_clk, i_rst, i_ram_wen)
    begin
        -- Reset on reset signal or when a RAM write operation is detected
        if i_rst = '1' or i_ram_wen = '0' then
            o_ram_addr      <= (others => 'Z');
            o_ram_cen       <= 'Z';
            o_ram_oen       <= 'Z';
            o_ram_ub        <= 'Z';
            o_ram_lb        <= 'Z';
            r_display       <= '0';
            r_ram_read_addr <= (others => '0');
            r_data_read     <= '0';
            r_reading       <= '0';
        elsif rising_edge(i_clk) then
            -- Load from RAM only when in display range, with 1 count prefetch
            r_display <= '0';
            if w_v_count >= y_pixel_start and w_v_count <= y_pixel_end then
                if w_h_count >= x_pixel_start - 1 and w_h_count <= x_pixel_end - 1 then
                    r_display <= '1';
                    -- Skip reading if all data was already read
                    if r_data_read = '0' then
                        -- Check if red, green and blue pixel values were not read yet
                        if r_data_read = '0' then
                            -- Reading has finished
                            if w_read_done = '1' then
                                o_ram_addr      <= (others => 'Z');
                                o_ram_cen       <= 'Z';
                                o_ram_oen       <= 'Z';
                                o_ram_ub        <= 'Z';
                                o_ram_lb        <= 'Z';
                                r_ram_read_addr <= r_ram_read_addr + 3;
                                r_data_read     <= '1';
                                r_reading       <= '0';
                                r_red_value     <= i_ram_data_r(3 downto 0);
                                r_green_value   <= i_ram_data_r(7 downto 4);
                                r_blue_value    <= i_ram_data_r(11 downto 8);
                            else
                                o_ram_addr <= std_logic_vector(r_ram_read_addr);
                                o_ram_cen  <= '0';
                                o_ram_oen  <= '0';
                                o_ram_ub   <= '0';
                                o_ram_lb   <= '0';
                                r_reading  <= '1';
                            end if;
                        end if;
                    end if;
                end if;
            else
                -- Reset RAM address when image has been read
                r_ram_read_addr <= (others => '0');
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
            i_rst => i_rst or not r_reading,
            i_en  => r_reading,
            o_out => w_read_done
        );
end RTL;
