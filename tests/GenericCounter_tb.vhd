-- VHDL Testbench for GenericCounter
library ieee;
use ieee.std_logic_1164.all;

entity GenericCounter_tb is
end GenericCounter_tb;

architecture behavior of GenericCounter_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component GenericCounter
        generic (
            Width             : integer := 4;
            InitialValue      : integer := 0;
            ResetValue        : integer := 0;
            CountingDirection : string  := "UP";
            LookAhead         : integer := 0
        );
        port (
            CLK            : in std_logic;
            RST            : in std_logic;
            CE             : in std_logic;
            CountEnable    : in std_logic;
            CounterValue   : out std_logic_vector(Width - 1 downto 0);
            LookAheadValue : out std_logic_vector(Width - 1 downto 0);
            Set            : in std_logic;
            SetValue       : in std_logic_vector(Width - 1 downto 0);
            OverUnderflow  : out std_logic
        );
    end component;

    -- Inputs
    signal CLK         : std_logic                    := '0';
    signal RST         : std_logic                    := '0';
    signal CE          : std_logic                    := '0';
    signal CountEnable : std_logic                    := '0';
    signal Set         : std_logic                    := '0';
    signal SetValue    : std_logic_vector(3 downto 0) := (others => '0');

    --Outputs
    signal CounterValue   : std_logic_vector(3 downto 0);
    signal LookAheadValue : std_logic_vector(3 downto 0);
    signal OverUnderflow  : std_logic;

    -- Clock period definitions
    constant CLK_period : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut : component GenericCounter
        generic map(
            Width             => 4,
            InitialValue      => 0,
            ResetValue        => 0,
            CountingDirection => "UP",
            LookAhead         => 1
        )
        port map(
            CLK            => CLK,
            RST            => RST,
            CE             => CE,
            CountEnable    => CountEnable,
            CounterValue   => CounterValue,
            LookAheadValue => LookAheadValue,
            Set            => Set,
            SetValue       => SetValue,
            OverUnderflow  => OverUnderflow
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
            SetValue <= "1010";
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
