function wavestruct = imake_wavestructs_jd(equil,launch)
%
id_rtparam = launch.type;
wavestruct = load_structures_yp('rtparam',id_rtparam,'');
wavestruct.rtparam = ['C3POPARAM_',id_rtparam,'.mat'];
%
wavestruct.launch = launch;
wavestruct.wavesolver = 'C3PO';
wavestruct.id = [wavestruct.wavesolver,'_',wavestruct.launch.id];
wavestruct.equil = equil;
wavestruct.equil_id = equil.id;
