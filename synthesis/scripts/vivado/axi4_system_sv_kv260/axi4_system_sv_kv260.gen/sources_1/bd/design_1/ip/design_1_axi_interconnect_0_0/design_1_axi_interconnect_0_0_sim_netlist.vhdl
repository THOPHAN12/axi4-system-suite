-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2024.2 (win64) Build 5239630 Fri Nov 08 22:35:27 MST 2024
-- Date        : Sat Dec 20 09:47:20 2025
-- Host        : NGUYEN-HA-HAI running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim {c:/Users/Nguyen Ha
--               Hai/axi4-system-suite/synthesis/scripts/vivado/axi4_system_sv_kv260/axi4_system_sv_kv260.gen/sources_1/bd/design_1/ip/design_1_axi_interconnect_0_0/design_1_axi_interconnect_0_0_sim_netlist.vhdl}
-- Design      : design_1_axi_interconnect_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xczu5ev-sfvc784-1-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_AW_HandShake_Checker is
  port (
    AW_HandShake_Done : out STD_LOGIC;
    HandShake_Done3 : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    HandShake_Done_reg_0 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_AW_HandShake_Checker : entity is "AW_HandShake_Checker";
end design_1_axi_interconnect_0_0_AW_HandShake_Checker;

architecture STRUCTURE of design_1_axi_interconnect_0_0_AW_HandShake_Checker is
begin
HandShake_Done_reg: unisim.vcomponents.FDPE
     port map (
      C => ACLK,
      CE => '1',
      D => HandShake_Done3,
      PRE => HandShake_Done_reg_0,
      Q => AW_HandShake_Done
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_AW_HandShake_Checker_2 is
  port (
    AR_HandShake_Done : out STD_LOGIC;
    AR_Selected_Slave : in STD_LOGIC;
    M1_ARVALID : in STD_LOGIC;
    Sel_Slave_Ready : in STD_LOGIC;
    M0_ARVALID : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    HandShake_Done_reg_0 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_AW_HandShake_Checker_2 : entity is "AW_HandShake_Checker";
end design_1_axi_interconnect_0_0_AW_HandShake_Checker_2;

architecture STRUCTURE of design_1_axi_interconnect_0_0_AW_HandShake_Checker_2 is
  signal \^ar_handshake_done\ : STD_LOGIC;
  signal HandShake_Done_i_1_n_0 : STD_LOGIC;
begin
  AR_HandShake_Done <= \^ar_handshake_done\;
HandShake_Done_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"D0B3D080"
    )
        port map (
      I0 => AR_Selected_Slave,
      I1 => M1_ARVALID,
      I2 => Sel_Slave_Ready,
      I3 => M0_ARVALID,
      I4 => \^ar_handshake_done\,
      O => HandShake_Done_i_1_n_0
    );
HandShake_Done_reg: unisim.vcomponents.FDPE
     port map (
      C => ACLK,
      CE => '1',
      D => HandShake_Done_i_1_n_0,
      PRE => HandShake_Done_reg_0,
      Q => \^ar_handshake_done\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Controller is
  port (
    \FSM_sequential_curr_state_slave_reg[0]_0\ : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 );
    M0_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_RLAST : out STD_LOGIC;
    M0_RVALID : out STD_LOGIC;
    \FSM_onehot_curr_state_slave2_reg[4]_0\ : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S2_RREADY : out STD_LOGIC;
    S1_RREADY : out STD_LOGIC;
    S0_RREADY : out STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[0]_1\ : out STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[0]_2\ : out STD_LOGIC;
    M1_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_RLAST : out STD_LOGIC;
    M1_RVALID : out STD_LOGIC;
    S3_RLAST_0 : out STD_LOGIC;
    S3_RREADY : out STD_LOGIC;
    M0_RREADY : in STD_LOGIC;
    S1_RLAST : in STD_LOGIC;
    S1_RVALID : in STD_LOGIC;
    S2_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_RLAST : in STD_LOGIC;
    S3_RLAST : in STD_LOGIC;
    S0_RLAST : in STD_LOGIC;
    S2_RVALID : in STD_LOGIC;
    S3_RVALID : in STD_LOGIC;
    S0_RVALID : in STD_LOGIC;
    M1_RREADY : in STD_LOGIC;
    D : in STD_LOGIC_VECTOR ( 1 downto 0 );
    CO : in STD_LOGIC_VECTOR ( 0 to 0 );
    \FSM_sequential_curr_state_slave_reg[0]_3\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    \FSM_sequential_curr_state_slave_reg[0]_4\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[0]_5\ : in STD_LOGIC;
    M0_ARVALID : in STD_LOGIC;
    next_state_slave119_out : in STD_LOGIC;
    M1_ARVALID : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    \FSM_onehot_curr_state_slave2_reg[0]_0\ : in STD_LOGIC;
    \FSM_onehot_curr_state_slave2_reg[4]_1\ : in STD_LOGIC_VECTOR ( 2 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Controller : entity is "Controller";
end design_1_axi_interconnect_0_0_Controller;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Controller is
  signal \FSM_onehot_curr_state_slave2[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[0]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[0]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[0]_i_4_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[0]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[4]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_onehot_curr_state_slave2[4]_i_3_n_0\ : STD_LOGIC;
  signal \^fsm_onehot_curr_state_slave2_reg[4]_0\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \FSM_sequential_curr_state_slave[0]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_1_n_0\ : STD_LOGIC;
  signal \^fsm_sequential_curr_state_slave_reg[0]_1\ : STD_LOGIC;
  signal \^fsm_sequential_curr_state_slave_reg[0]_2\ : STD_LOGIC;
  signal M0_data_wire : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal M1_data_wire : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal \^q\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal S0_RREADY_INST_0_i_1_n_0 : STD_LOGIC;
  signal S1_RREADY_INST_0_i_1_n_0 : STD_LOGIC;
  signal S2_RREADY_INST_0_i_1_n_0 : STD_LOGIC;
  signal S3_RREADY_INST_0_i_1_n_0 : STD_LOGIC;
  signal curr_state_slave : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal en_S0_M1 : STD_LOGIC;
  signal \next_state_slave__0\ : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_onehot_curr_state_slave2[0]_i_2\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \FSM_onehot_curr_state_slave2[0]_i_5\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \FSM_onehot_curr_state_slave2[4]_i_3\ : label is "soft_lutpair0";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_onehot_curr_state_slave2_reg[0]\ : label is "Slave0_2:00010,Slave1_2:00100,Slave2_2:01000,Slave3_2:10000,Idle_slave_2:00001";
  attribute FSM_ENCODED_STATES of \FSM_onehot_curr_state_slave2_reg[1]\ : label is "Slave0_2:00010,Slave1_2:00100,Slave2_2:01000,Slave3_2:10000,Idle_slave_2:00001";
  attribute FSM_ENCODED_STATES of \FSM_onehot_curr_state_slave2_reg[2]\ : label is "Slave0_2:00010,Slave1_2:00100,Slave2_2:01000,Slave3_2:10000,Idle_slave_2:00001";
  attribute FSM_ENCODED_STATES of \FSM_onehot_curr_state_slave2_reg[3]\ : label is "Slave0_2:00010,Slave1_2:00100,Slave2_2:01000,Slave3_2:10000,Idle_slave_2:00001";
  attribute FSM_ENCODED_STATES of \FSM_onehot_curr_state_slave2_reg[4]\ : label is "Slave0_2:00010,Slave1_2:00100,Slave2_2:01000,Slave3_2:10000,Idle_slave_2:00001";
  attribute FSM_ENCODED_STATES of \FSM_sequential_curr_state_slave_reg[0]\ : label is "Slave0:001,Slave1:010,Slave2:011,Slave3:100,Idle_slave:000";
  attribute FSM_ENCODED_STATES of \FSM_sequential_curr_state_slave_reg[1]\ : label is "Slave0:001,Slave1:010,Slave2:011,Slave3:100,Idle_slave:000";
  attribute FSM_ENCODED_STATES of \FSM_sequential_curr_state_slave_reg[2]\ : label is "Slave0:001,Slave1:010,Slave2:011,Slave3:100,Idle_slave:000";
  attribute SOFT_HLUTNM of S3_RREADY_INST_0 : label is "soft_lutpair0";
begin
  \FSM_onehot_curr_state_slave2_reg[4]_0\(3 downto 0) <= \^fsm_onehot_curr_state_slave2_reg[4]_0\(3 downto 0);
  \FSM_sequential_curr_state_slave_reg[0]_1\ <= \^fsm_sequential_curr_state_slave_reg[0]_1\;
  \FSM_sequential_curr_state_slave_reg[0]_2\ <= \^fsm_sequential_curr_state_slave_reg[0]_2\;
  Q(0) <= \^q\(0);
\FSM_onehot_curr_state_slave2[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFF22F2"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I1 => \FSM_onehot_curr_state_slave2[0]_i_2_n_0\,
      I2 => en_S0_M1,
      I3 => \FSM_onehot_curr_state_slave2[0]_i_3_n_0\,
      I4 => \FSM_onehot_curr_state_slave2[0]_i_4_n_0\,
      O => \FSM_onehot_curr_state_slave2[0]_i_1_n_0\
    );
\FSM_onehot_curr_state_slave2[0]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => S1_RVALID,
      I1 => S1_RLAST,
      I2 => M1_RREADY,
      O => \FSM_onehot_curr_state_slave2[0]_i_2_n_0\
    );
\FSM_onehot_curr_state_slave2[0]_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => S0_RVALID,
      I1 => S0_RLAST,
      I2 => M1_RREADY,
      O => \FSM_onehot_curr_state_slave2[0]_i_3_n_0\
    );
\FSM_onehot_curr_state_slave2[0]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8000FFFF80008000"
    )
        port map (
      I0 => S3_RVALID,
      I1 => S3_RLAST,
      I2 => M1_RREADY,
      I3 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I4 => \FSM_onehot_curr_state_slave2[0]_i_5_n_0\,
      I5 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      O => \FSM_onehot_curr_state_slave2[0]_i_4_n_0\
    );
\FSM_onehot_curr_state_slave2[0]_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => S2_RVALID,
      I1 => S2_RLAST,
      I2 => M1_RREADY,
      O => \FSM_onehot_curr_state_slave2[0]_i_5_n_0\
    );
\FSM_onehot_curr_state_slave2[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF2AAA2AAA2AAA"
    )
        port map (
      I0 => en_S0_M1,
      I1 => S0_RVALID,
      I2 => S0_RLAST,
      I3 => M1_RREADY,
      I4 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I5 => next_state_slave119_out,
      O => \FSM_onehot_curr_state_slave2[1]_i_1_n_0\
    );
\FSM_onehot_curr_state_slave2[4]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFFFF80"
    )
        port map (
      I0 => M1_ARVALID,
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I2 => \FSM_sequential_curr_state_slave_reg[0]_5\,
      I3 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      I4 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I5 => \FSM_onehot_curr_state_slave2[4]_i_3_n_0\,
      O => \FSM_onehot_curr_state_slave2[4]_i_1_n_0\
    );
\FSM_onehot_curr_state_slave2[4]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I1 => en_S0_M1,
      O => \FSM_onehot_curr_state_slave2[4]_i_3_n_0\
    );
\FSM_onehot_curr_state_slave2_reg[0]\: unisim.vcomponents.FDPE
    generic map(
      INIT => '1'
    )
        port map (
      C => ACLK,
      CE => \FSM_onehot_curr_state_slave2[4]_i_1_n_0\,
      D => \FSM_onehot_curr_state_slave2[0]_i_1_n_0\,
      PRE => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      Q => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0)
    );
\FSM_onehot_curr_state_slave2_reg[1]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => ACLK,
      CE => \FSM_onehot_curr_state_slave2[4]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => \FSM_onehot_curr_state_slave2[1]_i_1_n_0\,
      Q => en_S0_M1
    );
\FSM_onehot_curr_state_slave2_reg[2]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => ACLK,
      CE => \FSM_onehot_curr_state_slave2[4]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => \FSM_onehot_curr_state_slave2_reg[4]_1\(0),
      Q => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1)
    );
\FSM_onehot_curr_state_slave2_reg[3]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => ACLK,
      CE => \FSM_onehot_curr_state_slave2[4]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => \FSM_onehot_curr_state_slave2_reg[4]_1\(1),
      Q => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2)
    );
\FSM_onehot_curr_state_slave2_reg[4]\: unisim.vcomponents.FDCE
    generic map(
      INIT => '0'
    )
        port map (
      C => ACLK,
      CE => \FSM_onehot_curr_state_slave2[4]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => \FSM_onehot_curr_state_slave2_reg[4]_1\(2),
      Q => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3)
    );
\FSM_sequential_curr_state_slave[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FEFEFEFEFEEEEEEE"
    )
        port map (
      I0 => \FSM_sequential_curr_state_slave[0]_i_2_n_0\,
      I1 => \^fsm_sequential_curr_state_slave_reg[0]_1\,
      I2 => \^fsm_sequential_curr_state_slave_reg[0]_2\,
      I3 => CO(0),
      I4 => \FSM_sequential_curr_state_slave_reg[0]_3\(0),
      I5 => \FSM_sequential_curr_state_slave_reg[0]_4\,
      O => \next_state_slave__0\(0)
    );
\FSM_sequential_curr_state_slave[0]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0002020202020202"
    )
        port map (
      I0 => curr_state_slave(0),
      I1 => curr_state_slave(1),
      I2 => \^q\(0),
      I3 => M0_RREADY,
      I4 => S0_RLAST,
      I5 => S0_RVALID,
      O => \FSM_sequential_curr_state_slave[0]_i_2_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0004040404040404"
    )
        port map (
      I0 => curr_state_slave(0),
      I1 => curr_state_slave(1),
      I2 => \^q\(0),
      I3 => M0_RREADY,
      I4 => S1_RLAST,
      I5 => S1_RVALID,
      O => \FSM_sequential_curr_state_slave_reg[0]_0\
    );
\FSM_sequential_curr_state_slave[1]_i_5\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0008080808080808"
    )
        port map (
      I0 => curr_state_slave(0),
      I1 => curr_state_slave(1),
      I2 => \^q\(0),
      I3 => M0_RREADY,
      I4 => S2_RLAST,
      I5 => S2_RVALID,
      O => \^fsm_sequential_curr_state_slave_reg[0]_1\
    );
\FSM_sequential_curr_state_slave[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0F0F0FF8"
    )
        port map (
      I0 => \FSM_sequential_curr_state_slave_reg[0]_5\,
      I1 => M0_ARVALID,
      I2 => \^q\(0),
      I3 => curr_state_slave(1),
      I4 => curr_state_slave(0),
      O => \FSM_sequential_curr_state_slave[2]_i_1_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_6\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"01"
    )
        port map (
      I0 => curr_state_slave(0),
      I1 => curr_state_slave(1),
      I2 => \^q\(0),
      O => \^fsm_sequential_curr_state_slave_reg[0]_2\
    );
\FSM_sequential_curr_state_slave[2]_i_7\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => S3_RLAST,
      I1 => S3_RVALID,
      O => S3_RLAST_0
    );
\FSM_sequential_curr_state_slave_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \FSM_sequential_curr_state_slave[2]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => \next_state_slave__0\(0),
      Q => curr_state_slave(0)
    );
\FSM_sequential_curr_state_slave_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \FSM_sequential_curr_state_slave[2]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => D(0),
      Q => curr_state_slave(1)
    );
\FSM_sequential_curr_state_slave_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \FSM_sequential_curr_state_slave[2]_i_1_n_0\,
      CLR => \FSM_onehot_curr_state_slave2_reg[0]_0\,
      D => D(1),
      Q => \^q\(0)
    );
\M0_RDATA[0]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(0),
      I1 => S3_RDATA(0),
      I2 => S0_RDATA(0),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(0),
      O => M0_RDATA(0)
    );
\M0_RDATA[10]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(10),
      I1 => S3_RDATA(10),
      I2 => S0_RDATA(10),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(10),
      O => M0_RDATA(10)
    );
\M0_RDATA[11]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(11),
      I1 => S3_RDATA(11),
      I2 => S0_RDATA(11),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(11),
      O => M0_RDATA(11)
    );
\M0_RDATA[12]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(12),
      I1 => S3_RDATA(12),
      I2 => S0_RDATA(12),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(12),
      O => M0_RDATA(12)
    );
\M0_RDATA[13]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(13),
      I1 => S3_RDATA(13),
      I2 => S0_RDATA(13),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(13),
      O => M0_RDATA(13)
    );
\M0_RDATA[14]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(14),
      I1 => S3_RDATA(14),
      I2 => S0_RDATA(14),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(14),
      O => M0_RDATA(14)
    );
\M0_RDATA[15]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(15),
      I1 => S3_RDATA(15),
      I2 => S0_RDATA(15),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(15),
      O => M0_RDATA(15)
    );
\M0_RDATA[16]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(16),
      I1 => S3_RDATA(16),
      I2 => S0_RDATA(16),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(16),
      O => M0_RDATA(16)
    );
\M0_RDATA[17]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(17),
      I1 => S3_RDATA(17),
      I2 => S0_RDATA(17),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(17),
      O => M0_RDATA(17)
    );
\M0_RDATA[18]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(18),
      I1 => S3_RDATA(18),
      I2 => S0_RDATA(18),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(18),
      O => M0_RDATA(18)
    );
\M0_RDATA[19]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(19),
      I1 => S3_RDATA(19),
      I2 => S0_RDATA(19),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(19),
      O => M0_RDATA(19)
    );
\M0_RDATA[1]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(1),
      I1 => S3_RDATA(1),
      I2 => S0_RDATA(1),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(1),
      O => M0_RDATA(1)
    );
\M0_RDATA[20]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(20),
      I1 => S3_RDATA(20),
      I2 => S0_RDATA(20),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(20),
      O => M0_RDATA(20)
    );
\M0_RDATA[21]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(21),
      I1 => S3_RDATA(21),
      I2 => S0_RDATA(21),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(21),
      O => M0_RDATA(21)
    );
\M0_RDATA[22]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(22),
      I1 => S3_RDATA(22),
      I2 => S0_RDATA(22),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(22),
      O => M0_RDATA(22)
    );
\M0_RDATA[23]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(23),
      I1 => S3_RDATA(23),
      I2 => S0_RDATA(23),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(23),
      O => M0_RDATA(23)
    );
\M0_RDATA[24]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(24),
      I1 => S3_RDATA(24),
      I2 => S0_RDATA(24),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(24),
      O => M0_RDATA(24)
    );
\M0_RDATA[25]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(25),
      I1 => S3_RDATA(25),
      I2 => S0_RDATA(25),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(25),
      O => M0_RDATA(25)
    );
\M0_RDATA[26]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(26),
      I1 => S3_RDATA(26),
      I2 => S0_RDATA(26),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(26),
      O => M0_RDATA(26)
    );
\M0_RDATA[27]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(27),
      I1 => S3_RDATA(27),
      I2 => S0_RDATA(27),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(27),
      O => M0_RDATA(27)
    );
\M0_RDATA[28]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(28),
      I1 => S3_RDATA(28),
      I2 => S0_RDATA(28),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(28),
      O => M0_RDATA(28)
    );
\M0_RDATA[29]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(29),
      I1 => S3_RDATA(29),
      I2 => S0_RDATA(29),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(29),
      O => M0_RDATA(29)
    );
\M0_RDATA[2]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(2),
      I1 => S3_RDATA(2),
      I2 => S0_RDATA(2),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(2),
      O => M0_RDATA(2)
    );
\M0_RDATA[30]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(30),
      I1 => S3_RDATA(30),
      I2 => S0_RDATA(30),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(30),
      O => M0_RDATA(30)
    );
\M0_RDATA[31]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(31),
      I1 => S3_RDATA(31),
      I2 => S0_RDATA(31),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(31),
      O => M0_RDATA(31)
    );
\M0_RDATA[31]_INST_0_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"18"
    )
        port map (
      I0 => curr_state_slave(0),
      I1 => curr_state_slave(1),
      I2 => \^q\(0),
      O => M0_data_wire(1)
    );
\M0_RDATA[31]_INST_0_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"14"
    )
        port map (
      I0 => curr_state_slave(0),
      I1 => curr_state_slave(1),
      I2 => \^q\(0),
      O => M0_data_wire(0)
    );
\M0_RDATA[3]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(3),
      I1 => S3_RDATA(3),
      I2 => S0_RDATA(3),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(3),
      O => M0_RDATA(3)
    );
\M0_RDATA[4]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(4),
      I1 => S3_RDATA(4),
      I2 => S0_RDATA(4),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(4),
      O => M0_RDATA(4)
    );
\M0_RDATA[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(5),
      I1 => S3_RDATA(5),
      I2 => S0_RDATA(5),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(5),
      O => M0_RDATA(5)
    );
\M0_RDATA[6]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(6),
      I1 => S3_RDATA(6),
      I2 => S0_RDATA(6),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(6),
      O => M0_RDATA(6)
    );
\M0_RDATA[7]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(7),
      I1 => S3_RDATA(7),
      I2 => S0_RDATA(7),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(7),
      O => M0_RDATA(7)
    );
\M0_RDATA[8]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(8),
      I1 => S3_RDATA(8),
      I2 => S0_RDATA(8),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(8),
      O => M0_RDATA(8)
    );
\M0_RDATA[9]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(9),
      I1 => S3_RDATA(9),
      I2 => S0_RDATA(9),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RDATA(9),
      O => M0_RDATA(9)
    );
M0_RLAST_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RLAST,
      I1 => S3_RLAST,
      I2 => S0_RLAST,
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RLAST,
      O => M0_RLAST
    );
\M0_RRESP[0]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RRESP(0),
      I1 => S3_RRESP(0),
      I2 => S0_RRESP(0),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RRESP(0),
      O => M0_RRESP(0)
    );
\M0_RRESP[1]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RRESP(1),
      I1 => S3_RRESP(1),
      I2 => S0_RRESP(1),
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RRESP(1),
      O => M0_RRESP(1)
    );
M0_RVALID_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RVALID,
      I1 => S3_RVALID,
      I2 => S0_RVALID,
      I3 => M0_data_wire(1),
      I4 => M0_data_wire(0),
      I5 => S1_RVALID,
      O => M0_RVALID
    );
\M1_RDATA[0]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(0),
      I1 => S3_RDATA(0),
      I2 => S0_RDATA(0),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(0),
      O => M1_RDATA(0)
    );
\M1_RDATA[10]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(10),
      I1 => S3_RDATA(10),
      I2 => S0_RDATA(10),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(10),
      O => M1_RDATA(10)
    );
\M1_RDATA[11]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(11),
      I1 => S3_RDATA(11),
      I2 => S0_RDATA(11),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(11),
      O => M1_RDATA(11)
    );
\M1_RDATA[12]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(12),
      I1 => S3_RDATA(12),
      I2 => S0_RDATA(12),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(12),
      O => M1_RDATA(12)
    );
\M1_RDATA[13]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(13),
      I1 => S3_RDATA(13),
      I2 => S0_RDATA(13),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(13),
      O => M1_RDATA(13)
    );
\M1_RDATA[14]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(14),
      I1 => S3_RDATA(14),
      I2 => S0_RDATA(14),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(14),
      O => M1_RDATA(14)
    );
\M1_RDATA[15]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(15),
      I1 => S3_RDATA(15),
      I2 => S0_RDATA(15),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(15),
      O => M1_RDATA(15)
    );
\M1_RDATA[16]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(16),
      I1 => S3_RDATA(16),
      I2 => S0_RDATA(16),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(16),
      O => M1_RDATA(16)
    );
\M1_RDATA[17]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(17),
      I1 => S3_RDATA(17),
      I2 => S0_RDATA(17),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(17),
      O => M1_RDATA(17)
    );
\M1_RDATA[18]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(18),
      I1 => S3_RDATA(18),
      I2 => S0_RDATA(18),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(18),
      O => M1_RDATA(18)
    );
\M1_RDATA[19]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(19),
      I1 => S3_RDATA(19),
      I2 => S0_RDATA(19),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(19),
      O => M1_RDATA(19)
    );
\M1_RDATA[1]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(1),
      I1 => S3_RDATA(1),
      I2 => S0_RDATA(1),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(1),
      O => M1_RDATA(1)
    );
\M1_RDATA[20]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(20),
      I1 => S3_RDATA(20),
      I2 => S0_RDATA(20),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(20),
      O => M1_RDATA(20)
    );
\M1_RDATA[21]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(21),
      I1 => S3_RDATA(21),
      I2 => S0_RDATA(21),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(21),
      O => M1_RDATA(21)
    );
\M1_RDATA[22]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(22),
      I1 => S3_RDATA(22),
      I2 => S0_RDATA(22),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(22),
      O => M1_RDATA(22)
    );
\M1_RDATA[23]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(23),
      I1 => S3_RDATA(23),
      I2 => S0_RDATA(23),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(23),
      O => M1_RDATA(23)
    );
\M1_RDATA[24]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(24),
      I1 => S3_RDATA(24),
      I2 => S0_RDATA(24),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(24),
      O => M1_RDATA(24)
    );
\M1_RDATA[25]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(25),
      I1 => S3_RDATA(25),
      I2 => S0_RDATA(25),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(25),
      O => M1_RDATA(25)
    );
\M1_RDATA[26]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(26),
      I1 => S3_RDATA(26),
      I2 => S0_RDATA(26),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(26),
      O => M1_RDATA(26)
    );
\M1_RDATA[27]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(27),
      I1 => S3_RDATA(27),
      I2 => S0_RDATA(27),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(27),
      O => M1_RDATA(27)
    );
\M1_RDATA[28]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(28),
      I1 => S3_RDATA(28),
      I2 => S0_RDATA(28),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(28),
      O => M1_RDATA(28)
    );
\M1_RDATA[29]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(29),
      I1 => S3_RDATA(29),
      I2 => S0_RDATA(29),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(29),
      O => M1_RDATA(29)
    );
\M1_RDATA[2]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(2),
      I1 => S3_RDATA(2),
      I2 => S0_RDATA(2),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(2),
      O => M1_RDATA(2)
    );
\M1_RDATA[30]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(30),
      I1 => S3_RDATA(30),
      I2 => S0_RDATA(30),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(30),
      O => M1_RDATA(30)
    );
\M1_RDATA[31]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(31),
      I1 => S3_RDATA(31),
      I2 => S0_RDATA(31),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(31),
      O => M1_RDATA(31)
    );
\M1_RDATA[31]_INST_0_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      O => M1_data_wire(1)
    );
\M1_RDATA[31]_INST_0_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      O => M1_data_wire(0)
    );
\M1_RDATA[3]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(3),
      I1 => S3_RDATA(3),
      I2 => S0_RDATA(3),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(3),
      O => M1_RDATA(3)
    );
\M1_RDATA[4]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(4),
      I1 => S3_RDATA(4),
      I2 => S0_RDATA(4),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(4),
      O => M1_RDATA(4)
    );
\M1_RDATA[5]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(5),
      I1 => S3_RDATA(5),
      I2 => S0_RDATA(5),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(5),
      O => M1_RDATA(5)
    );
\M1_RDATA[6]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(6),
      I1 => S3_RDATA(6),
      I2 => S0_RDATA(6),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(6),
      O => M1_RDATA(6)
    );
\M1_RDATA[7]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(7),
      I1 => S3_RDATA(7),
      I2 => S0_RDATA(7),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(7),
      O => M1_RDATA(7)
    );
\M1_RDATA[8]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(8),
      I1 => S3_RDATA(8),
      I2 => S0_RDATA(8),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(8),
      O => M1_RDATA(8)
    );
\M1_RDATA[9]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RDATA(9),
      I1 => S3_RDATA(9),
      I2 => S0_RDATA(9),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RDATA(9),
      O => M1_RDATA(9)
    );
M1_RLAST_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RLAST,
      I1 => S3_RLAST,
      I2 => S0_RLAST,
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RLAST,
      O => M1_RLAST
    );
\M1_RRESP[0]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RRESP(0),
      I1 => S3_RRESP(0),
      I2 => S0_RRESP(0),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RRESP(0),
      O => M1_RRESP(0)
    );
\M1_RRESP[1]_INST_0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RRESP(1),
      I1 => S3_RRESP(1),
      I2 => S0_RRESP(1),
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RRESP(1),
      O => M1_RRESP(1)
    );
M1_RVALID_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_RVALID,
      I1 => S3_RVALID,
      I2 => S0_RVALID,
      I3 => M1_data_wire(1),
      I4 => M1_data_wire(0),
      I5 => S1_RVALID,
      O => M1_RVALID
    );
S0_RREADY_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAAAAAAABAAABABA"
    )
        port map (
      I0 => S0_RREADY_INST_0_i_1_n_0,
      I1 => M0_data_wire(1),
      I2 => M0_RREADY,
      I3 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I4 => en_S0_M1,
      I5 => M0_data_wire(0),
      O => S0_RREADY
    );
S0_RREADY_INST_0_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000001000000000"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I2 => en_S0_M1,
      I3 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I4 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I5 => M1_RREADY,
      O => S0_RREADY_INST_0_i_1_n_0
    );
S1_RREADY_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF00000040"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I2 => M1_RREADY,
      I3 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I4 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      I5 => S1_RREADY_INST_0_i_1_n_0,
      O => S1_RREADY
    );
S1_RREADY_INST_0_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000D00000"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I2 => M0_RREADY,
      I3 => \^q\(0),
      I4 => curr_state_slave(1),
      I5 => curr_state_slave(0),
      O => S1_RREADY_INST_0_i_1_n_0
    );
S2_RREADY_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFF00000200"
    )
        port map (
      I0 => M1_RREADY,
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I2 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(1),
      I3 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      I4 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I5 => S2_RREADY_INST_0_i_1_n_0,
      O => S2_RREADY
    );
S2_RREADY_INST_0_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00D0000000000000"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(2),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I2 => M0_RREADY,
      I3 => \^q\(0),
      I4 => curr_state_slave(1),
      I5 => curr_state_slave(0),
      O => S2_RREADY_INST_0_i_1_n_0
    );
S3_RREADY_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FF08"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I1 => M1_RREADY,
      I2 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I3 => S3_RREADY_INST_0_i_1_n_0,
      O => S3_RREADY
    );
S3_RREADY_INST_0_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000000000D000"
    )
        port map (
      I0 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(3),
      I1 => \^fsm_onehot_curr_state_slave2_reg[4]_0\(0),
      I2 => M0_RREADY,
      I3 => \^q\(0),
      I4 => curr_state_slave(1),
      I5 => curr_state_slave(0),
      O => S3_RREADY_INST_0_i_1_n_0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Faling_Edge_Detc is
  port (
    AW_Access_Grant : out STD_LOGIC;
    Falling_reg_0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    AW_HandShake_Done : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    reg_Test_Signal_reg_0 : in STD_LOGIC;
    M0_AWADDR : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWADDR : in STD_LOGIC_VECTOR ( 1 downto 0 );
    AW_Selected_Slave : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Faling_Edge_Detc : entity is "Faling_Edge_Detc";
end design_1_axi_interconnect_0_0_Faling_Edge_Detc;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Faling_Edge_Detc is
  signal \^aw_access_grant\ : STD_LOGIC;
  signal Falling_i_1_n_0 : STD_LOGIC;
  signal \u_Raising_Edge_Det/reg_Test_Signal\ : STD_LOGIC;
begin
  AW_Access_Grant <= \^aw_access_grant\;
Falling_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \u_Raising_Edge_Det/reg_Test_Signal\,
      I1 => AW_HandShake_Done,
      O => Falling_i_1_n_0
    );
Falling_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => reg_Test_Signal_reg_0,
      D => Falling_i_1_n_0,
      Q => \^aw_access_grant\
    );
\Write_Pointer[1]_i_1__0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000000220A0A0022"
    )
        port map (
      I0 => \^aw_access_grant\,
      I1 => M0_AWADDR(1),
      I2 => M1_AWADDR(1),
      I3 => M0_AWADDR(0),
      I4 => AW_Selected_Slave,
      I5 => M1_AWADDR(0),
      O => Falling_reg_0(0)
    );
reg_Test_Signal_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => reg_Test_Signal_reg_0,
      D => AW_HandShake_Done,
      Q => \u_Raising_Edge_Det/reg_Test_Signal\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Qos_Arbiter is
  port (
    S1_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    AW_Selected_Slave : out STD_LOGIC;
    M0_AWADDR_30_sp_1 : out STD_LOGIC;
    S1_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_AWVALID : out STD_LOGIC;
    S1_AWADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S1_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    M1_AWREADY : out STD_LOGIC;
    M0_AWREADY : out STD_LOGIC;
    HandShake_Done3 : out STD_LOGIC;
    S0_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_AWADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S0_AWVALID : out STD_LOGIC;
    S0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \Selected_Slave_reg[0]_0\ : out STD_LOGIC;
    \Selected_Slave_reg[0]_1\ : out STD_LOGIC;
    \Selected_Slave_reg[0]_2\ : out STD_LOGIC;
    \Selected_Slave_reg[0]_3\ : out STD_LOGIC;
    M0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_AWVALID : in STD_LOGIC;
    M1_AWVALID : in STD_LOGIC;
    M0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    AW_Access_Grant : in STD_LOGIC;
    S0_AWREADY : in STD_LOGIC;
    S1_AWREADY : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 0 to 0 );
    \Queue_reg[0]_0\ : in STD_LOGIC;
    \Queue_reg[1]_1\ : in STD_LOGIC;
    \Queue_reg[1][0]\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    \Queue_reg[0][0]\ : in STD_LOGIC;
    \Queue_reg[1][0]_0\ : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    \Selected_Slave_reg[0]_4\ : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Qos_Arbiter : entity is "Qos_Arbiter";
