--=================================================================================================--
--##################################   Module Information   #######################################--
--=================================================================================================--
--                                                                                         
-- Company:               CERN (PH-ESE-BE)                                                         
-- Engineer:              Manoel Barros Marin (manoel.barros.marin@cern.ch) (m.barros.marin@ieee.org)
--                                                                                                 
-- Project Name:          GBT-FPGA                                                                
-- Module Name:           KC705 - GBT Bank example design                                        
--                                                                                                 
-- Language:              VHDL'93                                                                  
--                                                                                                   
-- Target Device:         KC705 (Xilinx Kintex 7)                                                         
-- Tool version:          ISE 14.5, Vivado 2014.4                                                                
--                                                                                                   
-- Version:               3.1                                                                      
--
-- Description:            
--
-- Versions history:      DATE         VERSION   AUTHOR            DESCRIPTION
--
--                        28/10/2013   3.0       M. Barros Marin   First .vhd module definition   
--                        28/10/2013   3.1       J. Mendez         Vivado support           
--
-- Additional Comments:   Note!! Only ONE GBT Bank with ONE link can be used in this example design.     
--
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!                                                                                           !!
-- !! * The different parameters of the GBT Bank are set through:                               !!  
-- !!   (Note!! These parameters are vendor specific)                                           !!                    
-- !!                                                                                           !!
-- !!   - The MGT control ports of the GBT Bank module (these ports are listed in the records   !!
-- !!     of the file "<vendor>_<device>_gbt_bank_package.vhd").                                !! 
-- !!     (e.g. xlx_v6_gbt_bank_package.vhd)                                                    !!
-- !!                                                                                           !!  
-- !!   - By modifying the content of the file "<vendor>_<device>_gbt_bank_user_setup.vhd".     !!
-- !!     (e.g. xlx_v6_gbt_bank_user_setup.vhd)                                                 !! 
-- !!                                                                                           !! 
-- !! * The "<vendor>_<device>_gbt_bank_user_setup.vhd" is the only file of the GBT Bank that   !!
-- !!   may be modified by the user. The rest of the files MUST be used as is.                  !!
-- !!                                                                                           !!  
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--                                                                                              
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--

-- IEEE VHDL standard library:
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Xilinx devices library:
library unisim;
use unisim.vcomponents.all;

-- Custom libraries and packages:
use work.gbt_bank_package.all;
use work.vendor_specific_gbt_bank_package.all;
use work.gbt_exampledesign_package.all;

--=================================================================================================--
--#######################################   Entity   ##############################################--
--=================================================================================================--

entity kcu105_gbt_example_design is
    port (  
      --===============--     
      -- General reset --     
      --===============--     

      CPU_RESET                                      : in  std_logic;     
      
      --===============--
      -- Clocks scheme --
      --===============-- 
      
      -- System clock:
      ----------------
      SYSCLK_P                                     : in  std_logic;
      SYSCLK_N                                     : in  std_logic;   
            
      -- Fabric clock:
      ----------------     

      USER_CLOCK_P                                   : in  std_logic;
      USER_CLOCK_N                                   : in  std_logic;      
      
      -- MGT(GTX) reference clock:
      ----------------------------
      
      -- Comment: * The MGT reference clock MUST be provided by an external clock generator.
      --
      --          * The MGT reference clock frequency must be 120MHz for the latency-optimized GBT Bank.      
      
      SMA_MGT_REFCLK_P                               : in  std_logic;
      SMA_MGT_REFCLK_N                               : in  std_logic; 
      
      --==========--
      -- MGT(GTX) --
      --==========--                   
      
      -- Serial lanes:
      ----------------
      
      SFP_TX_P                                       : out std_logic;
      SFP_TX_N                                       : out std_logic;
      SFP_RX_P                                       : in  std_logic;
      SFP_RX_N                                       : in  std_logic;    
      
      -- SFP control:
      ---------------
      
      SFP_TX_DISABLE                                 : out std_logic;    
      
      --====================--
      -- Signals forwarding --
      --====================--
      
      -- SMA output:
      --------------
      USER_SMA_GPIO_P                                : out std_logic;    
      USER_SMA_GPIO_N                                : out std_logic     
     

   );
end kcu105_gbt_example_design;

