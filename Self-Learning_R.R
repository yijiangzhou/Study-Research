#My first R project
#Textbook: Learning R
options("repos"=c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))


#Chapter 1 Introduction ####

mean(1:5)

a_vector <- c(1,3,6,10)
apropos("vector") #用于查找含有关键字vector的变量
apropos("z$")

example(plot)
demo() #这俩都是看函数示例的

install.packages("installr")
library(installr)

hundred=(0:100)
sd(hundred) #小练习：计算标准差


#Chapter 2 Calculator ####

new <- c(1,2,3,4)+c(5,6,7,8)
new - 2 #每个元素都会-2

1:10/3 #普通除法
1:10 %/% 3 #整除
1:10 %% 3 #取余数

c(3,4-1,2+1,sqrt(9),2)==3 #返回true or false，用于判断相等
#同理适用于 > < >= <= !=

all.equal(sqrt(2)^2,2)
all.equal(sqrt(2)^2,3)
isTRUE(all.equal(sqrt(2)^2,3))

c("Can","can","cAn","can?")=="can" #用于比较字符串
#其他一些比较字符串的技巧见p191

?assign
assign("my_var",9^3+10) #另一种不常用的赋值方法

?rnorm
z <- rnorm(10,mean=1,sd=2);z #产生正态分布随机数

(x <- 1:10 >= 5) #此时x的元素全部为true or false
!x
(y <- 1:10 %% 2 == 0)
x & y
!x & y
! (x & y)
x | y #逻辑运算

z <- c(2:8)
sometrue = (z >= 5)
any(sometrue)
all(sometrue) #all和any也用于逻辑运算


#Chapter 3 & 4 ####

bla <- c(1,3,4,7,10)
for (i in 1:length(bla))
  print(bla[i]) #print函数的用法

bla <- c(1,3,4,7,10)
for (i in bla)
  print(i) #效果完全相同

num <- rchisq(10,df=2)
summary(num) #summary函数的用法，注意不能写成sum
#summary还可用于描述logical var和factor var，见p34

ls()
ls(pattern = "m") #查找（含有特定关键字）的变量

vector("numeric",5)
vector("logical",5)
numeric(5)
logical(5) #创建向量

seq.int(3,12)
seq.int(3,15,by=3)
cathy = c("C","a","t","h","e","r","i","n","e")
for (i in seq_along(cathy)) 
  print(cathy[i])  #sequence的用法

cj <- c("Cathy","loves","jack")
length(cj)
nchar(cj) #length用于计算向量长度，nchar用于数每个元素所含字母

school <- c("lshs"=1,"RUC"=2,"CUHK"=3,4)
school2 <- 1:4
names(school2) <- c("lshs","RUC","CUHK","")
school
school2
names(school) #给value加label

x <- (1:5)^2
x[c(1,3,5)]
x[c(-2,-4)] #表示不显示第二个和第四个元素

which(x > 10)
which.max(x)

1:5+1:15 #向量长度不一时，R会自动repeat短向量完成运算

?rep
rep(1:5,3)
rep(1:5,each==3)
rep(1:5,each=3)
rep(1:5,times=1:5)
rep(1:5,length.out=7) #创建含有重复元素的向量

(a_matrix <- matrix(
  1:12,
  nrow=4, #ncol=3 works the same
  dimnames = list(
    c("one","two","three","four"),
    c("ein","zwei","drei")
  )
))
class(a_matrix)

#如果想以row的方式填充（默认填充方式为column）
(b_matrix <- matrix(
  1:12,
  nrow=4,
  byrow = TRUE,
  dimnames = list(
    c("one","two","three","four"),
    c("ein","zwei","drei")
  )
))

dim(a_matrix)
nrow(b_matrix)
ncol(b_matrix) #矩阵的行数和列数
length(a_matrix) #矩阵元素的总数

a_matrix[1,2]
a_matrix[1,]
a_matrix[,c("zwei","drei")] #提取矩阵中的元素

c_vector <- c(a_matrix,b_matrix) #c(...)会把矩阵转为向量再合并
c_matrix_col <- cbind(a_matrix,b_matrix)
c_matrix_row <- rbind(a_matrix,b_matrix) #使用cbind()和rbind()合并矩阵

