----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2021 23:30:43
-- Design Name: 
-- Module Name: tb_vga_controller_wrapper - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.env.finish;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_vga_controller_wrapper is
--  Port ( );
end tb_vga_controller_wrapper;

architecture Behavioral of tb_vga_controller_wrapper is
    component vga_controller_wrapper is
        port (
            sys_clock : in std_logic;
            reset : in std_logic;
            ram_addr : out std_logic_vector (26 downto 0) );
    end component;
    
    signal tb_clk : std_logic := '0';
    signal tb_rst : std_logic := '0';
    signal tb_rst_neg : std_logic;
    signal tb_mem_add : std_logic_vector (26 downto 0);
    
    procedure wait_clk(constant cycle : in integer) is
    begin
        for i in 0 to cycle-1 loop
            wait until falling_edge(tb_clk);
        end loop;
    end procedure;
begin
    -- Clock generation @ 100 MHz
    tb_clk <= not tb_clk after 5 ns;
    
    -- Assign negated reset
    tb_rst_neg <= not tb_rst;

    DUT: vga_controller_wrapper port map (
        sys_clock => tb_clk,
        reset => tb_rst_neg,
        ram_addr => tb_mem_add );
        
        
    test_vga_controller_wrapper: process
    begin
        -- Reset system
        tb_rst <= '1';
        wait_clk(10);
        tb_rst <= '0';
        wait_clk(10);
        wait for 50 ms;
        -- Stop simulation
        report "Simulation completed";
        finish;
    end process; 
end Behavioral;
