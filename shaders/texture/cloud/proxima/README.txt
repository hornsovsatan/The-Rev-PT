Folder ini harus berisi 6 file tekstur dari Proxima
(proxima/shaders/texture/atmosphere/cloud/):

  CloudMap.png
  CloudMap.png.mcmeta
  CustomBase.dat
  CustomBase.dat.mcmeta
  CloudNoise.dat
  CloudNoise.dat.mcmeta

File .mcmeta wajib ikut (mengatur filtering dan wrap tekstur).
Dipakai oleh lib/atmosphere/clouds/ProximaLow.glsl lewat customTexture di shaders.properties.
Tekstur ini hanya dimuat saat Cumulus Mode = Proxima; mode Off dan Revelation tetap jalan tanpa file ini.