a_matrix %*% t(b_matrix) #矩阵乘法


#Chapter 5 Lists and Dataframes ####

(a_list <- list(
  c(1,1,2,5,14,42),
  month.abb,
  matrix(1:9,nrow=3,byrow = TRUE),
  asin
))

names(a_list) <- c("vector","months","matrix","function")
a_list #用names()给list的内容加label

#list之间可以相互嵌套

a_list[c(1,3)]; a_list[2:4]; a_list[-2] #提取list中的元素（结果为另一个list）

#注意以下两种表述的区别
a_list[1] #提取出来的另一个list
a_list[[1]] #提取出来的是元素本身！

#因此，提取元素中的元素要使用：
a_list[[1]][3]

miao <- list(1,3,6,100)
wang <- c(10,2,0,-1)
as.list(wang) #vector转list
as.numeric(miao) #list转vector

combinedlists <- c(a_list,miao) #使用c()即可合并lists

(a_df <- data.frame(
  x = letters[1:5],
  y = rnorm(5,mean=2),
  z = runif(5) > 0.5
)) #创建dataframe，相当于excel spreadsheet

(a_df <- data.frame(
  x = letters[1:5],
  y = rnorm(5,mean=2),
  z = runif(5) > 0.5,
  row.names = c("jack","cathy","will","get","married")
  #row.names= NULL可去掉所有row.names
))
rownames(a_df) <- NULL #也可以用这个

nrow(a_df); ncol(a_df); dim(a_df)

a_df[1]; a_df[2:3] #提取列
a_df[2,] #提取行
a_df[,2] #将列提取为行向量
a_df$x; #提取列x
a_df$x[2:3] #提取列x的第2、3个元素

(b_df <- data.frame(
  y = rnorm(5,mean=10),
  z = runif(5) > 0.6,
  x = letters[3:7]
))
rb_ab <- rbind(a_df,b_df) #rbind在按行合并dataframes时会自动按列标题对齐
rb_ab
#但cbind()没有这个功能

(c_df <- data.frame(
  giao = rnorm(5,mean=10),
  biu = runif(5) > 0.8,
  x = letters[1:5]
))

(d_df <- data.frame(
  giao2 = rnorm(5,mean=10),
  biu2 = runif(5) > 0.3,
  x = letters[3:7]
))

#重要！merge dataframes
?merge
merge(a_df,c_df,by = "x") #此时需要master和using的x完全一致
merge(a_df,d_df,by = "x",all = TRUE) #此时不需要x完全一致，R会自动留白

colSums(a_df[2:3])
colMeans(a_df[2]) #同理有rowSums和rowMeans

a_df[4] = rchisq(5,df=2) #添加column
colnames(a_df)[4] = "chisq" #重命名column
a_df[5] = 1
colnames(a_df)[5] = "one"


#Chapter 6 Environments and Functions ####

anenvir <- new.env()
anenvir[["oyo"]] <- c(12,15,20,21)
anenvir$root <- polyroot(c(6,-5,1))
assign(
  "bucuowo",
  weekdays(as.Date("1997/04/09")),
  anenvir
) #创建新environment并写入内容

get("bucuowo",anenvir)
anenvir[["oyo"]] #提取environment中的内容

ls(envir = anenvir)
ls.str(envir = anenvir)

#as.list和as.environment（以及list2env）用于list和environment互转

hypo <- function(x,y){
  sqrt(x^2 + y^2)
}

hypo(10,12) #求平方和的平方根
hypo(y=15,x=2)


normalize <- function(x,m=mean(x),s=sd(x)){
  (x-m)/s
} #没有针对输入的缺失值NA做处理
normalize(c(1,3,5,10,201))
normalize(c(1,30,2,9,NA))


normalize <- function(x,m=mean(x,na.rm = na.rm),
                      s=sd(x,na.rm),na.rm=TRUE){
  (x-m)/s
} #这样写之后，缺失值不会影响整体计算
normalize(c(1,3,5,10,201))
normalize(c(1,30,2,9,NA))

