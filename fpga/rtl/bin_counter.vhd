----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.10.2021 00:44:52
-- Design Name: 
-- Module Name: bin_counter - Behavioral
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

entity bin_counter is
    generic(
        c_WIDTH : integer := 32
    );
    port(
        i_clk   : in  std_logic;
        i_rst   : in  std_logic;
        i_en    : in  std_logic;
        o_count : out unsigned(c_WIDTH downto 0)
    );
end bin_counter;

architecture Behavioral of bin_counter is
    signal r_counter : unsigned(c_WIDTH downto 0);
begin
    o_count <= r_counter;

    process(i_rst, i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_en = '1') then
                r_counter <= r_counter + 1;
            end if;
        end if;
        if (i_rst = '1') then
            r_counter <= (others => '0');
        end if;
    end process;

end Behavioral;
