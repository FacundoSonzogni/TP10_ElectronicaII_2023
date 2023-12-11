library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Paquete que incluye el Contador -------------
package contador_pkg is
    component contador is
        port (
        rst   : in std_logic;
        D     : in std_logic_vector (5 downto 0); -- que valor tiene N?
        carga : in std_logic;
        hab   : in std_logic;
        clk   : in std_logic;
        Q     : out std_logic_vector (5 downto 0); -- que valor tiene N?
        Co    : out std_logic);
    end component;
end package;

-- Declaración de la entidad ---------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity contador is 
port (
    rst   : in std_logic;
    D     : in std_logic_vector (5 downto 0); -- que valor tiene N?
    carga : in std_logic;
    hab   : in std_logic;
    clk   : in std_logic;
    Q     : out std_logic_vector (5 downto 0); -- que valor tiene N?
    Co    : out std_logic);
end contador;

-- Arquitectura e Implementación del Contador ----------------
architecture solucion_contador of contador is
    signal EstadoActual, EstadoSig : std_logic_vector (5 downto 0);
begin
        LogicaSalida: process (all)
            begin 
                Q <= EstadoActual;
                if EstadoActual = (5 downto 0 => '1') then 
                    Co <= '1'; 
                else 
                    Co <= '0';
                end if;
            end process;

        Memoria: process(all)
            begin
                if rst = '1' then 
                    EstadoActual <= (others => '0');
                elsif rising_edge(clk) then 
                    EstadoActual <= EstadoSig;
                end if;
            end process;

        LogicaEstadoSig: process (all)
        begin
            if hab = '0' then EstadoSig <= EstadoActual;
            elsif carga ='1' then EstadoSig <= D;
            else EstadoSig <= std_logic_vector(unsigned (EstadoActual) + 1);       
            end if ;
        end process;

end solucion_contador;

