#小练习：判断奇偶性
evenodd <- function(x){
  y = rep(0,length(x))
  for (i in 1:length(x)) {
    if (x[i] %% 2 == 0 & is.finite(x[i]) == TRUE) {
      y[i] <- "even"
    } else if (x[i] %% 2 == 1 & is.finite(x[i]) == TRUE){
      y[i] <- "odd"
    } else {
      y[i] <- FALSE
    }
  }
  cat(y)
}


#Chapter 8 Flow Control and Loops ####

if(TRUE)
  message("It is true!") #这个message函数会返回加红的字体，有时候会用到！

x <- 3
if (x>2){
  y <- 2*x
  z <- 3*y
}
print(c(y,z))

#养成好习惯，if的后括号{和else放在同一行！

x <- sqrt(-1 + 0i)
(reality <- if(Re(x) == 0) "real" else "imaginary")
reality #if和else可以放在一起，简化使用

#ifelse用于conditional element selection
ifelse(rbinom(10,1,0.5),"Head","Tail")

#switch的用法不同于Matlab中的switch，不用掌握

repeat{
  message("Try again!")
  words <- sample( #sample用于在以下内容中随机抽取一个
  c(
    "I like Coca-cola",
    "I study Economics",
    "I am in my home",
    "Oh look it's Cathy!"
  ),1)
  message("words = ",words)
  if (words == "Oh look it's Cathy!") break #跳出循环
}

repeat{
  message("Try again!")
  words <- sample(
    c(
      "I like Coca-cola",
      "I study Economics",
      "I am in my home",
      "Oh look it's Cathy!"
    ),1)
  if (words == "I study Economics"){
    message("Quietly skipping to the next iteration")
    next #直接跳到下次循环
  }
  message("words = ",words)
  if (words == "Oh look it's Cathy!") break
}
#执行一下就知道是什么意思了

n = 1
while (n<=100){
  out <- sum(1:n)
  n = n+1
} #自己写的例子，学习while的用法（和Matlab基本相同）
out

#小练习：提取指定长度的单词
somewords <- c("Cathy","is","a","graduate","student",
               "at","NUS","she","studies","applied","economics",
               "after","graduation","she","plans","to","return",
               "to","Beijing","and","find","a","job")
howmany <- function(x){
  collection = c()
  for (i in 1:length(somewords)){
    if (nchar(somewords[i]) == x){
      message("The word ",somewords[i]," has ",x," characters.")
      collection[i] = somewords[i]
      collection <- collection[!is.na(collection)] #去掉NA
    }
  }
  print(collection)
}


#Chapter 9 Advanced Looping ####

rep(runif(1),5) #rep每次返回的结果是相同的
replicate(5,runif(1)) #replicate每次返回的结果是独立（不同）的

primef <- list(
  two = 2, three = 3, four = c(2,2),
  five = 5, six = c(2,3), seven = 7,
  eight = c(2,2,2), nine = c(3,3),
  ten = c(2,5)
)
primef

#如何从primef中提取unique factor？
lapply(primef, unique) #使用lapply和unique函数

#如果用for循环，会比较麻烦
listunique = function(x){
  unifac <- vector(mode = "list", length = length(x))
  #技巧：用vector指定生成空lists
  for (i in 1:length(x)){
    unifac[[i]] <- unique(x[[i]]) #使用双括号提取出来的才是元素本身！
  }
  names(unifac) <- names(primef)
  print(unifac)
}

vapply(primef,mean,numeric(1)) ##vapply is "list apply that returns a vector"

sapply(primef, unique)
sapply(primef, mean)
sapply(primef, summary) #sapply非常智能，会根据function的不同返回list、vector或array

install.packages("matlab")
library(matlab) #使用matlab包可以对矩阵的行、列执行函数，见下
#matlab包会覆盖一些R本身的函数，要disable这个包，用
detach("package:matlab")

magic4 <- magic(4)
m1 <- matrix(1:16,nrow = 4,byrow = TRUE)
rowSums(m1)
colSums(m1) #都是matlab包自带的函数，用于求矩阵每一行或每一列的和

#也可以用apply
apply(m1,MARGIN = 1,toString) #MARGIN = 1表示对each row
apply(m1,MARGIN = 2,toString) #MARGIN = 2表示对each column

mapply(median,m1,magic4) #mapply可将一个函数用于多个matrix

