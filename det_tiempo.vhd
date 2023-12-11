library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.contador_pkg.all;

-- Paquete que incluye el Detector de Tiempo entre Pulsos -------------
package det_tiempo_pkg is
    component det_tiempo is
        generic (
            constant N : natural := 4); -- cuanto debería ser N?
        port (
            rst     : in std_logic;
            pulso   : in std_logic;
            hab     : in std_logic;
            clk     : in std_logic;
            med     : out std_logic;
            tiempo  : out std_logic_vector (N-1 downto 0)); 
    end component;
end package;

-- Declaración de la entidad -------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.contador_pkg.all;

entity det_tiempo is
    port (
        rst     : in std_logic;
        pulso   : in std_logic;
        hab     : in std_logic;
        clk     : in std_logic;
        med     : out std_logic;
        tiempo  : out std_logic_vector (5 downto 0));
end det_tiempo;

-- Arquitectura e Implementación del Detector de Tiempo entre Pulsos ----------------
architecture solucion of det_tiempo is
    component contador
        port (
            rst   : in std_logic;
            D     : in std_logic_vector (5 downto 0); -- que valor tiene N?
            carga : in std_logic;
            hab   : in std_logic;
            clk   : in std_logic;
            Q     : out std_logic_vector (5 downto 0); -- que valor tiene N?
            Co    : out std_logic);
    end component;

    constant cte_uno:std_logic_vector(5 downto 0):=(0 =>'1', others=>'0');
    signal HabContador, FlancoAsc, FlancoDes, Flanco, MedAnterior, Q_1: std_logic;
    signal Q_2, Salida: std_logic_vector (5 downto 0);

begin                       
    FlancoDes <= not pulso and Q_1;
    FlancoAsc <= pulso and not Q_1;
    
    Flanco <= FlancoAsc or FlancoDes;
    MedAnterior <=FlancoAsc when Flanco else med;
    
    Salida <= Q_2 when FlancoAsc else tiempo;
                                                    ---- ver como es con N despues
    U1: contador port map ( 
            rst     => rst,
            D       => cte_uno,
            carga   => FlancoDes,
            hab     => HabContador,
            clk     => clk,
            Q       => Q_2
        );
        
    HabContador <= hab when to_integer(unsigned(Q_2)) /= 0 else (FlancoDes and hab);
        
    FFD1: process(all)
    begin
        if rst='1' then 
            Q_1 <= ('1');
        elsif rising_edge(clk) then 
            Q_1 <= pulso;
        end if ;
    end process; 

    FFD2: process(all)
    begin
        if rst = '1' then 
            med <= '0';
        elsif (rising_edge(clk)) then 
            med <= MedAnterior;    
        end if ;
    end process;

    FFD3: process(all)
    begin
        if rst = '1' then 
            tiempo <= (others=>'0');
        elsif (rising_edge (clk)) then 
            tiempo <= Salida;  
        end if ;
    end process;
        
end solucion;















