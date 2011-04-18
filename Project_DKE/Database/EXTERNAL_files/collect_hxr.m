for i=1:length(shot),
  mdsopen(shot(i));
  hxr{i}=reshape(mdsdata([ ...
	'2*[getnci("\\diagz::hxr_counts:chord_00%:channel_00%","record"),', ...
	'getnci("\\diagz::hxr_counts:chord_01%:channel_00%","record")]']), ...
	1023,8,19);
  t{i}=mdsdata('dim_of(\diagz::hxr_counts:chord_015:channel_001)');
  energy{i}=mdsdata('\diagz::hxr_thresholds');
  filter_thickness{i}=mdsdata('\diagz::hxr_filter:thickness');
  filter_material{i}=mdsdata('\diagz::hxr_filter:material');
  mdsclose
end
beta(1:4)=NaN;
beta(5:18)= ...
[183.3893  182.6976  181.7569  180.8162  179.8755  178.9349  178.0000 ...
 177.0651  176.1245  175.1838  174.2431  173.3024  172.3615  171.6614]/180*pi;
beta(19)=NaN;
