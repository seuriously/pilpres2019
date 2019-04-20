library(rvest)
library(dplyr)
library(stringr)
library(httr)

setwd("~/pilpres2019")
set_config(config(ssl_verifypeer = 0L))
link = content(GET(URLencode("https://pemilu2019.kpu.go.id/static/json/wilayah/0.json")), as="text")
# get provinsi
smmry_wilayah =  link %>% 
  jsonlite::fromJSON(.)
wilayah_names = data.frame(name = sapply(smmry_wilayah, function(x) x$nama), id = names(smmry_wilayah))

i_null = j_null = k_null = l_null = m_null = vector()
i=j=k=l=m=1
i_prog=1;j_prog=1;k_prog=1;l_prog=1;m_prog=1

## start looping
for(i in i_prog:nrow(wilayah_names)){
  possibleError = tryCatch({
    # get kabupaten
    link = content(GET(URLencode(paste0('https://pemilu2019.kpu.go.id/static/json/wilayah/', wilayah_names$id[i] ,'.json'))), as="text")
    Sys.sleep(sample(seq(1, 3, by=0.001), 1))
    smmry_kabupaten = link %>% 
      jsonlite::fromJSON(.)
    kabupaten_names = data.frame(name = sapply(smmry_kabupaten, function(x) x$nama), id = names(smmry_kabupaten))
  }, error = function(e) e)
  
  if(inherits(possibleError, "error")){
    i_null = c(i_null, i)
    j_null = c(j_null, j)
    k_null = c(k_null, k)
    l_null = c(l_null, l)
    m_null = c(m_null, m)
    print(paste("error", i, j, k, l, m))
    next
  }
  for(j in j_prog:nrow(kabupaten_names)){
    Sys.sleep(sample(seq(1, 3, by=0.001), 1))
    possibleError = tryCatch({
      #get kecamatan
      link = content(GET(URLencode(paste0('https://pemilu2019.kpu.go.id/static/json/wilayah/', wilayah_names$id[i], '/', kabupaten_names$id[j],'.json'))), as="text")
      smmry_kecamatan = link %>% 
        jsonlite::fromJSON(.)
      kecamatan_names = data.frame(name = sapply(smmry_kecamatan, function(x) x$nama), id = names(smmry_kecamatan))
    }, error = function(e) e)
    
    if(inherits(possibleError, "error")){
      i_null = c(i_null, i)
      j_null = c(j_null, j)
      k_null = c(k_null, k)
      l_null = c(l_null, l)
      m_null = c(m_null, m)
      print(paste("error", i, j, k, l, m))
      next
    }
    for (k in k_prog:nrow(kecamatan_names)){
      Sys.sleep(sample(seq(1, 3, by=0.001), 1))
      possibleError = tryCatch({
        #get kelurahan
        link = content(GET(URLencode(paste0('https://pemilu2019.kpu.go.id/static/json/wilayah/', wilayah_names$id[i], '/', kabupaten_names$id[j],'/', kecamatan_names$id[k],'.json'))), as="text")
        smmry_kelurahan = link %>% 
          jsonlite::fromJSON(.)
        kelurahan_names = data.frame(name = sapply(smmry_kelurahan, function(x) x$nama), id = names(smmry_kelurahan))
      }, error = function(e) e)
      
      if(inherits(possibleError, "error")){
        i_null = c(i_null, i)
        j_null = c(j_null, j)
        k_null = c(k_null, k)
        l_null = c(l_null, l)
        m_null = c(m_null, m)
        print(paste("error", i, j, k, l, m))
        next
      }
      for(l in l_prog:nrow(kelurahan_names)){
        Sys.sleep(sample(seq(1, 3, by=0.001), 1))
        possibleError = tryCatch({
          #get tps
          link = content(GET(URLencode(paste0('https://pemilu2019.kpu.go.id/static/json/wilayah/', wilayah_names$id[i], '/', kabupaten_names$id[j],'/', kecamatan_names$id[k],'/', kelurahan_names$id[l],'.json'))), as="text")
          smmry_tps = link %>% 
            jsonlite::fromJSON(.)
          tps_names = data.frame(name = sapply(smmry_tps, function(x) x$nama), id = names(smmry_tps))
        }, error = function(e) e)
        
        if(inherits(possibleError, "error")){
          i_null = c(i_null, i)
          j_null = c(j_null, j)
          k_null = c(k_null, k)
          l_null = c(l_null, l)
          m_null = c(m_null, m)
          print(paste("error", i, j, k, l, m))
          next
        }
        for(m in m_prog:nrow(tps_names)){
          Sys.sleep(sample(seq(1, 3, by=0.001), 1))
          possibleError = tryCatch({
            #get_result
            link = content(GET(URLencode(paste0('https://pemilu2019.kpu.go.id/static/json/hhcw/ppwp/', wilayah_names$id[i], '/', kabupaten_names$id[j],'/', kecamatan_names$id[k],'/', kelurahan_names$id[l],'/', tps_names$id[m], '.json'))), as="text")
            result = link %>% 
              jsonlite::fromJSON(.)
            if(length(result)==0){
              result = data.frame(matrix(NA, ncol = 9, nrow = 1))
            }else{
              result$images = paste0('https://pemilu2019.kpu.go.id/img/c/',substr(tps_names$id[m],1,3),'/', substr(tps_names$id[m],4,6), '/', tps_names$id[m], '/', result$images, collapse = ', ')
              result = data.frame(result)
            }
            names(result) = c('timestamp', 'paslon_01', 'paslon_02', 'c1_url', 'pemilih_terdaftar', 'jumlah_suara_sah', 'pengguna_hak_pilih', 'jumlah_suara', 'jumlah_suara_tdk_sah')
            result$tps = tps_names$name[m]
            result$kelurahan = kelurahan_names$name[l]
            result$kecamatan = kecamatan_names$name[k]
            result$kabupaten = kabupaten_names$name[j]
            result$wilayah = wilayah_names$name[i]
            write.table(result, "pilpres_kpu_result.csv", append = T, sep = "|", col.names = !file.exists("pilpres_kpu_result.csv"), row.names = F)
            print(paste("crawled provinsi", wilayah_names$name[i], wilayah_names$id[i], "kota", kabupaten_names$name[j], kabupaten_names$id[j], "kecamatan", kecamatan_names$name[k], kecamatan_names$id[k], "kelurahan", kelurahan_names$name[l], kelurahan_names$id[l], 'tps', tps_names$name[m], tps_names$id[m]))
          }, error = function(e) e)
          
          if(inherits(possibleError, "error")){
            i_null = c(i_null, i)
            j_null = c(j_null, j)
            k_null = c(k_null, k)
            l_null = c(l_null, l)
            m_null = c(m_null, m)
            print(paste("error", i, j, k, l, m))
            next
          }
        }
        if(m==nrow(tps_names)) m_prog<<-1
      }
      if(l==nrow(kelurahan_names)) l_prog<<-1
      
    }
    if(k==nrow(kecamatan_names)) k_prog<<-1
    
  }
  if(j==nrow(kabupaten_names)) j_prog<<-1
}