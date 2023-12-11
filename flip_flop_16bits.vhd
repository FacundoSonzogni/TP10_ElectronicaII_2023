library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Paquete que incluye el Flip Flop de 16 bits -------------
package ffd_16bits_pkg is
    component ffd_16bits is
        port (
            in_cmd          : in std_logic_vector (7 downto 0);
            in_dir          : in std_logic_vector (7 downto 0);
            in_hab          : in std_logic;
            in_reset          : in std_logic;
            in_clk          : in std_logic;
            out_cmd         : out std_logic_vector (7 downto 0);
            out_dir         : out std_logic_vector (7 downto 0)); 
    end component;
end package;

-- Declaración de la entidad ---------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ffd_16bits is
    port (
        in_cmd          : in std_logic_vector (7 downto 0);
        in_dir          : in std_logic_vector (7 downto 0);
        in_hab          : in std_logic;
        in_reset        : in std_logic;
        in_clk          : in std_logic;
        out_cmd         : out std_logic_vector (7 downto 0);
        out_dir         : out std_logic_vector (7 downto 0));
end ffd_16bits;

-- Arquitectura e Implementación del Flip Flop ----------------
architecture solucion_FFD of ffd_16bits is
    signal D, Q : std_logic_vector (15 downto 0);
begin

    in_cmd <= D(15 downto 8);
    in_dir <= D(7 downto 0);

    ffd_16bits : process(in_clk,in_reset)
    begin
        if (in_reset = '1') then
            Q <= (others => '0');
        elsif(rising_edge(in_clk) and in_hab='1') then
            Q <= D;
        end if; 
    end process;

    out_cmd <= Q(15 downto 8);
    out_dir <= Q(7 downto 0);

end architecture;