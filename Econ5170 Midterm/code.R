#Econ5170 Midterm Exercise R Part
#Yijiang Zhou, MPhil, ID:1155133829


#a.Import Dataset ####

library(readxl)
dataset <- read_xlsx("within_city.xlsx") #Chinese words are displayed correctly


#b.Lunar dates ####

library(plyr)

templist <- strptime(dataset$date,"%Y%m%d",tz="UTC") #Converting string date 
#to formated date that R can process
tempdf <- data.frame(date_fmt = templist)
dataset <- cbind(dataset,tempdf) #Append dataset with newly-generated dates
remove(templist,tempdf)

dataset$lunaryear <- rep(0,length(dataset$date_fmt))
for (i in 1:length(dataset$date_fmt)){
  if (as.Date(dataset$date_fmt[i]) 
      >= as.Date("2020-01-25")){
    dataset$lunaryear[i] = 2020
  } else if (as.Date(dataset$date_fmt[i]) 
            >= as.Date("2019-02-05")){
    dataset$lunaryear[i] = 2019
  } else{
    dataset$lunaryear[i] = 2018
  }
} #lunaryear indicates which lunar year the date is in
remove(i)

dataset$lunarday <- rep(0,length(dataset$date_fmt))
for (i in 1:length(dataset$date_fmt)){
  if (as.Date(dataset$date_fmt[i]) 
      >= as.Date("2020-01-25")){
    dataset$lunarday[i] = as.numeric(as.Date(dataset$date_fmt[i])
                                  - as.Date("2020-01-24"))
  } else if (as.Date(dataset$date_fmt[i]) 
             >= as.Date("2019-02-05")){
    dataset$lunarday[i] = as.numeric(as.Date(dataset$date_fmt[i])
                                  - as.Date("2019-02-04"))
  } else{
    dataset$lunarday[i] = as.numeric(as.Date(dataset$date_fmt[i])
                                  - as.Date("2018-02-15"))
  }
} #Calculate lunar dates with 2018-02-16 as the first day
#of lunar year 2018, 2019-02-05 as the first day of 
#lunar year 2019, and 2020-01-25 as the first day of 
#lunar year 2020
remove(i)

tempdf <- dataset[c(1,6)]
panel <- unique.data.frame(tempdf) #Drop duplicated city-lunarday
#observations and form a new panel dataset
remove(tempdf)
panel <- arrange(panel,lunarday)

df_index19 <- subset(dataset,lunaryear == 2019,
                   select = c(city,lunarday,trip_index))
df_index20 <- subset(dataset,lunaryear == 2020,
                   select = c(city,lunarday,trip_index))
panel <- merge(panel,df_index19,
               by = c("city","lunarday"),all = FALSE)
names(panel)[3] = "index19"
panel <- merge(panel,df_index20,
               by = c("city","lunarday"),all = FALSE)
names(panel)[4] = "index20" #Extract trip index of each
#city in 2019 and 2020 and merge them into the panel dataset

remove(df_index19,df_index20)
panel <- transform(panel,
                   y = index20/index19) #Generate y

panel <- arrange(panel,city,lunarday)