--=================================================================================================--
--####################################   Architecture   ###########################################-- 
--=================================================================================================--

architecture structural of kcu105_gbt_example_design is
   
   --================================ Signal Declarations ================================--          
   
   --===============--
   -- General reset --     
   --===============--     

   signal reset_from_genRst                          : std_logic;    
   
   --===============--
   -- Clocks scheme -- 
   --===============--   
   
   -- Fabric clock:
   ----------------
   
   signal fabricClk_from_userClockIbufgds            : std_logic;     

   -- MGT(GTX) reference clock:     
   ----------------------------     
  
   signal mgtRefClk_from_smaMgtRefClkIbufdsGtxe2     : std_logic;   

    -- Frame clock:
    ---------------
    signal mgtClk_to_Buf                             : std_logic;
    signal mgtClkBuf_to_txPll                        : std_logic;
    signal txFrameClk_from_txPll                     : std_logic;
    
   --=========================--
   -- GBT Bank example design --
   --=========================--
   
   -- Control:
   -----------   
   signal txPllReset                                 : std_logic;   
   signal resetgbtfpga_from_jtag                     : std_logic;
   signal resetgbtfpga_from_vio                      : std_logic;
   signal generalReset_from_user                     : std_logic;      
   signal manualResetTx_from_user                    : std_logic; 
   signal manualResetRx_from_user                    : std_logic; 
   signal clkMuxSel_from_user                        : std_logic;       
   signal testPatterSel_from_user                    : std_logic_vector(1 downto 0); 
   signal loopBack_from_user                         : std_logic_vector(2 downto 0); 
   signal resetDataErrorSeenFlag_from_user           : std_logic; 
   signal resetGbtRxReadyLostFlag_from_user          : std_logic; 
   signal txIsDataSel_from_user                      : std_logic;   
   --------------------------------------------------      
   signal latOptGbtBankTx_from_gbtExmplDsgn          : std_logic;
   signal latOptGbtBankRx_from_gbtExmplDsgn          : std_logic;
   signal txFrameClkPllLocked_from_gbtExmplDsgn      : std_logic;
   signal mgtReady_from_gbtExmplDsgn                 : std_logic; 
   signal rxFrameClkReady_from_gbtExmplDsgn          : std_logic; 
   signal gbtRxReady_from_gbtExmplDsgn               : std_logic;    
   signal rxIsData_from_gbtExmplDsgn                 : std_logic;        
   signal gbtRxReadyLostFlag_from_gbtExmplDsgn       : std_logic; 
   signal rxDataErrorSeen_from_gbtExmplDsgn          : std_logic; 
   signal rxExtrDataWidebusErSeen_from_gbtExmplDsgn  : std_logic; 
   signal rxBitSlipRstCount_from_gbtExmplDsgn        : std_logic_vector(7 downto 0);
   signal rxBitSlipRstOnEvent_from_user              : std_logic;
   
   -- Data:
   --------
   
   signal txData_from_gbtExmplDsgn                   : std_logic_vector(83 downto 0);
   signal rxData_from_gbtExmplDsgn                   : std_logic_vector(83 downto 0);
   --------------------------------------------------      
   signal txExtraDataWidebus_from_gbtExmplDsgn       : std_logic_vector(115 downto 0);
   signal rxExtraDataWidebus_from_gbtExmplDsgn       : std_logic_vector(115 downto 0);
   
   -- Jtag to Axi component and signals:
   --     Used to control the design and monitor the signals in order to
   --     perform automatic tests.
   signal m_axi_awaddr         :  STD_LOGIC_VECTOR(31 DOWNTO 0);
   signal m_axi_awprot         :  STD_LOGIC_VECTOR(2 DOWNTO 0);
   signal m_axi_awvalid         :  STD_LOGIC;
   signal m_axi_awready         :  STD_LOGIC;
   signal m_axi_wdata         :  STD_LOGIC_VECTOR(31 DOWNTO 0);
   signal m_axi_wstrb         :  STD_LOGIC_VECTOR(3 DOWNTO 0);
   signal m_axi_wvalid         :  STD_LOGIC;
   signal m_axi_wready         :  STD_LOGIC;
   signal m_axi_bresp         :  STD_LOGIC_VECTOR(1 DOWNTO 0);
   signal m_axi_bvalid         :  STD_LOGIC;
   signal m_axi_bready         :  STD_LOGIC;
   signal m_axi_araddr         :  STD_LOGIC_VECTOR(31 DOWNTO 0);
   signal m_axi_arprot         :  STD_LOGIC_VECTOR(2 DOWNTO 0);
   signal m_axi_arvalid         :  STD_LOGIC;
   signal m_axi_arready         :  STD_LOGIC;
   signal m_axi_rdata         :  STD_LOGIC_VECTOR(31 DOWNTO 0);
   signal m_axi_rresp         :  STD_LOGIC_VECTOR(1 DOWNTO 0);
   signal m_axi_rvalid         :  STD_LOGIC;
   signal m_axi_rready         :  STD_LOGIC;
    
   -- Vivado synthesis tool does not support mixed-language
   -- Solution: http://www.xilinx.com/support/answers/47454.html
      
   COMPONENT jtagCtrl_gbtfpgaTest
     PORT (
       aclk : IN STD_LOGIC;
       aresetn : IN STD_LOGIC;
       m_axi_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axi_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       m_axi_awvalid : OUT STD_LOGIC;
       m_axi_awready : IN STD_LOGIC;
       m_axi_wdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axi_wstrb : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
       m_axi_wvalid : OUT STD_LOGIC;
       m_axi_wready : IN STD_LOGIC;
       m_axi_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       m_axi_bvalid : IN STD_LOGIC;
       m_axi_bready : OUT STD_LOGIC;
       m_axi_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axi_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       m_axi_arvalid : OUT STD_LOGIC;
       m_axi_arready : IN STD_LOGIC;
       m_axi_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
       m_axi_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
       m_axi_rvalid : IN STD_LOGIC;
       m_axi_rready : OUT STD_LOGIC
     );
   END COMPONENT;      
   
   --===========--
   -- Chipscope --
   --===========--
   
   signal vioControl_from_icon                       : std_logic_vector(35 downto 0); 
   signal txIlaControl_from_icon                     : std_logic_vector(35 downto 0); 
   signal rxIlaControl_from_icon                     : std_logic_vector(35 downto 0); 
   signal gbtErrorDetected                            : std_logic;
   signal modifiedBitsCnt                    : std_logic_vector(7 downto 0);
   signal countWordReceived                : std_logic_vector(31 downto 0);
   signal countBitsModified                : std_logic_vector(31 downto 0);
   signal countWordErrors                    : std_logic_vector(31 downto 0);
   signal gbtModifiedBitFlagFiltered    : std_logic_vector(127 downto 0);
   signal gbtModifiedBitFlag                    : std_logic_vector(83 downto 0);
   
   signal shiftTxClock_from_vio            : std_logic;
   signal txShiftCount_from_vio             : std_logic_vector(7 downto 0);
   signal txAligned_from_gbtbank            : std_logic;
   signal txAlignComputed_from_gbtbank      : std_logic;
   signal txAligned_from_gbtbank_latched        : std_logic;
   
   --------------------------------------------------
   signal sync_from_vio                              : std_logic_vector(11 downto 0);
   signal async_to_vio                               : std_logic_vector(17 downto 0);
      
   signal txEncoding_from_vio              : std_logic;
   signal rxEncoding_from_vio              : std_logic;
   
     COMPONENT xlx_ku_vivado_debug PORT(
        CLK: in std_logic;
        PROBE0: in std_logic_vector(83 downto 0);
        PROBE1: in std_logic_vector(115 downto 0);
        PROBE2: in std_logic_vector(0 downto 0);
        PROBE3: in std_logic_vector(0 downto 0)
     );
     END COMPONENT;

     
     COMPONENT xlx_ku_vio
       PORT (
         clk : IN STD_LOGIC;
         probe_in0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in5 : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
         probe_in6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in13 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         probe_in14 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         probe_in15 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in16 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_in17 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
         probe_out3 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         probe_out4 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out5 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out6 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out7 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out8 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out9 : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
         probe_out10 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out11 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
         probe_out12 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out13 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out14 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
         probe_out15 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
       );
     END COMPONENT;
     
   --=====================--
   -- Latency measurement --
   --=====================--
   signal DEBUG_CLK_ALIGNMENT_debug                  : std_logic_vector(2 downto 0);
   signal txFrameClk_from_gbtExmplDsgn               : std_logic;
   signal txWordClk_from_gbtExmplDsgn                : std_logic;
   signal rxFrameClk_from_gbtExmplDsgn               : std_logic;
   signal rxWordClk_from_gbtExmplDsgn                : std_logic;
   --------------------------------------------------                                    
   signal txMatchFlag_from_gbtExmplDsgn              : std_logic;
   signal rxMatchFlag_from_gbtExmplDsgn              : std_logic;
         
   --================--
   signal sysclk:                    std_logic;  


   COMPONENT vio_tx
     PORT (
       clk : IN STD_LOGIC;
       probe_out0 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
       probe_out1 : OUT STD_LOGIC_VECTOR(79 DOWNTO 0);
       probe_out2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
     );
   END COMPONENT;
   signal static_pattern_scec_s : std_logic_vector( 1 downto 0);
   signal static_pattern_data_s : std_logic_vector(79 downto 0);
   signal static_pattern_extradata_widebus_s : std_logic_vector(31 downto 0);

          
   --=====================================================================================--  