end design_1_axi_interconnect_0_0_Qos_Arbiter;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Qos_Arbiter is
  signal \^aw_selected_slave\ : STD_LOGIC;
  signal HandShake_Done_i_2_n_0 : STD_LOGIC;
  signal M0_AWADDR_30_sn_1 : STD_LOGIC;
  signal M0_AWREADY_INST_0_i_1_n_0 : STD_LOGIC;
  signal \Selected_Slave[0]_i_1_n_0\ : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of HandShake_Done_i_1 : label is "soft_lutpair84";
  attribute SOFT_HLUTNM of M0_AWREADY_INST_0 : label is "soft_lutpair52";
  attribute SOFT_HLUTNM of M1_AWREADY_INST_0 : label is "soft_lutpair52";
  attribute SOFT_HLUTNM of \S0_AWADDR[0]_INST_0\ : label is "soft_lutpair83";
  attribute SOFT_HLUTNM of \S0_AWADDR[10]_INST_0\ : label is "soft_lutpair73";
  attribute SOFT_HLUTNM of \S0_AWADDR[11]_INST_0\ : label is "soft_lutpair72";
  attribute SOFT_HLUTNM of \S0_AWADDR[12]_INST_0\ : label is "soft_lutpair71";
  attribute SOFT_HLUTNM of \S0_AWADDR[13]_INST_0\ : label is "soft_lutpair70";
  attribute SOFT_HLUTNM of \S0_AWADDR[14]_INST_0\ : label is "soft_lutpair69";
  attribute SOFT_HLUTNM of \S0_AWADDR[15]_INST_0\ : label is "soft_lutpair68";
  attribute SOFT_HLUTNM of \S0_AWADDR[16]_INST_0\ : label is "soft_lutpair67";
  attribute SOFT_HLUTNM of \S0_AWADDR[17]_INST_0\ : label is "soft_lutpair66";
  attribute SOFT_HLUTNM of \S0_AWADDR[18]_INST_0\ : label is "soft_lutpair65";
  attribute SOFT_HLUTNM of \S0_AWADDR[19]_INST_0\ : label is "soft_lutpair64";
  attribute SOFT_HLUTNM of \S0_AWADDR[1]_INST_0\ : label is "soft_lutpair82";
  attribute SOFT_HLUTNM of \S0_AWADDR[20]_INST_0\ : label is "soft_lutpair63";
  attribute SOFT_HLUTNM of \S0_AWADDR[21]_INST_0\ : label is "soft_lutpair62";
  attribute SOFT_HLUTNM of \S0_AWADDR[22]_INST_0\ : label is "soft_lutpair61";
  attribute SOFT_HLUTNM of \S0_AWADDR[23]_INST_0\ : label is "soft_lutpair60";
  attribute SOFT_HLUTNM of \S0_AWADDR[24]_INST_0\ : label is "soft_lutpair59";
  attribute SOFT_HLUTNM of \S0_AWADDR[25]_INST_0\ : label is "soft_lutpair58";
  attribute SOFT_HLUTNM of \S0_AWADDR[26]_INST_0\ : label is "soft_lutpair57";
  attribute SOFT_HLUTNM of \S0_AWADDR[27]_INST_0\ : label is "soft_lutpair56";
  attribute SOFT_HLUTNM of \S0_AWADDR[28]_INST_0\ : label is "soft_lutpair55";
  attribute SOFT_HLUTNM of \S0_AWADDR[29]_INST_0\ : label is "soft_lutpair54";
  attribute SOFT_HLUTNM of \S0_AWADDR[2]_INST_0\ : label is "soft_lutpair81";
  attribute SOFT_HLUTNM of \S0_AWADDR[3]_INST_0\ : label is "soft_lutpair80";
  attribute SOFT_HLUTNM of \S0_AWADDR[4]_INST_0\ : label is "soft_lutpair79";
  attribute SOFT_HLUTNM of \S0_AWADDR[5]_INST_0\ : label is "soft_lutpair78";
  attribute SOFT_HLUTNM of \S0_AWADDR[6]_INST_0\ : label is "soft_lutpair77";
  attribute SOFT_HLUTNM of \S0_AWADDR[7]_INST_0\ : label is "soft_lutpair76";
  attribute SOFT_HLUTNM of \S0_AWADDR[8]_INST_0\ : label is "soft_lutpair75";
  attribute SOFT_HLUTNM of \S0_AWADDR[9]_INST_0\ : label is "soft_lutpair74";
  attribute SOFT_HLUTNM of \S0_AWBURST[0]_INST_0\ : label is "soft_lutpair89";
  attribute SOFT_HLUTNM of \S0_AWBURST[1]_INST_0\ : label is "soft_lutpair88";
  attribute SOFT_HLUTNM of \S0_AWLEN[0]_INST_0\ : label is "soft_lutpair97";
  attribute SOFT_HLUTNM of \S0_AWLEN[1]_INST_0\ : label is "soft_lutpair96";
  attribute SOFT_HLUTNM of \S0_AWLEN[2]_INST_0\ : label is "soft_lutpair95";
  attribute SOFT_HLUTNM of \S0_AWLEN[3]_INST_0\ : label is "soft_lutpair94";
  attribute SOFT_HLUTNM of \S0_AWLEN[4]_INST_0\ : label is "soft_lutpair93";
  attribute SOFT_HLUTNM of \S0_AWLEN[5]_INST_0\ : label is "soft_lutpair92";
  attribute SOFT_HLUTNM of \S0_AWLEN[6]_INST_0\ : label is "soft_lutpair91";
  attribute SOFT_HLUTNM of \S0_AWLEN[7]_INST_0\ : label is "soft_lutpair90";
  attribute SOFT_HLUTNM of \S0_AWSIZE[0]_INST_0\ : label is "soft_lutpair87";
  attribute SOFT_HLUTNM of \S0_AWSIZE[1]_INST_0\ : label is "soft_lutpair86";
  attribute SOFT_HLUTNM of \S0_AWSIZE[2]_INST_0\ : label is "soft_lutpair85";
  attribute SOFT_HLUTNM of S0_AWVALID_INST_0 : label is "soft_lutpair53";
  attribute SOFT_HLUTNM of \S1_AWADDR[0]_INST_0\ : label is "soft_lutpair83";
  attribute SOFT_HLUTNM of \S1_AWADDR[10]_INST_0\ : label is "soft_lutpair73";
  attribute SOFT_HLUTNM of \S1_AWADDR[11]_INST_0\ : label is "soft_lutpair72";
  attribute SOFT_HLUTNM of \S1_AWADDR[12]_INST_0\ : label is "soft_lutpair71";
  attribute SOFT_HLUTNM of \S1_AWADDR[13]_INST_0\ : label is "soft_lutpair70";
  attribute SOFT_HLUTNM of \S1_AWADDR[14]_INST_0\ : label is "soft_lutpair69";
  attribute SOFT_HLUTNM of \S1_AWADDR[15]_INST_0\ : label is "soft_lutpair68";
  attribute SOFT_HLUTNM of \S1_AWADDR[16]_INST_0\ : label is "soft_lutpair67";
  attribute SOFT_HLUTNM of \S1_AWADDR[17]_INST_0\ : label is "soft_lutpair66";
  attribute SOFT_HLUTNM of \S1_AWADDR[18]_INST_0\ : label is "soft_lutpair65";
  attribute SOFT_HLUTNM of \S1_AWADDR[19]_INST_0\ : label is "soft_lutpair64";
  attribute SOFT_HLUTNM of \S1_AWADDR[1]_INST_0\ : label is "soft_lutpair82";
  attribute SOFT_HLUTNM of \S1_AWADDR[20]_INST_0\ : label is "soft_lutpair63";
  attribute SOFT_HLUTNM of \S1_AWADDR[21]_INST_0\ : label is "soft_lutpair62";
  attribute SOFT_HLUTNM of \S1_AWADDR[22]_INST_0\ : label is "soft_lutpair61";
  attribute SOFT_HLUTNM of \S1_AWADDR[23]_INST_0\ : label is "soft_lutpair60";
  attribute SOFT_HLUTNM of \S1_AWADDR[24]_INST_0\ : label is "soft_lutpair59";
  attribute SOFT_HLUTNM of \S1_AWADDR[25]_INST_0\ : label is "soft_lutpair58";
  attribute SOFT_HLUTNM of \S1_AWADDR[26]_INST_0\ : label is "soft_lutpair57";
  attribute SOFT_HLUTNM of \S1_AWADDR[27]_INST_0\ : label is "soft_lutpair56";
  attribute SOFT_HLUTNM of \S1_AWADDR[28]_INST_0\ : label is "soft_lutpair55";
  attribute SOFT_HLUTNM of \S1_AWADDR[29]_INST_0\ : label is "soft_lutpair54";
  attribute SOFT_HLUTNM of \S1_AWADDR[2]_INST_0\ : label is "soft_lutpair81";
  attribute SOFT_HLUTNM of \S1_AWADDR[3]_INST_0\ : label is "soft_lutpair80";
  attribute SOFT_HLUTNM of \S1_AWADDR[4]_INST_0\ : label is "soft_lutpair79";
  attribute SOFT_HLUTNM of \S1_AWADDR[5]_INST_0\ : label is "soft_lutpair78";
  attribute SOFT_HLUTNM of \S1_AWADDR[6]_INST_0\ : label is "soft_lutpair77";
  attribute SOFT_HLUTNM of \S1_AWADDR[7]_INST_0\ : label is "soft_lutpair76";
  attribute SOFT_HLUTNM of \S1_AWADDR[8]_INST_0\ : label is "soft_lutpair75";
  attribute SOFT_HLUTNM of \S1_AWADDR[9]_INST_0\ : label is "soft_lutpair74";
  attribute SOFT_HLUTNM of \S1_AWBURST[0]_INST_0\ : label is "soft_lutpair89";
  attribute SOFT_HLUTNM of \S1_AWBURST[1]_INST_0\ : label is "soft_lutpair88";
  attribute SOFT_HLUTNM of \S1_AWLEN[0]_INST_0\ : label is "soft_lutpair97";
  attribute SOFT_HLUTNM of \S1_AWLEN[1]_INST_0\ : label is "soft_lutpair96";
  attribute SOFT_HLUTNM of \S1_AWLEN[2]_INST_0\ : label is "soft_lutpair95";
  attribute SOFT_HLUTNM of \S1_AWLEN[3]_INST_0\ : label is "soft_lutpair94";
  attribute SOFT_HLUTNM of \S1_AWLEN[4]_INST_0\ : label is "soft_lutpair93";
  attribute SOFT_HLUTNM of \S1_AWLEN[5]_INST_0\ : label is "soft_lutpair92";
  attribute SOFT_HLUTNM of \S1_AWLEN[6]_INST_0\ : label is "soft_lutpair91";
  attribute SOFT_HLUTNM of \S1_AWLEN[7]_INST_0\ : label is "soft_lutpair90";
  attribute SOFT_HLUTNM of \S1_AWSIZE[0]_INST_0\ : label is "soft_lutpair87";
  attribute SOFT_HLUTNM of \S1_AWSIZE[1]_INST_0\ : label is "soft_lutpair86";
  attribute SOFT_HLUTNM of \S1_AWSIZE[2]_INST_0\ : label is "soft_lutpair85";
  attribute SOFT_HLUTNM of S1_AWVALID_INST_0 : label is "soft_lutpair53";
  attribute SOFT_HLUTNM of \Selected_Slave[0]_i_1\ : label is "soft_lutpair84";
begin
  AW_Selected_Slave <= \^aw_selected_slave\;
  M0_AWADDR_30_sp_1 <= M0_AWADDR_30_sn_1;
HandShake_Done_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWVALID,
      I1 => \^aw_selected_slave\,
      I2 => M1_AWVALID,
      I3 => HandShake_Done_i_2_n_0,
      O => HandShake_Done3
    );
HandShake_Done_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7077"
    )
        port map (
      I0 => M0_AWADDR_30_sn_1,
      I1 => S1_AWREADY,
      I2 => M0_AWREADY_INST_0_i_1_n_0,
      I3 => S0_AWREADY,
      O => HandShake_Done_i_2_n_0
    );
M0_AWREADY_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"55040404"
    )
        port map (
      I0 => \^aw_selected_slave\,
      I1 => S0_AWREADY,
      I2 => M0_AWREADY_INST_0_i_1_n_0,
      I3 => S1_AWREADY,
      I4 => M0_AWADDR_30_sn_1,
      O => M0_AWREADY
    );
M0_AWREADY_INST_0_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFACCFA"
    )
        port map (
      I0 => M0_AWADDR(31),
      I1 => M1_AWADDR(31),
      I2 => M0_AWADDR(30),
      I3 => \^aw_selected_slave\,
      I4 => M1_AWADDR(30),
      O => M0_AWREADY_INST_0_i_1_n_0
    );
M1_AWREADY_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AA080808"
    )
        port map (
      I0 => \^aw_selected_slave\,
      I1 => S0_AWREADY,
      I2 => M0_AWREADY_INST_0_i_1_n_0,
      I3 => S1_AWREADY,
      I4 => M0_AWADDR_30_sn_1,
      O => M1_AWREADY
    );
\S0_AWADDR[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(0),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(0)
    );
\S0_AWADDR[10]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(10),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(10),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(10)
    );
\S0_AWADDR[11]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(11),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(11),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(11)
    );
\S0_AWADDR[12]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(12),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(12),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(12)
    );
\S0_AWADDR[13]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(13),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(13),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(13)
    );
\S0_AWADDR[14]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(14),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(14),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(14)
    );
\S0_AWADDR[15]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(15),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(15),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(15)
    );
\S0_AWADDR[16]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(16),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(16),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(16)
    );
\S0_AWADDR[17]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(17),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(17),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(17)
    );
\S0_AWADDR[18]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(18),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(18),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(18)
    );
\S0_AWADDR[19]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(19),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(19),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(19)
    );
\S0_AWADDR[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(1),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(1)
    );
\S0_AWADDR[20]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(20),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(20),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(20)
    );
\S0_AWADDR[21]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(21),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(21),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(21)
    );
\S0_AWADDR[22]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(22),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(22),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(22)
    );
\S0_AWADDR[23]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(23),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(23),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(23)
    );
\S0_AWADDR[24]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(24),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(24),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(24)
    );
\S0_AWADDR[25]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(25),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(25),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(25)
    );
\S0_AWADDR[26]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(26),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(26),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(26)
    );
\S0_AWADDR[27]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(27),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(27),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(27)
    );
\S0_AWADDR[28]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(28),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(28),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(28)
    );
\S0_AWADDR[29]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(29),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(29),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(29)
    );
\S0_AWADDR[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(2),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(2),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(2)
    );
\S0_AWADDR[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(3),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(3),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(3)
    );
\S0_AWADDR[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(4),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(4),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(4)
    );
\S0_AWADDR[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(5),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(5),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(5)
    );
\S0_AWADDR[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(6),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(6),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(6)
    );
\S0_AWADDR[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(7),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(7),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(7)
    );
\S0_AWADDR[8]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(8),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(8),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(8)
    );
\S0_AWADDR[9]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWADDR(9),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(9),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWADDR(9)
    );
\S0_AWBURST[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWBURST(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWBURST(0),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWBURST(0)
    );
\S0_AWBURST[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWBURST(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWBURST(1),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWBURST(1)
    );
\S0_AWLEN[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(0),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(0)
    );
\S0_AWLEN[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(1),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(1)
    );
\S0_AWLEN[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(2),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(2),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(2)
    );
\S0_AWLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(3),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(3),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(3)
    );
\S0_AWLEN[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(4),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(4),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(4)
    );
\S0_AWLEN[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(5),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(5),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(5)
    );
\S0_AWLEN[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(6),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(6),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(6)
    );
\S0_AWLEN[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWLEN(7),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(7),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWLEN(7)
    );
\S0_AWSIZE[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWSIZE(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWSIZE(0),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWSIZE(0)
    );
\S0_AWSIZE[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWSIZE(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWSIZE(1),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWSIZE(1)
    );
\S0_AWSIZE[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWSIZE(2),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWSIZE(2),
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWSIZE(2)
    );
S0_AWVALID_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_AWVALID,
      I1 => \^aw_selected_slave\,
      I2 => M1_AWVALID,
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      O => S0_AWVALID
    );
\S1_AWADDR[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(0),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(0)
    );
\S1_AWADDR[10]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(10),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(10),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(10)
    );
\S1_AWADDR[11]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(11),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(11),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(11)
    );
\S1_AWADDR[12]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(12),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(12),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(12)
    );
\S1_AWADDR[13]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(13),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(13),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(13)
    );
\S1_AWADDR[14]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(14),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(14),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(14)
    );
\S1_AWADDR[15]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(15),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(15),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(15)
    );
\S1_AWADDR[16]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(16),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(16),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(16)
    );
\S1_AWADDR[17]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(17),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(17),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(17)
    );
\S1_AWADDR[18]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(18),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(18),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(18)
    );
\S1_AWADDR[19]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(19),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(19),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(19)
    );
\S1_AWADDR[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(1),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(1)
    );
\S1_AWADDR[20]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(20),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(20),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(20)
    );
\S1_AWADDR[21]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(21),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(21),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(21)
    );
\S1_AWADDR[22]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(22),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(22),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(22)
    );
\S1_AWADDR[23]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(23),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(23),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(23)
    );
\S1_AWADDR[24]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(24),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(24),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(24)
    );
\S1_AWADDR[25]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(25),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(25),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(25)
    );
\S1_AWADDR[26]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(26),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(26),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(26)
    );
\S1_AWADDR[27]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(27),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(27),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(27)
    );
\S1_AWADDR[28]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(28),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(28),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(28)
    );
\S1_AWADDR[29]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(29),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(29),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(29)
    );
\S1_AWADDR[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(2),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(2),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(2)
    );
\S1_AWADDR[30]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_AWADDR(30),
      I1 => M1_AWADDR(30),
      I2 => M0_AWADDR(31),
      I3 => \^aw_selected_slave\,
      I4 => M1_AWADDR(31),
      O => M0_AWADDR_30_sn_1
    );
\S1_AWADDR[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(3),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(3),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(3)
    );
\S1_AWADDR[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(4),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(4),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(4)
    );
\S1_AWADDR[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(5),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(5),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(5)
    );
\S1_AWADDR[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(6),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(6),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(6)
    );
\S1_AWADDR[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(7),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(7),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(7)
    );
\S1_AWADDR[8]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(8),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(8),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(8)
    );
\S1_AWADDR[9]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWADDR(9),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWADDR(9),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWADDR(9)
    );
\S1_AWBURST[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWBURST(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWBURST(0),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWBURST(0)
    );
\S1_AWBURST[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWBURST(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWBURST(1),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWBURST(1)
    );
\S1_AWLEN[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(0),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(0)
    );
\S1_AWLEN[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(1),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(1)
    );
\S1_AWLEN[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(2),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(2),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(2)
    );
\S1_AWLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(3),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(3),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(3)
    );
\S1_AWLEN[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(4),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(4),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(4)
    );
\S1_AWLEN[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(5),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(5),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(5)
    );
\S1_AWLEN[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(6),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(6),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(6)
    );
\S1_AWLEN[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWLEN(7),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWLEN(7),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWLEN(7)
    );
\S1_AWSIZE[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWSIZE(0),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWSIZE(0),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWSIZE(0)
    );
\S1_AWSIZE[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWSIZE(1),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWSIZE(1),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWSIZE(1)
    );
\S1_AWSIZE[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWSIZE(2),
      I1 => \^aw_selected_slave\,
      I2 => M1_AWSIZE(2),
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWSIZE(2)
    );
S1_AWVALID_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E200"
    )
        port map (
      I0 => M0_AWVALID,
      I1 => \^aw_selected_slave\,
      I2 => M1_AWVALID,
      I3 => M0_AWADDR_30_sn_1,
      O => S1_AWVALID
    );
\Selected_Slave[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"32"
    )
        port map (
      I0 => M1_AWVALID,
      I1 => M0_AWVALID,
      I2 => \^aw_selected_slave\,
      O => \Selected_Slave[0]_i_1_n_0\
    );
\Selected_Slave_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Selected_Slave_reg[0]_4\,
      D => \Selected_Slave[0]_i_1_n_0\,
      Q => \^aw_selected_slave\
    );
\Write_Pointer[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"000ACC0A00000000"
    )
        port map (
      I0 => M0_AWADDR(30),
      I1 => M1_AWADDR(30),
      I2 => M0_AWADDR(31),
      I3 => \^aw_selected_slave\,
      I4 => M1_AWADDR(31),
      I5 => AW_Access_Grant,
      O => E(0)
    );
\u_Queue/Queue[0][0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFEF0020"
    )
        port map (
      I0 => \^aw_selected_slave\,
      I1 => Q(0),
      I2 => AW_Access_Grant,
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      I4 => \Queue_reg[0]_0\,
      O => \Selected_Slave_reg[0]_0\
    );
\u_Queue/Queue[1][0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBF0080"
    )
        port map (
      I0 => \^aw_selected_slave\,
      I1 => Q(0),
      I2 => AW_Access_Grant,
      I3 => M0_AWREADY_INST_0_i_1_n_0,
      I4 => \Queue_reg[1]_1\,
      O => \Selected_Slave_reg[0]_1\
    );
\u_Queue2/Queue[0][0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EFFF2000"
    )
        port map (
      I0 => \^aw_selected_slave\,
      I1 => \Queue_reg[1][0]\(0),
      I2 => M0_AWADDR_30_sn_1,
      I3 => AW_Access_Grant,
      I4 => \Queue_reg[0][0]\,
      O => \Selected_Slave_reg[0]_2\
    );
\u_Queue2/Queue[1][0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BFFF8000"
    )
        port map (
      I0 => \^aw_selected_slave\,
      I1 => \Queue_reg[1][0]\(0),
      I2 => M0_AWADDR_30_sn_1,
      I3 => AW_Access_Grant,
      I4 => \Queue_reg[1][0]_0\,
      O => \Selected_Slave_reg[0]_3\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Queue is
  port (
    \Queue_reg[0][0]_0\ : out STD_LOGIC;
    \Queue_reg[1][0]_0\ : out STD_LOGIC;
    S0_WVALID : out STD_LOGIC;
    HandShake_Done_reg : out STD_LOGIC;
    S0_WLAST : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 );
    S0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    \Queue_reg[1][0]_1\ : out STD_LOGIC;
    ACLK : in STD_LOGIC;
    \Queue_reg[1][0]_2\ : in STD_LOGIC;
    \Queue_reg[0][0]_1\ : in STD_LOGIC;
    \Queue_reg[1][0]_3\ : in STD_LOGIC;
    M0_WVALID : in STD_LOGIC;
    M1_WVALID : in STD_LOGIC;
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    S0_WREADY : in STD_LOGIC;
    M1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WLAST : in STD_LOGIC;
    M0_WLAST : in STD_LOGIC;
    \Write_Pointer_reg[0]_0\ : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Queue : entity is "Queue";
end design_1_axi_interconnect_0_0_Queue;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Queue is
  signal \HandShake_Done_i_2__0_n_0\ : STD_LOGIC;
  signal Master_Valid_1 : STD_LOGIC;
  signal Pulse : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^queue_reg[0][0]_0\ : STD_LOGIC;
  signal \^queue_reg[1][0]_0\ : STD_LOGIC;
  signal \Read_Pointer[0]_i_1_n_0\ : STD_LOGIC;
  signal \Read_Pointer[1]_i_1_n_0\ : STD_LOGIC;
  signal \Read_Pointer_reg_n_0_[0]\ : STD_LOGIC;
  signal \^s0_wlast\ : STD_LOGIC;
  signal \Write_Pointer[0]_i_1_n_0\ : STD_LOGIC;
  signal \Write_Pointer[1]_i_2_n_0\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC;
  signal p_1_in : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of M0_WREADY_INST_0_i_1 : label is "soft_lutpair102";
  attribute SOFT_HLUTNM of \Read_Pointer[0]_i_1\ : label is "soft_lutpair103";
  attribute SOFT_HLUTNM of \Read_Pointer[1]_i_1\ : label is "soft_lutpair104";
  attribute SOFT_HLUTNM of \S0_WDATA[0]_INST_0\ : label is "soft_lutpair102";
  attribute SOFT_HLUTNM of \S0_WDATA[1]_INST_0\ : label is "soft_lutpair103";
  attribute SOFT_HLUTNM of S0_WVALID_INST_0_i_1 : label is "soft_lutpair104";
  attribute SOFT_HLUTNM of \Write_Pointer[0]_i_1\ : label is "soft_lutpair105";
  attribute SOFT_HLUTNM of \Write_Pointer[1]_i_2\ : label is "soft_lutpair105";
begin
  Q(0) <= \^q\(0);
  \Queue_reg[0][0]_0\ <= \^queue_reg[0][0]_0\;
  \Queue_reg[1][0]_0\ <= \^queue_reg[1][0]_0\;
  S0_WLAST <= \^s0_wlast\;
\HandShake_Done_i_1__0\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000040400040"
    )
        port map (
      I0 => E(0),
      I1 => S0_WREADY,
      I2 => \^s0_wlast\,
      I3 => Master_Valid_1,
      I4 => Pulse,
      I5 => \HandShake_Done_i_2__0_n_0\,
      O => HandShake_Done_reg
    );
\HandShake_Done_i_2__0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"4540757F"
    )
        port map (
      I0 => M1_WVALID,
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WVALID,
      O => \HandShake_Done_i_2__0_n_0\
    );
M0_WREADY_INST_0_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \^queue_reg[1][0]_0\,
      I1 => \Read_Pointer_reg_n_0_[0]\,
      I2 => \^queue_reg[0][0]_0\,
      O => \Queue_reg[1][0]_1\
    );
Pulse_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Queue_reg[1][0]_2\,
      D => Master_Valid_1,
      Q => Pulse
    );
\Queue_reg[0][0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Queue_reg[1][0]_2\,
      D => \Queue_reg[0][0]_1\,
      Q => \^queue_reg[0][0]_0\
    );
\Queue_reg[1][0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Queue_reg[1][0]_2\,
      D => \Queue_reg[1][0]_3\,
      Q => \^queue_reg[1][0]_0\
    );
\Read_Pointer[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \Read_Pointer_reg_n_0_[0]\,
      O => \Read_Pointer[0]_i_1_n_0\
    );
\Read_Pointer[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \Read_Pointer_reg_n_0_[0]\,
      I1 => p_1_in,
      O => \Read_Pointer[1]_i_1_n_0\
    );
\Read_Pointer_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \Queue_reg[1][0]_2\,
      D => \Read_Pointer[0]_i_1_n_0\,
      Q => \Read_Pointer_reg_n_0_[0]\
    );
\Read_Pointer_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \Queue_reg[1][0]_2\,
      D => \Read_Pointer[1]_i_1_n_0\,
      Q => p_1_in
    );
\S0_WDATA[0]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(0),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(0),
      O => S0_WDATA(0)
    );
\S0_WDATA[10]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(10),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(10),
      O => S0_WDATA(10)
    );
\S0_WDATA[11]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(11),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(11),
      O => S0_WDATA(11)
    );
\S0_WDATA[12]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(12),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(12),
      O => S0_WDATA(12)
    );
\S0_WDATA[13]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(13),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(13),
      O => S0_WDATA(13)
    );
\S0_WDATA[14]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(14),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(14),
      O => S0_WDATA(14)
    );
\S0_WDATA[15]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(15),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(15),
      O => S0_WDATA(15)
    );
\S0_WDATA[16]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(16),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(16),
      O => S0_WDATA(16)
    );
\S0_WDATA[17]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(17),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(17),
      O => S0_WDATA(17)
    );
\S0_WDATA[18]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(18),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(18),
      O => S0_WDATA(18)
    );
\S0_WDATA[19]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(19),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(19),
      O => S0_WDATA(19)
    );
\S0_WDATA[1]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(1),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(1),
      O => S0_WDATA(1)
    );
\S0_WDATA[20]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(20),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(20),
      O => S0_WDATA(20)
    );
\S0_WDATA[21]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(21),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(21),
      O => S0_WDATA(21)
    );
\S0_WDATA[22]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(22),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(22),
      O => S0_WDATA(22)
    );
\S0_WDATA[23]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(23),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(23),
      O => S0_WDATA(23)
    );
\S0_WDATA[24]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(24),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(24),
      O => S0_WDATA(24)
    );
\S0_WDATA[25]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(25),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(25),
      O => S0_WDATA(25)
    );
\S0_WDATA[26]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(26),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(26),
      O => S0_WDATA(26)
    );
\S0_WDATA[27]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(27),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(27),
      O => S0_WDATA(27)
    );
\S0_WDATA[28]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(28),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(28),
      O => S0_WDATA(28)
    );
\S0_WDATA[29]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(29),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(29),
      O => S0_WDATA(29)
    );
\S0_WDATA[2]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(2),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(2),
      O => S0_WDATA(2)
    );
\S0_WDATA[30]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(30),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(30),
      O => S0_WDATA(30)
    );
\S0_WDATA[31]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(31),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(31),
      O => S0_WDATA(31)
    );
\S0_WDATA[3]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(3),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(3),
      O => S0_WDATA(3)
    );
\S0_WDATA[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(4),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(4),
      O => S0_WDATA(4)
    );
\S0_WDATA[5]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(5),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(5),
      O => S0_WDATA(5)
    );
\S0_WDATA[6]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(6),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(6),
      O => S0_WDATA(6)
    );
\S0_WDATA[7]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(7),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(7),
      O => S0_WDATA(7)
    );
\S0_WDATA[8]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(8),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(8),
      O => S0_WDATA(8)
    );
\S0_WDATA[9]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(9),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(9),
      O => S0_WDATA(9)
    );
S0_WLAST_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WLAST,
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WLAST,
      O => \^s0_wlast\
    );
\S0_WSTRB[0]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(0),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(0),
      O => S0_WSTRB(0)
    );
\S0_WSTRB[1]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(1),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(1),
      O => S0_WSTRB(1)
    );
\S0_WSTRB[2]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(2),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(2),
      O => S0_WSTRB(2)
    );
\S0_WSTRB[3]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(3),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(3),
      O => S0_WSTRB(3)
    );
S0_WVALID_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA888A800088808"
    )
        port map (
      I0 => Master_Valid_1,
      I1 => M0_WVALID,
      I2 => \^queue_reg[0][0]_0\,
      I3 => \Read_Pointer_reg_n_0_[0]\,
      I4 => \^queue_reg[1][0]_0\,
      I5 => M1_WVALID,
      O => S0_WVALID
    );
S0_WVALID_INST_0_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6FF6"
    )
        port map (
      I0 => p_1_in,
      I1 => p_0_in,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^q\(0),
      O => Master_Valid_1
    );
\Write_Pointer[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^q\(0),
      O => \Write_Pointer[0]_i_1_n_0\
    );
\Write_Pointer[1]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \^q\(0),
      I1 => p_0_in,
      O => \Write_Pointer[1]_i_2_n_0\
    );
\Write_Pointer_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \Write_Pointer_reg[0]_0\(0),
      CLR => \Queue_reg[1][0]_2\,
      D => \Write_Pointer[0]_i_1_n_0\,
      Q => \^q\(0)
    );
\Write_Pointer_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \Write_Pointer_reg[0]_0\(0),
      CLR => \Queue_reg[1][0]_2\,
      D => \Write_Pointer[1]_i_2_n_0\,
      Q => p_0_in
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Queue_0 is
  port (
    ARESETN_0 : out STD_LOGIC;
    \Queue_reg[0][0]_0\ : out STD_LOGIC;
    \Queue_reg[1][0]_0\ : out STD_LOGIC;
    S1_WVALID : out STD_LOGIC;
    HandShake_Done_reg : out STD_LOGIC;
    S1_WLAST : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 );
    M1_WREADY : out STD_LOGIC;
    M0_WREADY : out STD_LOGIC;
    S1_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ACLK : in STD_LOGIC;
    \Queue_reg[0][0]_1\ : in STD_LOGIC;
    \Queue_reg[1][0]_1\ : in STD_LOGIC;
    M0_WVALID : in STD_LOGIC;
    M1_WVALID : in STD_LOGIC;
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    S1_WREADY : in STD_LOGIC;
    M1_WREADY_0 : in STD_LOGIC;
    S0_WREADY : in STD_LOGIC;
    M1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WLAST : in STD_LOGIC;
    M0_WLAST : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    \Write_Pointer_reg[0]_0\ : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Queue_0 : entity is "Queue";
end design_1_axi_interconnect_0_0_Queue_0;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Queue_0 is
  signal \^aresetn_0\ : STD_LOGIC;
  signal \HandShake_Done_i_2__1_n_0\ : STD_LOGIC;
  signal Master_Valid_2 : STD_LOGIC;
  signal Pulse : STD_LOGIC;
  signal \^q\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^queue_reg[0][0]_0\ : STD_LOGIC;
  signal \^queue_reg[1][0]_0\ : STD_LOGIC;
  signal \Read_Pointer[0]_i_1__0_n_0\ : STD_LOGIC;
  signal \Read_Pointer[1]_i_1__0_n_0\ : STD_LOGIC;
  signal \Read_Pointer_reg_n_0_[0]\ : STD_LOGIC;
  signal \Read_Pointer_reg_n_0_[1]\ : STD_LOGIC;
  signal \^s1_wlast\ : STD_LOGIC;
  signal \Write_Pointer[0]_i_1__0_n_0\ : STD_LOGIC;
  signal \Write_Pointer[1]_i_2__0_n_0\ : STD_LOGIC;
  signal \Write_Pointer_reg_n_0_[1]\ : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \Read_Pointer[0]_i_1__0\ : label is "soft_lutpair106";
  attribute SOFT_HLUTNM of \Read_Pointer[1]_i_1__0\ : label is "soft_lutpair107";
  attribute SOFT_HLUTNM of \S1_WDATA[0]_INST_0\ : label is "soft_lutpair106";
  attribute SOFT_HLUTNM of S1_WVALID_INST_0_i_1 : label is "soft_lutpair107";
  attribute SOFT_HLUTNM of \Write_Pointer[0]_i_1__0\ : label is "soft_lutpair108";
  attribute SOFT_HLUTNM of \Write_Pointer[1]_i_2__0\ : label is "soft_lutpair108";
begin
  ARESETN_0 <= \^aresetn_0\;
  Q(0) <= \^q\(0);
  \Queue_reg[0][0]_0\ <= \^queue_reg[0][0]_0\;
  \Queue_reg[1][0]_0\ <= \^queue_reg[1][0]_0\;
  S1_WLAST <= \^s1_wlast\;
\HandShake_Done_i_1__1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000040400040"
    )
        port map (
      I0 => E(0),
      I1 => S1_WREADY,
      I2 => \^s1_wlast\,
      I3 => Master_Valid_2,
      I4 => Pulse,
      I5 => \HandShake_Done_i_2__1_n_0\,
      O => HandShake_Done_reg
    );
\HandShake_Done_i_2__1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"4540757F"
    )
        port map (
      I0 => M1_WVALID,
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WVALID,
      O => \HandShake_Done_i_2__1_n_0\
    );
M0_WREADY_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"4700FFFF47004700"
    )
        port map (
      I0 => \^queue_reg[1][0]_0\,
      I1 => \Read_Pointer_reg_n_0_[0]\,
      I2 => \^queue_reg[0][0]_0\,
      I3 => S1_WREADY,
      I4 => M1_WREADY_0,
      I5 => S0_WREADY,
      O => M0_WREADY
    );
M1_WREADY_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFB800B800B800"
    )
        port map (
      I0 => \^queue_reg[1][0]_0\,
      I1 => \Read_Pointer_reg_n_0_[0]\,
      I2 => \^queue_reg[0][0]_0\,
      I3 => S1_WREADY,
      I4 => M1_WREADY_0,
      I5 => S0_WREADY,
      O => M1_WREADY
    );
Pulse_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \^aresetn_0\,
      D => Master_Valid_2,
      Q => Pulse
    );
\Queue_reg[0][0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \^aresetn_0\,
      D => \Queue_reg[0][0]_1\,
      Q => \^queue_reg[0][0]_0\
    );
\Queue_reg[1][0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \^aresetn_0\,
      D => \Queue_reg[1][0]_1\,
      Q => \^queue_reg[1][0]_0\
    );
\Read_Pointer[0]_i_1__0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \Read_Pointer_reg_n_0_[0]\,
      O => \Read_Pointer[0]_i_1__0_n_0\
    );
\Read_Pointer[1]_i_1__0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \Read_Pointer_reg_n_0_[0]\,
      I1 => \Read_Pointer_reg_n_0_[1]\,
      O => \Read_Pointer[1]_i_1__0_n_0\
    );
\Read_Pointer_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \^aresetn_0\,
      D => \Read_Pointer[0]_i_1__0_n_0\,
      Q => \Read_Pointer_reg_n_0_[0]\
    );
\Read_Pointer_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \^aresetn_0\,
      D => \Read_Pointer[1]_i_1__0_n_0\,
      Q => \Read_Pointer_reg_n_0_[1]\
    );
\S1_WDATA[0]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(0),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(0),
      O => S1_WDATA(0)
    );
\S1_WDATA[10]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(10),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(10),
      O => S1_WDATA(10)
    );
