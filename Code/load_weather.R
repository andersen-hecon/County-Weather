library(tidyverse)
library(tidync)
library(furrr)

dates=seq.Date(from=as.Date("2019-01-01"),
               to=as.Date("2023-12-31"),
               by=1
)

dates_str=map_chr(dates,~paste0(year(.),sprintf("%02.0f",month(.)),sprintf("%02.0f",day(.))))

names(dates_str)=dates

counties<-
  tigris::counties(year=2021,cb=T)|>
  select(county_fips=GEOID)

plan(multisession, workers=4)
future_iwalk(
    dates_str,
    \(x,y) {
      f=glue::glue("https://www.northwestknowledge.net/metdata/data/permanent/{lubridate::year(y)}/permanent_gridmet_{x}.nc")
      
      tf=paste0(tempdir(),"/",basename(f))
      print(f)
      print(tf)
      
      download.file(f,tf,mode = "wb")
      
      c_out=tibble(county_fips=counties$county_fips)
      
      c_out$vals=terra::extract(
        terra::rast(tf),
        counties,
        fun=mean,
        na.rm=TRUE,
        method='bilinear')
      
      
      c_out<-
        c_out|>
        unnest(cols=c(vals))
      
      write_csv(c_out,glue::glue("Output/county_weather_{x}.csv.gz"))
      
      return(c_out)
    },
    .progress=TRUE
  )