#重要：分组计算——R中的split-apply-combine problem
gamescore <- data.frame(
  player = rep(c("Jack","Cathy","Cheng Peng"),times = c(2,3,4)),
  score = round(rlnorm(9,8),-1)
)
gamescore

#如何求Jack、Cathy、Cheng Peng每个人的平均分呢？
meanscore <- with(gamescore,tapply(score, player, mean)) #使用with和tapply即可

library(plyr)
llply(primef,unique) #同lapply
laply(primef,length) #同sapply

#ddaply可用于替换tapply用于分组计算，且可以同时计算多个指标
gamescore$level <- floor(log(gamescore$score))
#计算三人的average score和average level
ddply(
  gamescore,
  .(player), #表示根据player来分组
  colwise(mean)
)
#或者对不同行做不同计算：加上summarize即可
ddply(
  gamescore,
  .(player),
  summarize,
  mean_score = mean(score),
  min_level = min(level)
)

#小练习：统计第一代家庭成员各有几个孩子
bigfamily <- list(
  John = list(),
  Philip = list(
    "Jack","Natalie","Philip Jr.","David"
  ),
  "Chris Ivory" = list(
    "Tom","Jerry","Lawrance"
  ),
  Kim = list(),
  Marlon = list(
    "Shawn","Arry"
  ),
  Diedre = list(
    "Craig","Gregg","Summer","Justin","James"
  ),
  "Oliver Young" = list("Laila")
)

#方法一：for loop
countkids <- function(x){
  out <- rep(0,length(x))
  for (i in 1:length(x)){
    out[i] <- length(x[[i]])
    names(out) <- names(bigfamily)
    message(names(bigfamily)[i]," has ",length(x[[i]])," kids.")
  }
  return(out) #学会用return来输出结果
}
countkids(bigfamily)
nkids <- countkids(bigfamily)
nkids

#方法二：apply
sapply(bigfamily,length)

#方法三：plyr
nkids <- laply(bigfamily,length)
names(nkids) <- names(bigfamily)


#Parallel Computing and ggplot2####

library(plyr); library(foreach); library(doParallel)

#自己写一个示例函数
cap <- function(n){
  x <- rnorm(n,mean = 0)
  z <- qnorm(.95,mean = 0)
  out <- mean(x > z)
  return(out)
}
result <- cap(1000)

#使用4个CPU
registerDoParallel(4)
pts0 <- Sys.time()
result <- foreach(1:500,.combine = c) %dopar% {
  cap(1000000)
}
pts1 <- Sys.time() - pts0
cat("Parallel loop takes",pts1,"seconds\n")
cat("Empirical probablity of x falling in upper 5% quantile is",mean(result))

#使用单个CPU
pts0 <- Sys.time()
result <- foreach(1:500,.combine = c) %do% {
  cap(1000000)
}
pts1 <- Sys.time() - pts0
cat("Parallel loop takes",pts1,"seconds\n")
cat("Empirical probablity of x falling in upper 5% quantile is",mean(result))
#当循环次数低，且每次循环计算量大时，多个CPU同时计算效果最好！

#本部分使用教材为《R语言实战》
library(ggplot2); library(car)

ggplot(data = mtcars, aes(x = wt,y=mpg)) +
  geom_point() + #画散点图
  labs(title = "Automobile Data",x = "Weight",y = "Miles per gallon") #添加注释

ggplot(data = mtcars, aes(x = wt,y=mpg)) +
  geom_point(pch=17,color="blue",size=2) + #pch=17表示用三角形代表数据点
  geom_smooth(method = "lm",color = "red",linetype=2) +#OLS拟合线及95%置信区间（默认）
  labs(title = "Automobile Data",x = "Weight",y = "Miles per gallon")

#使用geom不同选项绘图，详见表19.2
data(singer,package = "lattice")
ggplot(singer,aes(x=height)) + geom_histogram() #直方图
ggplot(singer,aes(x=voice.part,y=height)) + geom_boxplot() #箱线图

#geom自带的各种选项，详见表19.3
data = (Salaries)
ggplot(Salaries,aes(x=rank,y=salary)) +
  geom_boxplot(fill = "cornflowerblue",
               color = "black",notch=TRUE) +
  geom_point(position = "jitter",color = "blue",alpha = .5) +
  geom_rug(side = "1",color = "black")


