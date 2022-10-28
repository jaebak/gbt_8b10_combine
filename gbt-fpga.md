GBT-FPGA IP
===========
The GBTx is a radiation tolerant chip that can be used to implement multipurpose high speed (3.2-4.48 Gbps user bandwidth) bidirectional optical links for high-energy physics experiments. Logically the link provides three “distinct” data paths for Timing and Trigger Control (TTC), Data Acquisition (DAQ) and Slow Control (SC) information. In practice, the three logical paths do not need to be physically separated and are merged on a single optical link as indicated in Figure 1. The aim of such architecture is to allow a single bidirectional link to be used simultaneously for data readout, trigger data, timing control distribution, and experiment slow control and monitoring. This link establishes a point-to-point, optical, bidirectional (two fibres), constant latency connection that can function with very high reliability in the harsh radiation environment typical of high energy physics experiments at LHC.

<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/generalArchitecture.png">
</p>

The development of the proposed link is conceptually divided into two distinct but complementary parts: the GBT link chips and the Versatile link opto components. The versatile link selects and qualifies appropriate fibres and opto-electronic components for use in radiation. The GBT develops and qualifies the required radiation hard ASICs. The link is implemented by a combination of custom developed and Commercial-Off-The-Shelf (COTS) components. In the counting room the receiver and transmitters are implemented using COTS components and FPGA’s. Embedded in the experiments, the receivers and transmitters are implemented by the GBT chipset and the Versatile Link optoelectronic components. This architecture clearly distinguishes between the counting room and front-end electronics because of the very different radiation environments. The on-detector front-end electronics works in a hostile radiation environment requiring custom made components. The counting room components operate in a radiation free environment and can be implemented by COTS components. The use of COTS components in the counting house allows this part of the link to take full advantage of the latest commercial technologies and components (e.g. FPGA) enabling efficient data concentration and data processing from many front-end sources to be implemented in very compact and cost efficient trigger and DAQ interface systems. The firmware required to allow these FPGAs to communicate with the GBTx chipset over the versatile link is handled by the GBT-FPGA project.

**Links:**

* **Sharepoint:** <a href="https://espace.cern.ch/GBT-Project/GBT-FPGA">GBT-FPGA: Sharepoint</a>
* **Documentation:** <a href="https://gbt-fpga.web.cern.ch">GBT-FPGA</a>
* **SVN:** <a href="https://svnweb.cern.ch/cern/wsvn/ph-ese/be/gbt_fpga">CERN WebSVN</a>
* **GIT:** <a href="#">CERN GitLAB</a>

# Tools:

This current version of the GBT-FPGA has been compiled using:

* Quartus 16.1.0
* Vivado 2016.3

The decision was taken to only move to the latest version of the tools on new releases. However, we provide support in case the IP migration requires modification on the firmware or causes trouble. 

Therefore, we could generate new releases if big changes are required (the previous releases would still be accessible using the former tags).
Please, do not hesitate to contact the gbt-fpga-support in case of problem.

