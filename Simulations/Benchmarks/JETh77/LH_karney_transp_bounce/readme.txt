Benchmark for the JET77 transport case - 10/18/2010

1) Old reference was obtained with /luke/LUKE_1_4 (figure is a bit different to the one submitted to CPC in 2008 with a modified LUKE 1_5... not explained yet)

2) With LUKE 1_8 and new equil, local Te is lower and current is an order of magnitude below (case bad_equil)

3) With LUKE 1_8 and old equil, current is at right level but slight visual differences. DQL is too small by ~10%,
	because of rfdiff_dke_jd l.343 : bD0_rf = bD0_rf./(1 + bxb_rf/Rp); (case old_equil). Try function test.m

4) With LUKE 1_8 and old equil and rfdiff_dke_jd l.343 commented, the figure and DQL are correct again. Verified numerically
	=> link is validated. (case old_equil_rfdiff)

5) Now new equil with different eTe1, ene1, eTi1 to have similar temperature and density profiles => gives very similar figures
	=> validation LUKE 1_8 complete