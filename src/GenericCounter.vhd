----------------------------------------------------------------------------------
--@ - Name:     Generic Counter <br>
--@ - Version:  0.0.3 <br>
--@ - Author:   __Maximilian Passarello ([Blog](mpassarello.de))__ <br>
--@ - License:  [MIT](LICENSE) <br>
--@             
--@             Generic Counter with the following features:
--@             - **Without Output Register**
--@             - Look ahead value (configurable per generic)
--@             - Synchronous reset
--@             - Clock enable
--@             - `Set` with priority over the `CountEnable`
--@             - Over- and Underflow flag
--@             - Configurable width
--@             - Configurable initial value
--@             - Configurable reset value
--@             - Configurable counting direction (Up and Down counting)
--@ ## History
--@ - 0.0.1 (2024-03-15) Initial version
--@ - 0.0.2 (2024-03-16) Added Testbench. Simulation passed.
--@ - 0.0.3 (2024-03-19) Add `LookAheadOverUnderflow` output,
--@                      added parallel adders for the counter and lookahead.
----------------------------------------------------------------------------------
--@ ## Waveform
--@ {
--@     "signal": [
--@         [
--@             "General",
--@             {
--@                 "name": "CLK",
--@                 "wave": "P.....|........",
--@                 "node": "0123456789abcde",
--@                 "period": 1
--@             },
--@             {
--@                 "name": "RST",
--@                 "wave": "10....|.....10."
--@             },
--@             {
--@                 "name": "CE",
--@                 "wave": "0.1...|........"
--@             }
--@         ],
--@         [
--@             "Set",
--@             {
--@                 "name": "Set",
--@                 "wave": "0.....|..10...."
--@             },
--@             {
--@                 "name": "SetValue",
--@                 "wave": "x.....|..8x....",
--@                 "data": [
--@                     "5"
--@                 ]
--@             }
--@         ],
--@         [
--@             "Counter",
--@             {
--@                 "name": "CountEnable",
--@                 "wave": "0..1..|.......0"
--@             },
--@             {
--@                 "name": "CounterValue",
--@                 "wave": "4..777|77777777",
--@                 "data": "0 1 2 3 15 0 5 6 7 8 1 1"
--@             },
--@             {
--@                 "name": "LookAheadValue",
--@                 "wave": "4..777|77777777",
--@                 "data": "1 2 3 4 0 1 6 7 8 9 2 2"
--@             }
--@         ],
--@         [
--@             "Flags",
--@             {
--@                 "name": "OverUnderflow",
--@                 "wave": "0.....|.10....."
--@             }
--@         ]
--@     ],
--@     "config": {
--@         "hscale": 1
--@     },
--@     "head": {
--@         "text": "<b>Generic Counter</b>"
--@     },
--@     "foot": {
--@         "text": "RST Value = 0"
--@     }
--@ }
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity GenericCounter is
    generic (
        --@ Width of the counter
        Width : integer := 4;
        --@ Initial value of the counter
        InitialValue : integer := 0;
        --@ Reset value of the counter
        ResetValue : integer := 0;
        --@ Counting direction: "UP" or "DOWN"
        CountingDirection : string := "UP";
        --@ Look ahead value
        LookAhead : integer := 2
    );
    port (
        --@ Clock input; rising edge
        CLK : in std_logic;
        --@ Reset input; active high; synchronous
        RST : in std_logic;
        --@ Clock enable; active high
        CE : in std_logic;
        --@ Count enable; active high
        CountEnable : in std_logic;
        --@ Counter Value
        CounterValue : out std_logic_vector(Width - 1 downto 0);
        --@ Counter over- and underflow flag
        CounterOverUnderflow : out std_logic;
        --@ Look ahead value
        LookAheadValue : out std_logic_vector(Width - 1 downto 0);
        --@ Counter over- and underflow flag
        LookAheadOverUnderflow : out std_logic;
        --@ Set with priority over the `CountEnable`
        Set : in std_logic;
        --@ If set is high, the counter will be set to SetValue
        SetValue : in std_logic_vector(Width - 1 downto 0)
    );
end entity GenericCounter;

architecture RTL of GenericCounter is
    function Str_Equal(str1 : string; str2 : string) return boolean is
    begin
        if str1'length /= str2'length then
            return FALSE;
        else
            return (str1 = str2);
        end if;
    end function;

    function CountingStep(BinaryValue : unsigned; Step : integer := 1)
        return unsigned is
    begin
        if Str_Equal(CountingDirection, "UP") then
            return BinaryValue + Step;
        else
            return BinaryValue - Step;
        end if;
    end function CountingStep;

    signal R_Counter                : unsigned(Width - 1 downto 0) := to_unsigned(InitialValue, Width);
    signal C_NextCounter            : unsigned(Width - 1 downto 0) := to_unsigned(InitialValue, Width);
    signal C_LookAhead              : unsigned(Width - 1 downto 0) := to_unsigned(InitialValue + LookAhead, Width);
    signal C_OverUnderflow          : std_logic;
    signal C_LookAheadOverUnderflow : std_logic;
begin

    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                R_Counter <= to_unsigned(ResetValue, Width);
            elsif CE = '1' then
                if Set = '1' then
                    R_Counter <= unsigned(SetValue);
                else
                    R_Counter <= C_NextCounter;
                end if;
            end if;
        end if;
    end process;

    Counting : process (R_Counter, CountEnable)
        variable V_CounterOverUnderflow   : unsigned(Width downto 0);
        variable V_LookAhead              : unsigned(Width downto 0);
        variable V_LookAheadOverUnderflow : unsigned(Width downto 0);
    begin
        if CountEnable = '1' then
            V_CounterOverUnderflow   := CountingStep("0" & R_Counter);
            V_LookAheadOverUnderflow := CountingStep("0" & R_Counter, 1 + LookAhead);

            C_NextCounter   <= V_CounterOverUnderflow(Width - 1 downto 0);
            C_OverUnderflow <= V_CounterOverUnderflow(Width);

            C_LookAhead              <= V_LookAheadOverUnderflow(Width - 1 downto 0);
            C_LookAheadOverUnderflow <= V_LookAheadOverUnderflow(Width) and not(V_CounterOverUnderflow(Width));
        else
            V_LookAhead := CountingStep("0" & R_Counter, LookAhead);

            C_NextCounter   <= R_Counter;
            C_OverUnderflow <= '0';

            C_LookAhead              <= V_LookAhead(Width - 1 downto 0);
            C_LookAheadOverUnderflow <= '0';
        end if;
    end process;

    CounterValue           <= std_logic_vector(C_NextCounter);
    CounterOverUnderflow   <= C_OverUnderflow;
    LookAheadValue         <= std_logic_vector(C_LookAhead);
    LookAheadOverUnderflow <= C_LookAheadOverUnderflow;

end architecture RTL;