# Outline:
* [The GBT-FPGA Project Mandate](#the-gbt-fpga-project-mandate)

* [GBT-FPGA Core Overview](#gbt-fpga-core-overview)
    * [Standard vs Latency-Optimized](#standard-vs-latency-optimized)
    * [Data Frame & Encodings](#data-frame-encodings)
    * [Single-Link vs Multi-Link Instantiation](#single-link-vs-multi-link-instantiation)

* [Clock and Reset schemes](#clock-and-reset-schemes)
    * [Clocking scheme](#clocking-scheme)
    * [Reset scheme](#reset-scheme)

# The GBT-FPGA Project Mandate:
Initiated in 2009 to emulate the GBTx serial link and test the first GBTx prototypes, the GBT-FPGA project developed first to provide the users with a basic “starter kit” allowing them to get used to the GBTx protocol. As the features of the GBTx ASIC inflated during design phase together with the users’ requirements, the GBT-FPGA project followed naturally and grew up as well. This GBT-FPGA core is now a full library, targeting FPGAs from ALTERA and XILINX, allowing the implementation of one or several GBT links of 2 different types: “Standard” or “Latency-Optimized” (providing low, fixed and deterministic latency either on Tx, Rx or on both). These links can be also configured to provide any encoding mode offered by the GBTx: the “GBT-Frame” mode (Reed-Solomon based) or the “Wide-Bus” mode (no encoding). The GBT-FPGA core is freely available from SVN, and can be instantiated on Back-End FPGAs, but it can also be used as a GBTx emulator for the serial link. As such, the core is fully configurable in any of the above described options. For obvious reasons, the GBT-FPGA core will not offer firmware versions for each FPGA type on the market. It targets the main vendors and the main series. The design effort on new series is foreseen to stop during 2014. The evolution of the core to follow-up the technology will thus depend on users’ contributions. 

# GBT-FPGA Core Overview
The GBT-FPGA core has been designed to facilitate the in-system implementation and the user support of the GBT-FPGA. Therefore, the different components of the GBT-FPGA Core are integrated in a single module called "*GBT Bank*". Each GBT Link is composed by a GBT Tx, a GBT Rx (both together will be referred to as “GBT Logic”) and a Multi-Gigabit Transceiver (MGT). The number of GBT Links of the GBT Bank as well as the two encoding schemes proposed by the GBTx ASIC ("GBT-Frame" (Reed-Solomon) and "Wide-Bus") and the  two types of optimization ("Standard" and "Latency-Optimized") shall be configured at implementation time using the generic parameters of the core.

<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/GeneralBlockDiagram.png">
</p>

## Standard vs Latency-Optimized
Trigger related electronic systems in High Energy Physics (HEP) experiments, such as Timing Trigger and Control (TTC), require a fixed, low and deterministic latency in the transmission of the clock and data to ensure correct event building. On the other hand, other electronic systems that are not time critical, such as Data Acquisition (DAQ), do not need to comply with this requirement. The GBT-FPGA project provides two types of implementation for the transmitter and the receiver: the “Standard” version, targeted for non-time critical applications and the “Latency-Optimized” version, ensuring a fixed, low and deterministic latency of the clock and data (at the cost of a more complex implementation).

**Bunch Crossing clock scheme:**

|                      | Latency optimized | Standard   | External path delay | MGT Ref clock     |
|----------------------|:-----------------:|:----------:|:-------------------:|:-----------------:|
| Altera Arria 10      | 203.5ns *         | 497.4ns *  | 53.2ns              | 240MHz            |
| Xilinx Kintex 7      | 258.7ns *         | 550.2ns *  | 50.0ns              | 120MHz            |
| Xilinx Virtex 7      | 260.3ns *         | 550.0ns *  | 52.8ns              | 120MHz            |
| Xilinx Kintex Uscale | 212.3ns *         | 499.2ns *  | 52.2ns              | 120MHz            |

<span>* Including external path delay</span>

**Unified clock scheme:**

|                      | Latency optimized | Standard   | External path delay | MGT Ref clock     |
|----------------------|:-----------------:|:----------:|:-------------------:|:-----------------:|
| Altera Arria 10      | 188.3ns *         | 293.4ns *  | 53.2ns              | 240MHz            |
| Xilinx Kintex 7      | 242.6ns *         | 376.6ns *  | 50.0ns              | 120MHz            |
| Xilinx Virtex 7      | 243.4ns *         | 376.4ns *  | 52.8ns              | 120MHz            |
| Xilinx Kintex Uscale | 198.8ns *         | 332.2ns *  | 52.2ns              | 120MHz            |

<span>* Including external path delay</span>

***Note***: All of the measurement are made using external loopback (fibre). The External path delay is the latency added by the copper line, SFP and the fibre.

## Data Frame & Encodings
As previously mentioned, the GBT-FPGA supports the two available encoding schemes proposed by the GBTx. The "GBT-Frame", shown in Figure 4, adopts the Reed-Solomon that can correct bursts of bit errors caused by Single Event Upsets (SEU). This encoding scheme can be used for Data Acquisition (DAQ), Timing Trigger & Control (TTC) and Experiment Control (EC). For the “Wide-Bus”, shown in Figure 5, the FEC field is fully replaced by user data at the cost of no error detection nor correction capability. This encoding scheme can only be used for DAQ and EC in the uplink direction.

<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/supportedEncodings.png">
</p>

## Single-Link vs Multi-Link Instantiation
One of the aims of the GBT-FPGA Core is to facilitate the implementation of single-link and multi-link GBT-based systems. For that reason, the GBT-FPGA Core has been designed in such a way that for implementing either single-link or multi-link GBT-based systems, it is only necessary to set the number of desired GBT Links through the generic parameters and to provide the external required resources (e.g. clocking resources, reset resources, etc.). The maximum number of GBT Links per GBT Bank is limited by the architecture of the targeted FPGA. The concept behind the design of the GBT Core is to keep each GBT Bank as an independent entity in terms of both logic and clocking resources. In applications that require more GBT Links than the number provided by a single GBT Bank, it is possible to add more GBT Links by instantiating GBT Banks in parallel. The maximum number of GBT Banks is also device dependent.

Maximum number of link per bank:
* **Altera**: 6 links (1 bank)
* **Xilinx**: 4 links (1 quad)

# Clock and Reset schemes
The GBT-FPGA IP was designed to support two clocking schemes: using a 40MHz clock (Bunch Crossing [BC] clock) or the transceiver's word clock (multiple of the BC clock). Concerning the reset scheme, a specific scheme detailled below shall be implemented.

<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/globalResetClockScheme.png">
</p>

## Clocking scheme
The GBT-FPGA core required 3 different clocks for the encoding, decoding and the transceiver. The transceiver clock frequency depends on the FPGA: 120MHz for the Xilinx's FPGA and 240MHz for the Altera's ones. The GBT core was designed to allow running the logic either at 40MHz or at the transceiver's wordclock frequency. No extra configuration is required and only the constraints differs between the two configurations.

**Clocking scheme to run the core at 40MHz (Bunch Crossing Clocking Scheme)**:
<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/BCClockScheme.png">
</p>

With this clock scheme, the Tx and Rx words can be clocked with a 40MHz synchronous with the BC crossing clock. Nevertheless, that makes the clocking more complex because of the use of two different clock domain on each path. Therefore, the phase relationship between the Tx worclk and the Tx frameclock must be monitored and controlled (see ref. note: *GBT_FPGA: Tx frameclock alignment*). In addition, the generation of the 40MHz clock used for the Rx logic from the Rx wordclock imply to control a clock division process (based either on a PLL or a Gated clock). The same phase has to be selected after each reset, making the design delicate (see ref. note: *GBT-FPGA: Rx frameclock generation*).

**Clocking scheme to run the core at 120/240MHz** (Unified Clocking Scheme)**:
<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/MGTClockScheme.png">
</p>

This clock scheme simplifies the GBT core cloking scheme but implies to clock the upstream and dowstream logic with a 240/120MHz clock with multicycle constraints. Therefore, that makes the constraint a bit more difficult to define and requires to manage the clock domain crossing from the user's clocks to the transceiver's clocks into the user code. Nevertheless, when the GBT transceivers are connected to others transceiver, the full MGT clock scheme can make the clocking easier.

## Reset scheme
The GBT-FPGA IP resets must be controlled following a specific state machine detailled below:

<p align="center">
    <img src="http://gbt-fpga.web.cern.ch/img/resetScheme.png">
</p>

Nevretheless, because all of the reset signals be managed synchronously with their associated clock domain:
* **MGT_TXRESET_i**: MGT_CLK_i
* **MGT_RXRESET_i**: MGT_CLK_i
* **GBT_TXRESET_i**: GBT_TXFRAMECLK_i
* **GBT_RXRESET_i**: GBT_RXFRAMECLK_i
