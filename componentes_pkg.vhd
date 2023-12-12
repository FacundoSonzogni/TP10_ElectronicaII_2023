library IEEE;
use IEEE.std_logic_1164.all;

package componentes_pkg is
    component control is
        port (
            hab          : in std_logic;
            med          : in std_logic;
            rst          : in std_logic;
            clk          : in std_logic;
            mensaje_ok   : in std_logic;
            tiempo       : in std_logic_vector (5 downto 0);
            valido       : out std_logic;
            dato         : out std_logic;
            hab_FF       : out std_logic;
            hab_sipo     : out std_logic);
    end component;
    component contador is
        generic (
            constant N : natural);
        port (
        rst   : in std_logic;
        D     : in std_logic_vector (N-1 downto 0);
        carga : in std_logic;
        hab   : in std_logic;
        clk   : in std_logic;
        Q     : out std_logic_vector (N-1 downto 0);
        Co    : out std_logic);
    end component;
    component det_tiempo is
        generic (
            constant N : natural); 
        port (
            rst     : in std_logic;
            pulso   : in std_logic;
            hab     : in std_logic;
            clk     : in std_logic;
            med     : out std_logic;
            tiempo  : out std_logic_vector (N-1 downto 0)); 
    end component;
    component sipo is
        generic (
            constant N : natural); 
        port (
        in_dato         : in std_logic;
        in_clk          : in std_logic;
        in_hab          : in std_logic;
        in_reset        : in std_logic;
        out_datos       : out std_logic_vector (N-1 downto 0)); 
    end component;

end package;


------------------------CONTADOR--------------------------------------------
entity contador is 
    generic (
        constant N : natural);
    port (
    rst   : in std_logic;
    D     : in std_logic_vector (N-1 downto 0);
    carga : in std_logic;
    hab   : in std_logic;
    clk   : in std_logic;
    Q     : out std_logic_vector (N-1 downto 0);
    Co    : out std_logic);
end contador;

architecture solucion_contador of contador is
    signal EstadoActual, EstadoSig : std_logic_vector (N-1 downto 0);
begin
    LogicaSalida: process (all)
        begin 
            Q <= EstadoActual;
            if EstadoActual = (N-1 downto 0 => '1') then 
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

end architecture;

----------------------------SIPO--------------------------------------------
entity sipo is
    generic (
        constant N : natural); 
    port (
    in_dato         : in std_logic;
    in_clk          : in std_logic;
    in_hab          : in std_logic;
    in_reset        : in std_logic;
    out_datos       : out std_logic_vector (N-1 downto 0)); 
end sipo;

architecture solucion_sipo of sipo is
    signal EstadoActual, EstadoSig : std_logic_vector (N-1 downto 0);
begin
    Q <= EstadoActual;

    LogicaEstadoSiguiente: process(all)
        begin
            if hab = '1' then
                EstadoSig <= entrada & EstadoActual(N-1 downto 1);
            else
                EstadoSig <= EstadoActual;
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
end architecture;

--------------------------DETECTOR DE TIEMPO--------------------------------------------
entity det_tiempo is
    generic (
        constant N : natural); 
    port (
        rst     : in std_logic;
        pulso   : in std_logic;
        hab     : in std_logic;
        clk     : in std_logic;
        med     : out std_logic;
        tiempo  : out std_logic_vector (N-1 downto 0));
end det_tiempo;

-- Arquitectura e Implementación del Detector de Tiempo entre Pulsos ----------------
architecture solucion_det_tiempo of det_tiempo is

    constant cte_uno:std_logic_vector(N-1 downto 0):=(0 =>'1', others=>'0');
    signal HabContador, FlancoAsc, FlancoDes, Flanco, MedAnterior, Q_1: std_logic;
    signal Q_2, Salida: std_logic_vector (N-1 downto 0);

begin                       
    FlancoDes <= not pulso and Q_1;
    FlancoAsc <= pulso and not Q_1;
    
    Flanco <= FlancoAsc or FlancoDes;
    MedAnterior <=FlancoAsc when Flanco else med;
    
    Salida <= Q_2 when FlancoAsc else tiempo;

    U1 : contador generic map (N => N) port map ( 
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
        
end architecture;


---------------------------BLOQUE DE CONTROL--------------------------------------------
entity control is
    port (
        hab          : in std_logic;
        med          : in std_logic;
        rst          : in std_logic;
        clk          : in std_logic;
        mensaje_ok   : in std_logic;
        tiempo       : in std_logic_vector (5 downto 0);
        valido       : out std_logic;
        dato         : out std_logic;
        hab_FF       : out std_logic;
        hab_sipo     : out std_logic);
end control;

architecture solucion_control of control is
begin
end architecture