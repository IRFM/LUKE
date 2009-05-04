cd JETlike/EQUIL
delete('*.mat')
make_equil_JETliketest
make_equil_JETliketest_bis
cd ../WAVE
delete('*.mat')
make_wave_JETliketest
make_wave_JETliketest_bis
cd ../..
%
cd PLT/EQUIL
delete('*.mat')
make_equil_PLTtest
cd ../WAVE
delete('*.mat')
make_wave_PLTtest
cd ../..
%
cd RTtest/EQUIL
delete('*.mat')
make_equil_RTtest
make_equil_RTtest_vacuum
cd ../WAVE
delete('*.mat')
make_wave_RTtest
make_wave_RTtest_straight
cd ../..
%
cd VERSATOR2/EQUIL
delete('*.mat')
make_equil_VERSATOR2test
cd ../WAVE
delete('*.mat')
make_wave_VERSATOR2test
cd ../..
%
cd RFP/EQUIL
delete('*.mat')
make_equil_RFP
cd ../WAVE
delete('*.mat')
make_rayinit_RFP
make_wave_RFP
cd ../..
%
