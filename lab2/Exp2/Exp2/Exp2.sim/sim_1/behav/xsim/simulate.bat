@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Tue Oct 19 08:57:32 +0800 2021
REM SW Build 3064766 on Wed Nov 18 09:12:45 MST 2020
REM
REM Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim core_sim_behav -key {Behavioral:sim_1:Functional:core_sim} -tclbatch core_sim.tcl -view E:/arch_labs_2021/lab2/Exp2/Exp2/code/sim/core_sim_behav.wcfg -log simulate.log"
call xsim  core_sim_behav -key {Behavioral:sim_1:Functional:core_sim} -tclbatch core_sim.tcl -view E:/arch_labs_2021/lab2/Exp2/Exp2/code/sim/core_sim_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
