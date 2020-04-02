#Econ5170 Midterm Exercise R Part
#Yijiang Zhou, MPhil, ID:1155133829


#a.Import Dataset ####

library(readxl)
dataset <- read_xlsx("within_city.xlsx") #Chinese words are displayed correctly


#b.Lunar dates ####

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


test <- data.frame(
  player = c(rep("a",4),rep("b",4)),
  timer = c(rep(c(1,2),2)),
  score = 1:8
)

test$ratio <- rep(0,length(test$timer))
for (i in 1:length(test$timer)){
  for (j in 1:length(test$timer)){
    if (i > j & test$timer[i] == test$timer[j] 
        & test$player[i] == test$player[j]){
      test$ratio[i] <- test$score[i] / test$score[j]
    }
  }
}

