--=================================================================================================--
begin                 --========####   Architecture Body   ####========-- 
--=================================================================================================--
   
   --==================================== User Logic =====================================--
   
   --=============--
   -- SFP control -- 
   --=============-- 
   
   SFP_TX_DISABLE                                    <= '0';   
   
   --===============--
   -- General reset -- 
   --===============--
   -- JB: Reset is issued after CLK_FREQ
   genRst: entity work.xlx_ku_reset 
      generic map (
         CLK_FREQ                                    => 156e6)
      port map (     
         CLK_I                                       => fabricClk_from_userClockIbufgds,
         RESET1_B_I                                  => not CPU_RESET, 
         RESET2_B_I                                  => not generalReset_from_user,
         RESET_O                                     => reset_from_genRst 
      ); 

   --===============--
   -- Clocks scheme -- 
   --===============--   
   
   -- Fabric clock:
   ----------------
   
   -- Comment: USER_CLOCK frequency: 156MHz
   -- JB: USER_CLOCK is actually 125 MHz. Used for VIO and GTH_DPR.
   
   userClockIbufgds: ibufgds
      generic map (
         IBUF_LOW_PWR                                => FALSE,      
         IOSTANDARD                                  => "LVDS_25")
      port map (     
         O                                           => fabricClk_from_userClockIbufgds,   
         I                                           => USER_CLOCK_P,  
         IB                                          => USER_CLOCK_N 
      );
   
   -- MGT(GTX) reference clock:
   ----------------------------
   
   -- Comment: * The MGT reference clock MUST be provided by an external clock generator.
   --
   --          * The MGT reference clock frequency must be 120MHz for the latency-optimized GBT Bank. 
   -- JB: Set reference clock to 40.0789 * 3 = 120.237 MHz
   -- JB: O goes to tranceiver reference clock
   -- JB: O freq == ODIV2 freq when REFCLK_HROW_CK_SEL = 00
   -- JB: ODIV2 goes to ...

   smaMgtRefClkIbufdsGtxe2: ibufds_gte3
      generic map(
        REFCLK_EN_TX_PATH           => '0',
        REFCLK_HROW_CK_SEL          => "00",
        REFCLK_ICNTL_RX             => "00"
      )
      port map (
         O                                           => mgtRefClk_from_smaMgtRefClkIbufdsGtxe2,
         ODIV2                                       => mgtClk_to_Buf,
         CEB                                         => '0',
         I                                           => SMA_MGT_REFCLK_P,
         IB                                          => SMA_MGT_REFCLK_N
      );

    
    -- Frame clock
    
    txPllBuf_inst: bufg_gt
      port map (
         O                                        => mgtClkBuf_to_txPll, 
         I                                        => mgtClk_to_Buf,
         CE                                       => '1',
         DIV                                      => "000",
         CLR                                      => '0',
         CLRMASK                                  => '0',
         CEMASK                                   => '0'
      ); 
      
    -- JB: Creates phase shifted clock (txFrameClk_from_txPll)
    -- JB: SHIFT_IN starts phase shift
    -- JB: SHIFT_COUNT_IN is number of phase shifts. Phase is shifted by 1/32 of VCO period.
    txFrameclkGen_inst: entity work.xlx_ku_tx_phaligner
        Port map( 
            -- Reset
            RESET_IN              => txPllReset,
            
            -- Clocks
            CLK_IN                => mgtClkBuf_to_txPll,
            CLK_OUT               => txFrameClk_from_txPll,
            
            -- Control
            SHIFT_IN              => shiftTxClock_from_vio,
            SHIFT_COUNT_IN        => txShiftCount_from_vio,
            
            -- Status
            LOCKED_OUT            => txFrameClkPllLocked_from_gbtExmplDsgn
        );
          
   --=========================--
   -- GBT Bank example design --
   --=========================--	
   
   gbtExmplDsgn_inst: entity work.xlx_ku_gbt_example_design
       generic map(
          NUM_LINKS                                              => NUM_LINK_Conf,                 -- Up to 4
          TX_OPTIMIZATION                                        => TX_OPTIMIZATION_Conf,          -- LATENCY_OPTIMIZED or STANDARD
          RX_OPTIMIZATION                                        => RX_OPTIMIZATION_Conf,          -- LATENCY_OPTIMIZED or STANDARD
          TX_ENCODING                                            => TX_ENCODING_Conf,         -- GBT_FRAME or WIDE_BUS
          RX_ENCODING                                            => RX_ENCODING_Conf,         -- GBT_FRAME or WIDE_BUS
          
          DATA_GENERATOR_ENABLE                                  => DATA_GENERATOR_ENABLE_Conf,
          DATA_CHECKER_ENABLE                                    => DATA_CHECKER_ENABLE_Conf,
          MATCH_FLAG_ENABLE                                      => MATCH_FLAG_ENABLE_Conf,
          CLOCKING_SCHEME                                        => CLOCKING_SCHEME_Conf
       )
     port map (

       --==============--
       -- Clocks       --
       --==============--
       FRAMECLK_40MHZ                                             => txFrameClk_from_txPll,
       XCVRCLK                                                    => mgtRefClk_from_smaMgtRefClkIbufdsGtxe2,
       
       TX_FRAMECLK_O(1)                                              => txFrameClk_from_gbtExmplDsgn,        
       TX_WORDCLK_O(1)                                               => txWordClk_from_gbtExmplDsgn,          
       RX_FRAMECLK_O(1)                                              => rxFrameClk_from_gbtExmplDsgn,
       RX_WORDCLK_O(1)                                               => rxWordClk_from_gbtExmplDsgn,      
       
       RX_FRAMECLK_RDY_O(1)                                          => rxFrameClkReady_from_gbtExmplDsgn,
       
       --==============--
       -- Reset        --
       --==============--
       GBTBANK_GENERAL_RESET_I                                    => reset_from_genRst,
       GBTBANK_MANUAL_RESET_TX_I                                  => manualResetTx_from_user,
       GBTBANK_MANUAL_RESET_RX_I                                  => manualResetRx_from_user,
       
       --==============--
       -- Serial lanes --
       --==============--
       GBTBANK_MGT_RX_P(1)                                        => SFP_RX_P,
       GBTBANK_MGT_RX_N(1)                                        => SFP_RX_N,
       GBTBANK_MGT_TX_P(1)                                        => SFP_TX_P,
       GBTBANK_MGT_TX_N(1)                                        => SFP_TX_N,
       
       --==============--
       -- Data         --
       --==============--        
       GBTBANK_GBT_DATA_I(1)                                      => (others => '0'),
       GBTBANK_WB_DATA_I(1)                                       => (others => '0'),
       
       TX_DATA_O(1)                                               => txData_from_gbtExmplDsgn,            
       WB_DATA_O(1)                                               => txExtraDataWidebus_from_gbtExmplDsgn,
       
       GBTBANK_GBT_DATA_O(1)                                      => rxData_from_gbtExmplDsgn,
       GBTBANK_WB_DATA_O(1)                                       => rxExtraDataWidebus_from_gbtExmplDsgn,
       
       --==============--
       -- Reconf.         --
       --==============--
       GBTBANK_MGT_DRP_RST                                        => '0',
       GBTBANK_MGT_DRP_CLK                                        => fabricClk_from_userClockIbufgds,
       
       --==============--
       -- TX ctrl      --
       --==============--
       TX_ENCODING_SEL_i(1)                                      => txEncoding_from_vio,
       GBTBANK_TX_ISDATA_SEL_I(1)                                => txIsDataSel_from_user,
       GBTBANK_TEST_PATTERN_SEL_I                                => testPatterSel_from_user, 
       
       --==============--
       -- RX ctrl      --
       --==============--
       RX_ENCODING_SEL_i(1)                                      => rxEncoding_from_vio,
       GBTBANK_RESET_GBTRXREADY_LOST_FLAG_I(1)                   => resetGbtRxReadyLostFlag_from_user,
       GBTBANK_RESET_DATA_ERRORSEEN_FLAG_I(1)                    => resetDataErrorSeenFlag_from_user,
       GBTBANK_RXFRAMECLK_ALIGNPATTER_I                          => DEBUG_CLK_ALIGNMENT_debug,
       GBTBANK_RXBITSLIT_RSTONEVEN_I(1)                          => rxBitSlipRstOnEvent_from_user,
       
       --==============--
       -- TX Status    --
       --==============--
       GBTBANK_LINK_READY_O(1)                                   => mgtReady_from_gbtExmplDsgn,
       GBTBANK_TX_MATCHFLAG_O                                    => txMatchFlag_from_gbtExmplDsgn,
       GBTBANK_TX_ALIGNED_O(1)                                   => txAligned_from_gbtbank,
       GBTBANK_TX_ALIGNCOMPUTED_O(1)                             => txAlignComputed_from_gbtbank,
       
       --==============--
       -- RX Status    --
       --==============--
       GBTBANK_GBTRX_READY_O(1)                                  => gbtRxReady_from_gbtExmplDsgn, --
       GBTBANK_GBTRXREADY_LOST_FLAG_O(1)                         => gbtRxReadyLostFlag_from_gbtExmplDsgn, --
       GBTBANK_RXDATA_ERRORSEEN_FLAG_O(1)                        => rxDataErrorSeen_from_gbtExmplDsgn, --
       GBTBANK_RXEXTRADATA_WIDEBUS_ERRORSEEN_FLAG_O(1)           => rxExtrDataWidebusErSeen_from_gbtExmplDsgn, --
       GBTBANK_RX_MATCHFLAG_O(1)                                 => rxMatchFlag_from_gbtExmplDsgn, --
       GBTBANK_RX_ISDATA_SEL_O(1)                                => rxIsData_from_gbtExmplDsgn, --
       GBTBANK_RX_ERRORDETECTED_O(1)                             => gbtErrorDetected,
       GBTBANK_RX_BITMODIFIED_FLAG_O(1)                          => gbtModifiedBitFlag,
       GBTBANK_RXBITSLIP_RST_CNT_O(1)                            => rxBitSlipRstCount_from_gbtExmplDsgn,
       
       --==============--
       -- XCVR ctrl    --
       --==============--
       GBTBANK_LOOPBACK_I                                        => loopBack_from_user, --
       
       GBTBANK_TX_POL(1)                                         => '0',
       GBTBANK_RX_POL(1)                                         => '0',

		--==============--
		-- TX VIO       --
		--==============--
        STATIC_PATTERN_SCEC_I                                    => static_pattern_scec_s,
        STATIC_PATTERN_DATA_I                                    => static_pattern_data_s,
        STATIC_PATTERN_EXTRADATA_WIDEBUS_I                       => static_pattern_extradata_widebus_s

  ); 
   --=====================================--
   -- BER                                 --
   --=====================================--
   countWordReceivedProc: PROCESS(reset_from_genRst, rxframeclk_from_gbtExmplDsgn)
   begin
   
       if reset_from_genRst = '1' then
           countWordReceived <= (others => '0');
           countBitsModified <= (others => '0');
           countWordErrors    <= (others => '0');
           
       elsif rising_edge(rxframeclk_from_gbtExmplDsgn) then
           if gbtRxReady_from_gbtExmplDsgn = '1' then
               
               if gbtErrorDetected = '1' then
                   countWordErrors    <= std_logic_vector(unsigned(countWordErrors) + 1 );                
               end if;
               
               countWordReceived <= std_logic_vector(unsigned(countWordReceived) + 1 );
           end if;
           
           countBitsModified <= std_logic_vector(unsigned(modifiedBitsCnt) + unsigned(countBitsModified) );
       end if;
   end process;
   
   gbtModifiedBitFlagFiltered(127 downto 84) <= (others => '0');
   gbtModifiedBitFlagFiltered(83 downto 0) <= gbtModifiedBitFlag when gbtRxReady_from_gbtExmplDsgn = '1' else
                                              (others => '0');
   
   -- JB: Counts the number of '1' in bit vector.
   countOnesCorrected: entity work.CountOnes
       Generic map (SIZE           => 128,
                    MAXOUTWIDTH        => 8
       )
       Port map( 
           Clock    => rxframeclk_from_gbtExmplDsgn, -- Warning: Because the enable signal (1 over 3 or 6 clock cycle) is not used, the number of error is multiplied by 3 or 6.
           I        => gbtModifiedBitFlagFiltered,
           O        => modifiedBitsCnt);            
               
   --==============--   
   -- Test control --   
   --==============--
   jtag_master_inst : jtagCtrl_gbtfpgaTest
          PORT MAP (
            aclk => txFrameClk_from_txPll,
            aresetn => txFrameClkPllLocked_from_gbtExmplDsgn,
            m_axi_awaddr => m_axi_awaddr,
            m_axi_awprot => m_axi_awprot,
            m_axi_awvalid => m_axi_awvalid,
            m_axi_awready => m_axi_awready,
            m_axi_wdata => m_axi_wdata,
            m_axi_wstrb => m_axi_wstrb,
            m_axi_wvalid => m_axi_wvalid,
            m_axi_wready => m_axi_wready,
            m_axi_bresp => m_axi_bresp,
            m_axi_bvalid => m_axi_bvalid,
            m_axi_bready => m_axi_bready,
            m_axi_araddr => m_axi_araddr,
            m_axi_arprot => m_axi_arprot,
            m_axi_arvalid => m_axi_arvalid,
            m_axi_arready => m_axi_arready,
            m_axi_rdata => m_axi_rdata,
            m_axi_rresp => m_axi_rresp,
            m_axi_rvalid => m_axi_rvalid,
            m_axi_rready => m_axi_rready
          );
   
     gbtfpga_controller_inst: entity work.gbtfpga_controller
         Port map( 
           
             -- AXI4LITE Interface
             S_AXI_ACLK            => txFrameClk_from_txPll,
             S_AXI_ARESETN         => txFrameClkPllLocked_from_gbtExmplDsgn,
             S_AXI_AWADDR          => m_axi_awaddr(4 downto 0),
             S_AXI_AWVALID         => m_axi_awvalid,
             S_AXI_AWREADY         => m_axi_awready,
             S_AXI_WDATA           => m_axi_wdata,
             S_AXI_WSTRB           => m_axi_wstrb,
             S_AXI_WVALID          => m_axi_wvalid,
             S_AXI_WREADY          => m_axi_wready,
             S_AXI_BRESP           => m_axi_bresp,
             S_AXI_BVALID          => m_axi_bvalid,
             S_AXI_BREADY          => m_axi_bready,
             S_AXI_ARADDR          => m_axi_araddr(4 downto 0),
             S_AXI_ARVALID         => m_axi_arvalid,
             S_AXI_ARREADY         => m_axi_arready,
             S_AXI_RDATA           => m_axi_rdata,
             S_AXI_RRESP           => m_axi_rresp,
             S_AXI_RVALID          => m_axi_rvalid,
             S_AXI_RREADY          => m_axi_rready,
           
             -- To GBT-FPGA
             reset_gbtfpga         => resetgbtfpga_from_jtag,
           
             -- From GBT-FPGA
             gbtRxReady            => gbtRxReady_from_gbtExmplDsgn
         );
             
     sysclk_inst: ibufds
         port map (
            I                                           => SYSCLK_P,
            IB                                          => SYSCLK_N,
            O                                           => sysclk
         ); 
    
    txILa: xlx_ku_vivado_debug
         port map (
            CLK => sysclk,
            PROBE0 => txData_from_gbtExmplDsgn,
            PROBE1 => txExtraDataWidebus_from_gbtExmplDsgn,
            PROBE2(0) => txIsDataSel_from_user,
            PROBE3(0) => '0'
         );  
   
    rxIla: xlx_ku_vivado_debug
         port map (
            CLK => sysclk,
            PROBE0 => rxData_from_gbtExmplDsgn,
            PROBE1 => rxExtraDataWidebus_from_gbtExmplDsgn,
            PROBE2(0) => rxIsData_from_gbtExmplDsgn,
            PROBE3(0) => gbtErrorDetected
         );  
    
    generalReset_from_user  <= resetgbtfpga_from_vio or resetgbtfpga_from_jtag or not(txFrameClkPllLocked_from_gbtExmplDsgn);
        
    alignmenetLatchProc: process(txFrameClk_from_txPll)
    begin
    
        if reset_from_genRst = '1' then
            txAligned_from_gbtbank_latched <= '0';
            
        elsif rising_edge(txFrameClk_from_txPll) then
        
           if txAlignComputed_from_gbtbank = '1' then
                txAligned_from_gbtbank_latched <= txAligned_from_gbtbank;
           end if;
           
        end if;
    end process;

    vio_tx_i : vio_tx
      PORT MAP (
        clk => txFrameClk_from_gbtExmplDsgn,
        probe_out0 => static_pattern_scec_s,
        probe_out1 => static_pattern_data_s,
        probe_out2 => static_pattern_extradata_widebus_s
      );

      
    vio : xlx_ku_vio
       PORT MAP (
         clk => fabricClk_from_userClockIbufgds,
         
         probe_in0(0) => rxIsData_from_gbtExmplDsgn,
         probe_in1(0) => txFrameClkPllLocked_from_gbtExmplDsgn,
         probe_in2(0) => latOptGbtBankTx_from_gbtExmplDsgn,
         probe_in3(0) => mgtReady_from_gbtExmplDsgn,
         probe_in4(0) => '0',
         probe_in5    => (others => '0'),
         probe_in6(0) => rxFrameClkReady_from_gbtExmplDsgn,
         probe_in7(0) => gbtRxReady_from_gbtExmplDsgn,
         probe_in8(0) => gbtRxReadyLostFlag_from_gbtExmplDsgn,
         probe_in9(0) => rxDataErrorSeen_from_gbtExmplDsgn,
         probe_in10(0) => rxExtrDataWidebusErSeen_from_gbtExmplDsgn,
         probe_in11(0) => '0',
         probe_in12(0) => latOptGbtBankRx_from_gbtExmplDsgn,
         probe_in13    => countBitsModified,
         probe_in14    => countWordReceived,
         probe_in15(0)    => txAligned_from_gbtbank_latched,
         probe_in16(0)    => txAlignComputed_from_gbtbank,
         probe_in17       => rxBitSlipRstCount_from_gbtExmplDsgn,
         probe_out0(0) => resetgbtfpga_from_vio,
         probe_out1(0) => clkMuxSel_from_user,
         probe_out2 => testPatterSel_from_user,
         probe_out3 => loopBack_from_user,
         probe_out4(0) => resetDataErrorSeenFlag_from_user,
         probe_out5(0) => resetGbtRxReadyLostFlag_from_user,
         probe_out6(0) => txIsDataSel_from_user,
         probe_out7(0) => manualResetTx_from_user,
         probe_out8(0) => manualResetRx_from_user,
         probe_out9    => DEBUG_CLK_ALIGNMENT_debug,
         probe_out10(0) => shiftTxClock_from_vio,
         probe_out11    => txShiftCount_from_vio,
         probe_out12(0) => rxBitSlipRstOnEvent_from_user,
         probe_out13(0) => txPllReset,
         probe_out14(0) => txEncoding_from_vio,
         probe_out15(0) => rxEncoding_from_vio
       );
             
    latOptGbtBankTx_from_gbtExmplDsgn                       <= '1';
    latOptGbtBankRx_from_gbtExmplDsgn                       <= '1';
                                                              
   -- Latency measurement --     
   --=====================--
                                                           
   USER_SMA_GPIO_P                                   <= txWordClk_from_gbtExmplDsgn when clkMuxSel_from_user = '1' else
                                                        txMatchFlag_from_gbtExmplDsgn;
                                                           
   USER_SMA_GPIO_N                                   <= txFrameClk_from_txPll when clkMuxSel_from_user = '1' else
                                                        rxMatchFlag_from_gbtExmplDsgn;
   
   --=====================================================================================--   
end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