\S1_WDATA[11]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(11),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(11),
      O => S1_WDATA(11)
    );
\S1_WDATA[12]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(12),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(12),
      O => S1_WDATA(12)
    );
\S1_WDATA[13]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(13),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(13),
      O => S1_WDATA(13)
    );
\S1_WDATA[14]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(14),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(14),
      O => S1_WDATA(14)
    );
\S1_WDATA[15]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(15),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(15),
      O => S1_WDATA(15)
    );
\S1_WDATA[16]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(16),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(16),
      O => S1_WDATA(16)
    );
\S1_WDATA[17]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(17),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(17),
      O => S1_WDATA(17)
    );
\S1_WDATA[18]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(18),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(18),
      O => S1_WDATA(18)
    );
\S1_WDATA[19]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(19),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(19),
      O => S1_WDATA(19)
    );
\S1_WDATA[1]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(1),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(1),
      O => S1_WDATA(1)
    );
\S1_WDATA[20]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(20),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(20),
      O => S1_WDATA(20)
    );
\S1_WDATA[21]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(21),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(21),
      O => S1_WDATA(21)
    );
\S1_WDATA[22]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(22),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(22),
      O => S1_WDATA(22)
    );
\S1_WDATA[23]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(23),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(23),
      O => S1_WDATA(23)
    );
\S1_WDATA[24]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(24),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(24),
      O => S1_WDATA(24)
    );
\S1_WDATA[25]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(25),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(25),
      O => S1_WDATA(25)
    );
\S1_WDATA[26]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(26),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(26),
      O => S1_WDATA(26)
    );
\S1_WDATA[27]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(27),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(27),
      O => S1_WDATA(27)
    );
\S1_WDATA[28]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(28),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(28),
      O => S1_WDATA(28)
    );
\S1_WDATA[29]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(29),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(29),
      O => S1_WDATA(29)
    );
\S1_WDATA[2]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(2),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(2),
      O => S1_WDATA(2)
    );
\S1_WDATA[30]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(30),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(30),
      O => S1_WDATA(30)
    );
\S1_WDATA[31]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(31),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(31),
      O => S1_WDATA(31)
    );
\S1_WDATA[3]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(3),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(3),
      O => S1_WDATA(3)
    );
\S1_WDATA[4]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(4),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(4),
      O => S1_WDATA(4)
    );
\S1_WDATA[5]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(5),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(5),
      O => S1_WDATA(5)
    );
\S1_WDATA[6]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(6),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(6),
      O => S1_WDATA(6)
    );
\S1_WDATA[7]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(7),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(7),
      O => S1_WDATA(7)
    );
\S1_WDATA[8]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(8),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(8),
      O => S1_WDATA(8)
    );
\S1_WDATA[9]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WDATA(9),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WDATA(9),
      O => S1_WDATA(9)
    );
S1_WLAST_INST_0: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WLAST,
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WLAST,
      O => \^s1_wlast\
    );
\S1_WSTRB[0]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(0),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(0),
      O => S1_WSTRB(0)
    );
\S1_WSTRB[1]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(1),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(1),
      O => S1_WSTRB(1)
    );
\S1_WSTRB[2]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(2),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(2),
      O => S1_WSTRB(2)
    );
\S1_WSTRB[3]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"BABF8A80"
    )
        port map (
      I0 => M1_WSTRB(3),
      I1 => \^queue_reg[1][0]_0\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^queue_reg[0][0]_0\,
      I4 => M0_WSTRB(3),
      O => S1_WSTRB(3)
    );
S1_WVALID_INST_0: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AAA888A800088808"
    )
        port map (
      I0 => Master_Valid_2,
      I1 => M0_WVALID,
      I2 => \^queue_reg[0][0]_0\,
      I3 => \Read_Pointer_reg_n_0_[0]\,
      I4 => \^queue_reg[1][0]_0\,
      I5 => M1_WVALID,
      O => S1_WVALID
    );
S1_WVALID_INST_0_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"6FF6"
    )
        port map (
      I0 => \Read_Pointer_reg_n_0_[1]\,
      I1 => \Write_Pointer_reg_n_0_[1]\,
      I2 => \Read_Pointer_reg_n_0_[0]\,
      I3 => \^q\(0),
      O => Master_Valid_2
    );
\Sel_Write_Resp[1]_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => ARESETN,
      O => \^aresetn_0\
    );
\Write_Pointer[0]_i_1__0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^q\(0),
      O => \Write_Pointer[0]_i_1__0_n_0\
    );
\Write_Pointer[1]_i_2__0\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \^q\(0),
      I1 => \Write_Pointer_reg_n_0_[1]\,
      O => \Write_Pointer[1]_i_2__0_n_0\
    );
\Write_Pointer_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \Write_Pointer_reg[0]_0\(0),
      CLR => \^aresetn_0\,
      D => \Write_Pointer[0]_i_1__0_n_0\,
      Q => \^q\(0)
    );
\Write_Pointer_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => \Write_Pointer_reg[0]_0\(0),
      CLR => \^aresetn_0\,
      D => \Write_Pointer[1]_i_2__0_n_0\,
      Q => \Write_Pointer_reg_n_0_[1]\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Read_Arbiter is
  port (
    S0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_ARVALID : out STD_LOGIC;
    S0_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    CO : out STD_LOGIC_VECTOR ( 0 to 0 );
    \M0_ARADDR[30]\ : out STD_LOGIC_VECTOR ( 0 to 0 );
    M1_ARREADY : out STD_LOGIC;
    AR_Selected_Slave : out STD_LOGIC;
    Sel_Slave_Ready : out STD_LOGIC;
    M0_ARREADY : out STD_LOGIC;
    S0_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \M0_ARADDR[30]_0\ : out STD_LOGIC;
    S1_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_ARVALID : out STD_LOGIC;
    S1_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S1_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARADDR_31_sp_1 : out STD_LOGIC;
    S2_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_ARVALID : out STD_LOGIC;
    S2_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S2_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \M0_ARADDR[30]_1\ : out STD_LOGIC;
    S3_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_ARVALID : out STD_LOGIC;
    S3_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S3_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    D : out STD_LOGIC_VECTOR ( 1 downto 0 );
    next_state_slave119_out : out STD_LOGIC;
    \FSM_onehot_curr_state_slave2_reg[4]\ : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \FSM_sequential_curr_state_slave_reg[2]_i_8_0\ : out STD_LOGIC;
    S0_ARREADY_0 : out STD_LOGIC;
    M0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_ARVALID : in STD_LOGIC;
    M1_ARVALID : in STD_LOGIC;
    M0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_ARREADY : in STD_LOGIC;
    S3_ARREADY : in STD_LOGIC;
    S0_ARREADY : in STD_LOGIC;
    S1_ARREADY : in STD_LOGIC;
    M0_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    \FSM_sequential_curr_state_slave_reg[2]\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[1]\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[1]_0\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[2]_0\ : in STD_LOGIC;
    M0_RREADY : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 0 to 0 );
    \FSM_onehot_curr_state_slave2_reg[4]_0\ : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S2_RVALID : in STD_LOGIC;
    S2_RLAST : in STD_LOGIC;
    M1_RREADY : in STD_LOGIC;
    S1_RVALID : in STD_LOGIC;
    S1_RLAST : in STD_LOGIC;
    S3_RVALID : in STD_LOGIC;
    S3_RLAST : in STD_LOGIC;
    AR_HandShake_Done : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    \Selected_Master_reg[0]_rep__1_0\ : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Read_Arbiter : entity is "Read_Arbiter";
end design_1_axi_interconnect_0_0_Read_Arbiter;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Read_Arbiter is
  signal \^ar_selected_slave\ : STD_LOGIC;
  signal \^co\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \FSM_onehot_curr_state_slave2[4]_i_4_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_10_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_11_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_12_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_13_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_14_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_15_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_16_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_17_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_18_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_19_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_20_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_21_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_22_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_24_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_25_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_26_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_27_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_28_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_29_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_30_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_31_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_32_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_33_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_34_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_35_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_36_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_37_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_38_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_39_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_40_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_41_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_42_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_43_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_44_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_45_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_46_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_47_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_48_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_49_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_50_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_51_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_52_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_53_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_54_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_55_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_56_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_57_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_58_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_59_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_60_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_61_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_62_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_63_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_64_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_65_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_66_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_67_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_68_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_7_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_8_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[1]_i_9_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_100_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_101_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_102_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_103_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_105_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_106_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_107_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_108_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_109_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_10_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_110_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_111_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_113_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_114_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_115_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_116_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_117_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_118_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_119_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_120_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_121_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_122_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_123_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_124_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_125_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_126_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_127_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_128_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_129_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_130_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_131_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_132_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_133_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_134_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_135_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_136_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_137_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_138_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_139_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_140_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_141_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_142_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_143_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_144_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_145_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_146_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_147_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_148_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_149_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_14_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_150_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_151_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_152_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_153_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_154_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_155_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_156_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_157_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_158_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_159_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_15_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_160_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_161_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_162_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_163_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_164_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_165_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_166_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_167_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_168_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_169_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_16_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_170_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_171_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_172_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_173_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_174_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_175_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_17_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_18_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_19_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_20_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_21_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_22_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_23_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_24_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_25_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_26_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_27_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_28_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_29_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_31_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_32_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_33_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_34_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_35_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_36_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_37_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_38_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_39_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_40_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_41_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_42_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_43_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_44_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_45_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_46_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_50_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_51_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_52_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_53_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_54_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_55_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_56_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_58_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_59_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_60_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_61_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_62_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_63_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_64_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_65_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_66_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_67_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_68_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_69_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_70_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_71_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_72_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_73_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_74_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_75_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_76_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_77_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_78_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_79_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_80_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_81_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_82_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_83_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_84_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_85_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_86_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_87_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_88_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_89_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_90_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_91_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_92_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_93_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_94_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_95_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_96_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_97_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_98_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave[2]_i_99_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_23_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_2_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_3_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[1]_i_6_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_104_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_112_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_11_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_11_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_11_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_11_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_11_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_11_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_12_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_13_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_30_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_47_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_47_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_47_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_47_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_47_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_47_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_48_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_49_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_57_n_7\ : STD_LOGIC;
  signal \^fsm_sequential_curr_state_slave_reg[2]_i_8_0\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_8_n_7\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_1\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_2\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_3\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_4\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_5\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_6\ : STD_LOGIC;
  signal \FSM_sequential_curr_state_slave_reg[2]_i_9_n_7\ : STD_LOGIC;
  signal \^m0_araddr[30]\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \^m0_araddr[30]_0\ : STD_LOGIC;
  signal \^m0_araddr[30]_1\ : STD_LOGIC;
  signal M0_ARADDR_31_sn_1 : STD_LOGIC;
  signal \Read_controller/next_state_slave116_out\ : STD_LOGIC;
  signal \Read_controller/next_state_slave2\ : STD_LOGIC;
  signal \Read_controller/next_state_slave210_in\ : STD_LOGIC;
  signal \Read_controller/next_state_slave212_in\ : STD_LOGIC;
  signal \Read_controller/next_state_slave213_in\ : STD_LOGIC;
  signal \Read_controller/next_state_slave214_in\ : STD_LOGIC;
  signal \Read_controller/next_state_slave215_in\ : STD_LOGIC;
  signal \S0_ARADDR[29]_INST_0_i_1_n_0\ : STD_LOGIC;
  signal Sel_Master_araddr : STD_LOGIC_VECTOR ( 31 to 31 );
  signal \Sel_Master_araddr__0\ : STD_LOGIC_VECTOR ( 30 to 30 );
  signal \^sel_slave_ready\ : STD_LOGIC;
  signal \Selected_Master[0]_i_1_n_0\ : STD_LOGIC;
  signal \Selected_Master[0]_rep__0_i_1_n_0\ : STD_LOGIC;
  signal \Selected_Master[0]_rep__1_i_1_n_0\ : STD_LOGIC;
  signal \Selected_Master[0]_rep_i_1_n_0\ : STD_LOGIC;
  signal \Selected_Master_reg[0]_rep__0_n_0\ : STD_LOGIC;
  signal \Selected_Master_reg[0]_rep__1_n_0\ : STD_LOGIC;
  signal \Selected_Master_reg[0]_rep_n_0\ : STD_LOGIC;
  signal \^next_state_slave119_out\ : STD_LOGIC;
  signal \NLW_FSM_sequential_curr_state_slave_reg[1]_i_2_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[1]_i_23_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[1]_i_3_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[1]_i_6_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_104_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_11_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 to 7 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_11_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_112_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_12_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_13_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_30_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_47_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 to 7 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_47_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_48_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_49_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_57_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_8_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \NLW_FSM_sequential_curr_state_slave_reg[2]_i_9_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_onehot_curr_state_slave2[4]_i_4\ : label is "soft_lutpair50";
  attribute SOFT_HLUTNM of \FSM_sequential_curr_state_slave[0]_i_3\ : label is "soft_lutpair36";
  attribute SOFT_HLUTNM of \FSM_sequential_curr_state_slave[2]_i_4\ : label is "soft_lutpair50";
  attribute SOFT_HLUTNM of \FSM_sequential_curr_state_slave[2]_i_5\ : label is "soft_lutpair36";
  attribute COMPARATOR_THRESHOLD : integer;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[1]_i_2\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[1]_i_23\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[1]_i_3\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[1]_i_6\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_104\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_11\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_112\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_12\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_13\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_30\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_47\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_48\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_49\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_57\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_8\ : label is 11;
  attribute COMPARATOR_THRESHOLD of \FSM_sequential_curr_state_slave_reg[2]_i_9\ : label is 11;
  attribute SOFT_HLUTNM of M0_ARREADY_INST_0 : label is "soft_lutpair35";
  attribute SOFT_HLUTNM of M0_ARREADY_INST_0_i_2 : label is "soft_lutpair51";
  attribute SOFT_HLUTNM of M0_ARREADY_INST_0_i_3 : label is "soft_lutpair51";
  attribute SOFT_HLUTNM of M1_ARREADY_INST_0 : label is "soft_lutpair34";
  attribute SOFT_HLUTNM of \S1_ARADDR[0]_INST_0\ : label is "soft_lutpair32";
  attribute SOFT_HLUTNM of \S1_ARADDR[10]_INST_0\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of \S1_ARADDR[11]_INST_0\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \S1_ARADDR[12]_INST_0\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \S1_ARADDR[13]_INST_0\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \S1_ARADDR[14]_INST_0\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \S1_ARADDR[15]_INST_0\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \S1_ARADDR[16]_INST_0\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \S1_ARADDR[17]_INST_0\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \S1_ARADDR[18]_INST_0\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \S1_ARADDR[19]_INST_0\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \S1_ARADDR[1]_INST_0\ : label is "soft_lutpair31";
  attribute SOFT_HLUTNM of \S1_ARADDR[20]_INST_0\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \S1_ARADDR[21]_INST_0\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \S1_ARADDR[22]_INST_0\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \S1_ARADDR[23]_INST_0\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \S1_ARADDR[24]_INST_0\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \S1_ARADDR[25]_INST_0\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \S1_ARADDR[26]_INST_0\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \S1_ARADDR[27]_INST_0\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \S1_ARADDR[28]_INST_0\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \S1_ARADDR[29]_INST_0\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \S1_ARADDR[2]_INST_0\ : label is "soft_lutpair30";
  attribute SOFT_HLUTNM of \S1_ARADDR[3]_INST_0\ : label is "soft_lutpair29";
  attribute SOFT_HLUTNM of \S1_ARADDR[4]_INST_0\ : label is "soft_lutpair28";
  attribute SOFT_HLUTNM of \S1_ARADDR[5]_INST_0\ : label is "soft_lutpair27";
  attribute SOFT_HLUTNM of \S1_ARADDR[6]_INST_0\ : label is "soft_lutpair26";
  attribute SOFT_HLUTNM of \S1_ARADDR[7]_INST_0\ : label is "soft_lutpair25";
  attribute SOFT_HLUTNM of \S1_ARADDR[8]_INST_0\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \S1_ARADDR[9]_INST_0\ : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of \S1_ARBURST[0]_INST_0\ : label is "soft_lutpair41";
  attribute SOFT_HLUTNM of \S1_ARBURST[1]_INST_0\ : label is "soft_lutpair40";
  attribute SOFT_HLUTNM of \S1_ARLEN[0]_INST_0\ : label is "soft_lutpair49";
  attribute SOFT_HLUTNM of \S1_ARLEN[1]_INST_0\ : label is "soft_lutpair48";
  attribute SOFT_HLUTNM of \S1_ARLEN[2]_INST_0\ : label is "soft_lutpair47";
  attribute SOFT_HLUTNM of \S1_ARLEN[3]_INST_0\ : label is "soft_lutpair46";
  attribute SOFT_HLUTNM of \S1_ARLEN[4]_INST_0\ : label is "soft_lutpair45";
  attribute SOFT_HLUTNM of \S1_ARLEN[5]_INST_0\ : label is "soft_lutpair44";
  attribute SOFT_HLUTNM of \S1_ARLEN[6]_INST_0\ : label is "soft_lutpair43";
  attribute SOFT_HLUTNM of \S1_ARLEN[7]_INST_0\ : label is "soft_lutpair42";
  attribute SOFT_HLUTNM of \S1_ARSIZE[0]_INST_0\ : label is "soft_lutpair39";
  attribute SOFT_HLUTNM of \S1_ARSIZE[1]_INST_0\ : label is "soft_lutpair38";
  attribute SOFT_HLUTNM of \S1_ARSIZE[2]_INST_0\ : label is "soft_lutpair37";
  attribute SOFT_HLUTNM of S1_ARVALID_INST_0 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \S2_ARADDR[0]_INST_0\ : label is "soft_lutpair32";
  attribute SOFT_HLUTNM of \S2_ARADDR[10]_INST_0\ : label is "soft_lutpair22";
  attribute SOFT_HLUTNM of \S2_ARADDR[11]_INST_0\ : label is "soft_lutpair21";
  attribute SOFT_HLUTNM of \S2_ARADDR[12]_INST_0\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \S2_ARADDR[13]_INST_0\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \S2_ARADDR[14]_INST_0\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \S2_ARADDR[15]_INST_0\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \S2_ARADDR[16]_INST_0\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \S2_ARADDR[17]_INST_0\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \S2_ARADDR[18]_INST_0\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \S2_ARADDR[19]_INST_0\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \S2_ARADDR[1]_INST_0\ : label is "soft_lutpair31";
  attribute SOFT_HLUTNM of \S2_ARADDR[20]_INST_0\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \S2_ARADDR[21]_INST_0\ : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of \S2_ARADDR[22]_INST_0\ : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \S2_ARADDR[23]_INST_0\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \S2_ARADDR[24]_INST_0\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \S2_ARADDR[25]_INST_0\ : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \S2_ARADDR[26]_INST_0\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \S2_ARADDR[27]_INST_0\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \S2_ARADDR[28]_INST_0\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \S2_ARADDR[29]_INST_0\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \S2_ARADDR[2]_INST_0\ : label is "soft_lutpair30";
  attribute SOFT_HLUTNM of \S2_ARADDR[3]_INST_0\ : label is "soft_lutpair29";
  attribute SOFT_HLUTNM of \S2_ARADDR[4]_INST_0\ : label is "soft_lutpair28";
  attribute SOFT_HLUTNM of \S2_ARADDR[5]_INST_0\ : label is "soft_lutpair27";
  attribute SOFT_HLUTNM of \S2_ARADDR[6]_INST_0\ : label is "soft_lutpair26";
  attribute SOFT_HLUTNM of \S2_ARADDR[7]_INST_0\ : label is "soft_lutpair25";
  attribute SOFT_HLUTNM of \S2_ARADDR[8]_INST_0\ : label is "soft_lutpair24";
  attribute SOFT_HLUTNM of \S2_ARADDR[9]_INST_0\ : label is "soft_lutpair23";
  attribute SOFT_HLUTNM of \S2_ARBURST[0]_INST_0\ : label is "soft_lutpair41";
  attribute SOFT_HLUTNM of \S2_ARBURST[1]_INST_0\ : label is "soft_lutpair40";
  attribute SOFT_HLUTNM of \S2_ARLEN[0]_INST_0\ : label is "soft_lutpair49";
  attribute SOFT_HLUTNM of \S2_ARLEN[1]_INST_0\ : label is "soft_lutpair48";
  attribute SOFT_HLUTNM of \S2_ARLEN[2]_INST_0\ : label is "soft_lutpair47";
  attribute SOFT_HLUTNM of \S2_ARLEN[3]_INST_0\ : label is "soft_lutpair46";
  attribute SOFT_HLUTNM of \S2_ARLEN[4]_INST_0\ : label is "soft_lutpair45";
  attribute SOFT_HLUTNM of \S2_ARLEN[5]_INST_0\ : label is "soft_lutpair44";
  attribute SOFT_HLUTNM of \S2_ARLEN[6]_INST_0\ : label is "soft_lutpair43";
  attribute SOFT_HLUTNM of \S2_ARLEN[7]_INST_0\ : label is "soft_lutpair42";
  attribute SOFT_HLUTNM of \S2_ARSIZE[0]_INST_0\ : label is "soft_lutpair39";
  attribute SOFT_HLUTNM of \S2_ARSIZE[1]_INST_0\ : label is "soft_lutpair38";
  attribute SOFT_HLUTNM of \S2_ARSIZE[2]_INST_0\ : label is "soft_lutpair37";
  attribute SOFT_HLUTNM of S2_ARVALID_INST_0 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \S3_ARADDR[28]_INST_0\ : label is "soft_lutpair35";
  attribute SOFT_HLUTNM of \S3_ARADDR[29]_INST_0\ : label is "soft_lutpair34";
  attribute SOFT_HLUTNM of S3_ARVALID_INST_0 : label is "soft_lutpair33";
  attribute SOFT_HLUTNM of \Selected_Master[0]_i_1\ : label is "soft_lutpair33";
  attribute ORIG_CELL_NAME : string;
  attribute ORIG_CELL_NAME of \Selected_Master_reg[0]\ : label is "Selected_Master_reg[0]";
  attribute ORIG_CELL_NAME of \Selected_Master_reg[0]_rep\ : label is "Selected_Master_reg[0]";
  attribute ORIG_CELL_NAME of \Selected_Master_reg[0]_rep__0\ : label is "Selected_Master_reg[0]";
  attribute ORIG_CELL_NAME of \Selected_Master_reg[0]_rep__1\ : label is "Selected_Master_reg[0]";
begin
  AR_Selected_Slave <= \^ar_selected_slave\;
  CO(0) <= \^co\(0);
  \FSM_sequential_curr_state_slave_reg[2]_i_8_0\ <= \^fsm_sequential_curr_state_slave_reg[2]_i_8_0\;
  \M0_ARADDR[30]\(0) <= \^m0_araddr[30]\(0);
  \M0_ARADDR[30]_0\ <= \^m0_araddr[30]_0\;
  \M0_ARADDR[30]_1\ <= \^m0_araddr[30]_1\;
  M0_ARADDR_31_sp_1 <= M0_ARADDR_31_sn_1;
  Sel_Slave_Ready <= \^sel_slave_ready\;
  next_state_slave119_out <= \^next_state_slave119_out\;
\FSM_onehot_curr_state_slave2[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"88F8F8F8F8F8F8F8"
    )
        port map (
      I0 => \Read_controller/next_state_slave116_out\,
      I1 => \FSM_onehot_curr_state_slave2[4]_i_4_n_0\,
      I2 => \FSM_onehot_curr_state_slave2_reg[4]_0\(1),
      I3 => S1_RVALID,
      I4 => S1_RLAST,
      I5 => M1_RREADY,
      O => \FSM_onehot_curr_state_slave2_reg[4]\(0)
    );
\FSM_onehot_curr_state_slave2[2]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \Read_controller/next_state_slave215_in\,
      I1 => \Read_controller/next_state_slave214_in\,
      O => \Read_controller/next_state_slave116_out\
    );
\FSM_onehot_curr_state_slave2[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"88F8F8F8F8F8F8F8"
    )
        port map (
      I0 => \FSM_onehot_curr_state_slave2[4]_i_4_n_0\,
      I1 => \^fsm_sequential_curr_state_slave_reg[2]_i_8_0\,
      I2 => \FSM_onehot_curr_state_slave2_reg[4]_0\(2),
      I3 => S2_RVALID,
      I4 => S2_RLAST,
      I5 => M1_RREADY,
      O => \FSM_onehot_curr_state_slave2_reg[4]\(1)
    );
\FSM_onehot_curr_state_slave2[4]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"44F4F4F4F4F4F4F4"
    )
        port map (
      I0 => \FSM_sequential_curr_state_slave[2]_i_5_n_0\,
      I1 => \FSM_onehot_curr_state_slave2[4]_i_4_n_0\,
      I2 => \FSM_onehot_curr_state_slave2_reg[4]_0\(3),
      I3 => S3_RVALID,
      I4 => S3_RLAST,
      I5 => M1_RREADY,
      O => \FSM_onehot_curr_state_slave2_reg[4]\(2)
    );
\FSM_onehot_curr_state_slave2[4]_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"2A"
    )
        port map (
      I0 => \FSM_onehot_curr_state_slave2_reg[4]_0\(0),
      I1 => \^co\(0),
      I2 => \^m0_araddr[30]\(0),
      O => \FSM_onehot_curr_state_slave2[4]_i_4_n_0\
    );
\FSM_sequential_curr_state_slave[0]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0888"
    )
        port map (
      I0 => \Read_controller/next_state_slave212_in\,
      I1 => \Read_controller/next_state_slave213_in\,
      I2 => \Read_controller/next_state_slave214_in\,
      I3 => \Read_controller/next_state_slave215_in\,
      O => \^fsm_sequential_curr_state_slave_reg[2]_i_8_0\
    );
\FSM_sequential_curr_state_slave[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFFFFFFF7000"
    )
        port map (
      I0 => \^m0_araddr[30]\(0),
      I1 => \^co\(0),
      I2 => \FSM_sequential_curr_state_slave[2]_i_5_n_0\,
      I3 => \FSM_sequential_curr_state_slave_reg[2]\,
      I4 => \FSM_sequential_curr_state_slave_reg[1]\,
      I5 => \FSM_sequential_curr_state_slave_reg[1]_0\,
      O => D(0)
    );
\FSM_sequential_curr_state_slave[1]_i_10\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(24),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(24),
      I3 => M1_ARADDR(25),
      I4 => M0_ARADDR(25),
      O => \FSM_sequential_curr_state_slave[1]_i_10_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_11\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(22),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(22),
      I3 => M1_ARADDR(23),
      I4 => M0_ARADDR(23),
      O => \FSM_sequential_curr_state_slave[1]_i_11_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_12\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(20),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(20),
      I3 => M1_ARADDR(21),
      I4 => M0_ARADDR(21),
      O => \FSM_sequential_curr_state_slave[1]_i_12_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_13\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(18),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(18),
      I3 => M1_ARADDR(19),
      I4 => M0_ARADDR(19),
      O => \FSM_sequential_curr_state_slave[1]_i_13_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_14\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(16),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(16),
      I3 => M1_ARADDR(17),
      I4 => M0_ARADDR(17),
      O => \FSM_sequential_curr_state_slave[1]_i_14_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_15\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[1]_i_15_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_16\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[1]_i_16_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_17\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => M1_ARADDR(27),
      I2 => M0_ARADDR(26),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[1]_i_17_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_18\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => M1_ARADDR(25),
      I2 => M0_ARADDR(24),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[1]_i_18_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_19\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => M1_ARADDR(23),
      I2 => M0_ARADDR(22),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[1]_i_19_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_20\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => M1_ARADDR(21),
      I2 => M0_ARADDR(20),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[1]_i_20_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_21\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => M1_ARADDR(19),
      I2 => M0_ARADDR(18),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[1]_i_21_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_22\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => M1_ARADDR(17),
      I2 => M0_ARADDR(16),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[1]_i_22_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_24\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[1]_i_24_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_25\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(27),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(27),
      I3 => M1_ARADDR(26),
      I4 => M0_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[1]_i_25_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_26\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(25),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(25),
      I3 => M1_ARADDR(24),
      I4 => M0_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[1]_i_26_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_27\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(23),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(23),
      I3 => M1_ARADDR(22),
      I4 => M0_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[1]_i_27_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_28\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(21),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(21),
      I3 => M1_ARADDR(20),
      I4 => M0_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[1]_i_28_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_29\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(19),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(19),
      I3 => M1_ARADDR(18),
      I4 => M0_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[1]_i_29_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_30\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(17),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(17),
      I3 => M1_ARADDR(16),
      I4 => M0_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[1]_i_30_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_31\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[1]_i_31_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_32\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_ARADDR(28),
      I1 => M1_ARADDR(28),
      I2 => M0_ARADDR(29),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(29),
      O => \FSM_sequential_curr_state_slave[1]_i_32_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_33\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(26),
      I1 => M1_ARADDR(26),
      I2 => M0_ARADDR(27),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(27),
      O => \FSM_sequential_curr_state_slave[1]_i_33_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_34\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(24),
      I1 => M1_ARADDR(24),
      I2 => M0_ARADDR(25),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(25),
      O => \FSM_sequential_curr_state_slave[1]_i_34_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_35\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(22),
      I1 => M1_ARADDR(22),
      I2 => M0_ARADDR(23),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(23),
      O => \FSM_sequential_curr_state_slave[1]_i_35_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_36\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(20),
      I1 => M1_ARADDR(20),
      I2 => M0_ARADDR(21),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(21),
      O => \FSM_sequential_curr_state_slave[1]_i_36_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_37\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(18),
      I1 => M1_ARADDR(18),
      I2 => M0_ARADDR(19),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(19),
      O => \FSM_sequential_curr_state_slave[1]_i_37_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_38\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(16),
      I1 => M1_ARADDR(16),
      I2 => M0_ARADDR(17),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(17),
      O => \FSM_sequential_curr_state_slave[1]_i_38_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_39\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(14),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(14),
      I3 => M1_ARADDR(15),
      I4 => M0_ARADDR(15),
      O => \FSM_sequential_curr_state_slave[1]_i_39_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_40\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(12),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(12),
      I3 => M1_ARADDR(13),
      I4 => M0_ARADDR(13),
      O => \FSM_sequential_curr_state_slave[1]_i_40_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_41\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(10),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(10),
      I3 => M1_ARADDR(11),
      I4 => M0_ARADDR(11),
      O => \FSM_sequential_curr_state_slave[1]_i_41_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_42\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(8),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(8),
      I3 => M1_ARADDR(9),
      I4 => M0_ARADDR(9),
      O => \FSM_sequential_curr_state_slave[1]_i_42_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_43\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(6),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(6),
      I3 => M1_ARADDR(7),
      I4 => M0_ARADDR(7),
      O => \FSM_sequential_curr_state_slave[1]_i_43_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_44\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(4),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(4),
      I3 => M1_ARADDR(5),
      I4 => M0_ARADDR(5),
      O => \FSM_sequential_curr_state_slave[1]_i_44_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_45\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(2),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(2),
      I3 => M1_ARADDR(3),
      I4 => M0_ARADDR(3),
      O => \FSM_sequential_curr_state_slave[1]_i_45_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_46\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => M1_ARADDR(15),
      I2 => M0_ARADDR(14),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[1]_i_46_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_47\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => M1_ARADDR(13),
      I2 => M0_ARADDR(12),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[1]_i_47_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_48\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => M1_ARADDR(11),
      I2 => M0_ARADDR(10),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[1]_i_48_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_49\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => M1_ARADDR(9),
      I2 => M0_ARADDR(8),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[1]_i_49_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_50\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => M1_ARADDR(7),
      I2 => M0_ARADDR(6),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[1]_i_50_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_51\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => M1_ARADDR(5),
      I2 => M0_ARADDR(4),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[1]_i_51_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_52\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => M1_ARADDR(3),
      I2 => M0_ARADDR(2),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[1]_i_52_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_53\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(0),
      I1 => M1_ARADDR(0),
      I2 => M0_ARADDR(1),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(1),
      O => \FSM_sequential_curr_state_slave[1]_i_53_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_54\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(15),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(15),
      I3 => M1_ARADDR(14),
      I4 => M0_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[1]_i_54_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_55\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(13),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(13),
      I3 => M1_ARADDR(12),
      I4 => M0_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[1]_i_55_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_56\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(11),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(11),
      I3 => M1_ARADDR(10),
      I4 => M0_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[1]_i_56_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_57\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(9),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(9),
      I3 => M1_ARADDR(8),
      I4 => M0_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[1]_i_57_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_58\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(7),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(7),
      I3 => M1_ARADDR(6),
      I4 => M0_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[1]_i_58_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_59\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(5),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(5),
      I3 => M1_ARADDR(4),
      I4 => M0_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[1]_i_59_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_60\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(3),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(3),
      I3 => M1_ARADDR(2),
      I4 => M0_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[1]_i_60_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_61\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(14),
      I1 => M1_ARADDR(14),
      I2 => M0_ARADDR(15),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(15),
      O => \FSM_sequential_curr_state_slave[1]_i_61_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_62\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(12),
      I1 => M1_ARADDR(12),
      I2 => M0_ARADDR(13),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(13),
      O => \FSM_sequential_curr_state_slave[1]_i_62_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_63\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(10),
      I1 => M1_ARADDR(10),
      I2 => M0_ARADDR(11),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(11),
      O => \FSM_sequential_curr_state_slave[1]_i_63_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_64\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(8),
      I1 => M1_ARADDR(8),
      I2 => M0_ARADDR(9),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(9),
      O => \FSM_sequential_curr_state_slave[1]_i_64_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_65\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(6),
      I1 => M1_ARADDR(6),
      I2 => M0_ARADDR(7),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(7),
      O => \FSM_sequential_curr_state_slave[1]_i_65_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_66\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(4),
      I1 => M1_ARADDR(4),
      I2 => M0_ARADDR(5),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(5),
      O => \FSM_sequential_curr_state_slave[1]_i_66_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_67\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(2),
      I1 => M1_ARADDR(2),
      I2 => M0_ARADDR(3),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(3),
      O => \FSM_sequential_curr_state_slave[1]_i_67_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_68\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(1),
      I1 => M1_ARADDR(1),
      I2 => M0_ARADDR(0),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(0),
      O => \FSM_sequential_curr_state_slave[1]_i_68_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_7\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFACCFA"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(31),
      O => \FSM_sequential_curr_state_slave[1]_i_7_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_8\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(28),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(28),
      I3 => M1_ARADDR(29),
      I4 => M0_ARADDR(29),
      O => \FSM_sequential_curr_state_slave[1]_i_8_n_0\
    );
