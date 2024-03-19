library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity GenericCounter_pb is
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
end entity GenericCounter_pb;

architecture RTL of GenericCounter_pb is

    signal R_CountEnable            : std_logic;
    signal R_CounterValue           : std_logic_vector(Width - 1 downto 0);
    signal R_CounterOverUnderflow   : std_logic;
    signal R_LookAheadValue         : std_logic_vector(Width - 1 downto 0);
    signal R_LookAheadOverUnderflow : std_logic;
    signal R_Set                    : std_logic;
    signal R_SetValue               : std_logic_vector(Width - 1 downto 0);

begin
    GenericCounter_inst : entity work.GenericCounter
        generic map(
            Width             => Width,
            InitialValue      => InitialValue,
            ResetValue        => ResetValue,
            CountingDirection => CountingDirection,
            LookAhead         => LookAhead
        )
        port map(
            CLK                    => CLK,
            RST                    => RST,
            CE                     => CE,
            CountEnable            => R_CountEnable,
            CounterValue           => R_CounterValue,
            CounterOverUnderflow   => R_CounterOverUnderflow,
            LookAheadValue         => R_LookAheadValue,
            LookAheadOverUnderflow => R_LookAheadOverUnderflow,
            Set                    => R_Set,
            SetValue               => R_SetValue
        );

    process (CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                R_CountEnable          <= '0';
                CounterValue           <= (others => '0');
                CounterOverUnderflow   <= '0';
                LookAheadValue         <= (others => '0');
                LookAheadOverUnderflow <= '0';
                R_Set                  <= '0';
                R_SetValue             <= (others => '0');
            elsif CE = '1' then
                R_CountEnable          <= CountEnable;
                CounterValue           <= R_CounterValue;
                CounterOverUnderflow   <= R_CounterOverUnderflow;
                LookAheadValue         <= R_LookAheadValue;
                LookAheadOverUnderflow <= R_LookAheadOverUnderflow;
                R_Set                  <= Set;
                R_SetValue             <= SetValue;
            end if;
        end if;
    end process;
end architecture RTL;