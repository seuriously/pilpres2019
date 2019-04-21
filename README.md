# pilpres2019
crawl these columns from kpu (https://pemilu2019.kpu.go.id/#/ppwp/hitung-suara/)

* timestamp
* paslon_01	
* paslon_02	
* c1_url	
* pemilih_terdaftar
* jumlah_suara_sah
* pengguna_hak_pilih
* jumlah_suara
* jumlah_suara_tdk_sah
* tps
* kelurahan
* kecamatan
* kabupaten
* wilayah
* b+c+i	: jumlah suara yang terpakai
* o = h	: melakukan pengecekan apakah jumlah suara yg terpakai == jumlah_suara. Nilai 1 jika tidak sama
* b+c	: jumlah suara sah
* q = f : checker apakah jumlah suara sah == jumlah_suara_sah. Nilai 1 jika tidak sama

![example data](https://i.imgur.com/qCH7keR.png)
