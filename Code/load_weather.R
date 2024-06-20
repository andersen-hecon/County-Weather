library(tidyverse)
library(tidync)

dates=seq.Date(from=as.Date("2019-01-01"),
               to=as.Date("2023-12-31"),
               by=1
)

dates_str=map_chr(dates,~paste0(year(.),sprintf("%02.0f",month(.)),sprintf("%02.0f",day(.))))

names(dates_str)=dates

counties<-
  tigris::counties(year=2021,cb=T)|>
  select(county_fips=GEOID)


td=tempdir()
# dir.create(td,showWarnings = F)

shp_weather<-
  imap(
    dates_str[1:2],
    \(x,y) {
      f=glue::glue("https://www.northwestknowledge.net/metdata/data/permanent/{year(y)}/permanent_gridmet_{x}.nc")
      
      tf=paste0(td,"/",basename(f))
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
    }
  )

shp_weather|>list_rbind()|>unnest(cols=c(vals))|>
  write_csv("Output/county_weather.csv.gz")
