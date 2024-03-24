-- VHDL Testbench for GenericCounter
library ieee;
use ieee.std_logic_1164.all;

entity GenericCounter_tb is
end GenericCounter_tb;

architecture behavior of GenericCounter_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component GenericCounter
        generic (
            Width             : integer := 6;
            InitialValue      : integer := 0;
            ResetValue        : integer := 0;
            CountingDirection : string  := "DOWN";
            LookAhead         : integer := 1
        );
        port (
            CLK : in std_logic;
            RST : in std_logic;
            CE  : in std_logic;
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
    end component;

    -- Inputs
    signal CLK         : std_logic                    := '0';
    signal RST         : std_logic                    := '0';
    signal CE          : std_logic                    := '0';
    signal CountEnable : std_logic                    := '0';
    signal Set         : std_logic                    := '0';
    signal SetValue    : std_logic_vector(5 downto 0) := (others => '0');

    --Outputs
    signal CounterValue           : std_logic_vector(5 downto 0);
    signal CounterOverUnderflow   : std_logic;
    signal LookAheadValue         : std_logic_vector(5 downto 0);
    signal LookAheadOverUnderflow : std_logic;

    -- Clock period definitions
    constant CLK_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut : component GenericCounter
        generic map(
            Width             => 6,
            InitialValue      => 0,
            ResetValue        => 0,
            CountingDirection => "DOWN",
            LookAhead         => 1
        )
        port map(
            CLK                    => CLK,
            RST                    => RST,
            CE                     => CE,
            CountEnable            => CountEnable,
            CounterValue           => CounterValue,
            LookAheadValue         => LookAheadValue,
            Set                    => Set,
            SetValue               => SetValue,
            CounterOverUnderflow   => CounterOverUnderflow,
            LookAheadOverUnderflow => LookAheadOverUnderflow
        );

        -- Clock process definitions
        CLK_process : process
        begin
            CLK <= '0';
            wait for CLK_period/2;
            CLK <= '1';
            wait for CLK_period/2;
        end process;

        -- Testbench Statements
        stim_proc : process
        begin
            -- Initialize Inputs
            RST <= '1';
            wait for CLK_period * 1;
            RST <= '0';
            CE  <= '1';

            -- Add stimulus here
            CountEnable <= '0';
            wait for CLK_period * 5;

            -- Add stimulus here
            CountEnable <= '1';
            wait for CLK_period * 5;

            -- Set operation
            Set      <= '1';
            SetValue <= "101010";
            wait for CLK_period * 1;
            Set <= '0';

            -- Additional stimulus
            wait for CLK_period * 10;
            RST <= '1';
            wait for CLK_period * 1;
            RST <= '0';

            wait;
        end process;

    end behavior;