\FSM_sequential_curr_state_slave[1]_i_9\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(26),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(26),
      I3 => M1_ARADDR(27),
      I4 => M0_ARADDR(27),
      O => \FSM_sequential_curr_state_slave[1]_i_9_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_10\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF00808080808080"
    )
        port map (
      I0 => \Read_controller/next_state_slave2\,
      I1 => \Read_controller/next_state_slave210_in\,
      I2 => S3_ARREADY,
      I3 => S2_ARREADY,
      I4 => \Read_controller/next_state_slave213_in\,
      I5 => \Read_controller/next_state_slave212_in\,
      O => \FSM_sequential_curr_state_slave[2]_i_10_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_100\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(6),
      I1 => M1_ARADDR(6),
      I2 => M0_ARADDR(7),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(7),
      O => \FSM_sequential_curr_state_slave[2]_i_100_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_101\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(4),
      I1 => M1_ARADDR(4),
      I2 => M0_ARADDR(5),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(5),
      O => \FSM_sequential_curr_state_slave[2]_i_101_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_102\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(2),
      I1 => M1_ARADDR(2),
      I2 => M0_ARADDR(3),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(3),
      O => \FSM_sequential_curr_state_slave[2]_i_102_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_103\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(1),
      I1 => M1_ARADDR(1),
      I2 => M0_ARADDR(0),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(0),
      O => \FSM_sequential_curr_state_slave[2]_i_103_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_105\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[2]_i_105_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_106\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[2]_i_106_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_107\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => M1_ARADDR(27),
      I2 => M0_ARADDR(26),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[2]_i_107_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_108\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => M1_ARADDR(25),
      I2 => M0_ARADDR(24),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[2]_i_108_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_109\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => M1_ARADDR(23),
      I2 => M0_ARADDR(22),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[2]_i_109_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_110\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => M1_ARADDR(21),
      I2 => M0_ARADDR(20),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[2]_i_110_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_111\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => M1_ARADDR(19),
      I2 => M0_ARADDR(18),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[2]_i_111_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_113\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFACCFA"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(31),
      O => \FSM_sequential_curr_state_slave[2]_i_113_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_114\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(28),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(28),
      I3 => M1_ARADDR(29),
      I4 => M0_ARADDR(29),
      O => \FSM_sequential_curr_state_slave[2]_i_114_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_115\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(26),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(26),
      I3 => M1_ARADDR(27),
      I4 => M0_ARADDR(27),
      O => \FSM_sequential_curr_state_slave[2]_i_115_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_116\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(24),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(24),
      I3 => M1_ARADDR(25),
      I4 => M0_ARADDR(25),
      O => \FSM_sequential_curr_state_slave[2]_i_116_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_117\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(22),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(22),
      I3 => M1_ARADDR(23),
      I4 => M0_ARADDR(23),
      O => \FSM_sequential_curr_state_slave[2]_i_117_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_118\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(20),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(20),
      I3 => M1_ARADDR(21),
      I4 => M0_ARADDR(21),
      O => \FSM_sequential_curr_state_slave[2]_i_118_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_119\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(18),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(18),
      I3 => M1_ARADDR(19),
      I4 => M0_ARADDR(19),
      O => \FSM_sequential_curr_state_slave[2]_i_119_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_120\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(16),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(16),
      I3 => M1_ARADDR(17),
      I4 => M0_ARADDR(17),
      O => \FSM_sequential_curr_state_slave[2]_i_120_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_121\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[2]_i_121_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_122\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[2]_i_122_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_123\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => M1_ARADDR(27),
      I2 => M0_ARADDR(26),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[2]_i_123_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_124\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => M1_ARADDR(25),
      I2 => M0_ARADDR(24),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[2]_i_124_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_125\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => M1_ARADDR(23),
      I2 => M0_ARADDR(22),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[2]_i_125_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_126\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => M1_ARADDR(21),
      I2 => M0_ARADDR(20),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[2]_i_126_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_127\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => M1_ARADDR(19),
      I2 => M0_ARADDR(18),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[2]_i_127_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_128\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => M1_ARADDR(17),
      I2 => M0_ARADDR(16),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[2]_i_128_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_129\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(0),
      I1 => M1_ARADDR(0),
      I2 => M0_ARADDR(1),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(1),
      O => \FSM_sequential_curr_state_slave[2]_i_129_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_130\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => M1_ARADDR(17),
      I2 => M0_ARADDR(16),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[2]_i_130_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_131\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => M1_ARADDR(15),
      I2 => M0_ARADDR(14),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[2]_i_131_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_132\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => M1_ARADDR(13),
      I2 => M0_ARADDR(12),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[2]_i_132_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_133\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => M1_ARADDR(11),
      I2 => M0_ARADDR(10),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[2]_i_133_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_134\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => M1_ARADDR(9),
      I2 => M0_ARADDR(8),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[2]_i_134_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_135\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => M1_ARADDR(7),
      I2 => M0_ARADDR(6),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[2]_i_135_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_136\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => M1_ARADDR(5),
      I2 => M0_ARADDR(4),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[2]_i_136_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_137\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => M1_ARADDR(3),
      I2 => M0_ARADDR(2),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[2]_i_137_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_138\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(14),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(14),
      I3 => M1_ARADDR(15),
      I4 => M0_ARADDR(15),
      O => \FSM_sequential_curr_state_slave[2]_i_138_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_139\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(12),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(12),
      I3 => M1_ARADDR(13),
      I4 => M0_ARADDR(13),
      O => \FSM_sequential_curr_state_slave[2]_i_139_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_14\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(31),
      O => \FSM_sequential_curr_state_slave[2]_i_14_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_140\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(10),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(10),
      I3 => M1_ARADDR(11),
      I4 => M0_ARADDR(11),
      O => \FSM_sequential_curr_state_slave[2]_i_140_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_141\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(8),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(8),
      I3 => M1_ARADDR(9),
      I4 => M0_ARADDR(9),
      O => \FSM_sequential_curr_state_slave[2]_i_141_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_142\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(6),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(6),
      I3 => M1_ARADDR(7),
      I4 => M0_ARADDR(7),
      O => \FSM_sequential_curr_state_slave[2]_i_142_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_143\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(4),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(4),
      I3 => M1_ARADDR(5),
      I4 => M0_ARADDR(5),
      O => \FSM_sequential_curr_state_slave[2]_i_143_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_144\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(2),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(2),
      I3 => M1_ARADDR(3),
      I4 => M0_ARADDR(3),
      O => \FSM_sequential_curr_state_slave[2]_i_144_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_145\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => M1_ARADDR(15),
      I2 => M0_ARADDR(14),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[2]_i_145_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_146\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => M1_ARADDR(13),
      I2 => M0_ARADDR(12),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[2]_i_146_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_147\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => M1_ARADDR(11),
      I2 => M0_ARADDR(10),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[2]_i_147_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_148\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => M1_ARADDR(9),
      I2 => M0_ARADDR(8),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[2]_i_148_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_149\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => M1_ARADDR(7),
      I2 => M0_ARADDR(6),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[2]_i_149_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_15\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(28),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(28),
      I3 => M1_ARADDR(29),
      I4 => M0_ARADDR(29),
      O => \FSM_sequential_curr_state_slave[2]_i_15_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_150\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => M1_ARADDR(5),
      I2 => M0_ARADDR(4),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[2]_i_150_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_151\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => M1_ARADDR(3),
      I2 => M0_ARADDR(2),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[2]_i_151_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_152\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(0),
      I1 => M1_ARADDR(0),
      I2 => M0_ARADDR(1),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(1),
      O => \FSM_sequential_curr_state_slave[2]_i_152_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_153\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => M1_ARADDR(17),
      I2 => M0_ARADDR(16),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[2]_i_153_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_154\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => M1_ARADDR(15),
      I2 => M0_ARADDR(14),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[2]_i_154_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_155\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => M1_ARADDR(13),
      I2 => M0_ARADDR(12),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[2]_i_155_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_156\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => M1_ARADDR(11),
      I2 => M0_ARADDR(10),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[2]_i_156_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_157\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => M1_ARADDR(9),
      I2 => M0_ARADDR(8),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[2]_i_157_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_158\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => M1_ARADDR(7),
      I2 => M0_ARADDR(6),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[2]_i_158_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_159\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => M1_ARADDR(5),
      I2 => M0_ARADDR(4),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[2]_i_159_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_16\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(26),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(26),
      I3 => M1_ARADDR(27),
      I4 => M0_ARADDR(27),
      O => \FSM_sequential_curr_state_slave[2]_i_16_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_160\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => M1_ARADDR(3),
      I2 => M0_ARADDR(2),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[2]_i_160_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_161\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(14),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(14),
      I3 => M1_ARADDR(15),
      I4 => M0_ARADDR(15),
      O => \FSM_sequential_curr_state_slave[2]_i_161_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_162\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(12),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(12),
      I3 => M1_ARADDR(13),
      I4 => M0_ARADDR(13),
      O => \FSM_sequential_curr_state_slave[2]_i_162_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_163\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(10),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(10),
      I3 => M1_ARADDR(11),
      I4 => M0_ARADDR(11),
      O => \FSM_sequential_curr_state_slave[2]_i_163_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_164\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(8),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(8),
      I3 => M1_ARADDR(9),
      I4 => M0_ARADDR(9),
      O => \FSM_sequential_curr_state_slave[2]_i_164_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_165\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(6),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(6),
      I3 => M1_ARADDR(7),
      I4 => M0_ARADDR(7),
      O => \FSM_sequential_curr_state_slave[2]_i_165_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_166\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(4),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(4),
      I3 => M1_ARADDR(5),
      I4 => M0_ARADDR(5),
      O => \FSM_sequential_curr_state_slave[2]_i_166_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_167\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(2),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(2),
      I3 => M1_ARADDR(3),
      I4 => M0_ARADDR(3),
      O => \FSM_sequential_curr_state_slave[2]_i_167_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_168\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => M1_ARADDR(15),
      I2 => M0_ARADDR(14),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[2]_i_168_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_169\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => M1_ARADDR(13),
      I2 => M0_ARADDR(12),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[2]_i_169_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_17\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(24),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(24),
      I3 => M1_ARADDR(25),
      I4 => M0_ARADDR(25),
      O => \FSM_sequential_curr_state_slave[2]_i_17_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_170\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => M1_ARADDR(11),
      I2 => M0_ARADDR(10),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[2]_i_170_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_171\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => M1_ARADDR(9),
      I2 => M0_ARADDR(8),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[2]_i_171_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_172\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => M1_ARADDR(7),
      I2 => M0_ARADDR(6),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[2]_i_172_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_173\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => M1_ARADDR(5),
      I2 => M0_ARADDR(4),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[2]_i_173_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_174\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => M1_ARADDR(3),
      I2 => M0_ARADDR(2),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[2]_i_174_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_175\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(0),
      I1 => M1_ARADDR(0),
      I2 => M0_ARADDR(1),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(1),
      O => \FSM_sequential_curr_state_slave[2]_i_175_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_18\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(22),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(22),
      I3 => M1_ARADDR(23),
      I4 => M0_ARADDR(23),
      O => \FSM_sequential_curr_state_slave[2]_i_18_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_19\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(20),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(20),
      I3 => M1_ARADDR(21),
      I4 => M0_ARADDR(21),
      O => \FSM_sequential_curr_state_slave[2]_i_19_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF10FFFF10101010"
    )
        port map (
      I0 => \^next_state_slave119_out\,
      I1 => \FSM_sequential_curr_state_slave[2]_i_5_n_0\,
      I2 => \FSM_sequential_curr_state_slave_reg[2]\,
      I3 => \FSM_sequential_curr_state_slave_reg[2]_0\,
      I4 => M0_RREADY,
      I5 => Q(0),
      O => D(1)
    );
\FSM_sequential_curr_state_slave[2]_i_20\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(18),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(18),
      I3 => M1_ARADDR(19),
      I4 => M0_ARADDR(19),
      O => \FSM_sequential_curr_state_slave[2]_i_20_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_21\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(16),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(16),
      I3 => M1_ARADDR(17),
      I4 => M0_ARADDR(17),
      O => \FSM_sequential_curr_state_slave[2]_i_21_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_22\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(31),
      O => \FSM_sequential_curr_state_slave[2]_i_22_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_23\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[2]_i_23_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_24\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => M1_ARADDR(27),
      I2 => M0_ARADDR(26),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[2]_i_24_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_25\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => M1_ARADDR(25),
      I2 => M0_ARADDR(24),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[2]_i_25_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_26\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => M1_ARADDR(23),
      I2 => M0_ARADDR(22),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[2]_i_26_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_27\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => M1_ARADDR(21),
      I2 => M0_ARADDR(20),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[2]_i_27_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_28\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => M1_ARADDR(19),
      I2 => M0_ARADDR(18),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[2]_i_28_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_29\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => M1_ARADDR(17),
      I2 => M0_ARADDR(16),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[2]_i_29_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"B8BBBBBBB8888888"
    )
        port map (
      I0 => S0_ARREADY,
      I1 => \^next_state_slave119_out\,
      I2 => S1_ARREADY,
      I3 => \Read_controller/next_state_slave215_in\,
      I4 => \Read_controller/next_state_slave214_in\,
      I5 => \FSM_sequential_curr_state_slave[2]_i_10_n_0\,
      O => S0_ARREADY_0
    );
\FSM_sequential_curr_state_slave[2]_i_31\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[2]_i_31_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_32\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[2]_i_32_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_33\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(27),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(27),
      I3 => M1_ARADDR(26),
      I4 => M0_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[2]_i_33_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_34\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(25),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(25),
      I3 => M1_ARADDR(24),
      I4 => M0_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[2]_i_34_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_35\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(23),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(23),
      I3 => M1_ARADDR(22),
      I4 => M0_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[2]_i_35_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_36\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(21),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(21),
      I3 => M1_ARADDR(20),
      I4 => M0_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[2]_i_36_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_37\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(19),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(19),
      I3 => M1_ARADDR(18),
      I4 => M0_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[2]_i_37_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_38\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(17),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(17),
      I3 => M1_ARADDR(16),
      I4 => M0_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[2]_i_38_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_39\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(31),
      O => \FSM_sequential_curr_state_slave[2]_i_39_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^m0_araddr[30]\(0),
      I1 => \^co\(0),
      O => \^next_state_slave119_out\
    );
\FSM_sequential_curr_state_slave[2]_i_40\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_ARADDR(28),
      I1 => M1_ARADDR(28),
      I2 => M0_ARADDR(29),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(29),
      O => \FSM_sequential_curr_state_slave[2]_i_40_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_41\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(26),
      I1 => M1_ARADDR(26),
      I2 => M0_ARADDR(27),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(27),
      O => \FSM_sequential_curr_state_slave[2]_i_41_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_42\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(24),
      I1 => M1_ARADDR(24),
      I2 => M0_ARADDR(25),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(25),
      O => \FSM_sequential_curr_state_slave[2]_i_42_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_43\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(22),
      I1 => M1_ARADDR(22),
      I2 => M0_ARADDR(23),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(23),
      O => \FSM_sequential_curr_state_slave[2]_i_43_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_44\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(20),
      I1 => M1_ARADDR(20),
      I2 => M0_ARADDR(21),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(21),
      O => \FSM_sequential_curr_state_slave[2]_i_44_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_45\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(18),
      I1 => M1_ARADDR(18),
      I2 => M0_ARADDR(19),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(19),
      O => \FSM_sequential_curr_state_slave[2]_i_45_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_46\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(16),
      I1 => M1_ARADDR(16),
      I2 => M0_ARADDR(17),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(17),
      O => \FSM_sequential_curr_state_slave[2]_i_46_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"F888"
    )
        port map (
      I0 => \Read_controller/next_state_slave214_in\,
      I1 => \Read_controller/next_state_slave215_in\,
      I2 => \Read_controller/next_state_slave212_in\,
      I3 => \Read_controller/next_state_slave213_in\,
      O => \FSM_sequential_curr_state_slave[2]_i_5_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_50\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[2]_i_50_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_51\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[2]_i_51_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_52\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => M1_ARADDR(27),
      I2 => M0_ARADDR(26),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[2]_i_52_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_53\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => M1_ARADDR(25),
      I2 => M0_ARADDR(24),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[2]_i_53_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_54\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => M1_ARADDR(23),
      I2 => M0_ARADDR(22),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[2]_i_54_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_55\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => M1_ARADDR(21),
      I2 => M0_ARADDR(20),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[2]_i_55_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_56\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => M1_ARADDR(19),
      I2 => M0_ARADDR(18),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[2]_i_56_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_58\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFACCFA"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(31),
      O => \FSM_sequential_curr_state_slave[2]_i_58_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_59\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(28),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(28),
      I3 => M1_ARADDR(29),
      I4 => M0_ARADDR(29),
      O => \FSM_sequential_curr_state_slave[2]_i_59_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_60\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(26),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(26),
      I3 => M1_ARADDR(27),
      I4 => M0_ARADDR(27),
      O => \FSM_sequential_curr_state_slave[2]_i_60_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_61\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(24),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(24),
      I3 => M1_ARADDR(25),
      I4 => M0_ARADDR(25),
      O => \FSM_sequential_curr_state_slave[2]_i_61_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_62\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(22),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(22),
      I3 => M1_ARADDR(23),
      I4 => M0_ARADDR(23),
      O => \FSM_sequential_curr_state_slave[2]_i_62_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_63\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(20),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(20),
      I3 => M1_ARADDR(21),
      I4 => M0_ARADDR(21),
      O => \FSM_sequential_curr_state_slave[2]_i_63_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_64\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(18),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(18),
      I3 => M1_ARADDR(19),
      I4 => M0_ARADDR(19),
      O => \FSM_sequential_curr_state_slave[2]_i_64_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_65\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(16),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(16),
      I3 => M1_ARADDR(17),
      I4 => M0_ARADDR(17),
      O => \FSM_sequential_curr_state_slave[2]_i_65_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_66\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00440347"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \Selected_Master_reg[0]_rep__1_n_0\,
      I2 => M0_ARADDR(31),
      I3 => M1_ARADDR(30),
      I4 => M0_ARADDR(30),
      O => \FSM_sequential_curr_state_slave[2]_i_66_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_67\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => M1_ARADDR(29),
      I2 => M0_ARADDR(28),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(28),
      O => \FSM_sequential_curr_state_slave[2]_i_67_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_68\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => M1_ARADDR(27),
      I2 => M0_ARADDR(26),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(26),
      O => \FSM_sequential_curr_state_slave[2]_i_68_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_69\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => M1_ARADDR(25),
      I2 => M0_ARADDR(24),
      I3 => \Selected_Master_reg[0]_rep__1_n_0\,
      I4 => M1_ARADDR(24),
      O => \FSM_sequential_curr_state_slave[2]_i_69_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_70\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => M1_ARADDR(23),
      I2 => M0_ARADDR(22),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(22),
      O => \FSM_sequential_curr_state_slave[2]_i_70_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_71\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => M1_ARADDR(21),
      I2 => M0_ARADDR(20),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(20),
      O => \FSM_sequential_curr_state_slave[2]_i_71_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_72\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => M1_ARADDR(19),
      I2 => M0_ARADDR(18),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(18),
      O => \FSM_sequential_curr_state_slave[2]_i_72_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_73\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => M1_ARADDR(17),
      I2 => M0_ARADDR(16),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(16),
      O => \FSM_sequential_curr_state_slave[2]_i_73_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_74\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(14),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(14),
      I3 => M1_ARADDR(15),
      I4 => M0_ARADDR(15),
      O => \FSM_sequential_curr_state_slave[2]_i_74_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_75\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(12),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(12),
      I3 => M1_ARADDR(13),
      I4 => M0_ARADDR(13),
      O => \FSM_sequential_curr_state_slave[2]_i_75_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_76\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(10),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(10),
      I3 => M1_ARADDR(11),
      I4 => M0_ARADDR(11),
      O => \FSM_sequential_curr_state_slave[2]_i_76_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_77\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(8),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(8),
      I3 => M1_ARADDR(9),
      I4 => M0_ARADDR(9),
      O => \FSM_sequential_curr_state_slave[2]_i_77_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_78\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(6),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(6),
      I3 => M1_ARADDR(7),
      I4 => M0_ARADDR(7),
      O => \FSM_sequential_curr_state_slave[2]_i_78_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_79\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(4),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(4),
      I3 => M1_ARADDR(5),
      I4 => M0_ARADDR(5),
      O => \FSM_sequential_curr_state_slave[2]_i_79_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_80\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFBBFCB8"
    )
        port map (
      I0 => M1_ARADDR(2),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(2),
      I3 => M1_ARADDR(3),
      I4 => M0_ARADDR(3),
      O => \FSM_sequential_curr_state_slave[2]_i_80_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_81\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => M1_ARADDR(15),
      I2 => M0_ARADDR(14),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[2]_i_81_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_82\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => M1_ARADDR(13),
      I2 => M0_ARADDR(12),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[2]_i_82_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_83\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => M1_ARADDR(11),
      I2 => M0_ARADDR(10),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[2]_i_83_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_84\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => M1_ARADDR(9),
      I2 => M0_ARADDR(8),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[2]_i_84_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_85\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => M1_ARADDR(7),
      I2 => M0_ARADDR(6),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[2]_i_85_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_86\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => M1_ARADDR(5),
      I2 => M0_ARADDR(4),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[2]_i_86_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_87\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => M1_ARADDR(3),
      I2 => M0_ARADDR(2),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[2]_i_87_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_88\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00053305"
    )
        port map (
      I0 => M0_ARADDR(0),
      I1 => M1_ARADDR(0),
      I2 => M0_ARADDR(1),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(1),
      O => \FSM_sequential_curr_state_slave[2]_i_88_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_89\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(15),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(15),
      I3 => M1_ARADDR(14),
      I4 => M0_ARADDR(14),
      O => \FSM_sequential_curr_state_slave[2]_i_89_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_90\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(13),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(13),
      I3 => M1_ARADDR(12),
      I4 => M0_ARADDR(12),
      O => \FSM_sequential_curr_state_slave[2]_i_90_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_91\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(11),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(11),
      I3 => M1_ARADDR(10),
      I4 => M0_ARADDR(10),
      O => \FSM_sequential_curr_state_slave[2]_i_91_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_92\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(9),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(9),
      I3 => M1_ARADDR(8),
      I4 => M0_ARADDR(8),
      O => \FSM_sequential_curr_state_slave[2]_i_92_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_93\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(7),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(7),
      I3 => M1_ARADDR(6),
      I4 => M0_ARADDR(6),
      O => \FSM_sequential_curr_state_slave[2]_i_93_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_94\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(5),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(5),
      I3 => M1_ARADDR(4),
      I4 => M0_ARADDR(4),
      O => \FSM_sequential_curr_state_slave[2]_i_94_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_95\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"47CF77FF"
    )
        port map (
      I0 => M1_ARADDR(3),
      I1 => \Selected_Master_reg[0]_rep__0_n_0\,
      I2 => M0_ARADDR(3),
      I3 => M1_ARADDR(2),
      I4 => M0_ARADDR(2),
      O => \FSM_sequential_curr_state_slave[2]_i_95_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_96\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(14),
      I1 => M1_ARADDR(14),
      I2 => M0_ARADDR(15),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(15),
      O => \FSM_sequential_curr_state_slave[2]_i_96_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_97\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(12),
      I1 => M1_ARADDR(12),
      I2 => M0_ARADDR(13),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(13),
      O => \FSM_sequential_curr_state_slave[2]_i_97_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_98\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(10),
      I1 => M1_ARADDR(10),
      I2 => M0_ARADDR(11),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(11),
      O => \FSM_sequential_curr_state_slave[2]_i_98_n_0\
    );
\FSM_sequential_curr_state_slave[2]_i_99\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(8),
      I1 => M1_ARADDR(8),
      I2 => M0_ARADDR(9),
      I3 => \Selected_Master_reg[0]_rep__0_n_0\,
      I4 => M1_ARADDR(9),
      O => \FSM_sequential_curr_state_slave[2]_i_99_n_0\
    );
\FSM_sequential_curr_state_slave_reg[1]_i_2\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_0\,
      CI_TOP => '0',
      CO(7) => \^m0_araddr[30]\(0),
      CO(6) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[1]_i_2_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[1]_i_7_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[1]_i_8_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[1]_i_9_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[1]_i_10_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[1]_i_11_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[1]_i_12_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[1]_i_13_n_0\,
      DI(0) => \FSM_sequential_curr_state_slave[1]_i_14_n_0\,
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[1]_i_2_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[1]_i_15_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[1]_i_16_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[1]_i_17_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[1]_i_18_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[1]_i_19_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[1]_i_20_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[1]_i_21_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[1]_i_22_n_0\
    );
\FSM_sequential_curr_state_slave_reg[1]_i_23\: unisim.vcomponents.CARRY8
     port map (
      CI => '1',
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[1]_i_54_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[1]_i_55_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[1]_i_56_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[1]_i_57_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[1]_i_58_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[1]_i_59_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[1]_i_60_n_0\,
      DI(0) => '1',
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[1]_i_23_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[1]_i_61_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[1]_i_62_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[1]_i_63_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[1]_i_64_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[1]_i_65_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[1]_i_66_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[1]_i_67_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[1]_i_68_n_0\
    );
\FSM_sequential_curr_state_slave_reg[1]_i_3\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[1]_i_23_n_0\,
      CI_TOP => '0',
      CO(7) => \^co\(0),
      CO(6) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[1]_i_3_n_7\,
      DI(7) => '0',
      DI(6) => \FSM_sequential_curr_state_slave[1]_i_24_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[1]_i_25_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[1]_i_26_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[1]_i_27_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[1]_i_28_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[1]_i_29_n_0\,
      DI(0) => \FSM_sequential_curr_state_slave[1]_i_30_n_0\,
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[1]_i_3_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[1]_i_31_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[1]_i_32_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[1]_i_33_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[1]_i_34_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[1]_i_35_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[1]_i_36_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[1]_i_37_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[1]_i_38_n_0\
    );
\FSM_sequential_curr_state_slave_reg[1]_i_6\: unisim.vcomponents.CARRY8
     port map (
      CI => '1',
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[1]_i_6_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[1]_i_39_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[1]_i_40_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[1]_i_41_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[1]_i_42_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[1]_i_43_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[1]_i_44_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[1]_i_45_n_0\,
      DI(0) => '1',
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[1]_i_6_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[1]_i_46_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[1]_i_47_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[1]_i_48_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[1]_i_49_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[1]_i_50_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[1]_i_51_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[1]_i_52_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[1]_i_53_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_104\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave[2]_i_129_n_0\,
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_7\,
      DI(7 downto 0) => B"00000000",
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_104_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_153_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_154_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_155_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_156_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_157_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_158_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_159_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_160_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_11\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_0\,
      CI_TOP => '0',
      CO(7) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_11_CO_UNCONNECTED\(7),
      CO(6) => \Read_controller/next_state_slave212_in\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_11_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_11_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_11_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_11_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_11_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_11_n_7\,
      DI(7 downto 0) => B"00000000",
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_11_O_UNCONNECTED\(7 downto 0),
      S(7) => '0',
      S(6) => \FSM_sequential_curr_state_slave[2]_i_50_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_51_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_52_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_53_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_54_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_55_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_56_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_112\: unisim.vcomponents.CARRY8
     port map (
      CI => '1',
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_161_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_162_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_163_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_164_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_165_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_166_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_167_n_0\,
      DI(0) => '1',
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_112_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_168_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_169_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_170_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_171_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_172_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_173_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_174_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_175_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_12\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_0\,
      CI_TOP => '0',
      CO(7) => \Read_controller/next_state_slave213_in\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_12_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_58_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_59_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_60_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_61_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_62_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_63_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_64_n_0\,
      DI(0) => \FSM_sequential_curr_state_slave[2]_i_65_n_0\,
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_12_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_66_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_67_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_68_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_69_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_70_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_71_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_72_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_73_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_13\: unisim.vcomponents.CARRY8
     port map (
      CI => '1',
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_74_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_75_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_76_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_77_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_78_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_79_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_80_n_0\,
      DI(0) => '1',
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_13_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_81_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_82_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_83_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_84_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_85_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_86_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_87_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_88_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_30\: unisim.vcomponents.CARRY8
     port map (
      CI => '1',
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_89_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_90_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_91_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_92_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_93_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_94_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_95_n_0\,
      DI(0) => '1',
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_30_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_96_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_97_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_98_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_99_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_100_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_101_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_102_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_103_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_47\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[2]_i_104_n_0\,
      CI_TOP => '0',
      CO(7) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_47_CO_UNCONNECTED\(7),
      CO(6) => \Read_controller/next_state_slave2\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_47_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_47_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_47_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_47_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_47_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_47_n_7\,
      DI(7 downto 0) => B"00000000",
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_47_O_UNCONNECTED\(7 downto 0),
      S(7) => '0',
      S(6) => \FSM_sequential_curr_state_slave[2]_i_105_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_106_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_107_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_108_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_109_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_110_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_111_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_48\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[2]_i_112_n_0\,
      CI_TOP => '0',
      CO(7) => \Read_controller/next_state_slave210_in\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_48_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_113_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_114_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_115_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_116_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_117_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_118_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_119_n_0\,
      DI(0) => \FSM_sequential_curr_state_slave[2]_i_120_n_0\,
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_48_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_121_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_122_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_123_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_124_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_125_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_126_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_127_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_128_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_49\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave[2]_i_129_n_0\,
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_49_n_7\,
      DI(7 downto 0) => B"00000000",
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_49_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_130_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_131_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_132_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_133_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_134_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_135_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_136_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_137_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_57\: unisim.vcomponents.CARRY8
     port map (
      CI => '1',
      CI_TOP => '0',
      CO(7) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_0\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_57_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_138_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_139_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_140_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_141_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_142_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_143_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_144_n_0\,
      DI(0) => '1',
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_57_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_145_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_146_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_147_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_148_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_149_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_150_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_151_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_152_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_8\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[2]_i_13_n_0\,
      CI_TOP => '0',
      CO(7) => \Read_controller/next_state_slave215_in\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_8_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_14_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_15_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_16_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_17_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_18_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_19_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_20_n_0\,
      DI(0) => \FSM_sequential_curr_state_slave[2]_i_21_n_0\,
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_8_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_22_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_23_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_24_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_25_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_26_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_27_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_28_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_29_n_0\
    );
\FSM_sequential_curr_state_slave_reg[2]_i_9\: unisim.vcomponents.CARRY8
     port map (
      CI => \FSM_sequential_curr_state_slave_reg[2]_i_30_n_0\,
      CI_TOP => '0',
      CO(7) => \Read_controller/next_state_slave214_in\,
      CO(6) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_1\,
      CO(5) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_2\,
      CO(4) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_3\,
      CO(3) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_4\,
      CO(2) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_5\,
      CO(1) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_6\,
      CO(0) => \FSM_sequential_curr_state_slave_reg[2]_i_9_n_7\,
      DI(7) => \FSM_sequential_curr_state_slave[2]_i_31_n_0\,
      DI(6) => \FSM_sequential_curr_state_slave[2]_i_32_n_0\,
      DI(5) => \FSM_sequential_curr_state_slave[2]_i_33_n_0\,
      DI(4) => \FSM_sequential_curr_state_slave[2]_i_34_n_0\,
      DI(3) => \FSM_sequential_curr_state_slave[2]_i_35_n_0\,
      DI(2) => \FSM_sequential_curr_state_slave[2]_i_36_n_0\,
      DI(1) => \FSM_sequential_curr_state_slave[2]_i_37_n_0\,
      DI(0) => \FSM_sequential_curr_state_slave[2]_i_38_n_0\,
      O(7 downto 0) => \NLW_FSM_sequential_curr_state_slave_reg[2]_i_9_O_UNCONNECTED\(7 downto 0),
      S(7) => \FSM_sequential_curr_state_slave[2]_i_39_n_0\,
      S(6) => \FSM_sequential_curr_state_slave[2]_i_40_n_0\,
      S(5) => \FSM_sequential_curr_state_slave[2]_i_41_n_0\,
      S(4) => \FSM_sequential_curr_state_slave[2]_i_42_n_0\,
      S(3) => \FSM_sequential_curr_state_slave[2]_i_43_n_0\,
      S(2) => \FSM_sequential_curr_state_slave[2]_i_44_n_0\,
      S(1) => \FSM_sequential_curr_state_slave[2]_i_45_n_0\,
      S(0) => \FSM_sequential_curr_state_slave[2]_i_46_n_0\
    );
M0_ARREADY_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \^sel_slave_ready\,
      I1 => \^ar_selected_slave\,
      O => M0_ARREADY
    );
M0_ARREADY_INST_0_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"CCFFAAF0CC00AAF0"
    )
        port map (
      I0 => S2_ARREADY,
      I1 => S3_ARREADY,
      I2 => S0_ARREADY,
      I3 => Sel_Master_araddr(31),
      I4 => \Sel_Master_araddr__0\(30),
      I5 => S1_ARREADY,
      O => \^sel_slave_ready\
    );
M0_ARREADY_INST_0_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => M1_ARADDR(31),
      I1 => \^ar_selected_slave\,
      I2 => M0_ARADDR(31),
      O => Sel_Master_araddr(31)
    );
M0_ARREADY_INST_0_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => M1_ARADDR(30),
      I1 => \^ar_selected_slave\,
      I2 => M0_ARADDR(30),
      O => \Sel_Master_araddr__0\(30)
    );
M1_ARREADY_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^ar_selected_slave\,
      I1 => \^sel_slave_ready\,
      O => M1_ARREADY
    );
\S0_ARADDR[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(0),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(0),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(0)
    );
\S0_ARADDR[10]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(10),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(10),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(10)
    );
\S0_ARADDR[11]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(11),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(11),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(11)
    );
\S0_ARADDR[12]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(12),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(12),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(12)
    );
\S0_ARADDR[13]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(13),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(13),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(13)
    );
\S0_ARADDR[14]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(14),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(14),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(14)
    );
\S0_ARADDR[15]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(15),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(15),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(15)
    );
\S0_ARADDR[16]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(16),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(16),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(16)
    );
\S0_ARADDR[17]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(17),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(17),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(17)
    );
\S0_ARADDR[18]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(18),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(18),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(18)
    );
\S0_ARADDR[19]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(19),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(19),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(19)
    );
\S0_ARADDR[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(1),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(1),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(1)
    );
\S0_ARADDR[20]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(20),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(20),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(20)
    );
\S0_ARADDR[21]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(21),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(21),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(21)
    );
\S0_ARADDR[22]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(22),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(22),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(22)
    );
\S0_ARADDR[23]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(23),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(23),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(23)
    );
\S0_ARADDR[24]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(24),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(24),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(24)
    );
\S0_ARADDR[25]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(25),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(25),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(25)
    );
\S0_ARADDR[26]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(26),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(26),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(26)
    );
\S0_ARADDR[27]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(27),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(27),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(27)
    );
\S0_ARADDR[28]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(28),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(28),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(28)
    );
\S0_ARADDR[29]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(29),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(29),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(29)
    );
\S0_ARADDR[29]_INST_0_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFACCFA"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \Selected_Master_reg[0]_rep_n_0\,
      I4 => M1_ARADDR(31),
      O => \S0_ARADDR[29]_INST_0_i_1_n_0\
    );
\S0_ARADDR[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(2),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(2),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(2)
    );
\S0_ARADDR[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(3),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(3),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(3)
    );
\S0_ARADDR[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(4),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(4),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(4)
    );
\S0_ARADDR[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(5),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(5),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(5)
    );
\S0_ARADDR[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(6),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(6),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(6)
    );
\S0_ARADDR[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(7),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(7),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(7)
    );
\S0_ARADDR[8]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(8),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(8),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(8)
    );
\S0_ARADDR[9]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARADDR(9),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARADDR(9),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARADDR(9)
    );
\S0_ARBURST[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARBURST(0),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARBURST(0),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARBURST(0)
    );
\S0_ARBURST[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARBURST(1),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARBURST(1),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARBURST(1)
    );
\S0_ARLEN[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(0),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(0),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(0)
    );
\S0_ARLEN[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(1),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(1),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(1)
    );