#同图分组：aes()
#1.以学术等级rank分组，考察salary的分布
ggplot(data = Salaries,aes(x=salary,fill=rank)) + #对rank着色
  geom_density(alpha=.3) #设置透明度

#2.以性别和学术等级分组，考察salary与years since phd的关系
ggplot(Salaries,aes(x=yrs.since.phd,y=salary,color=rank,shape=sex)) +
  geom_point() #可见，rank通过color来区分，shape通过sex来区分

#3.不同rank的性别构成
ggplot(Salaries,aes(x=rank,fill=sex)) +
  geom_bar(position="dodge") + labs(title = "Number of Professors")


#分组并排图：facet_wrap() and facet_grid()
#1.各声部歌手身高的分布
data(singer,package = "lattice")
ggplot(data = singer,aes(x=height)) +
  geom_histogram() +
  facet_wrap(~voice.part,nrow=4) #行数为4

#2.以性别和学术等级分组，考察salary与years since phd的关系
ggplot(Salaries,aes(x=yrs.since.phd,y=salary,color=rank,shape=sex)) +
  geom_point() + facet_grid(.~sex)

#3.kernel density
ggplot(data = singer,aes(x=height,fill=voice.part)) +
  geom_density() +
  facet_grid(voice.part~.)

#添加光滑曲线：geom_smooth
#1.使用smooth拟合
ggplot(Salaries,aes(x=yrs.since.phd,y=salary))+ 
  geom_smooth() + geom_point() #geom_smooth的选项中有多种平滑函数供选择，如lm、glm
#smooth、rlm等，默认为smooth

#2.按性别拟合二次多项式回归
ggplot(Salaries,aes(x=yrs.since.phd,y=salary,
                   linetype=sex,shape=sex,color=sex)) +
  geom_smooth(method = lm,formula = y~poly(x,2),se=FALSE,size=1) +
  #formula = y~poly(x,2)表示使用二次多项式拟合，se=FALSE表示不显示置信区间
  geom_point(size=2)

#自定义图表外观
#1.坐标轴
ggplot(data=Salaries, aes(x=rank, y=salary, fill=sex)) +
  geom_boxplot() +
  scale_x_discrete(breaks=c("AsstProf", "AssocProf", "Prof"),
                   labels=c("Assistant\nProfessor", #/n表示空行
                            "Associate\nProfessor",
                            "Full\nProfessor")) +
  scale_y_continuous(breaks=c(50000, 100000, 150000, 200000),
                     labels=c("$50K", "$100K", "$150K", "$200K")) +
  labs(title="Faculty Salary by Rank and Sex", x="", y="")

#2.图例
ggplot(data=Salaries, aes(x=rank, y=salary, fill=sex)) +
  geom_boxplot() +
  scale_x_discrete(breaks=c("AsstProf", "AssocProf", "Prof"),
                   labels=c("Assistant\nProfessor", #/n表示空行
                            "Associate\nProfessor",
                            "Full\nProfessor")) +
  scale_y_continuous(breaks=c(50000, 100000, 150000, 200000),
                     labels=c("$50K", "$100K", "$150K", "$200K")) +
  labs(title="Faculty Salary by Rank and Gender",
       x="", y="", fill="Gender") +
  theme(legend.position=c(.1,.8)) #图例的位置

#3.使用标尺绘制泡泡图
ggplot(mtcars, aes(x=wt, y=mpg, size=disp)) + #size生成连续变量disp的标尺，并控制泡泡大小
  geom_point(shape=21, color="black", fill="cornsilk") +
  labs(x="Weight", y="Miles Per Gallon",
       title="Bubble Chart", size="Engine\nDisplacement")

#4.主题：设计自己的主题（详见教材）

#5.组合多个ggplot2图
p1 <- ggplot(data=Salaries, aes(x=rank)) + geom_bar()
p2 <- ggplot(data=Salaries, aes(x=sex)) + geom_bar()
p3 <- ggplot(data=Salaries, aes(x=yrs.since.phd, y=salary)) + geom_point()
library(gridExtra)
grid.arrange(p1, p2, p3, ncol=3)







