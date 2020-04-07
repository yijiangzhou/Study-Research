#Econ5170 Midterm Exercise R Part
#Yijiang Zhou, MPhil, ID:1155133829


#a.Import Dataset ####

library(readxl)
dataset <- read_xlsx("within_city.xlsx") #Chinese words are displayed correctly


#b.Lunar Dates ####

library(plyr)

templist <- strptime(dataset$date,"%Y%m%d",tz="UTC") #Converting string date 
#to formated date that R can process
tempdf <- data.frame(date_fmt = templist)
dataset <- cbind(dataset,tempdf) #Append dataset with newly-generated dates
remove(templist,tempdf)

dataset$lunarday <- rep(0,length(dataset$date_fmt))
for (i in 1:length(dataset$date_fmt)){
  if (as.Date(dataset$date_fmt[i]) 
      >= as.Date("2020-01-01")){
    dataset$lunarday[i] = as.numeric(as.Date(dataset$date_fmt[i])
                                  - as.Date("2020-01-24"))
  } else{
    dataset$lunarday[i] = as.numeric(as.Date(dataset$date_fmt[i])
                                  - as.Date("2019-02-04"))
  }
} #Calculate lunar dates with 2019-02-05 as the first day of 
#lunar year 2019, and 2020-01-25 as the first day of lunar 
#year 2020. Solar calendar dates before 2019-02-05 are still 
#viewed as in lunar year 2019 but their values in lunarday
#are non-positve. Similar goes for solar dates after 2019-12-31 and 
#before 2020-01-25 so please don't be surprised to see some 
#negative values in lunarday
remove(i)

dataset$lunaryear <- rep(0,length(dataset$date_fmt))
for (i in 1:length(dataset$date_fmt)){
  if (as.Date(dataset$date_fmt[i]) 
      >= as.Date("2020-01-01")){
    dataset$lunaryear[i] = 2020
  } else{
    dataset$lunaryear[i] = 2019
  }
} #lunaryear is defined according to the notes above
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


#c.Plots ####

library(ggplot2)

dfplot <- subset(panel,city == "兰州" | city == "银川" 
              | city == "西安" | city == "太原" | city == "石家庄" 
              | city == "北京" | city == "天津" | city == "成都" 
              | city == "重庆" | city == "武汉" | city == "合肥" 
              | city == "南京" | city == "昆明" | city == "贵阳" 
              | city == "长沙" | city == "南昌" | city == "杭州" 
              | city == "福州" | city == "南宁" | city == "广州",
              select = c(city,lunarday,y))
df_engname <- data.frame(
  city = c("兰州","银川","西安","太原","石家庄","北京","天津",
           "成都","重庆","武汉","合肥","南京","昆明","贵阳",
           "长沙","南昌","杭州","福州","南宁","广州"),
  engname = c("Lanzhou","Yinchuan","Xi'an","Taiyuan",
              "Shijiazhuang","Beijing","Tianjin","Chengdu",
              "Chongqing","Wuhan","Hefei","Nanjing","Kunming",
              "Guiyang","Changsha","Nanchang","Hangzhou","Fuzhou",
              "Nanning","Guangzhou")) #Add English names to cities so 
#that ggplot2 can properly display plot labels

dfplot <- merge(dfplot,df_engname,by = c("city"),all = FALSE)
dfplot <- arrange(dfplot,engname,lunarday)
remove(df_engname)

p1 <- ggplot(data = dfplot,aes(x=lunarday,y=y)) +
  geom_line() +
  labs(title = "Trip Index Ratio of Selected Capital Cities",
       x="Lunar Day",y="Trip Index Ratio") +
  theme(plot.title = element_text(hjust = 0.5)) +
  facet_wrap(~engname,nrow=5) #Plots are arranged according to
#the alphabetic order of cities
print(p1)

pdf("trip_index_ratio.pdf",paper = "a4r",
    width = 11.69,height = 8.27)
p1
dev.off() #Save the image to PDF format


#d.Panel Data Regressions

library(plm)
panel <- pdata.frame(panel,index = c("city","lunarday"))

panel$lagy <- lag(panel$y,k=1) # Generate lagged y

for (i in 1:length(dataset$date)){
  if (dataset$city[i] == "北京" &
      dataset$date[i] == 20200123){
    message("2020-01-23 is lunar day ",dataset$lunarday[i],
            " of lunar year ",dataset$lunaryear[i],".")
  }
} #To check which lunar day it is on 2020-01-23
#This task can be done by human easily and doesn't require
#a for loop. I just write it for fun
remove(i)











