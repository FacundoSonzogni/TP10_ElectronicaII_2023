library IEEE;
use IEEE.std_logic_1164.all;

-- FlipFlop D de 16 bits-----------------------------------------------
entity FF_D_16b is
    port (
        in_cmd          : in std_logic_vector (7 downto 0);
        in_dir          : in std_logic_vector (7 downto 0);
        in_hab          : in std_logic;
        in_reset          : in std_logic;
        in_clk          : in std_logic;
        out_cmd         : out std_logic_vector (7 downto 0);
        out_dir         : out std_logic_vector (7 downto 0));
end FF_D_16b;

architecture solucion_FFD of FF_D_16b is
begin
    ffd_conRyHab : process(in_clk,in_reset)
        begin
            if (in_reset = '1') then
                Q <= (others => '0');
            elsif(rising_edge(in_clk) and in_hab='1') then
                Q <= D;
            end if; 
        end process;
end architecture;



--Registro de Desplazamiento------------------------------------------------
entity registro_sipo is
    port (
        in_dato         : in std_logic;
        in_clk          : in std_logic;
        in_hab          : in std_logic;
        in_reset        : in std_logic;
        out_datos       : out std_logic_vector (31 downto 0));
end registro_sipo;

architecture solucion_registro of registro_sipo is
    signal estado_actual, estado_sig : std_logic_vector (N-1 downto 0);
begin
    out_datos <= estado_actual;

    Logicaestado_siguiente: process(all)
        begin
            if in_hab = '1' then
                estado_sig <= in_dato & estado_actual(N-1 downto 1);
            else
                estado_sig <= estado_actual;
            end if;
        end process;

    Memoria: process(all)
        begin
            if in_reset = '1' then 
                estado_actual <= (others => '0');
            elsif rising_edge(in_clk) then 
                estado_actual <= estado_sig;
            end if;
        end process;
end solucion_registro;

-- Contador --------------------------------------------------------------------
entity contador is 
    generic (
        constant N:positive);
    port (
        rst   : in std_logic;
        D     : in std_logic_vector (N-1 downto 0); -- que valor tiene N?
        carga : in std_logic;
        hab   : in std_logic;
        clk   : in std_logic;
        Q     : out std_logic_vector (N-1 downto 0); -- que valor tiene N?
        Co    : out std_logic);
end contador;

architecture solucion_contador of contador is
    signal EstadoActual, EstadoSig : std_logic_vector (N-1 downto 0);
begin
        LogicaSalida: process (all)
            begin 
                Q<=EstadoActual;
                if EstadoActual=(N-1 downto 0 => '1') then 
                    Co<='1';
                else 
                    Co <='0';
                end if ;
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
            else EstadoSig <= std_logic_vector(unsigned (EstadoActual)+1);       
            end if ;
        end process;

end solucion_contador;

-- Detector de Tiempo ---------------------------------------------------------
entity det_tiempo is
    generic (
        constant N : natural := 4); -- cuanto debería ser N?
    port (
        rst     : in std_logic;
        pulso   : in std_logic;
        hab     : in std_logic;
        clk     : in std_logic;
        med     : out std_logic;
        tiempo  : out std_logic_vector (N-1 downto 0));
end det_tiempo;

architecture solucion of det_tiempo is
    component contador
        generic (
            constant N:positive); -- Va esto?
        port (
            rst   : in std_logic;
            D     : in std_logic_vector (N-1 downto 0); -- que valor tiene N?
            carga : in std_logic;
            hab   : in std_logic;
            clk   : in std_logic;
            Q     : out std_logic_vector (N-1 downto 0); -- que valor tiene N?
            Co    : out std_logic);
    end component;

    constant cte_uno:std_logic_vector(N-1 downto 0):=(0 =>'1', others=>'0');
    signal HabContador, FlancoAsc, FlancoDes, Flanco, MedAnterior, Q_1: std_logic;
    signal Q_2, Salida: std_logic_vector (N-1 downto 0);

begin                       
    FlancoDes<= not pulso and Q_1;
    FlancoAsc<= pulso and not Q_1;
    
    Flanco<= FlancoAsc or FlancoDes;
    MedAnterior<=FlancoAsc when Flanco else med;
    
    Salida <= Q_2 when FlancoAsc else tiempo;
                                                    ---- ver como es con N despues
    U1: contador generic map (N=>N) port map ( 
            rst=>rst,
            D=>cte_uno,
            carga=>FlancoDes,
            hab=>HabContador,
            clk=>clk,
            Q=>Q_2
        );
        
    HabContador <= hab when to_integer(unsigned(Q_2)) /= 0 else (FlancoDes and hab);
        
    FFD1: process(all)
    begin
        if rst='1' then 
            Q_1<=('1');
        elsif rising_edge(clk) then 
            Q_1<=pulso;
        end if ;
    end process; 

    FFD2: process(all)
    begin
        if rst='1' then 
            med<='0';
        elsif (rising_edge(clk)) then 
            med<=MedAnterior;    
        end if ;
    end process;

    FFD3: process(all)
    begin
        if rst='1' then 
            tiempo<=(others=>'0');
        elsif (rising_edge (clk)) then 
            tiempo<=Salida;  
        end if ;
    end process;
        
end solucion;


-- RECEPTOR----------------------------------------------------------------------
entity receptor_ir is
    port (
        in_rst          : in std_logic;
        in_infrarrojo   : in std_logic;
        in_hab          : in std_logic;
        in_clk          : in std_logic;
        out_valido      : out std_logic;
        out_dir         : out std_logic_vector (7 downto 0);
        out_cmd         : out std_logic_vector (7 downto 0));
end receptor_ir;

architecture arch of receptor_ir is
    component FF_D_16b
        port(
            in_cmd          : in std_logic_vector (7 downto 0);
            in_dir          : in std_logic_vector (7 downto 0);
            in_hab          : in std_logic;
            in_reset          : in std_logic;
            in_clk          : in std_logic;
            out_cmd         : out std_logic_vector (7 downto 0);
            out_dir         : out std_logic_vector (7 downto 0));
    end component;

    component registro_sipo
        port (
            in_dato         : in std_logic;
            in_clk          : in std_logic;
            in_hab          : in std_logic;
            in_reset        : in std_logic;
            out_datos       : out std_logic_vector (31 downto 0));
    end component;

    component det_tiempo
        port (
            rst     : in std_logic;
            pulso   : in std_logic;
            hab     : in std_logic;
            clk     : in std_logic;
            med     : out std_logic;
            tiempo  : out std_logic_vector (N-1 downto 0));
    end component;

begin

    FF_D : FF_D_16b port map(
    
    );
    registro : registro_sipo port map(
    
    );
    detector_tiempo : det_tiempo port map(
    --Nose si pueden tener el mismo nombre
    );


end architecture;