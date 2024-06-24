library(tidyverse)
library(prism)
library(stars)


prism_set_dl_dir(tempdir())

get_prism_dailys(type="tmean",
                 minDate="2018-01-01",
                 maxDate=floor_date(today(),"month")-1,
                 keepZip = F)


pd_stack(type="tmean",
         minDate="2018-01-01",
         maxDate="2018-02-01")

data<-
  pd_stack(
    prism_archive_subset(type="tmean",
                         temp_period = "daily",
                         minDate="2018-01-01",
                         maxDate=floor_date(today(),"month")-1)
  )

z=terra::rast(data)|>terra::extract(y = counties,small=T,bind=T,fun=mean, na.rm=T)


z|>
  as_tibble()|>
  write_csv("Output/prism_temp.csv.gz")




get_prism_dailys(type="ppt",
                 minDate="2018-01-01",
                 maxDate=floor_date(today(),"month")-1,
                 keepZip = F)

data<-
  pd_stack(
    prism_archive_subset(type="ppt",
                         temp_period = "daily",
                         minDate="2018-01-01",
                         maxDate=floor_date(today(),"month")-1)
  )

z=terra::rast(data)|>terra::extract(y = counties,small=T,bind=T,fun=mean, na.rm=T)


z|>
  as_tibble()|>
  write_csv("Output/prism_ppt.csv.gz")