\S0_ARLEN[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(2),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(2),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(2)
    );
\S0_ARLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(3),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(3),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(3)
    );
\S0_ARLEN[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(4),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(4),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(4)
    );
\S0_ARLEN[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(5),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(5),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(5)
    );
\S0_ARLEN[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(6),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(6),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(6)
    );
\S0_ARLEN[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARLEN(7),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARLEN(7),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARLEN(7)
    );
\S0_ARSIZE[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARSIZE(0),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARSIZE(0),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARSIZE(0)
    );
\S0_ARSIZE[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARSIZE(1),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARSIZE(1),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARSIZE(1)
    );
\S0_ARSIZE[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARSIZE(2),
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARSIZE(2),
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARSIZE(2)
    );
S0_ARVALID_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"00E2"
    )
        port map (
      I0 => M0_ARVALID,
      I1 => \Selected_Master_reg[0]_rep_n_0\,
      I2 => M1_ARVALID,
      I3 => \S0_ARADDR[29]_INST_0_i_1_n_0\,
      O => S0_ARVALID
    );
\S1_ARADDR[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(0),
      O => S1_ARADDR(0)
    );
\S1_ARADDR[10]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(10),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(10),
      O => S1_ARADDR(10)
    );
\S1_ARADDR[11]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(11),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(11),
      O => S1_ARADDR(11)
    );
\S1_ARADDR[12]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(12),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(12),
      O => S1_ARADDR(12)
    );
\S1_ARADDR[13]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(13),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(13),
      O => S1_ARADDR(13)
    );
\S1_ARADDR[14]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(14),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(14),
      O => S1_ARADDR(14)
    );
\S1_ARADDR[15]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(15),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(15),
      O => S1_ARADDR(15)
    );
\S1_ARADDR[16]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(16),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(16),
      O => S1_ARADDR(16)
    );
\S1_ARADDR[17]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(17),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(17),
      O => S1_ARADDR(17)
    );
\S1_ARADDR[18]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(18),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(18),
      O => S1_ARADDR(18)
    );
\S1_ARADDR[19]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(19),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(19),
      O => S1_ARADDR(19)
    );
\S1_ARADDR[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(1),
      O => S1_ARADDR(1)
    );
\S1_ARADDR[20]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(20),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(20),
      O => S1_ARADDR(20)
    );
\S1_ARADDR[21]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(21),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(21),
      O => S1_ARADDR(21)
    );
\S1_ARADDR[22]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(22),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(22),
      O => S1_ARADDR(22)
    );
\S1_ARADDR[23]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(23),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(23),
      O => S1_ARADDR(23)
    );
\S1_ARADDR[24]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(24),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(24),
      O => S1_ARADDR(24)
    );
\S1_ARADDR[25]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(25),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(25),
      O => S1_ARADDR(25)
    );
\S1_ARADDR[26]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(26),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(26),
      O => S1_ARADDR(26)
    );
\S1_ARADDR[27]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(27),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(27),
      O => S1_ARADDR(27)
    );
\S1_ARADDR[28]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(28),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(28),
      O => S1_ARADDR(28)
    );
\S1_ARADDR[29]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(29),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(29),
      O => S1_ARADDR(29)
    );
\S1_ARADDR[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(2),
      O => S1_ARADDR(2)
    );
\S1_ARADDR[30]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \^ar_selected_slave\,
      I4 => M1_ARADDR(31),
      O => \^m0_araddr[30]_0\
    );
\S1_ARADDR[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(3),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(3),
      O => S1_ARADDR(3)
    );
\S1_ARADDR[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(4),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(4),
      O => S1_ARADDR(4)
    );
\S1_ARADDR[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(5),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(5),
      O => S1_ARADDR(5)
    );
\S1_ARADDR[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(6),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(6),
      O => S1_ARADDR(6)
    );
\S1_ARADDR[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(7),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(7),
      O => S1_ARADDR(7)
    );
\S1_ARADDR[8]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(8),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(8),
      O => S1_ARADDR(8)
    );
\S1_ARADDR[9]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARADDR(9),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(9),
      O => S1_ARADDR(9)
    );
\S1_ARBURST[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARBURST(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARBURST(0),
      O => S1_ARBURST(0)
    );
\S1_ARBURST[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARBURST(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARBURST(1),
      O => S1_ARBURST(1)
    );
\S1_ARLEN[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(0),
      O => S1_ARLEN(0)
    );
\S1_ARLEN[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(1),
      O => S1_ARLEN(1)
    );
\S1_ARLEN[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(2),
      O => S1_ARLEN(2)
    );
\S1_ARLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(3),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(3),
      O => S1_ARLEN(3)
    );
\S1_ARLEN[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(4),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(4),
      O => S1_ARLEN(4)
    );
\S1_ARLEN[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(5),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(5),
      O => S1_ARLEN(5)
    );
\S1_ARLEN[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(6),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(6),
      O => S1_ARLEN(6)
    );
\S1_ARLEN[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARLEN(7),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(7),
      O => S1_ARLEN(7)
    );
\S1_ARSIZE[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARSIZE(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(0),
      O => S1_ARSIZE(0)
    );
\S1_ARSIZE[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARSIZE(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(1),
      O => S1_ARSIZE(1)
    );
\S1_ARSIZE[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARSIZE(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(2),
      O => S1_ARSIZE(2)
    );
S1_ARVALID_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_0\,
      I1 => M0_ARVALID,
      I2 => \^ar_selected_slave\,
      I3 => M1_ARVALID,
      O => S1_ARVALID
    );
\S2_ARADDR[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(0),
      O => S2_ARADDR(0)
    );
\S2_ARADDR[10]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(10),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(10),
      O => S2_ARADDR(10)
    );
\S2_ARADDR[11]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(11),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(11),
      O => S2_ARADDR(11)
    );
\S2_ARADDR[12]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(12),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(12),
      O => S2_ARADDR(12)
    );
\S2_ARADDR[13]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(13),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(13),
      O => S2_ARADDR(13)
    );
\S2_ARADDR[14]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(14),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(14),
      O => S2_ARADDR(14)
    );
\S2_ARADDR[15]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(15),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(15),
      O => S2_ARADDR(15)
    );
\S2_ARADDR[16]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(16),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(16),
      O => S2_ARADDR(16)
    );
\S2_ARADDR[17]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(17),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(17),
      O => S2_ARADDR(17)
    );
\S2_ARADDR[18]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(18),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(18),
      O => S2_ARADDR(18)
    );
\S2_ARADDR[19]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(19),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(19),
      O => S2_ARADDR(19)
    );
\S2_ARADDR[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(1),
      O => S2_ARADDR(1)
    );
\S2_ARADDR[20]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(20),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(20),
      O => S2_ARADDR(20)
    );
\S2_ARADDR[21]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(21),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(21),
      O => S2_ARADDR(21)
    );
\S2_ARADDR[22]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(22),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(22),
      O => S2_ARADDR(22)
    );
\S2_ARADDR[23]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(23),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(23),
      O => S2_ARADDR(23)
    );
\S2_ARADDR[24]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(24),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(24),
      O => S2_ARADDR(24)
    );
\S2_ARADDR[25]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(25),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(25),
      O => S2_ARADDR(25)
    );
\S2_ARADDR[26]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(26),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(26),
      O => S2_ARADDR(26)
    );
\S2_ARADDR[27]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(27),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(27),
      O => S2_ARADDR(27)
    );
\S2_ARADDR[28]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(28),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(28),
      O => S2_ARADDR(28)
    );
\S2_ARADDR[29]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(29),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(29),
      O => S2_ARADDR(29)
    );
\S2_ARADDR[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(2),
      O => S2_ARADDR(2)
    );
\S2_ARADDR[31]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000ACC0A"
    )
        port map (
      I0 => M0_ARADDR(31),
      I1 => M1_ARADDR(31),
      I2 => M0_ARADDR(30),
      I3 => \^ar_selected_slave\,
      I4 => M1_ARADDR(30),
      O => M0_ARADDR_31_sn_1
    );
\S2_ARADDR[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(3),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(3),
      O => S2_ARADDR(3)
    );
\S2_ARADDR[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(4),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(4),
      O => S2_ARADDR(4)
    );
\S2_ARADDR[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(5),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(5),
      O => S2_ARADDR(5)
    );
\S2_ARADDR[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(6),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(6),
      O => S2_ARADDR(6)
    );
\S2_ARADDR[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(7),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(7),
      O => S2_ARADDR(7)
    );
\S2_ARADDR[8]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(8),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(8),
      O => S2_ARADDR(8)
    );
\S2_ARADDR[9]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARADDR(9),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(9),
      O => S2_ARADDR(9)
    );
\S2_ARBURST[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARBURST(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARBURST(0),
      O => S2_ARBURST(0)
    );
\S2_ARBURST[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARBURST(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARBURST(1),
      O => S2_ARBURST(1)
    );
\S2_ARLEN[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(0),
      O => S2_ARLEN(0)
    );
\S2_ARLEN[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(1),
      O => S2_ARLEN(1)
    );
\S2_ARLEN[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(2),
      O => S2_ARLEN(2)
    );
\S2_ARLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(3),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(3),
      O => S2_ARLEN(3)
    );
\S2_ARLEN[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(4),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(4),
      O => S2_ARLEN(4)
    );
\S2_ARLEN[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(5),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(5),
      O => S2_ARLEN(5)
    );
\S2_ARLEN[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(6),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(6),
      O => S2_ARLEN(6)
    );
\S2_ARLEN[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARLEN(7),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(7),
      O => S2_ARLEN(7)
    );
\S2_ARSIZE[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARSIZE(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(0),
      O => S2_ARSIZE(0)
    );
\S2_ARSIZE[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARSIZE(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(1),
      O => S2_ARSIZE(1)
    );
\S2_ARSIZE[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARSIZE(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(2),
      O => S2_ARSIZE(2)
    );
S2_ARVALID_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => M0_ARADDR_31_sn_1,
      I1 => M0_ARVALID,
      I2 => \^ar_selected_slave\,
      I3 => M1_ARVALID,
      O => S2_ARVALID
    );
\S3_ARADDR[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(0),
      O => S3_ARADDR(0)
    );
\S3_ARADDR[10]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(10),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(10),
      O => S3_ARADDR(10)
    );
\S3_ARADDR[11]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(11),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(11),
      O => S3_ARADDR(11)
    );
\S3_ARADDR[12]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(12),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(12),
      O => S3_ARADDR(12)
    );
\S3_ARADDR[13]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(13),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(13),
      O => S3_ARADDR(13)
    );
\S3_ARADDR[14]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(14),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(14),
      O => S3_ARADDR(14)
    );
\S3_ARADDR[15]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(15),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(15),
      O => S3_ARADDR(15)
    );
\S3_ARADDR[16]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(16),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(16),
      O => S3_ARADDR(16)
    );
\S3_ARADDR[17]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(17),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(17),
      O => S3_ARADDR(17)
    );
\S3_ARADDR[18]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(18),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(18),
      O => S3_ARADDR(18)
    );
\S3_ARADDR[19]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(19),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(19),
      O => S3_ARADDR(19)
    );
\S3_ARADDR[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(1),
      O => S3_ARADDR(1)
    );
\S3_ARADDR[20]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(20),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(20),
      O => S3_ARADDR(20)
    );
\S3_ARADDR[21]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(21),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(21),
      O => S3_ARADDR(21)
    );
\S3_ARADDR[22]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(22),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(22),
      O => S3_ARADDR(22)
    );
\S3_ARADDR[23]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(23),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(23),
      O => S3_ARADDR(23)
    );
\S3_ARADDR[24]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(24),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(24),
      O => S3_ARADDR(24)
    );
\S3_ARADDR[25]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(25),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(25),
      O => S3_ARADDR(25)
    );
\S3_ARADDR[26]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(26),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(26),
      O => S3_ARADDR(26)
    );
\S3_ARADDR[27]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(27),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(27),
      O => S3_ARADDR(27)
    );
\S3_ARADDR[28]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(28),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(28),
      O => S3_ARADDR(28)
    );
\S3_ARADDR[29]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(29),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(29),
      O => S3_ARADDR(29)
    );
\S3_ARADDR[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(2),
      O => S3_ARADDR(2)
    );
\S3_ARADDR[30]_INST_0\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"CCA000A0"
    )
        port map (
      I0 => M0_ARADDR(30),
      I1 => M1_ARADDR(30),
      I2 => M0_ARADDR(31),
      I3 => \^ar_selected_slave\,
      I4 => M1_ARADDR(31),
      O => \^m0_araddr[30]_1\
    );
\S3_ARADDR[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(3),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(3),
      O => S3_ARADDR(3)
    );
\S3_ARADDR[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(4),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(4),
      O => S3_ARADDR(4)
    );
\S3_ARADDR[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(5),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(5),
      O => S3_ARADDR(5)
    );
\S3_ARADDR[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(6),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(6),
      O => S3_ARADDR(6)
    );
\S3_ARADDR[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(7),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(7),
      O => S3_ARADDR(7)
    );
\S3_ARADDR[8]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(8),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(8),
      O => S3_ARADDR(8)
    );
\S3_ARADDR[9]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARADDR(9),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARADDR(9),
      O => S3_ARADDR(9)
    );
\S3_ARBURST[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARBURST(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARBURST(0),
      O => S3_ARBURST(0)
    );
\S3_ARBURST[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARBURST(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARBURST(1),
      O => S3_ARBURST(1)
    );
\S3_ARLEN[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(0),
      O => S3_ARLEN(0)
    );
\S3_ARLEN[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(1),
      O => S3_ARLEN(1)
    );
\S3_ARLEN[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(2),
      O => S3_ARLEN(2)
    );
\S3_ARLEN[3]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(3),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(3),
      O => S3_ARLEN(3)
    );
\S3_ARLEN[4]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(4),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(4),
      O => S3_ARLEN(4)
    );
\S3_ARLEN[5]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(5),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(5),
      O => S3_ARLEN(5)
    );
\S3_ARLEN[6]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(6),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(6),
      O => S3_ARLEN(6)
    );
\S3_ARLEN[7]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARLEN(7),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARLEN(7),
      O => S3_ARLEN(7)
    );
\S3_ARSIZE[0]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARSIZE(0),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(0),
      O => S3_ARSIZE(0)
    );
\S3_ARSIZE[1]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARSIZE(1),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(1),
      O => S3_ARSIZE(1)
    );
\S3_ARSIZE[2]_INST_0\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARSIZE(2),
      I2 => \^ar_selected_slave\,
      I3 => M1_ARSIZE(2),
      O => S3_ARSIZE(2)
    );
S3_ARVALID_INST_0: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => \^m0_araddr[30]_1\,
      I1 => M0_ARVALID,
      I2 => \^ar_selected_slave\,
      I3 => M1_ARVALID,
      O => S3_ARVALID
    );
\Selected_Master[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => M1_ARVALID,
      I1 => M0_ARVALID,
      I2 => AR_HandShake_Done,
      I3 => \^ar_selected_slave\,
      O => \Selected_Master[0]_i_1_n_0\
    );
\Selected_Master[0]_rep__0_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => M1_ARVALID,
      I1 => M0_ARVALID,
      I2 => AR_HandShake_Done,
      I3 => \^ar_selected_slave\,
      O => \Selected_Master[0]_rep__0_i_1_n_0\
    );
\Selected_Master[0]_rep__1_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => M1_ARVALID,
      I1 => M0_ARVALID,
      I2 => AR_HandShake_Done,
      I3 => \^ar_selected_slave\,
      O => \Selected_Master[0]_rep__1_i_1_n_0\
    );
\Selected_Master[0]_rep_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => M1_ARVALID,
      I1 => M0_ARVALID,
      I2 => AR_HandShake_Done,
      I3 => \^ar_selected_slave\,
      O => \Selected_Master[0]_rep_i_1_n_0\
    );
\Selected_Master_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Selected_Master_reg[0]_rep__1_0\,
      D => \Selected_Master[0]_i_1_n_0\,
      Q => \^ar_selected_slave\
    );
\Selected_Master_reg[0]_rep\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Selected_Master_reg[0]_rep__1_0\,
      D => \Selected_Master[0]_rep_i_1_n_0\,
      Q => \Selected_Master_reg[0]_rep_n_0\
    );
\Selected_Master_reg[0]_rep__0\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Selected_Master_reg[0]_rep__1_0\,
      D => \Selected_Master[0]_rep__0_i_1_n_0\,
      Q => \Selected_Master_reg[0]_rep__0_n_0\
    );
\Selected_Master_reg[0]_rep__1\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Selected_Master_reg[0]_rep__1_0\,
      D => \Selected_Master[0]_rep__1_i_1_n_0\,
      Q => \Selected_Master_reg[0]_rep__1_n_0\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_WD_HandShake is
  port (
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    HandShake_Done_reg_0 : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    HandShake_Done_reg_1 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_WD_HandShake : entity is "WD_HandShake";
end design_1_axi_interconnect_0_0_WD_HandShake;

architecture STRUCTURE of design_1_axi_interconnect_0_0_WD_HandShake is
begin
HandShake_Done_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => HandShake_Done_reg_1,
      D => HandShake_Done_reg_0,
      Q => E(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_WD_HandShake_1 is
  port (
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    HandShake_Done_reg_0 : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    HandShake_Done_reg_1 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_WD_HandShake_1 : entity is "WD_HandShake";
end design_1_axi_interconnect_0_0_WD_HandShake_1;

architecture STRUCTURE of design_1_axi_interconnect_0_0_WD_HandShake_1 is
begin
HandShake_Done_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => HandShake_Done_reg_1,
      D => HandShake_Done_reg_0,
      Q => E(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_WR_HandShake is
  port (
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    S0_BVALID : in STD_LOGIC;
    S1_BVALID : in STD_LOGIC;
    HandShake_Done_reg_0 : in STD_LOGIC;
    Virtual_M00_AXI_bvalid : in STD_LOGIC;
    Write_Data_Finsh : in STD_LOGIC;
    Write_Data_Finsh_prev : in STD_LOGIC;
    Channel_Request_From_Arb : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    HandShake_Done_reg_1 : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_WR_HandShake : entity is "WR_HandShake";
end design_1_axi_interconnect_0_0_WR_HandShake;

architecture STRUCTURE of design_1_axi_interconnect_0_0_WR_HandShake is
  signal HandShake_Done_i_1_n_0 : STD_LOGIC;
  signal Write_Res_HandShake_Done : STD_LOGIC;
begin
HandShake_Done_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"8888FF8F88888888"
    )
        port map (
      I0 => HandShake_Done_reg_0,
      I1 => Virtual_M00_AXI_bvalid,
      I2 => Write_Data_Finsh,
      I3 => Write_Data_Finsh_prev,
      I4 => Channel_Request_From_Arb,
      I5 => Write_Res_HandShake_Done,
      O => HandShake_Done_i_1_n_0
    );
HandShake_Done_reg: unisim.vcomponents.FDPE
     port map (
      C => ACLK,
      CE => '1',
      D => HandShake_Done_i_1_n_0,
      PRE => HandShake_Done_reg_1,
      Q => Write_Res_HandShake_Done
    );
\Sel_Write_Resp[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"FE"
    )
        port map (
      I0 => Write_Res_HandShake_Done,
      I1 => S0_BVALID,
      I2 => S1_BVALID,
      O => E(0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_Write_Resp_Channel_Arb is
  port (
    Channel_Request_From_Arb : out STD_LOGIC;
    Virtual_M00_AXI_bvalid : out STD_LOGIC;
    M1_BREADY_0 : out STD_LOGIC;
    M1_BVALID : out STD_LOGIC;
    M0_BVALID : out STD_LOGIC;
    S0_BREADY : out STD_LOGIC;
    S1_BREADY : out STD_LOGIC;
    M1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ACLK : in STD_LOGIC;
    \Sel_Write_Resp_reg[1]_0\ : in STD_LOGIC;
    E : in STD_LOGIC_VECTOR ( 0 to 0 );
    M1_BREADY : in STD_LOGIC;
    M0_BREADY : in STD_LOGIC;
    S1_BVALID : in STD_LOGIC;
    S0_BVALID : in STD_LOGIC;
    S0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_Write_Resp_Channel_Arb : entity is "Write_Resp_Channel_Arb";
end design_1_axi_interconnect_0_0_Write_Resp_Channel_Arb;

architecture STRUCTURE of design_1_axi_interconnect_0_0_Write_Resp_Channel_Arb is
  signal Sel_M_ID_Signal : STD_LOGIC;
  signal Sel_Resp_ID_Comb : STD_LOGIC;
  signal Sel_Valid_Comb : STD_LOGIC;
  signal Sel_Write_Resp_Comb : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal \^virtual_m00_axi_bvalid\ : STD_LOGIC;
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of Channel_Request_i_1 : label is "soft_lutpair98";
  attribute SOFT_HLUTNM of \HandShake_Done_i_2__2\ : label is "soft_lutpair100";
  attribute SOFT_HLUTNM of M1_BVALID_INST_0 : label is "soft_lutpair101";
  attribute SOFT_HLUTNM of S0_BREADY_INST_0 : label is "soft_lutpair101";
  attribute SOFT_HLUTNM of S1_BREADY_INST_0 : label is "soft_lutpair100";
  attribute SOFT_HLUTNM of \Sel_Resp_ID[0]_i_1\ : label is "soft_lutpair99";
  attribute SOFT_HLUTNM of \Sel_Write_Resp[0]_i_1\ : label is "soft_lutpair99";
  attribute SOFT_HLUTNM of \Sel_Write_Resp[1]_i_2\ : label is "soft_lutpair98";
begin
  Virtual_M00_AXI_bvalid <= \^virtual_m00_axi_bvalid\;
Channel_Request_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => S1_BVALID,
      I1 => S0_BVALID,
      O => Sel_Valid_Comb
    );
Channel_Request_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Sel_Write_Resp_reg[1]_0\,
      D => Sel_Valid_Comb,
      Q => Channel_Request_From_Arb
    );
\HandShake_Done_i_2__2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => M1_BREADY,
      I1 => Sel_M_ID_Signal,
      I2 => M0_BREADY,
      O => M1_BREADY_0
    );
M0_BVALID_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \^virtual_m00_axi_bvalid\,
      I1 => Sel_M_ID_Signal,
      O => M0_BVALID
    );
M1_BVALID_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \^virtual_m00_axi_bvalid\,
      I1 => Sel_M_ID_Signal,
      O => M1_BVALID
    );
S0_BREADY_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => M0_BREADY,
      I1 => Sel_M_ID_Signal,
      O => S0_BREADY
    );
S1_BREADY_INST_0: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => Sel_M_ID_Signal,
      I1 => M1_BREADY,
      O => S1_BREADY
    );
\Sel_Resp_ID[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => S1_BVALID,
      I1 => S0_BVALID,
      O => Sel_Resp_ID_Comb
    );
\Sel_Resp_ID_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \Sel_Write_Resp_reg[1]_0\,
      D => Sel_Resp_ID_Comb,
      Q => Sel_M_ID_Signal
    );
Sel_Valid_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \Sel_Write_Resp_reg[1]_0\,
      D => Sel_Valid_Comb,
      Q => \^virtual_m00_axi_bvalid\
    );
\Sel_Write_Resp[0]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"B888"
    )
        port map (
      I0 => S0_BRESP(0),
      I1 => S0_BVALID,
      I2 => S1_BVALID,
      I3 => S1_BRESP(0),
      O => Sel_Write_Resp_Comb(0)
    );
\Sel_Write_Resp[1]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"B888"
    )
        port map (
      I0 => S0_BRESP(1),
      I1 => S0_BVALID,
      I2 => S1_BVALID,
      I3 => S1_BRESP(1),
      O => Sel_Write_Resp_Comb(1)
    );
\Sel_Write_Resp_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \Sel_Write_Resp_reg[1]_0\,
      D => Sel_Write_Resp_Comb(0),
      Q => M1_BRESP(0)
    );
\Sel_Write_Resp_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => E(0),
      CLR => \Sel_Write_Resp_reg[1]_0\,
      D => Sel_Write_Resp_Comb(1),
      Q => M1_BRESP(1)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_AR_Channel_Controller_Top is
  port (
    S0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_ARVALID : out STD_LOGIC;
    S0_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    CO : out STD_LOGIC_VECTOR ( 0 to 0 );
    \M0_ARADDR[30]\ : out STD_LOGIC_VECTOR ( 0 to 0 );
    M1_ARREADY : out STD_LOGIC;
    M0_ARREADY : out STD_LOGIC;
    S0_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \M0_ARADDR[30]_0\ : out STD_LOGIC;
    S1_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_ARVALID : out STD_LOGIC;
    S1_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S1_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARADDR_31_sp_1 : out STD_LOGIC;
    S2_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_ARVALID : out STD_LOGIC;
    S2_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S2_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \M0_ARADDR[30]_1\ : out STD_LOGIC;
    S3_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_ARVALID : out STD_LOGIC;
    S3_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S3_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    D : out STD_LOGIC_VECTOR ( 1 downto 0 );
    next_state_slave119_out : out STD_LOGIC;
    \FSM_onehot_curr_state_slave2_reg[4]\ : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \FSM_sequential_curr_state_slave_reg[2]_i_8\ : out STD_LOGIC;
    S0_ARREADY_0 : out STD_LOGIC;
    M0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_ARVALID : in STD_LOGIC;
    M1_ARVALID : in STD_LOGIC;
    M0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_ARREADY : in STD_LOGIC;
    S3_ARREADY : in STD_LOGIC;
    S0_ARREADY : in STD_LOGIC;
    S1_ARREADY : in STD_LOGIC;
    M0_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    \FSM_sequential_curr_state_slave_reg[2]\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[1]\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[1]_0\ : in STD_LOGIC;
    \FSM_sequential_curr_state_slave_reg[2]_0\ : in STD_LOGIC;
    M0_RREADY : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 0 to 0 );
    \FSM_onehot_curr_state_slave2_reg[4]_0\ : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S2_RVALID : in STD_LOGIC;
    S2_RLAST : in STD_LOGIC;
    M1_RREADY : in STD_LOGIC;
    S1_RVALID : in STD_LOGIC;
    S1_RLAST : in STD_LOGIC;
    S3_RVALID : in STD_LOGIC;
    S3_RLAST : in STD_LOGIC;
    ACLK : in STD_LOGIC;
    \Selected_Master_reg[0]_rep__1\ : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_AR_Channel_Controller_Top : entity is "AR_Channel_Controller_Top";
end design_1_axi_interconnect_0_0_AR_Channel_Controller_Top;

architecture STRUCTURE of design_1_axi_interconnect_0_0_AR_Channel_Controller_Top is
  signal AR_HandShake_Done : STD_LOGIC;
  signal AR_Selected_Slave : STD_LOGIC;
  signal M0_ARADDR_31_sn_1 : STD_LOGIC;
  signal Sel_Slave_Ready : STD_LOGIC;
begin
  M0_ARADDR_31_sp_1 <= M0_ARADDR_31_sn_1;
u_AR_HandShake_Checker: entity work.design_1_axi_interconnect_0_0_AW_HandShake_Checker_2
     port map (
      ACLK => ACLK,
      AR_HandShake_Done => AR_HandShake_Done,
      AR_Selected_Slave => AR_Selected_Slave,
      HandShake_Done_reg_0 => \Selected_Master_reg[0]_rep__1\,
      M0_ARVALID => M0_ARVALID,
      M1_ARVALID => M1_ARVALID,
      Sel_Slave_Ready => Sel_Slave_Ready
    );
