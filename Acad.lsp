;;After copying the dvb file to installed directory load it
(vl-load-com)

;;Get the installed directory of autocad itself
(setq AppPath (vlax-get-property (vlax-get-acad-object) "Path"))
(setq proj_loc (strcat AppPath "\\printer.dvb"))
(vl-vbaload proj_loc)