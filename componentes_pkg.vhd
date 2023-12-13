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
            tiempo       : in std_logic_vector (4 downto 0);
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

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
library IEEE;
use IEEE.std_logic_1164.all;

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
    out_datos <= EstadoActual;

    LogicaEstadoSiguiente: process(all)
        begin
            if in_hab = '1' then
                EstadoSig <= in_dato & EstadoActual(N-1 downto 1);
            else
                EstadoSig <= EstadoActual;
            end if;
        end process;

    Memoria: process(all)
        begin
            if in_reset = '1' then 
                EstadoActual <= (others => '0');
            elsif rising_edge(in_clk) then 
                EstadoActual <= EstadoSig;
            end if;
        end process;
end architecture;

--------------------------DETECTOR DE TIEMPO--------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

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

begin                       
    FlancoDes <= not pulso and Q_1;
    FlancoAsc <= pulso and not Q_1;
    
    Flanco <= FlancoAsc or FlancoDes;
    MedAnterior <= FlancoAsc when Flanco else med;
    
    Salida <= Q_2 when FlancoAsc else tiempo;

    U1 : contador generic map (N => N) port map ( 
            rst     => rst,
            D       => cte_uno,
            carga   => FlancoDes,
            hab     => HabContador,
            clk     => clk,
            Q       => Q_2
        );
        
    HabContador <= hab when unsigned(Q_2) /= 0 else (FlancoDes and hab);
        
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
            if (med = '0') then
                med <= MedAnterior;
            elsif (med = '1') then
                med <= '0';
            end if;
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
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity control is
    port (
        hab          : in std_logic;
        med          : in std_logic;
        rst          : in std_logic;
        clk          : in std_logic;
        mensaje_ok   : in std_logic;
        tiempo       : in std_logic_vector (4 downto 0);
        valido       : out std_logic;
        dato         : out std_logic;
        hab_FF       : out std_logic;
        hab_sipo     : out std_logic);
end control;

architecture solucion_control of control is
    signal cont_sig, cont_act : std_logic_vector (4 downto 0);
    signal valido_sig, valido_act : std_logic;
    signal tiempo_unsigned, cont_act_unsigned : unsigned (4 downto 0);
    type Tipo_Estado is (espera, recepcion, verificacion);
    signal estado_act, estado_sig : Tipo_Estado;
begin

    tiempo_unsigned <= unsigned(tiempo);
    cont_act_unsigned <= unsigned(cont_act);
    
    MEMORIA_ESTADO :  process (clk, rst)
    begin
        if rst = '1' then
            estado_act <= espera;
            valido_act <= '0';
            cont_act <= (others => '0');
        elsif rising_edge(clk) then
            if hab = '1' then
                estado_act <= estado_sig;
                valido_act <= valido_sig;
                cont_act <= cont_sig;
            end if;
        end if;
    end process;

    LOGICA_ESTADO_SIGUIENTE  : process (all)
    begin

        case estado_act is
            when espera =>
                if med = '0' then
                    estado_sig <= espera;
                elsif med = '1' then
                    if ((11 <= tiempo_unsigned) and (tiempo_unsigned <= 13)) then
                        estado_sig <= espera;
                    elsif ((23 <= tiempo_unsigned) and (tiempo_unsigned <= 25)) then
                        estado_sig <= recepcion;
                    end if;
                end if;

            when recepcion =>
                if med = '0' then
                    estado_sig <= recepcion;
                elsif med = '1' then
                    if ((2 <= tiempo_unsigned) and (tiempo_unsigned <= 4)) and (cont_act_unsigned <= 30)  then
                        estado_sig <= recepcion; 
                    elsif ((8 <= tiempo_unsigned) and (tiempo_unsigned <= 10)) and (cont_act_unsigned <= 30)  then
                        estado_sig <= recepcion;
                    elsif ((2 <= tiempo_unsigned) and (tiempo_unsigned <= 4)) and (cont_act_unsigned = 31)  then
                        estado_sig <= verificacion;
                    elsif ((8 <= tiempo_unsigned) and (tiempo_unsigned <= 10)) and (cont_act_unsigned = 31)  then
                        estado_sig <= verificacion;
                    end if;
                end if;

            when verificacion =>
                if mensaje_ok = '1' then
                    estado_sig <= espera;
                elsif mensaje_ok = '0' then
                    estado_sig <= espera;   
                end if;

            when others =>
                    estado_sig <= espera;
        end case;
    end process;

    LOGICA_SALIDA : process (all)
    begin

        -- Valores por Defecto
        hab_FF <= '0';
        hab_sipo <= '0';
        valido_sig <= '0';
        cont_sig <= cont_act;

        case estado_act is
            when espera =>
                if med = '1' then
                    if ((11 <= tiempo_unsigned) and (tiempo_unsigned <= 13)) and valido_act = '1' then
                        hab_FF <= '0';
                        valido_sig <= '1';
                    elsif ((23 <= tiempo_unsigned) and (tiempo_unsigned <= 25)) then
                        cont_sig <= (others => '0');
                    end if;
                end if;

            when recepcion =>
                if med = '1' then
                    if ((2 <= tiempo_unsigned) and (tiempo_unsigned <= 4)) and (cont_act_unsigned <= 30)  then
                        dato <= '0';
                        cont_sig <= std_logic_vector(unsigned(cont_act) + 1);
                        hab_sipo <= '1';
                    elsif ((8 <= tiempo_unsigned) and (tiempo_unsigned <= 10)) and (cont_act_unsigned <= 30)  then
                        dato <= '1';
                        cont_sig <= std_logic_vector(unsigned(cont_act) + 1);
                        hab_sipo <= '1';
                    elsif ((2 <= tiempo_unsigned) and (tiempo_unsigned <= 4)) and (cont_act_unsigned = 31)  then
                        dato <= '0';
                        cont_sig <= (others => '0');
                        hab_sipo <= '1';
                    elsif ((8 <= tiempo_unsigned) and (tiempo_unsigned <= 10)) and (cont_act_unsigned = 31)  then
                        dato <= '1';
                        cont_sig <= (others => '0');
                        hab_sipo <= '1';
                    end if;
                end if;

            when verificacion =>
                if mensaje_ok = '1' then
                    hab_sipo <= '0';
                    hab_FF <= '1';
                    valido_sig <= '1';
                elsif mensaje_ok = '0' then
                    hab_sipo <= '0';
                    hab_FF <= '0';
                    valido_sig <= '0';  
                end if;                
                 
        end case;        
    end process;

    valido <= valido_act;

end architecture;