u_Read_Arbiter: entity work.design_1_axi_interconnect_0_0_Read_Arbiter
     port map (
      ACLK => ACLK,
      AR_HandShake_Done => AR_HandShake_Done,
      AR_Selected_Slave => AR_Selected_Slave,
      CO(0) => CO(0),
      D(1 downto 0) => D(1 downto 0),
      \FSM_onehot_curr_state_slave2_reg[4]\(2 downto 0) => \FSM_onehot_curr_state_slave2_reg[4]\(2 downto 0),
      \FSM_onehot_curr_state_slave2_reg[4]_0\(3 downto 0) => \FSM_onehot_curr_state_slave2_reg[4]_0\(3 downto 0),
      \FSM_sequential_curr_state_slave_reg[1]\ => \FSM_sequential_curr_state_slave_reg[1]\,
      \FSM_sequential_curr_state_slave_reg[1]_0\ => \FSM_sequential_curr_state_slave_reg[1]_0\,
      \FSM_sequential_curr_state_slave_reg[2]\ => \FSM_sequential_curr_state_slave_reg[2]\,
      \FSM_sequential_curr_state_slave_reg[2]_0\ => \FSM_sequential_curr_state_slave_reg[2]_0\,
      \FSM_sequential_curr_state_slave_reg[2]_i_8_0\ => \FSM_sequential_curr_state_slave_reg[2]_i_8\,
      M0_ARADDR(31 downto 0) => M0_ARADDR(31 downto 0),
      \M0_ARADDR[30]\(0) => \M0_ARADDR[30]\(0),
      \M0_ARADDR[30]_0\ => \M0_ARADDR[30]_0\,
      \M0_ARADDR[30]_1\ => \M0_ARADDR[30]_1\,
      M0_ARADDR_31_sp_1 => M0_ARADDR_31_sn_1,
      M0_ARBURST(1 downto 0) => M0_ARBURST(1 downto 0),
      M0_ARLEN(7 downto 0) => M0_ARLEN(7 downto 0),
      M0_ARREADY => M0_ARREADY,
      M0_ARSIZE(2 downto 0) => M0_ARSIZE(2 downto 0),
      M0_ARVALID => M0_ARVALID,
      M0_RREADY => M0_RREADY,
      M1_ARADDR(31 downto 0) => M1_ARADDR(31 downto 0),
      M1_ARBURST(1 downto 0) => M1_ARBURST(1 downto 0),
      M1_ARLEN(7 downto 0) => M1_ARLEN(7 downto 0),
      M1_ARREADY => M1_ARREADY,
      M1_ARSIZE(2 downto 0) => M1_ARSIZE(2 downto 0),
      M1_ARVALID => M1_ARVALID,
      M1_RREADY => M1_RREADY,
      Q(0) => Q(0),
      S0_ARADDR(29 downto 0) => S0_ARADDR(29 downto 0),
      S0_ARBURST(1 downto 0) => S0_ARBURST(1 downto 0),
      S0_ARLEN(7 downto 0) => S0_ARLEN(7 downto 0),
      S0_ARREADY => S0_ARREADY,
      S0_ARREADY_0 => S0_ARREADY_0,
      S0_ARSIZE(2 downto 0) => S0_ARSIZE(2 downto 0),
      S0_ARVALID => S0_ARVALID,
      S1_ARADDR(29 downto 0) => S1_ARADDR(29 downto 0),
      S1_ARBURST(1 downto 0) => S1_ARBURST(1 downto 0),
      S1_ARLEN(7 downto 0) => S1_ARLEN(7 downto 0),
      S1_ARREADY => S1_ARREADY,
      S1_ARSIZE(2 downto 0) => S1_ARSIZE(2 downto 0),
      S1_ARVALID => S1_ARVALID,
      S1_RLAST => S1_RLAST,
      S1_RVALID => S1_RVALID,
      S2_ARADDR(29 downto 0) => S2_ARADDR(29 downto 0),
      S2_ARBURST(1 downto 0) => S2_ARBURST(1 downto 0),
      S2_ARLEN(7 downto 0) => S2_ARLEN(7 downto 0),
      S2_ARREADY => S2_ARREADY,
      S2_ARSIZE(2 downto 0) => S2_ARSIZE(2 downto 0),
      S2_ARVALID => S2_ARVALID,
      S2_RLAST => S2_RLAST,
      S2_RVALID => S2_RVALID,
      S3_ARADDR(29 downto 0) => S3_ARADDR(29 downto 0),
      S3_ARBURST(1 downto 0) => S3_ARBURST(1 downto 0),
      S3_ARLEN(7 downto 0) => S3_ARLEN(7 downto 0),
      S3_ARREADY => S3_ARREADY,
      S3_ARSIZE(2 downto 0) => S3_ARSIZE(2 downto 0),
      S3_ARVALID => S3_ARVALID,
      S3_RLAST => S3_RLAST,
      S3_RVALID => S3_RVALID,
      Sel_Slave_Ready => Sel_Slave_Ready,
      \Selected_Master_reg[0]_rep__1_0\ => \Selected_Master_reg[0]_rep__1\,
      next_state_slave119_out => next_state_slave119_out
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_AW_Channel_Controller_Top is
  port (
    S1_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWADDR_30_sp_1 : out STD_LOGIC;
    S1_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_AWVALID : out STD_LOGIC;
    S1_AWADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S1_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    M1_AWREADY : out STD_LOGIC;
    M0_AWREADY : out STD_LOGIC;
    Falling_reg : out STD_LOGIC_VECTOR ( 0 to 0 );
    S0_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_AWADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S0_AWVALID : out STD_LOGIC;
    S0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \Selected_Slave_reg[0]\ : out STD_LOGIC;
    \Selected_Slave_reg[0]_0\ : out STD_LOGIC;
    \Selected_Slave_reg[0]_1\ : out STD_LOGIC;
    \Selected_Slave_reg[0]_2\ : out STD_LOGIC;
    ACLK : in STD_LOGIC;
    \Selected_Slave_reg[0]_3\ : in STD_LOGIC;
    M0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_AWVALID : in STD_LOGIC;
    M1_AWVALID : in STD_LOGIC;
    M0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_AWREADY : in STD_LOGIC;
    S1_AWREADY : in STD_LOGIC;
    Q : in STD_LOGIC_VECTOR ( 0 to 0 );
    \Queue_reg[0]_0\ : in STD_LOGIC;
    \Queue_reg[1]_1\ : in STD_LOGIC;
    \Queue_reg[1][0]\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    \Queue_reg[0][0]\ : in STD_LOGIC;
    \Queue_reg[1][0]_0\ : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_AW_Channel_Controller_Top : entity is "AW_Channel_Controller_Top";
end design_1_axi_interconnect_0_0_AW_Channel_Controller_Top;

architecture STRUCTURE of design_1_axi_interconnect_0_0_AW_Channel_Controller_Top is
  signal AW_Access_Grant : STD_LOGIC;
  signal AW_HandShake_Done : STD_LOGIC;
  signal AW_Selected_Slave : STD_LOGIC;
  signal HandShake_Done3 : STD_LOGIC;
  signal M0_AWADDR_30_sn_1 : STD_LOGIC;
begin
  M0_AWADDR_30_sp_1 <= M0_AWADDR_30_sn_1;
u_Address_Write_HandShake_Checker: entity work.design_1_axi_interconnect_0_0_AW_HandShake_Checker
     port map (
      ACLK => ACLK,
      AW_HandShake_Done => AW_HandShake_Done,
      HandShake_Done3 => HandShake_Done3,
      HandShake_Done_reg_0 => \Selected_Slave_reg[0]_3\
    );
u_Faling_Edge_Detc: entity work.design_1_axi_interconnect_0_0_Faling_Edge_Detc
     port map (
      ACLK => ACLK,
      AW_Access_Grant => AW_Access_Grant,
      AW_HandShake_Done => AW_HandShake_Done,
      AW_Selected_Slave => AW_Selected_Slave,
      Falling_reg_0(0) => Falling_reg(0),
      M0_AWADDR(1 downto 0) => M0_AWADDR(31 downto 30),
      M1_AWADDR(1 downto 0) => M1_AWADDR(31 downto 30),
      reg_Test_Signal_reg_0 => \Selected_Slave_reg[0]_3\
    );
u_Qos_Arbiter: entity work.design_1_axi_interconnect_0_0_Qos_Arbiter
     port map (
      ACLK => ACLK,
      AW_Access_Grant => AW_Access_Grant,
      AW_Selected_Slave => AW_Selected_Slave,
      E(0) => E(0),
      HandShake_Done3 => HandShake_Done3,
      M0_AWADDR(31 downto 0) => M0_AWADDR(31 downto 0),
      M0_AWADDR_30_sp_1 => M0_AWADDR_30_sn_1,
      M0_AWBURST(1 downto 0) => M0_AWBURST(1 downto 0),
      M0_AWLEN(7 downto 0) => M0_AWLEN(7 downto 0),
      M0_AWREADY => M0_AWREADY,
      M0_AWSIZE(2 downto 0) => M0_AWSIZE(2 downto 0),
      M0_AWVALID => M0_AWVALID,
      M1_AWADDR(31 downto 0) => M1_AWADDR(31 downto 0),
      M1_AWBURST(1 downto 0) => M1_AWBURST(1 downto 0),
      M1_AWLEN(7 downto 0) => M1_AWLEN(7 downto 0),
      M1_AWREADY => M1_AWREADY,
      M1_AWSIZE(2 downto 0) => M1_AWSIZE(2 downto 0),
      M1_AWVALID => M1_AWVALID,
      Q(0) => Q(0),
      \Queue_reg[0][0]\ => \Queue_reg[0][0]\,
      \Queue_reg[0]_0\ => \Queue_reg[0]_0\,
      \Queue_reg[1][0]\(0) => \Queue_reg[1][0]\(0),
      \Queue_reg[1][0]_0\ => \Queue_reg[1][0]_0\,
      \Queue_reg[1]_1\ => \Queue_reg[1]_1\,
      S0_AWADDR(29 downto 0) => S0_AWADDR(29 downto 0),
      S0_AWBURST(1 downto 0) => S0_AWBURST(1 downto 0),
      S0_AWLEN(7 downto 0) => S0_AWLEN(7 downto 0),
      S0_AWREADY => S0_AWREADY,
      S0_AWSIZE(2 downto 0) => S0_AWSIZE(2 downto 0),
      S0_AWVALID => S0_AWVALID,
      S1_AWADDR(29 downto 0) => S1_AWADDR(29 downto 0),
      S1_AWBURST(1 downto 0) => S1_AWBURST(1 downto 0),
      S1_AWLEN(7 downto 0) => S1_AWLEN(7 downto 0),
      S1_AWREADY => S1_AWREADY,
      S1_AWSIZE(2 downto 0) => S1_AWSIZE(2 downto 0),
      S1_AWVALID => S1_AWVALID,
      \Selected_Slave_reg[0]_0\ => \Selected_Slave_reg[0]\,
      \Selected_Slave_reg[0]_1\ => \Selected_Slave_reg[0]_0\,
      \Selected_Slave_reg[0]_2\ => \Selected_Slave_reg[0]_1\,
      \Selected_Slave_reg[0]_3\ => \Selected_Slave_reg[0]_2\,
      \Selected_Slave_reg[0]_4\ => \Selected_Slave_reg[0]_3\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_BR_Channel_Controller_Top is
  port (
    M1_BVALID : out STD_LOGIC;
    M0_BVALID : out STD_LOGIC;
    S0_BREADY : out STD_LOGIC;
    S1_BREADY : out STD_LOGIC;
    M1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ACLK : in STD_LOGIC;
    \Sel_Write_Resp_reg[1]\ : in STD_LOGIC;
    Write_Data_Finsh : in STD_LOGIC;
    M1_BREADY : in STD_LOGIC;
    M0_BREADY : in STD_LOGIC;
    S0_BVALID : in STD_LOGIC;
    S1_BVALID : in STD_LOGIC;
    S0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_BR_Channel_Controller_Top : entity is "BR_Channel_Controller_Top";
end design_1_axi_interconnect_0_0_BR_Channel_Controller_Top;

architecture STRUCTURE of design_1_axi_interconnect_0_0_BR_Channel_Controller_Top is
  signal Channel_Request_From_Arb : STD_LOGIC;
  signal Virtual_M00_AXI_bvalid : STD_LOGIC;
  signal Write_Data_Finsh_prev : STD_LOGIC;
  signal u_WR_HandShake_n_0 : STD_LOGIC;
  signal u_Write_Resp_Channel_Arb_n_2 : STD_LOGIC;
begin
Write_Data_Finsh_prev_reg: unisim.vcomponents.FDCE
     port map (
      C => ACLK,
      CE => '1',
      CLR => \Sel_Write_Resp_reg[1]\,
      D => Write_Data_Finsh,
      Q => Write_Data_Finsh_prev
    );
u_WR_HandShake: entity work.design_1_axi_interconnect_0_0_WR_HandShake
     port map (
      ACLK => ACLK,
      Channel_Request_From_Arb => Channel_Request_From_Arb,
      E(0) => u_WR_HandShake_n_0,
      HandShake_Done_reg_0 => u_Write_Resp_Channel_Arb_n_2,
      HandShake_Done_reg_1 => \Sel_Write_Resp_reg[1]\,
      S0_BVALID => S0_BVALID,
      S1_BVALID => S1_BVALID,
      Virtual_M00_AXI_bvalid => Virtual_M00_AXI_bvalid,
      Write_Data_Finsh => Write_Data_Finsh,
      Write_Data_Finsh_prev => Write_Data_Finsh_prev
    );
u_Write_Resp_Channel_Arb: entity work.design_1_axi_interconnect_0_0_Write_Resp_Channel_Arb
     port map (
      ACLK => ACLK,
      Channel_Request_From_Arb => Channel_Request_From_Arb,
      E(0) => u_WR_HandShake_n_0,
      M0_BREADY => M0_BREADY,
      M0_BVALID => M0_BVALID,
      M1_BREADY => M1_BREADY,
      M1_BREADY_0 => u_Write_Resp_Channel_Arb_n_2,
      M1_BRESP(1 downto 0) => M1_BRESP(1 downto 0),
      M1_BVALID => M1_BVALID,
      S0_BREADY => S0_BREADY,
      S0_BRESP(1 downto 0) => S0_BRESP(1 downto 0),
      S0_BVALID => S0_BVALID,
      S1_BREADY => S1_BREADY,
      S1_BRESP(1 downto 0) => S1_BRESP(1 downto 0),
      S1_BVALID => S1_BVALID,
      \Sel_Write_Resp_reg[1]_0\ => \Sel_Write_Resp_reg[1]\,
      Virtual_M00_AXI_bvalid => Virtual_M00_AXI_bvalid
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_WD_Channel_Controller_Top is
  port (
    E : out STD_LOGIC_VECTOR ( 0 to 0 );
    ARESETN_0 : out STD_LOGIC;
    \Queue_reg[0]_0\ : out STD_LOGIC;
    \Queue_reg[1]_1\ : out STD_LOGIC;
    \Queue_reg[0][0]\ : out STD_LOGIC;
    \Queue_reg[1][0]\ : out STD_LOGIC;
    S0_WVALID : out STD_LOGIC;
    S0_WLAST : out STD_LOGIC;
    Q : out STD_LOGIC_VECTOR ( 0 to 0 );
    S1_WVALID : out STD_LOGIC;
    S1_WLAST : out STD_LOGIC;
    \Write_Pointer_reg[0]\ : out STD_LOGIC_VECTOR ( 0 to 0 );
    S0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WREADY : out STD_LOGIC;
    M0_WREADY : out STD_LOGIC;
    S1_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    ACLK : in STD_LOGIC;
    \Queue_reg[0][0]_0\ : in STD_LOGIC;
    \Queue_reg[1][0]_0\ : in STD_LOGIC;
    \Queue_reg[0][0]_1\ : in STD_LOGIC;
    \Queue_reg[1][0]_1\ : in STD_LOGIC;
    M0_WVALID : in STD_LOGIC;
    M1_WVALID : in STD_LOGIC;
    S0_WREADY : in STD_LOGIC;
    S1_WREADY : in STD_LOGIC;
    M1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WLAST : in STD_LOGIC;
    M0_WLAST : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    \Write_Pointer_reg[0]_0\ : in STD_LOGIC_VECTOR ( 0 to 0 );
    \Write_Pointer_reg[0]_1\ : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_WD_Channel_Controller_Top : entity is "WD_Channel_Controller_Top";
end design_1_axi_interconnect_0_0_WD_Channel_Controller_Top;

architecture STRUCTURE of design_1_axi_interconnect_0_0_WD_Channel_Controller_Top is
  signal \^aresetn_0\ : STD_LOGIC;
  signal \^e\ : STD_LOGIC_VECTOR ( 0 to 0 );
  signal u_Queue2_n_4 : STD_LOGIC;
  signal u_Queue_n_3 : STD_LOGIC;
  signal u_Queue_n_42 : STD_LOGIC;
  signal u_WD_HandShake2_n_0 : STD_LOGIC;
begin
  ARESETN_0 <= \^aresetn_0\;
  E(0) <= \^e\(0);
u_Queue: entity work.design_1_axi_interconnect_0_0_Queue
     port map (
      ACLK => ACLK,
      E(0) => \^e\(0),
      HandShake_Done_reg => u_Queue_n_3,
      M0_WDATA(31 downto 0) => M0_WDATA(31 downto 0),
      M0_WLAST => M0_WLAST,
      M0_WSTRB(3 downto 0) => M0_WSTRB(3 downto 0),
      M0_WVALID => M0_WVALID,
      M1_WDATA(31 downto 0) => M1_WDATA(31 downto 0),
      M1_WLAST => M1_WLAST,
      M1_WSTRB(3 downto 0) => M1_WSTRB(3 downto 0),
      M1_WVALID => M1_WVALID,
      Q(0) => Q(0),
      \Queue_reg[0][0]_0\ => \Queue_reg[0]_0\,
      \Queue_reg[0][0]_1\ => \Queue_reg[0][0]_0\,
      \Queue_reg[1][0]_0\ => \Queue_reg[1]_1\,
      \Queue_reg[1][0]_1\ => u_Queue_n_42,
      \Queue_reg[1][0]_2\ => \^aresetn_0\,
      \Queue_reg[1][0]_3\ => \Queue_reg[1][0]_0\,
      S0_WDATA(31 downto 0) => S0_WDATA(31 downto 0),
      S0_WLAST => S0_WLAST,
      S0_WREADY => S0_WREADY,
      S0_WSTRB(3 downto 0) => S0_WSTRB(3 downto 0),
      S0_WVALID => S0_WVALID,
      \Write_Pointer_reg[0]_0\(0) => \Write_Pointer_reg[0]_0\(0)
    );
u_Queue2: entity work.design_1_axi_interconnect_0_0_Queue_0
     port map (
      ACLK => ACLK,
      ARESETN => ARESETN,
      ARESETN_0 => \^aresetn_0\,
      E(0) => u_WD_HandShake2_n_0,
      HandShake_Done_reg => u_Queue2_n_4,
      M0_WDATA(31 downto 0) => M0_WDATA(31 downto 0),
      M0_WLAST => M0_WLAST,
      M0_WREADY => M0_WREADY,
      M0_WSTRB(3 downto 0) => M0_WSTRB(3 downto 0),
      M0_WVALID => M0_WVALID,
      M1_WDATA(31 downto 0) => M1_WDATA(31 downto 0),
      M1_WLAST => M1_WLAST,
      M1_WREADY => M1_WREADY,
      M1_WREADY_0 => u_Queue_n_42,
      M1_WSTRB(3 downto 0) => M1_WSTRB(3 downto 0),
      M1_WVALID => M1_WVALID,
      Q(0) => \Write_Pointer_reg[0]\(0),
      \Queue_reg[0][0]_0\ => \Queue_reg[0][0]\,
      \Queue_reg[0][0]_1\ => \Queue_reg[0][0]_1\,
      \Queue_reg[1][0]_0\ => \Queue_reg[1][0]\,
      \Queue_reg[1][0]_1\ => \Queue_reg[1][0]_1\,
      S0_WREADY => S0_WREADY,
      S1_WDATA(31 downto 0) => S1_WDATA(31 downto 0),
      S1_WLAST => S1_WLAST,
      S1_WREADY => S1_WREADY,
      S1_WSTRB(3 downto 0) => S1_WSTRB(3 downto 0),
      S1_WVALID => S1_WVALID,
      \Write_Pointer_reg[0]_0\(0) => \Write_Pointer_reg[0]_1\(0)
    );
u_WD_HandShake: entity work.design_1_axi_interconnect_0_0_WD_HandShake
     port map (
      ACLK => ACLK,
      E(0) => \^e\(0),
      HandShake_Done_reg_0 => u_Queue_n_3,
      HandShake_Done_reg_1 => \^aresetn_0\
    );
u_WD_HandShake2: entity work.design_1_axi_interconnect_0_0_WD_HandShake_1
     port map (
      ACLK => ACLK,
      E(0) => u_WD_HandShake2_n_0,
      HandShake_Done_reg_0 => u_Queue2_n_4,
      HandShake_Done_reg_1 => \^aresetn_0\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_AXI_Interconnect_Full is
  port (
    S1_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWADDR_30_sp_1 : out STD_LOGIC;
    S1_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_AWVALID : out STD_LOGIC;
    S1_AWADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S1_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_ARVALID : out STD_LOGIC;
    S0_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    M1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWREADY : out STD_LOGIC;
    M0_AWREADY : out STD_LOGIC;
    S0_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_AWADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S0_AWVALID : out STD_LOGIC;
    S0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_WVALID : out STD_LOGIC;
    S0_WLAST : out STD_LOGIC;
    S1_WVALID : out STD_LOGIC;
    S1_WLAST : out STD_LOGIC;
    S0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WREADY : out STD_LOGIC;
    M0_WREADY : out STD_LOGIC;
    S1_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_BVALID : out STD_LOGIC;
    M0_BVALID : out STD_LOGIC;
    S0_BREADY : out STD_LOGIC;
    S1_BREADY : out STD_LOGIC;
    M1_ARREADY : out STD_LOGIC;
    M0_ARREADY : out STD_LOGIC;
    S0_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARADDR_30_sp_1 : out STD_LOGIC;
    S1_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_ARVALID : out STD_LOGIC;
    S1_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S1_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARADDR_31_sp_1 : out STD_LOGIC;
    S2_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_ARVALID : out STD_LOGIC;
    S2_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S2_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    \M0_ARADDR[30]_0\ : out STD_LOGIC;
    S3_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_ARVALID : out STD_LOGIC;
    S3_ARADDR : out STD_LOGIC_VECTOR ( 29 downto 0 );
    S3_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_RLAST : out STD_LOGIC;
    M0_RVALID : out STD_LOGIC;
    S2_RREADY : out STD_LOGIC;
    S1_RREADY : out STD_LOGIC;
    S0_RREADY : out STD_LOGIC;
    M1_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_RLAST : out STD_LOGIC;
    M1_RVALID : out STD_LOGIC;
    S3_RREADY : out STD_LOGIC;
    M0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_AWVALID : in STD_LOGIC;
    M1_AWVALID : in STD_LOGIC;
    M0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_ARVALID : in STD_LOGIC;
    M1_ARVALID : in STD_LOGIC;
    M0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ACLK : in STD_LOGIC;
    S0_AWREADY : in STD_LOGIC;
    S1_AWREADY : in STD_LOGIC;
    M0_WVALID : in STD_LOGIC;
    M1_WVALID : in STD_LOGIC;
    S0_WREADY : in STD_LOGIC;
    S1_WREADY : in STD_LOGIC;
    M1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WLAST : in STD_LOGIC;
    M0_WLAST : in STD_LOGIC;
    M1_BREADY : in STD_LOGIC;
    M0_BREADY : in STD_LOGIC;
    S0_BVALID : in STD_LOGIC;
    S1_BVALID : in STD_LOGIC;
    S0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_ARREADY : in STD_LOGIC;
    S3_ARREADY : in STD_LOGIC;
    S0_ARREADY : in STD_LOGIC;
    S1_ARREADY : in STD_LOGIC;
    M0_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_RREADY : in STD_LOGIC;
    S1_RLAST : in STD_LOGIC;
    S1_RVALID : in STD_LOGIC;
    S2_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_RLAST : in STD_LOGIC;
    S3_RLAST : in STD_LOGIC;
    S0_RLAST : in STD_LOGIC;
    S2_RVALID : in STD_LOGIC;
    S3_RVALID : in STD_LOGIC;
    S0_RVALID : in STD_LOGIC;
    M1_RREADY : in STD_LOGIC;
    ARESETN : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_AXI_Interconnect_Full : entity is "AXI_Interconnect_Full";
end design_1_axi_interconnect_0_0_AXI_Interconnect_Full;

architecture STRUCTURE of design_1_axi_interconnect_0_0_AXI_Interconnect_Full is
  signal AW_Access_Grant0 : STD_LOGIC;
  signal AW_Access_Grant00_out : STD_LOGIC;
  signal M0_ARADDR_30_sn_1 : STD_LOGIC;
  signal M0_ARADDR_31_sn_1 : STD_LOGIC;
  signal M0_AWADDR_30_sn_1 : STD_LOGIC;
  signal \Queue_reg[0]_0\ : STD_LOGIC;
  signal \Queue_reg[1]_1\ : STD_LOGIC;
  signal Read_controller_n_0 : STD_LOGIC;
  signal Read_controller_n_41 : STD_LOGIC;
  signal Read_controller_n_45 : STD_LOGIC;
  signal Read_controller_n_46 : STD_LOGIC;
  signal Read_controller_n_83 : STD_LOGIC;
  signal Write_Data_Finsh : STD_LOGIC;
  signal curr_state_slave : STD_LOGIC_VECTOR ( 2 to 2 );
  signal en_S1_M1 : STD_LOGIC;
  signal en_S2_M1 : STD_LOGIC;
  signal en_S3_M1 : STD_LOGIC;
  signal next_state_slave119_out : STD_LOGIC;
  signal next_state_slave217_in : STD_LOGIC;
  signal next_state_slave218_in : STD_LOGIC;
  signal \next_state_slave__0\ : STD_LOGIC_VECTOR ( 2 downto 1 );
  signal u_AR_Channel_Controller_Top_n_186 : STD_LOGIC;
  signal u_AR_Channel_Controller_Top_n_187 : STD_LOGIC;
  signal u_AR_Channel_Controller_Top_n_188 : STD_LOGIC;
  signal u_AR_Channel_Controller_Top_n_189 : STD_LOGIC;
  signal u_AR_Channel_Controller_Top_n_190 : STD_LOGIC;
  signal u_AW_Channel_Controller_Top_n_93 : STD_LOGIC;
  signal u_AW_Channel_Controller_Top_n_94 : STD_LOGIC;
  signal u_AW_Channel_Controller_Top_n_95 : STD_LOGIC;
  signal u_AW_Channel_Controller_Top_n_96 : STD_LOGIC;
  signal u_WD_Channel_Controller_Top_n_1 : STD_LOGIC;
  signal u_WD_Channel_Controller_Top_n_11 : STD_LOGIC;
  signal u_WD_Channel_Controller_Top_n_4 : STD_LOGIC;
  signal u_WD_Channel_Controller_Top_n_5 : STD_LOGIC;
  signal u_WD_Channel_Controller_Top_n_8 : STD_LOGIC;
begin
  M0_ARADDR_30_sp_1 <= M0_ARADDR_30_sn_1;
  M0_ARADDR_31_sp_1 <= M0_ARADDR_31_sn_1;
  M0_AWADDR_30_sp_1 <= M0_AWADDR_30_sn_1;
Read_controller: entity work.design_1_axi_interconnect_0_0_Controller
     port map (
      ACLK => ACLK,
      CO(0) => next_state_slave217_in,
      D(1 downto 0) => \next_state_slave__0\(2 downto 1),
      \FSM_onehot_curr_state_slave2_reg[0]_0\ => u_WD_Channel_Controller_Top_n_1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(3) => en_S3_M1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(2) => en_S2_M1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(1) => en_S1_M1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(0) => Read_controller_n_41,
      \FSM_onehot_curr_state_slave2_reg[4]_1\(2) => u_AR_Channel_Controller_Top_n_186,
      \FSM_onehot_curr_state_slave2_reg[4]_1\(1) => u_AR_Channel_Controller_Top_n_187,
      \FSM_onehot_curr_state_slave2_reg[4]_1\(0) => u_AR_Channel_Controller_Top_n_188,
      \FSM_sequential_curr_state_slave_reg[0]_0\ => Read_controller_n_0,
      \FSM_sequential_curr_state_slave_reg[0]_1\ => Read_controller_n_45,
      \FSM_sequential_curr_state_slave_reg[0]_2\ => Read_controller_n_46,
      \FSM_sequential_curr_state_slave_reg[0]_3\(0) => next_state_slave218_in,
      \FSM_sequential_curr_state_slave_reg[0]_4\ => u_AR_Channel_Controller_Top_n_189,
      \FSM_sequential_curr_state_slave_reg[0]_5\ => u_AR_Channel_Controller_Top_n_190,
      M0_ARVALID => M0_ARVALID,
      M0_RDATA(31 downto 0) => M0_RDATA(31 downto 0),
      M0_RLAST => M0_RLAST,
      M0_RREADY => M0_RREADY,
      M0_RRESP(1 downto 0) => M0_RRESP(1 downto 0),
      M0_RVALID => M0_RVALID,
      M1_ARVALID => M1_ARVALID,
      M1_RDATA(31 downto 0) => M1_RDATA(31 downto 0),
      M1_RLAST => M1_RLAST,
      M1_RREADY => M1_RREADY,
      M1_RRESP(1 downto 0) => M1_RRESP(1 downto 0),
      M1_RVALID => M1_RVALID,
      Q(0) => curr_state_slave(2),
      S0_RDATA(31 downto 0) => S0_RDATA(31 downto 0),
      S0_RLAST => S0_RLAST,
      S0_RREADY => S0_RREADY,
      S0_RRESP(1 downto 0) => S0_RRESP(1 downto 0),
      S0_RVALID => S0_RVALID,
      S1_RDATA(31 downto 0) => S1_RDATA(31 downto 0),
      S1_RLAST => S1_RLAST,
      S1_RREADY => S1_RREADY,
      S1_RRESP(1 downto 0) => S1_RRESP(1 downto 0),
      S1_RVALID => S1_RVALID,
      S2_RDATA(31 downto 0) => S2_RDATA(31 downto 0),
      S2_RLAST => S2_RLAST,
      S2_RREADY => S2_RREADY,
      S2_RRESP(1 downto 0) => S2_RRESP(1 downto 0),
      S2_RVALID => S2_RVALID,
      S3_RDATA(31 downto 0) => S3_RDATA(31 downto 0),
      S3_RLAST => S3_RLAST,
      S3_RLAST_0 => Read_controller_n_83,
      S3_RREADY => S3_RREADY,
      S3_RRESP(1 downto 0) => S3_RRESP(1 downto 0),
      S3_RVALID => S3_RVALID,
      next_state_slave119_out => next_state_slave119_out
    );
u_AR_Channel_Controller_Top: entity work.design_1_axi_interconnect_0_0_AR_Channel_Controller_Top
     port map (
      ACLK => ACLK,
      CO(0) => next_state_slave217_in,
      D(1 downto 0) => \next_state_slave__0\(2 downto 1),
      \FSM_onehot_curr_state_slave2_reg[4]\(2) => u_AR_Channel_Controller_Top_n_186,
      \FSM_onehot_curr_state_slave2_reg[4]\(1) => u_AR_Channel_Controller_Top_n_187,
      \FSM_onehot_curr_state_slave2_reg[4]\(0) => u_AR_Channel_Controller_Top_n_188,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(3) => en_S3_M1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(2) => en_S2_M1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(1) => en_S1_M1,
      \FSM_onehot_curr_state_slave2_reg[4]_0\(0) => Read_controller_n_41,
      \FSM_sequential_curr_state_slave_reg[1]\ => Read_controller_n_0,
      \FSM_sequential_curr_state_slave_reg[1]_0\ => Read_controller_n_45,
      \FSM_sequential_curr_state_slave_reg[2]\ => Read_controller_n_46,
      \FSM_sequential_curr_state_slave_reg[2]_0\ => Read_controller_n_83,
      \FSM_sequential_curr_state_slave_reg[2]_i_8\ => u_AR_Channel_Controller_Top_n_189,
      M0_ARADDR(31 downto 0) => M0_ARADDR(31 downto 0),
      \M0_ARADDR[30]\(0) => next_state_slave218_in,
      \M0_ARADDR[30]_0\ => M0_ARADDR_30_sn_1,
      \M0_ARADDR[30]_1\ => \M0_ARADDR[30]_0\,
      M0_ARADDR_31_sp_1 => M0_ARADDR_31_sn_1,
      M0_ARBURST(1 downto 0) => M0_ARBURST(1 downto 0),
      M0_ARLEN(7 downto 0) => M0_ARLEN(7 downto 0),
      M0_ARREADY => M0_ARREADY,
      M0_ARSIZE(2 downto 0) => M0_ARSIZE(2 downto 0),
      M0_ARVALID => M0_ARVALID,
      M0_RREADY => M0_RREADY,
      M1_ARADDR(31 downto 0) => M1_ARADDR(31 downto 0),
      M1_ARBURST(1 downto 0) => M1_ARBURST(1 downto 0),
      M1_ARLEN(7 downto 0) => M1_ARLEN(7 downto 0),
      M1_ARREADY => M1_ARREADY,
      M1_ARSIZE(2 downto 0) => M1_ARSIZE(2 downto 0),
      M1_ARVALID => M1_ARVALID,
      M1_RREADY => M1_RREADY,
      Q(0) => curr_state_slave(2),
      S0_ARADDR(29 downto 0) => S0_ARADDR(29 downto 0),
      S0_ARBURST(1 downto 0) => S0_ARBURST(1 downto 0),
      S0_ARLEN(7 downto 0) => S0_ARLEN(7 downto 0),
      S0_ARREADY => S0_ARREADY,
      S0_ARREADY_0 => u_AR_Channel_Controller_Top_n_190,
      S0_ARSIZE(2 downto 0) => S0_ARSIZE(2 downto 0),
      S0_ARVALID => S0_ARVALID,
      S1_ARADDR(29 downto 0) => S1_ARADDR(29 downto 0),
      S1_ARBURST(1 downto 0) => S1_ARBURST(1 downto 0),
      S1_ARLEN(7 downto 0) => S1_ARLEN(7 downto 0),
      S1_ARREADY => S1_ARREADY,
      S1_ARSIZE(2 downto 0) => S1_ARSIZE(2 downto 0),
      S1_ARVALID => S1_ARVALID,
      S1_RLAST => S1_RLAST,
      S1_RVALID => S1_RVALID,
      S2_ARADDR(29 downto 0) => S2_ARADDR(29 downto 0),
      S2_ARBURST(1 downto 0) => S2_ARBURST(1 downto 0),
      S2_ARLEN(7 downto 0) => S2_ARLEN(7 downto 0),
      S2_ARREADY => S2_ARREADY,
      S2_ARSIZE(2 downto 0) => S2_ARSIZE(2 downto 0),
      S2_ARVALID => S2_ARVALID,
      S2_RLAST => S2_RLAST,
      S2_RVALID => S2_RVALID,
      S3_ARADDR(29 downto 0) => S3_ARADDR(29 downto 0),
      S3_ARBURST(1 downto 0) => S3_ARBURST(1 downto 0),
      S3_ARLEN(7 downto 0) => S3_ARLEN(7 downto 0),
      S3_ARREADY => S3_ARREADY,
      S3_ARSIZE(2 downto 0) => S3_ARSIZE(2 downto 0),
      S3_ARVALID => S3_ARVALID,
      S3_RLAST => S3_RLAST,
      S3_RVALID => S3_RVALID,
      \Selected_Master_reg[0]_rep__1\ => u_WD_Channel_Controller_Top_n_1,
      next_state_slave119_out => next_state_slave119_out
    );
u_AW_Channel_Controller_Top: entity work.design_1_axi_interconnect_0_0_AW_Channel_Controller_Top
     port map (
      ACLK => ACLK,
      E(0) => AW_Access_Grant0,
      Falling_reg(0) => AW_Access_Grant00_out,
      M0_AWADDR(31 downto 0) => M0_AWADDR(31 downto 0),
      M0_AWADDR_30_sp_1 => M0_AWADDR_30_sn_1,
      M0_AWBURST(1 downto 0) => M0_AWBURST(1 downto 0),
      M0_AWLEN(7 downto 0) => M0_AWLEN(7 downto 0),
      M0_AWREADY => M0_AWREADY,
      M0_AWSIZE(2 downto 0) => M0_AWSIZE(2 downto 0),
      M0_AWVALID => M0_AWVALID,
      M1_AWADDR(31 downto 0) => M1_AWADDR(31 downto 0),
      M1_AWBURST(1 downto 0) => M1_AWBURST(1 downto 0),
      M1_AWLEN(7 downto 0) => M1_AWLEN(7 downto 0),
      M1_AWREADY => M1_AWREADY,
      M1_AWSIZE(2 downto 0) => M1_AWSIZE(2 downto 0),
      M1_AWVALID => M1_AWVALID,
      Q(0) => u_WD_Channel_Controller_Top_n_8,
      \Queue_reg[0][0]\ => u_WD_Channel_Controller_Top_n_4,
      \Queue_reg[0]_0\ => \Queue_reg[0]_0\,
      \Queue_reg[1][0]\(0) => u_WD_Channel_Controller_Top_n_11,
      \Queue_reg[1][0]_0\ => u_WD_Channel_Controller_Top_n_5,
      \Queue_reg[1]_1\ => \Queue_reg[1]_1\,
      S0_AWADDR(29 downto 0) => S0_AWADDR(29 downto 0),
      S0_AWBURST(1 downto 0) => S0_AWBURST(1 downto 0),
      S0_AWLEN(7 downto 0) => S0_AWLEN(7 downto 0),
      S0_AWREADY => S0_AWREADY,
      S0_AWSIZE(2 downto 0) => S0_AWSIZE(2 downto 0),
      S0_AWVALID => S0_AWVALID,
      S1_AWADDR(29 downto 0) => S1_AWADDR(29 downto 0),
      S1_AWBURST(1 downto 0) => S1_AWBURST(1 downto 0),
      S1_AWLEN(7 downto 0) => S1_AWLEN(7 downto 0),
      S1_AWREADY => S1_AWREADY,
      S1_AWSIZE(2 downto 0) => S1_AWSIZE(2 downto 0),
      S1_AWVALID => S1_AWVALID,
      \Selected_Slave_reg[0]\ => u_AW_Channel_Controller_Top_n_93,
      \Selected_Slave_reg[0]_0\ => u_AW_Channel_Controller_Top_n_94,
      \Selected_Slave_reg[0]_1\ => u_AW_Channel_Controller_Top_n_95,
      \Selected_Slave_reg[0]_2\ => u_AW_Channel_Controller_Top_n_96,
      \Selected_Slave_reg[0]_3\ => u_WD_Channel_Controller_Top_n_1
    );
u_BR_Channel_Controller_Top: entity work.design_1_axi_interconnect_0_0_BR_Channel_Controller_Top
     port map (
      ACLK => ACLK,
      M0_BREADY => M0_BREADY,
      M0_BVALID => M0_BVALID,
      M1_BREADY => M1_BREADY,
      M1_BRESP(1 downto 0) => M1_BRESP(1 downto 0),
      M1_BVALID => M1_BVALID,
      S0_BREADY => S0_BREADY,
      S0_BRESP(1 downto 0) => S0_BRESP(1 downto 0),
      S0_BVALID => S0_BVALID,
      S1_BREADY => S1_BREADY,
      S1_BRESP(1 downto 0) => S1_BRESP(1 downto 0),
      S1_BVALID => S1_BVALID,
      \Sel_Write_Resp_reg[1]\ => u_WD_Channel_Controller_Top_n_1,
      Write_Data_Finsh => Write_Data_Finsh
    );
u_WD_Channel_Controller_Top: entity work.design_1_axi_interconnect_0_0_WD_Channel_Controller_Top
     port map (
      ACLK => ACLK,
      ARESETN => ARESETN,
      ARESETN_0 => u_WD_Channel_Controller_Top_n_1,
      E(0) => Write_Data_Finsh,
      M0_WDATA(31 downto 0) => M0_WDATA(31 downto 0),
      M0_WLAST => M0_WLAST,
      M0_WREADY => M0_WREADY,
      M0_WSTRB(3 downto 0) => M0_WSTRB(3 downto 0),
      M0_WVALID => M0_WVALID,
      M1_WDATA(31 downto 0) => M1_WDATA(31 downto 0),
      M1_WLAST => M1_WLAST,
      M1_WREADY => M1_WREADY,
      M1_WSTRB(3 downto 0) => M1_WSTRB(3 downto 0),
      M1_WVALID => M1_WVALID,
      Q(0) => u_WD_Channel_Controller_Top_n_8,
      \Queue_reg[0][0]\ => u_WD_Channel_Controller_Top_n_4,
      \Queue_reg[0][0]_0\ => u_AW_Channel_Controller_Top_n_93,
      \Queue_reg[0][0]_1\ => u_AW_Channel_Controller_Top_n_95,
      \Queue_reg[0]_0\ => \Queue_reg[0]_0\,
      \Queue_reg[1][0]\ => u_WD_Channel_Controller_Top_n_5,
      \Queue_reg[1][0]_0\ => u_AW_Channel_Controller_Top_n_94,
      \Queue_reg[1][0]_1\ => u_AW_Channel_Controller_Top_n_96,
      \Queue_reg[1]_1\ => \Queue_reg[1]_1\,
      S0_WDATA(31 downto 0) => S0_WDATA(31 downto 0),
      S0_WLAST => S0_WLAST,
      S0_WREADY => S0_WREADY,
      S0_WSTRB(3 downto 0) => S0_WSTRB(3 downto 0),
      S0_WVALID => S0_WVALID,
      S1_WDATA(31 downto 0) => S1_WDATA(31 downto 0),
      S1_WLAST => S1_WLAST,
      S1_WREADY => S1_WREADY,
      S1_WSTRB(3 downto 0) => S1_WSTRB(3 downto 0),
      S1_WVALID => S1_WVALID,
      \Write_Pointer_reg[0]\(0) => u_WD_Channel_Controller_Top_n_11,
      \Write_Pointer_reg[0]_0\(0) => AW_Access_Grant00_out,
      \Write_Pointer_reg[0]_1\(0) => AW_Access_Grant0
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0_AXI_Interconnect is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    M0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_AWVALID : in STD_LOGIC;
    M0_AWREADY : out STD_LOGIC;
    M0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M0_WLAST : in STD_LOGIC;
    M0_WVALID : in STD_LOGIC;
    M0_WREADY : out STD_LOGIC;
    M0_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_BVALID : out STD_LOGIC;
    M0_BREADY : in STD_LOGIC;
    M0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_ARVALID : in STD_LOGIC;
    M0_ARREADY : out STD_LOGIC;
    M0_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_RLAST : out STD_LOGIC;
    M0_RVALID : out STD_LOGIC;
    M0_RREADY : in STD_LOGIC;
    M1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWVALID : in STD_LOGIC;
    M1_AWREADY : out STD_LOGIC;
    M1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WLAST : in STD_LOGIC;
    M1_WVALID : in STD_LOGIC;
    M1_WREADY : out STD_LOGIC;
    M1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_BVALID : out STD_LOGIC;
    M1_BREADY : in STD_LOGIC;
    M1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_ARVALID : in STD_LOGIC;
    M1_ARREADY : out STD_LOGIC;
    M1_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_RLAST : out STD_LOGIC;
    M1_RVALID : out STD_LOGIC;
    M1_RREADY : in STD_LOGIC;
    S0_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_AWVALID : out STD_LOGIC;
    S0_AWREADY : in STD_LOGIC;
    S0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S0_WLAST : out STD_LOGIC;
    S0_WVALID : out STD_LOGIC;
    S0_WREADY : in STD_LOGIC;
    S0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_BVALID : in STD_LOGIC;
    S0_BREADY : out STD_LOGIC;
    S0_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_ARVALID : out STD_LOGIC;
    S0_ARREADY : in STD_LOGIC;
    S0_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_RLAST : in STD_LOGIC;
    S0_RVALID : in STD_LOGIC;
    S0_RREADY : out STD_LOGIC;
    S1_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S1_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_AWVALID : out STD_LOGIC;
    S1_AWREADY : in STD_LOGIC;
    S1_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S1_WLAST : out STD_LOGIC;
    S1_WVALID : out STD_LOGIC;
    S1_WREADY : in STD_LOGIC;
    S1_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_BVALID : in STD_LOGIC;
    S1_BREADY : out STD_LOGIC;
    S1_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S1_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_ARVALID : out STD_LOGIC;
    S1_ARREADY : in STD_LOGIC;
    S1_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_RLAST : in STD_LOGIC;
    S1_RVALID : in STD_LOGIC;
    S1_RREADY : out STD_LOGIC;
    S2_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S2_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_AWVALID : out STD_LOGIC;
    S2_AWREADY : in STD_LOGIC;
    S2_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S2_WLAST : out STD_LOGIC;
    S2_WVALID : out STD_LOGIC;
    S2_WREADY : in STD_LOGIC;
    S2_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_BVALID : in STD_LOGIC;
    S2_BREADY : out STD_LOGIC;
    S2_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S2_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_ARVALID : out STD_LOGIC;
    S2_ARREADY : in STD_LOGIC;
    S2_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_RLAST : in STD_LOGIC;
    S2_RVALID : in STD_LOGIC;
    S2_RREADY : out STD_LOGIC;
    S3_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S3_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_AWVALID : out STD_LOGIC;
    S3_AWREADY : in STD_LOGIC;
    S3_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S3_WLAST : out STD_LOGIC;
    S3_WVALID : out STD_LOGIC;
    S3_WREADY : in STD_LOGIC;
    S3_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_BVALID : in STD_LOGIC;
    S3_BREADY : out STD_LOGIC;
    S3_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S3_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_ARVALID : out STD_LOGIC;
    S3_ARREADY : in STD_LOGIC;
    S3_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_RLAST : in STD_LOGIC;
    S3_RVALID : in STD_LOGIC;
    S3_RREADY : out STD_LOGIC
  );
  attribute ARBITRATION_MODE : integer;
  attribute ARBITRATION_MODE of design_1_axi_interconnect_0_0_AXI_Interconnect : entity is 1;
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_axi_interconnect_0_0_AXI_Interconnect : entity is "AXI_Interconnect";
end design_1_axi_interconnect_0_0_AXI_Interconnect;

architecture STRUCTURE of design_1_axi_interconnect_0_0_AXI_Interconnect is
  signal \<const0>\ : STD_LOGIC;
  signal \^m1_bresp\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal \^s0_araddr\ : STD_LOGIC_VECTOR ( 29 downto 0 );
  signal \^s0_awaddr\ : STD_LOGIC_VECTOR ( 29 downto 0 );
  signal \^s1_araddr\ : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal \^s1_awaddr\ : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal \^s2_araddr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^s3_araddr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
begin
  M0_BRESP(1 downto 0) <= \^m1_bresp\(1 downto 0);
  M1_BRESP(1 downto 0) <= \^m1_bresp\(1 downto 0);
  S0_ARADDR(31) <= \<const0>\;
  S0_ARADDR(30) <= \<const0>\;
  S0_ARADDR(29 downto 0) <= \^s0_araddr\(29 downto 0);
  S0_AWADDR(31) <= \<const0>\;
  S0_AWADDR(30) <= \<const0>\;
  S0_AWADDR(29 downto 0) <= \^s0_awaddr\(29 downto 0);
  S1_ARADDR(31) <= \<const0>\;
  S1_ARADDR(30 downto 0) <= \^s1_araddr\(30 downto 0);
  S1_AWADDR(31) <= \<const0>\;
  S1_AWADDR(30 downto 0) <= \^s1_awaddr\(30 downto 0);
  S2_ARADDR(31) <= \^s2_araddr\(31);
  S2_ARADDR(30) <= \<const0>\;
  S2_ARADDR(29 downto 0) <= \^s2_araddr\(29 downto 0);
  S2_AWADDR(31) <= \<const0>\;
  S2_AWADDR(30) <= \<const0>\;
  S2_AWADDR(29) <= \<const0>\;
  S2_AWADDR(28) <= \<const0>\;
  S2_AWADDR(27) <= \<const0>\;
  S2_AWADDR(26) <= \<const0>\;
  S2_AWADDR(25) <= \<const0>\;
  S2_AWADDR(24) <= \<const0>\;
  S2_AWADDR(23) <= \<const0>\;
  S2_AWADDR(22) <= \<const0>\;
  S2_AWADDR(21) <= \<const0>\;
  S2_AWADDR(20) <= \<const0>\;
  S2_AWADDR(19) <= \<const0>\;
  S2_AWADDR(18) <= \<const0>\;
  S2_AWADDR(17) <= \<const0>\;
  S2_AWADDR(16) <= \<const0>\;
  S2_AWADDR(15) <= \<const0>\;
  S2_AWADDR(14) <= \<const0>\;
  S2_AWADDR(13) <= \<const0>\;
  S2_AWADDR(12) <= \<const0>\;
  S2_AWADDR(11) <= \<const0>\;
  S2_AWADDR(10) <= \<const0>\;
  S2_AWADDR(9) <= \<const0>\;
  S2_AWADDR(8) <= \<const0>\;
  S2_AWADDR(7) <= \<const0>\;
  S2_AWADDR(6) <= \<const0>\;
  S2_AWADDR(5) <= \<const0>\;
  S2_AWADDR(4) <= \<const0>\;
  S2_AWADDR(3) <= \<const0>\;
  S2_AWADDR(2) <= \<const0>\;
  S2_AWADDR(1) <= \<const0>\;
  S2_AWADDR(0) <= \<const0>\;
  S2_AWBURST(1) <= \<const0>\;
  S2_AWBURST(0) <= \<const0>\;
  S2_AWLEN(7) <= \<const0>\;
  S2_AWLEN(6) <= \<const0>\;
  S2_AWLEN(5) <= \<const0>\;
  S2_AWLEN(4) <= \<const0>\;
  S2_AWLEN(3) <= \<const0>\;
  S2_AWLEN(2) <= \<const0>\;
  S2_AWLEN(1) <= \<const0>\;
  S2_AWLEN(0) <= \<const0>\;
  S2_AWSIZE(2) <= \<const0>\;
  S2_AWSIZE(1) <= \<const0>\;
  S2_AWSIZE(0) <= \<const0>\;
  S2_AWVALID <= \<const0>\;
  S2_BREADY <= \<const0>\;
  S2_WDATA(31) <= \<const0>\;
  S2_WDATA(30) <= \<const0>\;
  S2_WDATA(29) <= \<const0>\;
  S2_WDATA(28) <= \<const0>\;
  S2_WDATA(27) <= \<const0>\;
  S2_WDATA(26) <= \<const0>\;
  S2_WDATA(25) <= \<const0>\;
  S2_WDATA(24) <= \<const0>\;
  S2_WDATA(23) <= \<const0>\;
  S2_WDATA(22) <= \<const0>\;
  S2_WDATA(21) <= \<const0>\;
  S2_WDATA(20) <= \<const0>\;
  S2_WDATA(19) <= \<const0>\;
  S2_WDATA(18) <= \<const0>\;
  S2_WDATA(17) <= \<const0>\;
  S2_WDATA(16) <= \<const0>\;
  S2_WDATA(15) <= \<const0>\;
  S2_WDATA(14) <= \<const0>\;
  S2_WDATA(13) <= \<const0>\;
  S2_WDATA(12) <= \<const0>\;
  S2_WDATA(11) <= \<const0>\;
  S2_WDATA(10) <= \<const0>\;
  S2_WDATA(9) <= \<const0>\;
  S2_WDATA(8) <= \<const0>\;
  S2_WDATA(7) <= \<const0>\;
  S2_WDATA(6) <= \<const0>\;
  S2_WDATA(5) <= \<const0>\;
  S2_WDATA(4) <= \<const0>\;
  S2_WDATA(3) <= \<const0>\;
  S2_WDATA(2) <= \<const0>\;
  S2_WDATA(1) <= \<const0>\;
  S2_WDATA(0) <= \<const0>\;
  S2_WLAST <= \<const0>\;
  S2_WSTRB(3) <= \<const0>\;
  S2_WSTRB(2) <= \<const0>\;
  S2_WSTRB(1) <= \<const0>\;
  S2_WSTRB(0) <= \<const0>\;
  S2_WVALID <= \<const0>\;
  S3_ARADDR(31) <= \^s3_araddr\(31);
  S3_ARADDR(30) <= \^s3_araddr\(31);
  S3_ARADDR(29 downto 0) <= \^s3_araddr\(29 downto 0);
  S3_AWADDR(31) <= \<const0>\;
  S3_AWADDR(30) <= \<const0>\;
  S3_AWADDR(29) <= \<const0>\;
  S3_AWADDR(28) <= \<const0>\;
  S3_AWADDR(27) <= \<const0>\;
  S3_AWADDR(26) <= \<const0>\;
  S3_AWADDR(25) <= \<const0>\;
  S3_AWADDR(24) <= \<const0>\;
  S3_AWADDR(23) <= \<const0>\;
  S3_AWADDR(22) <= \<const0>\;
  S3_AWADDR(21) <= \<const0>\;
  S3_AWADDR(20) <= \<const0>\;
  S3_AWADDR(19) <= \<const0>\;
  S3_AWADDR(18) <= \<const0>\;
  S3_AWADDR(17) <= \<const0>\;
  S3_AWADDR(16) <= \<const0>\;
  S3_AWADDR(15) <= \<const0>\;
  S3_AWADDR(14) <= \<const0>\;
  S3_AWADDR(13) <= \<const0>\;
  S3_AWADDR(12) <= \<const0>\;
  S3_AWADDR(11) <= \<const0>\;
  S3_AWADDR(10) <= \<const0>\;
  S3_AWADDR(9) <= \<const0>\;
  S3_AWADDR(8) <= \<const0>\;
  S3_AWADDR(7) <= \<const0>\;
  S3_AWADDR(6) <= \<const0>\;
  S3_AWADDR(5) <= \<const0>\;
  S3_AWADDR(4) <= \<const0>\;
  S3_AWADDR(3) <= \<const0>\;
  S3_AWADDR(2) <= \<const0>\;
  S3_AWADDR(1) <= \<const0>\;
  S3_AWADDR(0) <= \<const0>\;
  S3_AWBURST(1) <= \<const0>\;
  S3_AWBURST(0) <= \<const0>\;
  S3_AWLEN(7) <= \<const0>\;
  S3_AWLEN(6) <= \<const0>\;
  S3_AWLEN(5) <= \<const0>\;
  S3_AWLEN(4) <= \<const0>\;
  S3_AWLEN(3) <= \<const0>\;
  S3_AWLEN(2) <= \<const0>\;
  S3_AWLEN(1) <= \<const0>\;
  S3_AWLEN(0) <= \<const0>\;
  S3_AWSIZE(2) <= \<const0>\;
  S3_AWSIZE(1) <= \<const0>\;
  S3_AWSIZE(0) <= \<const0>\;
  S3_AWVALID <= \<const0>\;
  S3_BREADY <= \<const0>\;
  S3_WDATA(31) <= \<const0>\;
  S3_WDATA(30) <= \<const0>\;
  S3_WDATA(29) <= \<const0>\;
  S3_WDATA(28) <= \<const0>\;
  S3_WDATA(27) <= \<const0>\;
  S3_WDATA(26) <= \<const0>\;
  S3_WDATA(25) <= \<const0>\;
  S3_WDATA(24) <= \<const0>\;
  S3_WDATA(23) <= \<const0>\;
  S3_WDATA(22) <= \<const0>\;
  S3_WDATA(21) <= \<const0>\;
  S3_WDATA(20) <= \<const0>\;
  S3_WDATA(19) <= \<const0>\;
  S3_WDATA(18) <= \<const0>\;
  S3_WDATA(17) <= \<const0>\;
  S3_WDATA(16) <= \<const0>\;
  S3_WDATA(15) <= \<const0>\;
  S3_WDATA(14) <= \<const0>\;
  S3_WDATA(13) <= \<const0>\;
  S3_WDATA(12) <= \<const0>\;
  S3_WDATA(11) <= \<const0>\;
  S3_WDATA(10) <= \<const0>\;
  S3_WDATA(9) <= \<const0>\;
  S3_WDATA(8) <= \<const0>\;
  S3_WDATA(7) <= \<const0>\;
  S3_WDATA(6) <= \<const0>\;
  S3_WDATA(5) <= \<const0>\;
  S3_WDATA(4) <= \<const0>\;
  S3_WDATA(3) <= \<const0>\;
  S3_WDATA(2) <= \<const0>\;
  S3_WDATA(1) <= \<const0>\;
  S3_WDATA(0) <= \<const0>\;
  S3_WLAST <= \<const0>\;
  S3_WSTRB(3) <= \<const0>\;
  S3_WSTRB(2) <= \<const0>\;
  S3_WSTRB(1) <= \<const0>\;
  S3_WSTRB(0) <= \<const0>\;
  S3_WVALID <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
u_full_interconnect: entity work.design_1_axi_interconnect_0_0_AXI_Interconnect_Full
     port map (
      ACLK => ACLK,
      ARESETN => ARESETN,
      M0_ARADDR(31 downto 0) => M0_ARADDR(31 downto 0),
      \M0_ARADDR[30]_0\ => \^s3_araddr\(31),
      M0_ARADDR_30_sp_1 => \^s1_araddr\(30),
      M0_ARADDR_31_sp_1 => \^s2_araddr\(31),
      M0_ARBURST(1 downto 0) => M0_ARBURST(1 downto 0),
      M0_ARLEN(7 downto 0) => M0_ARLEN(7 downto 0),
      M0_ARREADY => M0_ARREADY,
      M0_ARSIZE(2 downto 0) => M0_ARSIZE(2 downto 0),
      M0_ARVALID => M0_ARVALID,
      M0_AWADDR(31 downto 0) => M0_AWADDR(31 downto 0),
      M0_AWADDR_30_sp_1 => \^s1_awaddr\(30),
      M0_AWBURST(1 downto 0) => M0_AWBURST(1 downto 0),
      M0_AWLEN(7 downto 0) => M0_AWLEN(7 downto 0),
      M0_AWREADY => M0_AWREADY,
      M0_AWSIZE(2 downto 0) => M0_AWSIZE(2 downto 0),
      M0_AWVALID => M0_AWVALID,
      M0_BREADY => M0_BREADY,
      M0_BVALID => M0_BVALID,
      M0_RDATA(31 downto 0) => M0_RDATA(31 downto 0),
      M0_RLAST => M0_RLAST,
      M0_RREADY => M0_RREADY,
      M0_RRESP(1 downto 0) => M0_RRESP(1 downto 0),
      M0_RVALID => M0_RVALID,
      M0_WDATA(31 downto 0) => M0_WDATA(31 downto 0),
      M0_WLAST => M0_WLAST,
      M0_WREADY => M0_WREADY,
      M0_WSTRB(3 downto 0) => M0_WSTRB(3 downto 0),
      M0_WVALID => M0_WVALID,
      M1_ARADDR(31 downto 0) => M1_ARADDR(31 downto 0),
      M1_ARBURST(1 downto 0) => M1_ARBURST(1 downto 0),
      M1_ARLEN(7 downto 0) => M1_ARLEN(7 downto 0),
      M1_ARREADY => M1_ARREADY,
      M1_ARSIZE(2 downto 0) => M1_ARSIZE(2 downto 0),
      M1_ARVALID => M1_ARVALID,
      M1_AWADDR(31 downto 0) => M1_AWADDR(31 downto 0),
      M1_AWBURST(1 downto 0) => M1_AWBURST(1 downto 0),
      M1_AWLEN(7 downto 0) => M1_AWLEN(7 downto 0),
      M1_AWREADY => M1_AWREADY,
      M1_AWSIZE(2 downto 0) => M1_AWSIZE(2 downto 0),
      M1_AWVALID => M1_AWVALID,
      M1_BREADY => M1_BREADY,
      M1_BRESP(1 downto 0) => \^m1_bresp\(1 downto 0),
      M1_BVALID => M1_BVALID,
      M1_RDATA(31 downto 0) => M1_RDATA(31 downto 0),
      M1_RLAST => M1_RLAST,
      M1_RREADY => M1_RREADY,
      M1_RRESP(1 downto 0) => M1_RRESP(1 downto 0),
      M1_RVALID => M1_RVALID,
      M1_WDATA(31 downto 0) => M1_WDATA(31 downto 0),
      M1_WLAST => M1_WLAST,
      M1_WREADY => M1_WREADY,
      M1_WSTRB(3 downto 0) => M1_WSTRB(3 downto 0),
      M1_WVALID => M1_WVALID,
      S0_ARADDR(29 downto 0) => \^s0_araddr\(29 downto 0),
      S0_ARBURST(1 downto 0) => S0_ARBURST(1 downto 0),
      S0_ARLEN(7 downto 0) => S0_ARLEN(7 downto 0),
      S0_ARREADY => S0_ARREADY,
      S0_ARSIZE(2 downto 0) => S0_ARSIZE(2 downto 0),
      S0_ARVALID => S0_ARVALID,
      S0_AWADDR(29 downto 0) => \^s0_awaddr\(29 downto 0),
      S0_AWBURST(1 downto 0) => S0_AWBURST(1 downto 0),
      S0_AWLEN(7 downto 0) => S0_AWLEN(7 downto 0),
      S0_AWREADY => S0_AWREADY,
      S0_AWSIZE(2 downto 0) => S0_AWSIZE(2 downto 0),
      S0_AWVALID => S0_AWVALID,
      S0_BREADY => S0_BREADY,
      S0_BRESP(1 downto 0) => S0_BRESP(1 downto 0),
      S0_BVALID => S0_BVALID,
      S0_RDATA(31 downto 0) => S0_RDATA(31 downto 0),
      S0_RLAST => S0_RLAST,
      S0_RREADY => S0_RREADY,
      S0_RRESP(1 downto 0) => S0_RRESP(1 downto 0),
      S0_RVALID => S0_RVALID,
      S0_WDATA(31 downto 0) => S0_WDATA(31 downto 0),
      S0_WLAST => S0_WLAST,
      S0_WREADY => S0_WREADY,
      S0_WSTRB(3 downto 0) => S0_WSTRB(3 downto 0),
      S0_WVALID => S0_WVALID,
      S1_ARADDR(29 downto 0) => \^s1_araddr\(29 downto 0),
      S1_ARBURST(1 downto 0) => S1_ARBURST(1 downto 0),
      S1_ARLEN(7 downto 0) => S1_ARLEN(7 downto 0),
      S1_ARREADY => S1_ARREADY,
      S1_ARSIZE(2 downto 0) => S1_ARSIZE(2 downto 0),
      S1_ARVALID => S1_ARVALID,
      S1_AWADDR(29 downto 0) => \^s1_awaddr\(29 downto 0),
      S1_AWBURST(1 downto 0) => S1_AWBURST(1 downto 0),
      S1_AWLEN(7 downto 0) => S1_AWLEN(7 downto 0),
      S1_AWREADY => S1_AWREADY,
      S1_AWSIZE(2 downto 0) => S1_AWSIZE(2 downto 0),
      S1_AWVALID => S1_AWVALID,
      S1_BREADY => S1_BREADY,
      S1_BRESP(1 downto 0) => S1_BRESP(1 downto 0),
      S1_BVALID => S1_BVALID,
      S1_RDATA(31 downto 0) => S1_RDATA(31 downto 0),
      S1_RLAST => S1_RLAST,
      S1_RREADY => S1_RREADY,
      S1_RRESP(1 downto 0) => S1_RRESP(1 downto 0),
      S1_RVALID => S1_RVALID,
      S1_WDATA(31 downto 0) => S1_WDATA(31 downto 0),
      S1_WLAST => S1_WLAST,
      S1_WREADY => S1_WREADY,
      S1_WSTRB(3 downto 0) => S1_WSTRB(3 downto 0),
      S1_WVALID => S1_WVALID,
      S2_ARADDR(29 downto 0) => \^s2_araddr\(29 downto 0),
      S2_ARBURST(1 downto 0) => S2_ARBURST(1 downto 0),
      S2_ARLEN(7 downto 0) => S2_ARLEN(7 downto 0),
      S2_ARREADY => S2_ARREADY,
      S2_ARSIZE(2 downto 0) => S2_ARSIZE(2 downto 0),
      S2_ARVALID => S2_ARVALID,
      S2_RDATA(31 downto 0) => S2_RDATA(31 downto 0),
      S2_RLAST => S2_RLAST,
      S2_RREADY => S2_RREADY,
      S2_RRESP(1 downto 0) => S2_RRESP(1 downto 0),
      S2_RVALID => S2_RVALID,
      S3_ARADDR(29 downto 0) => \^s3_araddr\(29 downto 0),
      S3_ARBURST(1 downto 0) => S3_ARBURST(1 downto 0),
      S3_ARLEN(7 downto 0) => S3_ARLEN(7 downto 0),
      S3_ARREADY => S3_ARREADY,
      S3_ARSIZE(2 downto 0) => S3_ARSIZE(2 downto 0),
      S3_ARVALID => S3_ARVALID,
      S3_RDATA(31 downto 0) => S3_RDATA(31 downto 0),
      S3_RLAST => S3_RLAST,
      S3_RREADY => S3_RREADY,
      S3_RRESP(1 downto 0) => S3_RRESP(1 downto 0),
      S3_RVALID => S3_RVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_interconnect_0_0 is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
    M0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_AWVALID : in STD_LOGIC;
    M0_AWREADY : out STD_LOGIC;
    M0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M0_WLAST : in STD_LOGIC;
    M0_WVALID : in STD_LOGIC;
    M0_WREADY : out STD_LOGIC;
    M0_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_BVALID : out STD_LOGIC;
    M0_BREADY : in STD_LOGIC;
    M0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_ARVALID : in STD_LOGIC;
    M0_ARREADY : out STD_LOGIC;
    M0_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M0_RLAST : out STD_LOGIC;
    M0_RVALID : out STD_LOGIC;
    M0_RREADY : in STD_LOGIC;
    M1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_AWVALID : in STD_LOGIC;
    M1_AWREADY : out STD_LOGIC;
    M1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    M1_WLAST : in STD_LOGIC;
    M1_WVALID : in STD_LOGIC;
    M1_WREADY : out STD_LOGIC;
    M1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_BVALID : out STD_LOGIC;
    M1_BREADY : in STD_LOGIC;
    M1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    M1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_ARVALID : in STD_LOGIC;
    M1_ARREADY : out STD_LOGIC;
    M1_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M1_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M1_RLAST : out STD_LOGIC;
    M1_RVALID : out STD_LOGIC;
    M1_RREADY : in STD_LOGIC;
    S0_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_AWVALID : out STD_LOGIC;
    S0_AWREADY : in STD_LOGIC;
    S0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S0_WLAST : out STD_LOGIC;
    S0_WVALID : out STD_LOGIC;
    S0_WREADY : in STD_LOGIC;
    S0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_BVALID : in STD_LOGIC;
    S0_BREADY : out STD_LOGIC;
    S0_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_ARVALID : out STD_LOGIC;
    S0_ARREADY : in STD_LOGIC;
    S0_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S0_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S0_RLAST : in STD_LOGIC;
    S0_RVALID : in STD_LOGIC;
    S0_RREADY : out STD_LOGIC;
    S1_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S1_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_AWVALID : out STD_LOGIC;
    S1_AWREADY : in STD_LOGIC;
    S1_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S1_WLAST : out STD_LOGIC;
    S1_WVALID : out STD_LOGIC;
    S1_WREADY : in STD_LOGIC;
    S1_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_BVALID : in STD_LOGIC;
    S1_BREADY : out STD_LOGIC;
    S1_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S1_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S1_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_ARVALID : out STD_LOGIC;
    S1_ARREADY : in STD_LOGIC;
    S1_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S1_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S1_RLAST : in STD_LOGIC;
    S1_RVALID : in STD_LOGIC;
    S1_RREADY : out STD_LOGIC;
    S2_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S2_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_AWVALID : out STD_LOGIC;
    S2_AWREADY : in STD_LOGIC;
    S2_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S2_WLAST : out STD_LOGIC;
    S2_WVALID : out STD_LOGIC;
    S2_WREADY : in STD_LOGIC;
    S2_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_BVALID : in STD_LOGIC;
    S2_BREADY : out STD_LOGIC;
    S2_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S2_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S2_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_ARVALID : out STD_LOGIC;
    S2_ARREADY : in STD_LOGIC;
    S2_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S2_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S2_RLAST : in STD_LOGIC;
    S2_RVALID : in STD_LOGIC;
    S2_RREADY : out STD_LOGIC;
    S3_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S3_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_AWVALID : out STD_LOGIC;
    S3_AWREADY : in STD_LOGIC;
    S3_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S3_WLAST : out STD_LOGIC;
    S3_WVALID : out STD_LOGIC;
    S3_WREADY : in STD_LOGIC;
    S3_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_BVALID : in STD_LOGIC;
    S3_BREADY : out STD_LOGIC;
    S3_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S3_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S3_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_ARVALID : out STD_LOGIC;
    S3_ARREADY : in STD_LOGIC;
    S3_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S3_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S3_RLAST : in STD_LOGIC;
    S3_RVALID : in STD_LOGIC;
    S3_RREADY : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of design_1_axi_interconnect_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of design_1_axi_interconnect_0_0 : entity is "design_1_axi_interconnect_0_0,AXI_Interconnect,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of design_1_axi_interconnect_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of design_1_axi_interconnect_0_0 : entity is "package_project";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of design_1_axi_interconnect_0_0 : entity is "AXI_Interconnect,Vivado 2024.2";
end design_1_axi_interconnect_0_0;

architecture STRUCTURE of design_1_axi_interconnect_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^s0_araddr\ : STD_LOGIC_VECTOR ( 29 downto 0 );
  signal \^s0_awaddr\ : STD_LOGIC_VECTOR ( 29 downto 0 );
  signal \^s1_araddr\ : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal \^s1_awaddr\ : STD_LOGIC_VECTOR ( 30 downto 0 );
  signal \^s2_araddr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S2_AWVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S2_BREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S2_WLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S2_WVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S3_AWVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S3_BREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S3_WLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S3_WVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S0_ARADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 30 );
  signal NLW_inst_S0_AWADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 30 );
  signal NLW_inst_S1_ARADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 to 31 );
  signal NLW_inst_S1_AWADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 to 31 );
  signal NLW_inst_S2_ARADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 30 to 30 );
  signal NLW_inst_S2_AWADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S2_AWBURST_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S2_AWLEN_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S2_AWSIZE_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S2_WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S2_WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_S3_AWADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S3_AWBURST_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S3_AWLEN_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S3_AWSIZE_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S3_WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S3_WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  attribute ARBITRATION_MODE : integer;
  attribute ARBITRATION_MODE of inst : label is 1;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of ACLK : signal is "xilinx.com:signal:clock:1.0 ACLK CLK";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of ACLK : signal is "slave";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of ACLK : signal is "XIL_INTERFACENAME ACLK, ASSOCIATED_BUSIF M0:M1:S0:S1:S2:S3, ASSOCIATED_RESET ARESETN, FREQ_HZ 99999001, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of ARESETN : signal is "xilinx.com:signal:reset:1.0 ARESETN RST";
  attribute X_INTERFACE_MODE of ARESETN : signal is "slave";
  attribute X_INTERFACE_PARAMETER of ARESETN : signal is "XIL_INTERFACENAME ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M0_ARREADY : signal is "xilinx.com:interface:aximm:1.0 M0 ARREADY";
  attribute X_INTERFACE_INFO of M0_ARVALID : signal is "xilinx.com:interface:aximm:1.0 M0 ARVALID";
  attribute X_INTERFACE_INFO of M0_AWREADY : signal is "xilinx.com:interface:aximm:1.0 M0 AWREADY";
  attribute X_INTERFACE_INFO of M0_AWVALID : signal is "xilinx.com:interface:aximm:1.0 M0 AWVALID";
  attribute X_INTERFACE_INFO of M0_BREADY : signal is "xilinx.com:interface:aximm:1.0 M0 BREADY";
  attribute X_INTERFACE_INFO of M0_BVALID : signal is "xilinx.com:interface:aximm:1.0 M0 BVALID";
  attribute X_INTERFACE_INFO of M0_RLAST : signal is "xilinx.com:interface:aximm:1.0 M0 RLAST";
  attribute X_INTERFACE_INFO of M0_RREADY : signal is "xilinx.com:interface:aximm:1.0 M0 RREADY";
  attribute X_INTERFACE_INFO of M0_RVALID : signal is "xilinx.com:interface:aximm:1.0 M0 RVALID";
  attribute X_INTERFACE_INFO of M0_WLAST : signal is "xilinx.com:interface:aximm:1.0 M0 WLAST";
  attribute X_INTERFACE_INFO of M0_WREADY : signal is "xilinx.com:interface:aximm:1.0 M0 WREADY";
  attribute X_INTERFACE_INFO of M0_WVALID : signal is "xilinx.com:interface:aximm:1.0 M0 WVALID";
  attribute X_INTERFACE_INFO of M1_ARREADY : signal is "xilinx.com:interface:aximm:1.0 M1 ARREADY";
  attribute X_INTERFACE_INFO of M1_ARVALID : signal is "xilinx.com:interface:aximm:1.0 M1 ARVALID";
  attribute X_INTERFACE_INFO of M1_AWREADY : signal is "xilinx.com:interface:aximm:1.0 M1 AWREADY";
  attribute X_INTERFACE_INFO of M1_AWVALID : signal is "xilinx.com:interface:aximm:1.0 M1 AWVALID";
  attribute X_INTERFACE_INFO of M1_BREADY : signal is "xilinx.com:interface:aximm:1.0 M1 BREADY";
  attribute X_INTERFACE_INFO of M1_BVALID : signal is "xilinx.com:interface:aximm:1.0 M1 BVALID";
  attribute X_INTERFACE_INFO of M1_RLAST : signal is "xilinx.com:interface:aximm:1.0 M1 RLAST";
  attribute X_INTERFACE_INFO of M1_RREADY : signal is "xilinx.com:interface:aximm:1.0 M1 RREADY";
  attribute X_INTERFACE_INFO of M1_RVALID : signal is "xilinx.com:interface:aximm:1.0 M1 RVALID";
  attribute X_INTERFACE_INFO of M1_WLAST : signal is "xilinx.com:interface:aximm:1.0 M1 WLAST";
  attribute X_INTERFACE_INFO of M1_WREADY : signal is "xilinx.com:interface:aximm:1.0 M1 WREADY";
  attribute X_INTERFACE_INFO of M1_WVALID : signal is "xilinx.com:interface:aximm:1.0 M1 WVALID";
  attribute X_INTERFACE_INFO of S0_ARREADY : signal is "xilinx.com:interface:aximm:1.0 S0 ARREADY";
  attribute X_INTERFACE_INFO of S0_ARVALID : signal is "xilinx.com:interface:aximm:1.0 S0 ARVALID";
  attribute X_INTERFACE_INFO of S0_AWREADY : signal is "xilinx.com:interface:aximm:1.0 S0 AWREADY";
  attribute X_INTERFACE_INFO of S0_AWVALID : signal is "xilinx.com:interface:aximm:1.0 S0 AWVALID";
  attribute X_INTERFACE_INFO of S0_BREADY : signal is "xilinx.com:interface:aximm:1.0 S0 BREADY";
  attribute X_INTERFACE_INFO of S0_BVALID : signal is "xilinx.com:interface:aximm:1.0 S0 BVALID";
  attribute X_INTERFACE_INFO of S0_RLAST : signal is "xilinx.com:interface:aximm:1.0 S0 RLAST";
  attribute X_INTERFACE_INFO of S0_RREADY : signal is "xilinx.com:interface:aximm:1.0 S0 RREADY";
  attribute X_INTERFACE_INFO of S0_RVALID : signal is "xilinx.com:interface:aximm:1.0 S0 RVALID";
  attribute X_INTERFACE_INFO of S0_WLAST : signal is "xilinx.com:interface:aximm:1.0 S0 WLAST";
  attribute X_INTERFACE_INFO of S0_WREADY : signal is "xilinx.com:interface:aximm:1.0 S0 WREADY";
  attribute X_INTERFACE_INFO of S0_WVALID : signal is "xilinx.com:interface:aximm:1.0 S0 WVALID";
  attribute X_INTERFACE_INFO of S1_ARREADY : signal is "xilinx.com:interface:aximm:1.0 S1 ARREADY";
  attribute X_INTERFACE_INFO of S1_ARVALID : signal is "xilinx.com:interface:aximm:1.0 S1 ARVALID";
  attribute X_INTERFACE_INFO of S1_AWREADY : signal is "xilinx.com:interface:aximm:1.0 S1 AWREADY";
  attribute X_INTERFACE_INFO of S1_AWVALID : signal is "xilinx.com:interface:aximm:1.0 S1 AWVALID";
  attribute X_INTERFACE_INFO of S1_BREADY : signal is "xilinx.com:interface:aximm:1.0 S1 BREADY";
  attribute X_INTERFACE_INFO of S1_BVALID : signal is "xilinx.com:interface:aximm:1.0 S1 BVALID";
  attribute X_INTERFACE_INFO of S1_RLAST : signal is "xilinx.com:interface:aximm:1.0 S1 RLAST";
  attribute X_INTERFACE_INFO of S1_RREADY : signal is "xilinx.com:interface:aximm:1.0 S1 RREADY";
  attribute X_INTERFACE_INFO of S1_RVALID : signal is "xilinx.com:interface:aximm:1.0 S1 RVALID";
  attribute X_INTERFACE_INFO of S1_WLAST : signal is "xilinx.com:interface:aximm:1.0 S1 WLAST";
  attribute X_INTERFACE_INFO of S1_WREADY : signal is "xilinx.com:interface:aximm:1.0 S1 WREADY";
  attribute X_INTERFACE_INFO of S1_WVALID : signal is "xilinx.com:interface:aximm:1.0 S1 WVALID";
  attribute X_INTERFACE_INFO of S2_ARREADY : signal is "xilinx.com:interface:aximm:1.0 S2 ARREADY";
  attribute X_INTERFACE_INFO of S2_ARVALID : signal is "xilinx.com:interface:aximm:1.0 S2 ARVALID";
  attribute X_INTERFACE_INFO of S2_AWREADY : signal is "xilinx.com:interface:aximm:1.0 S2 AWREADY";
  attribute X_INTERFACE_INFO of S2_AWVALID : signal is "xilinx.com:interface:aximm:1.0 S2 AWVALID";
  attribute X_INTERFACE_INFO of S2_BREADY : signal is "xilinx.com:interface:aximm:1.0 S2 BREADY";
  attribute X_INTERFACE_INFO of S2_BVALID : signal is "xilinx.com:interface:aximm:1.0 S2 BVALID";
  attribute X_INTERFACE_INFO of S2_RLAST : signal is "xilinx.com:interface:aximm:1.0 S2 RLAST";
  attribute X_INTERFACE_INFO of S2_RREADY : signal is "xilinx.com:interface:aximm:1.0 S2 RREADY";
  attribute X_INTERFACE_INFO of S2_RVALID : signal is "xilinx.com:interface:aximm:1.0 S2 RVALID";
  attribute X_INTERFACE_INFO of S2_WLAST : signal is "xilinx.com:interface:aximm:1.0 S2 WLAST";
  attribute X_INTERFACE_INFO of S2_WREADY : signal is "xilinx.com:interface:aximm:1.0 S2 WREADY";
  attribute X_INTERFACE_INFO of S2_WVALID : signal is "xilinx.com:interface:aximm:1.0 S2 WVALID";
  attribute X_INTERFACE_INFO of S3_ARREADY : signal is "xilinx.com:interface:aximm:1.0 S3 ARREADY";
  attribute X_INTERFACE_INFO of S3_ARVALID : signal is "xilinx.com:interface:aximm:1.0 S3 ARVALID";
  attribute X_INTERFACE_INFO of S3_AWREADY : signal is "xilinx.com:interface:aximm:1.0 S3 AWREADY";
  attribute X_INTERFACE_INFO of S3_AWVALID : signal is "xilinx.com:interface:aximm:1.0 S3 AWVALID";
  attribute X_INTERFACE_INFO of S3_BREADY : signal is "xilinx.com:interface:aximm:1.0 S3 BREADY";
  attribute X_INTERFACE_INFO of S3_BVALID : signal is "xilinx.com:interface:aximm:1.0 S3 BVALID";
  attribute X_INTERFACE_INFO of S3_RLAST : signal is "xilinx.com:interface:aximm:1.0 S3 RLAST";
  attribute X_INTERFACE_INFO of S3_RREADY : signal is "xilinx.com:interface:aximm:1.0 S3 RREADY";
  attribute X_INTERFACE_INFO of S3_RVALID : signal is "xilinx.com:interface:aximm:1.0 S3 RVALID";
  attribute X_INTERFACE_INFO of S3_WLAST : signal is "xilinx.com:interface:aximm:1.0 S3 WLAST";
  attribute X_INTERFACE_INFO of S3_WREADY : signal is "xilinx.com:interface:aximm:1.0 S3 WREADY";
  attribute X_INTERFACE_INFO of S3_WVALID : signal is "xilinx.com:interface:aximm:1.0 S3 WVALID";
  attribute X_INTERFACE_INFO of M0_ARADDR : signal is "xilinx.com:interface:aximm:1.0 M0 ARADDR";
  attribute X_INTERFACE_INFO of M0_ARBURST : signal is "xilinx.com:interface:aximm:1.0 M0 ARBURST";
  attribute X_INTERFACE_INFO of M0_ARLEN : signal is "xilinx.com:interface:aximm:1.0 M0 ARLEN";
  attribute X_INTERFACE_INFO of M0_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 M0 ARSIZE";
  attribute X_INTERFACE_INFO of M0_AWADDR : signal is "xilinx.com:interface:aximm:1.0 M0 AWADDR";
  attribute X_INTERFACE_MODE of M0_AWADDR : signal is "slave";
  attribute X_INTERFACE_PARAMETER of M0_AWADDR : signal is "XIL_INTERFACENAME M0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M0_AWBURST : signal is "xilinx.com:interface:aximm:1.0 M0 AWBURST";
  attribute X_INTERFACE_INFO of M0_AWLEN : signal is "xilinx.com:interface:aximm:1.0 M0 AWLEN";
  attribute X_INTERFACE_INFO of M0_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 M0 AWSIZE";
  attribute X_INTERFACE_INFO of M0_BRESP : signal is "xilinx.com:interface:aximm:1.0 M0 BRESP";
  attribute X_INTERFACE_INFO of M0_RDATA : signal is "xilinx.com:interface:aximm:1.0 M0 RDATA";
  attribute X_INTERFACE_INFO of M0_RRESP : signal is "xilinx.com:interface:aximm:1.0 M0 RRESP";
  attribute X_INTERFACE_INFO of M0_WDATA : signal is "xilinx.com:interface:aximm:1.0 M0 WDATA";
  attribute X_INTERFACE_INFO of M0_WSTRB : signal is "xilinx.com:interface:aximm:1.0 M0 WSTRB";
  attribute X_INTERFACE_INFO of M1_ARADDR : signal is "xilinx.com:interface:aximm:1.0 M1 ARADDR";
  attribute X_INTERFACE_INFO of M1_ARBURST : signal is "xilinx.com:interface:aximm:1.0 M1 ARBURST";
  attribute X_INTERFACE_INFO of M1_ARLEN : signal is "xilinx.com:interface:aximm:1.0 M1 ARLEN";
  attribute X_INTERFACE_INFO of M1_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 M1 ARSIZE";
  attribute X_INTERFACE_INFO of M1_AWADDR : signal is "xilinx.com:interface:aximm:1.0 M1 AWADDR";
  attribute X_INTERFACE_MODE of M1_AWADDR : signal is "slave";
  attribute X_INTERFACE_PARAMETER of M1_AWADDR : signal is "XIL_INTERFACENAME M1, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M1_AWBURST : signal is "xilinx.com:interface:aximm:1.0 M1 AWBURST";
  attribute X_INTERFACE_INFO of M1_AWLEN : signal is "xilinx.com:interface:aximm:1.0 M1 AWLEN";
  attribute X_INTERFACE_INFO of M1_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 M1 AWSIZE";
  attribute X_INTERFACE_INFO of M1_BRESP : signal is "xilinx.com:interface:aximm:1.0 M1 BRESP";
  attribute X_INTERFACE_INFO of M1_RDATA : signal is "xilinx.com:interface:aximm:1.0 M1 RDATA";
  attribute X_INTERFACE_INFO of M1_RRESP : signal is "xilinx.com:interface:aximm:1.0 M1 RRESP";
  attribute X_INTERFACE_INFO of M1_WDATA : signal is "xilinx.com:interface:aximm:1.0 M1 WDATA";
  attribute X_INTERFACE_INFO of M1_WSTRB : signal is "xilinx.com:interface:aximm:1.0 M1 WSTRB";
  attribute X_INTERFACE_INFO of S0_ARADDR : signal is "xilinx.com:interface:aximm:1.0 S0 ARADDR";
  attribute X_INTERFACE_INFO of S0_ARBURST : signal is "xilinx.com:interface:aximm:1.0 S0 ARBURST";
  attribute X_INTERFACE_INFO of S0_ARLEN : signal is "xilinx.com:interface:aximm:1.0 S0 ARLEN";
  attribute X_INTERFACE_INFO of S0_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 S0 ARSIZE";
  attribute X_INTERFACE_INFO of S0_AWADDR : signal is "xilinx.com:interface:aximm:1.0 S0 AWADDR";
  attribute X_INTERFACE_MODE of S0_AWADDR : signal is "master";
  attribute X_INTERFACE_PARAMETER of S0_AWADDR : signal is "XIL_INTERFACENAME S0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S0_AWBURST : signal is "xilinx.com:interface:aximm:1.0 S0 AWBURST";
  attribute X_INTERFACE_INFO of S0_AWLEN : signal is "xilinx.com:interface:aximm:1.0 S0 AWLEN";
  attribute X_INTERFACE_INFO of S0_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 S0 AWSIZE";
  attribute X_INTERFACE_INFO of S0_BRESP : signal is "xilinx.com:interface:aximm:1.0 S0 BRESP";
  attribute X_INTERFACE_INFO of S0_RDATA : signal is "xilinx.com:interface:aximm:1.0 S0 RDATA";
  attribute X_INTERFACE_INFO of S0_RRESP : signal is "xilinx.com:interface:aximm:1.0 S0 RRESP";
  attribute X_INTERFACE_INFO of S0_WDATA : signal is "xilinx.com:interface:aximm:1.0 S0 WDATA";
  attribute X_INTERFACE_INFO of S0_WSTRB : signal is "xilinx.com:interface:aximm:1.0 S0 WSTRB";
  attribute X_INTERFACE_INFO of S1_ARADDR : signal is "xilinx.com:interface:aximm:1.0 S1 ARADDR";
  attribute X_INTERFACE_INFO of S1_ARBURST : signal is "xilinx.com:interface:aximm:1.0 S1 ARBURST";
  attribute X_INTERFACE_INFO of S1_ARLEN : signal is "xilinx.com:interface:aximm:1.0 S1 ARLEN";
  attribute X_INTERFACE_INFO of S1_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 S1 ARSIZE";
  attribute X_INTERFACE_INFO of S1_AWADDR : signal is "xilinx.com:interface:aximm:1.0 S1 AWADDR";
  attribute X_INTERFACE_MODE of S1_AWADDR : signal is "master";
  attribute X_INTERFACE_PARAMETER of S1_AWADDR : signal is "XIL_INTERFACENAME S1, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S1_AWBURST : signal is "xilinx.com:interface:aximm:1.0 S1 AWBURST";
  attribute X_INTERFACE_INFO of S1_AWLEN : signal is "xilinx.com:interface:aximm:1.0 S1 AWLEN";
  attribute X_INTERFACE_INFO of S1_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 S1 AWSIZE";
  attribute X_INTERFACE_INFO of S1_BRESP : signal is "xilinx.com:interface:aximm:1.0 S1 BRESP";
  attribute X_INTERFACE_INFO of S1_RDATA : signal is "xilinx.com:interface:aximm:1.0 S1 RDATA";
  attribute X_INTERFACE_INFO of S1_RRESP : signal is "xilinx.com:interface:aximm:1.0 S1 RRESP";
  attribute X_INTERFACE_INFO of S1_WDATA : signal is "xilinx.com:interface:aximm:1.0 S1 WDATA";
  attribute X_INTERFACE_INFO of S1_WSTRB : signal is "xilinx.com:interface:aximm:1.0 S1 WSTRB";
  attribute X_INTERFACE_INFO of S2_ARADDR : signal is "xilinx.com:interface:aximm:1.0 S2 ARADDR";
  attribute X_INTERFACE_INFO of S2_ARBURST : signal is "xilinx.com:interface:aximm:1.0 S2 ARBURST";
  attribute X_INTERFACE_INFO of S2_ARLEN : signal is "xilinx.com:interface:aximm:1.0 S2 ARLEN";
  attribute X_INTERFACE_INFO of S2_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 S2 ARSIZE";
  attribute X_INTERFACE_INFO of S2_AWADDR : signal is "xilinx.com:interface:aximm:1.0 S2 AWADDR";
  attribute X_INTERFACE_MODE of S2_AWADDR : signal is "master";
  attribute X_INTERFACE_PARAMETER of S2_AWADDR : signal is "XIL_INTERFACENAME S2, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S2_AWBURST : signal is "xilinx.com:interface:aximm:1.0 S2 AWBURST";
  attribute X_INTERFACE_INFO of S2_AWLEN : signal is "xilinx.com:interface:aximm:1.0 S2 AWLEN";
  attribute X_INTERFACE_INFO of S2_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 S2 AWSIZE";
  attribute X_INTERFACE_INFO of S2_BRESP : signal is "xilinx.com:interface:aximm:1.0 S2 BRESP";
  attribute X_INTERFACE_INFO of S2_RDATA : signal is "xilinx.com:interface:aximm:1.0 S2 RDATA";
  attribute X_INTERFACE_INFO of S2_RRESP : signal is "xilinx.com:interface:aximm:1.0 S2 RRESP";
  attribute X_INTERFACE_INFO of S2_WDATA : signal is "xilinx.com:interface:aximm:1.0 S2 WDATA";
  attribute X_INTERFACE_INFO of S2_WSTRB : signal is "xilinx.com:interface:aximm:1.0 S2 WSTRB";
  attribute X_INTERFACE_INFO of S3_ARADDR : signal is "xilinx.com:interface:aximm:1.0 S3 ARADDR";
  attribute X_INTERFACE_INFO of S3_ARBURST : signal is "xilinx.com:interface:aximm:1.0 S3 ARBURST";
  attribute X_INTERFACE_INFO of S3_ARLEN : signal is "xilinx.com:interface:aximm:1.0 S3 ARLEN";
  attribute X_INTERFACE_INFO of S3_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 S3 ARSIZE";
  attribute X_INTERFACE_INFO of S3_AWADDR : signal is "xilinx.com:interface:aximm:1.0 S3 AWADDR";
  attribute X_INTERFACE_MODE of S3_AWADDR : signal is "master";
  attribute X_INTERFACE_PARAMETER of S3_AWADDR : signal is "XIL_INTERFACENAME S3, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 99999001, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, NUM_READ_OUTSTANDING 2, NUM_WRITE_OUTSTANDING 2, MAX_BURST_LENGTH 256, PHASE 0.0, CLK_DOMAIN design_1_zynq_ultra_ps_e_0_0_pl_clk0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S3_AWBURST : signal is "xilinx.com:interface:aximm:1.0 S3 AWBURST";
  attribute X_INTERFACE_INFO of S3_AWLEN : signal is "xilinx.com:interface:aximm:1.0 S3 AWLEN";
  attribute X_INTERFACE_INFO of S3_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 S3 AWSIZE";
  attribute X_INTERFACE_INFO of S3_BRESP : signal is "xilinx.com:interface:aximm:1.0 S3 BRESP";
  attribute X_INTERFACE_INFO of S3_RDATA : signal is "xilinx.com:interface:aximm:1.0 S3 RDATA";
  attribute X_INTERFACE_INFO of S3_RRESP : signal is "xilinx.com:interface:aximm:1.0 S3 RRESP";
  attribute X_INTERFACE_INFO of S3_WDATA : signal is "xilinx.com:interface:aximm:1.0 S3 WDATA";
  attribute X_INTERFACE_INFO of S3_WSTRB : signal is "xilinx.com:interface:aximm:1.0 S3 WSTRB";
begin
  S0_ARADDR(31) <= \<const0>\;
  S0_ARADDR(30) <= \<const0>\;
  S0_ARADDR(29 downto 0) <= \^s0_araddr\(29 downto 0);
  S0_AWADDR(31) <= \<const0>\;
  S0_AWADDR(30) <= \<const0>\;
  S0_AWADDR(29 downto 0) <= \^s0_awaddr\(29 downto 0);
  S1_ARADDR(31) <= \<const0>\;
  S1_ARADDR(30 downto 0) <= \^s1_araddr\(30 downto 0);
  S1_AWADDR(31) <= \<const0>\;
  S1_AWADDR(30 downto 0) <= \^s1_awaddr\(30 downto 0);
  S2_ARADDR(31) <= \^s2_araddr\(31);
  S2_ARADDR(30) <= \<const0>\;
  S2_ARADDR(29 downto 0) <= \^s2_araddr\(29 downto 0);
  S2_AWADDR(31) <= \<const0>\;
  S2_AWADDR(30) <= \<const0>\;
  S2_AWADDR(29) <= \<const0>\;
  S2_AWADDR(28) <= \<const0>\;
  S2_AWADDR(27) <= \<const0>\;
  S2_AWADDR(26) <= \<const0>\;
  S2_AWADDR(25) <= \<const0>\;
  S2_AWADDR(24) <= \<const0>\;
  S2_AWADDR(23) <= \<const0>\;
  S2_AWADDR(22) <= \<const0>\;
  S2_AWADDR(21) <= \<const0>\;
  S2_AWADDR(20) <= \<const0>\;
  S2_AWADDR(19) <= \<const0>\;
  S2_AWADDR(18) <= \<const0>\;
  S2_AWADDR(17) <= \<const0>\;
  S2_AWADDR(16) <= \<const0>\;
  S2_AWADDR(15) <= \<const0>\;
  S2_AWADDR(14) <= \<const0>\;
  S2_AWADDR(13) <= \<const0>\;
  S2_AWADDR(12) <= \<const0>\;
  S2_AWADDR(11) <= \<const0>\;
  S2_AWADDR(10) <= \<const0>\;
  S2_AWADDR(9) <= \<const0>\;
  S2_AWADDR(8) <= \<const0>\;
  S2_AWADDR(7) <= \<const0>\;
  S2_AWADDR(6) <= \<const0>\;
  S2_AWADDR(5) <= \<const0>\;
  S2_AWADDR(4) <= \<const0>\;
  S2_AWADDR(3) <= \<const0>\;
  S2_AWADDR(2) <= \<const0>\;
  S2_AWADDR(1) <= \<const0>\;
  S2_AWADDR(0) <= \<const0>\;
  S2_AWBURST(1) <= \<const0>\;
  S2_AWBURST(0) <= \<const0>\;
  S2_AWLEN(7) <= \<const0>\;
  S2_AWLEN(6) <= \<const0>\;
  S2_AWLEN(5) <= \<const0>\;
  S2_AWLEN(4) <= \<const0>\;
  S2_AWLEN(3) <= \<const0>\;
  S2_AWLEN(2) <= \<const0>\;
  S2_AWLEN(1) <= \<const0>\;
  S2_AWLEN(0) <= \<const0>\;
  S2_AWSIZE(2) <= \<const0>\;
  S2_AWSIZE(1) <= \<const0>\;
  S2_AWSIZE(0) <= \<const0>\;
  S2_AWVALID <= \<const0>\;
  S2_BREADY <= \<const0>\;
  S2_WDATA(31) <= \<const0>\;
  S2_WDATA(30) <= \<const0>\;
  S2_WDATA(29) <= \<const0>\;
  S2_WDATA(28) <= \<const0>\;
  S2_WDATA(27) <= \<const0>\;
  S2_WDATA(26) <= \<const0>\;
  S2_WDATA(25) <= \<const0>\;
  S2_WDATA(24) <= \<const0>\;
  S2_WDATA(23) <= \<const0>\;
  S2_WDATA(22) <= \<const0>\;
  S2_WDATA(21) <= \<const0>\;
  S2_WDATA(20) <= \<const0>\;
  S2_WDATA(19) <= \<const0>\;
  S2_WDATA(18) <= \<const0>\;
  S2_WDATA(17) <= \<const0>\;
  S2_WDATA(16) <= \<const0>\;
  S2_WDATA(15) <= \<const0>\;
  S2_WDATA(14) <= \<const0>\;
  S2_WDATA(13) <= \<const0>\;
  S2_WDATA(12) <= \<const0>\;
  S2_WDATA(11) <= \<const0>\;
  S2_WDATA(10) <= \<const0>\;
  S2_WDATA(9) <= \<const0>\;
  S2_WDATA(8) <= \<const0>\;
  S2_WDATA(7) <= \<const0>\;
  S2_WDATA(6) <= \<const0>\;
  S2_WDATA(5) <= \<const0>\;
  S2_WDATA(4) <= \<const0>\;
  S2_WDATA(3) <= \<const0>\;
  S2_WDATA(2) <= \<const0>\;
  S2_WDATA(1) <= \<const0>\;
  S2_WDATA(0) <= \<const0>\;
  S2_WLAST <= \<const0>\;
  S2_WSTRB(3) <= \<const0>\;
  S2_WSTRB(2) <= \<const0>\;
  S2_WSTRB(1) <= \<const0>\;
  S2_WSTRB(0) <= \<const0>\;
  S2_WVALID <= \<const0>\;
  S3_AWADDR(31) <= \<const0>\;
  S3_AWADDR(30) <= \<const0>\;
  S3_AWADDR(29) <= \<const0>\;
  S3_AWADDR(28) <= \<const0>\;
  S3_AWADDR(27) <= \<const0>\;
  S3_AWADDR(26) <= \<const0>\;
  S3_AWADDR(25) <= \<const0>\;
  S3_AWADDR(24) <= \<const0>\;
  S3_AWADDR(23) <= \<const0>\;
  S3_AWADDR(22) <= \<const0>\;
  S3_AWADDR(21) <= \<const0>\;
  S3_AWADDR(20) <= \<const0>\;
  S3_AWADDR(19) <= \<const0>\;
  S3_AWADDR(18) <= \<const0>\;
  S3_AWADDR(17) <= \<const0>\;
  S3_AWADDR(16) <= \<const0>\;
  S3_AWADDR(15) <= \<const0>\;
  S3_AWADDR(14) <= \<const0>\;
  S3_AWADDR(13) <= \<const0>\;
  S3_AWADDR(12) <= \<const0>\;
  S3_AWADDR(11) <= \<const0>\;
  S3_AWADDR(10) <= \<const0>\;
  S3_AWADDR(9) <= \<const0>\;
  S3_AWADDR(8) <= \<const0>\;
  S3_AWADDR(7) <= \<const0>\;
  S3_AWADDR(6) <= \<const0>\;
  S3_AWADDR(5) <= \<const0>\;
  S3_AWADDR(4) <= \<const0>\;
  S3_AWADDR(3) <= \<const0>\;
  S3_AWADDR(2) <= \<const0>\;
  S3_AWADDR(1) <= \<const0>\;
  S3_AWADDR(0) <= \<const0>\;
  S3_AWBURST(1) <= \<const0>\;
  S3_AWBURST(0) <= \<const0>\;
  S3_AWLEN(7) <= \<const0>\;
  S3_AWLEN(6) <= \<const0>\;
  S3_AWLEN(5) <= \<const0>\;
  S3_AWLEN(4) <= \<const0>\;
  S3_AWLEN(3) <= \<const0>\;
  S3_AWLEN(2) <= \<const0>\;
  S3_AWLEN(1) <= \<const0>\;
  S3_AWLEN(0) <= \<const0>\;
  S3_AWSIZE(2) <= \<const0>\;
  S3_AWSIZE(1) <= \<const0>\;
  S3_AWSIZE(0) <= \<const0>\;
  S3_AWVALID <= \<const0>\;
  S3_BREADY <= \<const0>\;
  S3_WDATA(31) <= \<const0>\;
  S3_WDATA(30) <= \<const0>\;
  S3_WDATA(29) <= \<const0>\;
  S3_WDATA(28) <= \<const0>\;
  S3_WDATA(27) <= \<const0>\;
  S3_WDATA(26) <= \<const0>\;
  S3_WDATA(25) <= \<const0>\;
  S3_WDATA(24) <= \<const0>\;
  S3_WDATA(23) <= \<const0>\;
  S3_WDATA(22) <= \<const0>\;
  S3_WDATA(21) <= \<const0>\;
  S3_WDATA(20) <= \<const0>\;
  S3_WDATA(19) <= \<const0>\;
  S3_WDATA(18) <= \<const0>\;
  S3_WDATA(17) <= \<const0>\;
  S3_WDATA(16) <= \<const0>\;
  S3_WDATA(15) <= \<const0>\;
  S3_WDATA(14) <= \<const0>\;
  S3_WDATA(13) <= \<const0>\;
  S3_WDATA(12) <= \<const0>\;
  S3_WDATA(11) <= \<const0>\;
  S3_WDATA(10) <= \<const0>\;
  S3_WDATA(9) <= \<const0>\;
  S3_WDATA(8) <= \<const0>\;
  S3_WDATA(7) <= \<const0>\;
  S3_WDATA(6) <= \<const0>\;
  S3_WDATA(5) <= \<const0>\;
  S3_WDATA(4) <= \<const0>\;
  S3_WDATA(3) <= \<const0>\;
  S3_WDATA(2) <= \<const0>\;
  S3_WDATA(1) <= \<const0>\;
  S3_WDATA(0) <= \<const0>\;
  S3_WLAST <= \<const0>\;
  S3_WSTRB(3) <= \<const0>\;
  S3_WSTRB(2) <= \<const0>\;
  S3_WSTRB(1) <= \<const0>\;
  S3_WSTRB(0) <= \<const0>\;
  S3_WVALID <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.design_1_axi_interconnect_0_0_AXI_Interconnect
     port map (
      ACLK => ACLK,
      ARESETN => ARESETN,
      M0_ARADDR(31 downto 0) => M0_ARADDR(31 downto 0),
      M0_ARBURST(1 downto 0) => M0_ARBURST(1 downto 0),
      M0_ARLEN(7 downto 0) => M0_ARLEN(7 downto 0),
      M0_ARREADY => M0_ARREADY,
      M0_ARSIZE(2 downto 0) => M0_ARSIZE(2 downto 0),
      M0_ARVALID => M0_ARVALID,
      M0_AWADDR(31 downto 0) => M0_AWADDR(31 downto 0),
      M0_AWBURST(1 downto 0) => M0_AWBURST(1 downto 0),
      M0_AWLEN(7 downto 0) => M0_AWLEN(7 downto 0),
      M0_AWREADY => M0_AWREADY,
      M0_AWSIZE(2 downto 0) => M0_AWSIZE(2 downto 0),
      M0_AWVALID => M0_AWVALID,
      M0_BREADY => M0_BREADY,
      M0_BRESP(1 downto 0) => M0_BRESP(1 downto 0),
      M0_BVALID => M0_BVALID,
      M0_RDATA(31 downto 0) => M0_RDATA(31 downto 0),
      M0_RLAST => M0_RLAST,
      M0_RREADY => M0_RREADY,
      M0_RRESP(1 downto 0) => M0_RRESP(1 downto 0),
      M0_RVALID => M0_RVALID,
      M0_WDATA(31 downto 0) => M0_WDATA(31 downto 0),
      M0_WLAST => M0_WLAST,
      M0_WREADY => M0_WREADY,
      M0_WSTRB(3 downto 0) => M0_WSTRB(3 downto 0),
      M0_WVALID => M0_WVALID,
      M1_ARADDR(31 downto 0) => M1_ARADDR(31 downto 0),
      M1_ARBURST(1 downto 0) => M1_ARBURST(1 downto 0),
      M1_ARLEN(7 downto 0) => M1_ARLEN(7 downto 0),
      M1_ARREADY => M1_ARREADY,
      M1_ARSIZE(2 downto 0) => M1_ARSIZE(2 downto 0),
      M1_ARVALID => M1_ARVALID,
      M1_AWADDR(31 downto 0) => M1_AWADDR(31 downto 0),
      M1_AWBURST(1 downto 0) => M1_AWBURST(1 downto 0),
      M1_AWLEN(7 downto 0) => M1_AWLEN(7 downto 0),
      M1_AWREADY => M1_AWREADY,
      M1_AWSIZE(2 downto 0) => M1_AWSIZE(2 downto 0),
      M1_AWVALID => M1_AWVALID,
      M1_BREADY => M1_BREADY,
      M1_BRESP(1 downto 0) => M1_BRESP(1 downto 0),
      M1_BVALID => M1_BVALID,
      M1_RDATA(31 downto 0) => M1_RDATA(31 downto 0),
      M1_RLAST => M1_RLAST,
      M1_RREADY => M1_RREADY,
      M1_RRESP(1 downto 0) => M1_RRESP(1 downto 0),
      M1_RVALID => M1_RVALID,
      M1_WDATA(31 downto 0) => M1_WDATA(31 downto 0),
      M1_WLAST => M1_WLAST,
      M1_WREADY => M1_WREADY,
      M1_WSTRB(3 downto 0) => M1_WSTRB(3 downto 0),
      M1_WVALID => M1_WVALID,
      S0_ARADDR(31 downto 30) => NLW_inst_S0_ARADDR_UNCONNECTED(31 downto 30),
      S0_ARADDR(29 downto 0) => \^s0_araddr\(29 downto 0),
      S0_ARBURST(1 downto 0) => S0_ARBURST(1 downto 0),
      S0_ARLEN(7 downto 0) => S0_ARLEN(7 downto 0),
      S0_ARREADY => S0_ARREADY,
      S0_ARSIZE(2 downto 0) => S0_ARSIZE(2 downto 0),
      S0_ARVALID => S0_ARVALID,
      S0_AWADDR(31 downto 30) => NLW_inst_S0_AWADDR_UNCONNECTED(31 downto 30),
      S0_AWADDR(29 downto 0) => \^s0_awaddr\(29 downto 0),
      S0_AWBURST(1 downto 0) => S0_AWBURST(1 downto 0),
      S0_AWLEN(7 downto 0) => S0_AWLEN(7 downto 0),
      S0_AWREADY => S0_AWREADY,
      S0_AWSIZE(2 downto 0) => S0_AWSIZE(2 downto 0),
      S0_AWVALID => S0_AWVALID,
      S0_BREADY => S0_BREADY,
      S0_BRESP(1 downto 0) => S0_BRESP(1 downto 0),
      S0_BVALID => S0_BVALID,
      S0_RDATA(31 downto 0) => S0_RDATA(31 downto 0),
      S0_RLAST => S0_RLAST,
      S0_RREADY => S0_RREADY,
      S0_RRESP(1 downto 0) => S0_RRESP(1 downto 0),
      S0_RVALID => S0_RVALID,
      S0_WDATA(31 downto 0) => S0_WDATA(31 downto 0),
      S0_WLAST => S0_WLAST,
      S0_WREADY => S0_WREADY,
      S0_WSTRB(3 downto 0) => S0_WSTRB(3 downto 0),
      S0_WVALID => S0_WVALID,
      S1_ARADDR(31) => NLW_inst_S1_ARADDR_UNCONNECTED(31),
      S1_ARADDR(30 downto 0) => \^s1_araddr\(30 downto 0),
      S1_ARBURST(1 downto 0) => S1_ARBURST(1 downto 0),
      S1_ARLEN(7 downto 0) => S1_ARLEN(7 downto 0),
      S1_ARREADY => S1_ARREADY,
      S1_ARSIZE(2 downto 0) => S1_ARSIZE(2 downto 0),
      S1_ARVALID => S1_ARVALID,
      S1_AWADDR(31) => NLW_inst_S1_AWADDR_UNCONNECTED(31),
      S1_AWADDR(30 downto 0) => \^s1_awaddr\(30 downto 0),
      S1_AWBURST(1 downto 0) => S1_AWBURST(1 downto 0),
      S1_AWLEN(7 downto 0) => S1_AWLEN(7 downto 0),
      S1_AWREADY => S1_AWREADY,
      S1_AWSIZE(2 downto 0) => S1_AWSIZE(2 downto 0),
      S1_AWVALID => S1_AWVALID,
      S1_BREADY => S1_BREADY,
      S1_BRESP(1 downto 0) => S1_BRESP(1 downto 0),
      S1_BVALID => S1_BVALID,
      S1_RDATA(31 downto 0) => S1_RDATA(31 downto 0),
      S1_RLAST => S1_RLAST,
      S1_RREADY => S1_RREADY,
      S1_RRESP(1 downto 0) => S1_RRESP(1 downto 0),
      S1_RVALID => S1_RVALID,
      S1_WDATA(31 downto 0) => S1_WDATA(31 downto 0),
      S1_WLAST => S1_WLAST,
      S1_WREADY => S1_WREADY,
      S1_WSTRB(3 downto 0) => S1_WSTRB(3 downto 0),
      S1_WVALID => S1_WVALID,
      S2_ARADDR(31) => \^s2_araddr\(31),
      S2_ARADDR(30) => NLW_inst_S2_ARADDR_UNCONNECTED(30),
      S2_ARADDR(29 downto 0) => \^s2_araddr\(29 downto 0),
      S2_ARBURST(1 downto 0) => S2_ARBURST(1 downto 0),
      S2_ARLEN(7 downto 0) => S2_ARLEN(7 downto 0),
      S2_ARREADY => S2_ARREADY,
      S2_ARSIZE(2 downto 0) => S2_ARSIZE(2 downto 0),
      S2_ARVALID => S2_ARVALID,
      S2_AWADDR(31 downto 0) => NLW_inst_S2_AWADDR_UNCONNECTED(31 downto 0),
      S2_AWBURST(1 downto 0) => NLW_inst_S2_AWBURST_UNCONNECTED(1 downto 0),
      S2_AWLEN(7 downto 0) => NLW_inst_S2_AWLEN_UNCONNECTED(7 downto 0),
      S2_AWREADY => '0',
      S2_AWSIZE(2 downto 0) => NLW_inst_S2_AWSIZE_UNCONNECTED(2 downto 0),
      S2_AWVALID => NLW_inst_S2_AWVALID_UNCONNECTED,
      S2_BREADY => NLW_inst_S2_BREADY_UNCONNECTED,
      S2_BRESP(1 downto 0) => B"00",
      S2_BVALID => '0',
      S2_RDATA(31 downto 0) => S2_RDATA(31 downto 0),
      S2_RLAST => S2_RLAST,
      S2_RREADY => S2_RREADY,
      S2_RRESP(1 downto 0) => S2_RRESP(1 downto 0),
      S2_RVALID => S2_RVALID,
      S2_WDATA(31 downto 0) => NLW_inst_S2_WDATA_UNCONNECTED(31 downto 0),
      S2_WLAST => NLW_inst_S2_WLAST_UNCONNECTED,
      S2_WREADY => '0',
      S2_WSTRB(3 downto 0) => NLW_inst_S2_WSTRB_UNCONNECTED(3 downto 0),
      S2_WVALID => NLW_inst_S2_WVALID_UNCONNECTED,
      S3_ARADDR(31 downto 0) => S3_ARADDR(31 downto 0),
      S3_ARBURST(1 downto 0) => S3_ARBURST(1 downto 0),
      S3_ARLEN(7 downto 0) => S3_ARLEN(7 downto 0),
      S3_ARREADY => S3_ARREADY,
      S3_ARSIZE(2 downto 0) => S3_ARSIZE(2 downto 0),
      S3_ARVALID => S3_ARVALID,
      S3_AWADDR(31 downto 0) => NLW_inst_S3_AWADDR_UNCONNECTED(31 downto 0),
      S3_AWBURST(1 downto 0) => NLW_inst_S3_AWBURST_UNCONNECTED(1 downto 0),
      S3_AWLEN(7 downto 0) => NLW_inst_S3_AWLEN_UNCONNECTED(7 downto 0),
      S3_AWREADY => '0',
      S3_AWSIZE(2 downto 0) => NLW_inst_S3_AWSIZE_UNCONNECTED(2 downto 0),
      S3_AWVALID => NLW_inst_S3_AWVALID_UNCONNECTED,
      S3_BREADY => NLW_inst_S3_BREADY_UNCONNECTED,
      S3_BRESP(1 downto 0) => B"00",
      S3_BVALID => '0',
      S3_RDATA(31 downto 0) => S3_RDATA(31 downto 0),
      S3_RLAST => S3_RLAST,
      S3_RREADY => S3_RREADY,
      S3_RRESP(1 downto 0) => S3_RRESP(1 downto 0),
      S3_RVALID => S3_RVALID,
      S3_WDATA(31 downto 0) => NLW_inst_S3_WDATA_UNCONNECTED(31 downto 0),
      S3_WLAST => NLW_inst_S3_WLAST_UNCONNECTED,
      S3_WREADY => '0',
      S3_WSTRB(3 downto 0) => NLW_inst_S3_WSTRB_UNCONNECTED(3 downto 0),
      S3_WVALID => NLW_inst_S3_WVALID_UNCONNECTED
    );
end STRUCTURE;
