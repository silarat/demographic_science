getwd()
currentwd <-"//////currentdirectory//////" 
setwd(currentwd)
q01dat <- read.csv("q01_data.csv", header = TRUE)
q03dat <- read.csv("q03_data.csv", header = TRUE)
q04dat <- read.csv("q04_data.csv", header = TRUE)
q06dat <- read.csv("q06_data.csv", header = TRUE)

library(pacman)
library(tidyverse) #for filter >%>
library(stringr) #for str_detect
library(magrittr)
library(plyr) #for round_any
library(ggplot)

#different methods of Person YEars (PY Estimation)
#method 1 - assuming constant growth rate
PYM1 <- (q01dat$end - q01dat$start)/log(q01dat$end/q01dat$start)
PYM1r <- round_any(PYM1, 10)
CGRM1 <- (q01dat$end - q01dat$start)/PYM1
CGRM1r <- round_any(CGRM1, 0.001)

#method 2 - mid period approximation
PYM2 <- q01dat$mid
PYM2r <- round_any(PYM2, 10)
CGRM2 <- (q01dat$end - q01dat$start)/PYM2
CGRM2r <- round_any(CGRM2, 0.001)

#method3 - averaging the starting and ending population number
PYM3 <- (q01dat$start+q01dat$end)/2
PYM3r <- round_any(PYM3, 10)
CGRM3 <- (q01dat$end - q01dat$start)/PYM3
CGRM3r <- round_any(CGRM3, 0.001)

#method 4 - adding up different numbers of population throughout different segment of time
PYM4 <- ((q01dat$start*(1/3))+(q01dat$mid*(1/3))+(q01dat$end*(1/3)))
PYM4r <- round_any(PYM4, 10)
CGRM4 <- (q01dat$end - q01dat$start)/PYM4
CGRM4r <- round_any(CGRM4, 0.001)
CGRM4r
mydf1 <- data.frame(
  Year = q01dat$year,
  PY_Method1 = PYM1r,
  PY_Method2 = PYM2r,
  PY_Method3 = PYM3r,
  PY_Method4 = PYM4r,
  CGR_Method1 = CGRM1r,
  CGR_Method2 = CGRM2r,
  CGR_Method3 = CGRM3r,
  CGR_Method4 = CGRM4r
)
mydf1

#----
#Computing person-years in the denominator of the crude birth rate of each area
PYarea <- q03dat$births_k/q03dat$cbr_k
mydf3 <- data.frame(
  Area = q03dat$area,
  Birth_count = q03dat$births_k,
  CBR = q03dat$cbr_k,
  Person_Years = PYarea
)
mydf3

#-----
Computing the distribution of current employees by hire year cohort, in terms of headcount and share of total headcount
q04dat_1 <- subset(q04dat, is.na(termination_date))
count(q04dat_1 %>% filter(str_detect(hire_date, "1988")))
#204
count(q04dat_1 %>% filter(str_detect(hire_date, "1989")))
#162
count(q04dat_1 %>% filter(str_detect(hire_date, "1990")))
#99
count(q04dat_1 %>% filter(str_detect(hire_date, "1991")))
#62
count(q04dat_1 %>% filter(str_detect(hire_date, "1992")))
#31
total <- 204+162+99+62+31
total

mydf4 <- data.frame(
  Cohort_Year = c("1988", "1989", "1990", "1991", "1992"),
  Head_Count = c(204, 162, 99, 62, 31),
  Percentage = c((100*204/558), (100*162/558), (100*99/558), (100*62/558), (100*31/558))
)
mydf4

#---
#Computing the distribution of CURRENT employees by hire MONTH, im terms of headcount and share of total headcount.
q04dat_1new <- q04dat_1
count(q04dat_1new %>% filter(str_detect(hire_date, "-01-")))
#count jan = 31
count(q04dat_1new %>% filter(str_detect(hire_date, "-02-")))
#feb = 27
count(q04dat_1new %>% filter(str_detect(hire_date, "-03-")))
#Mar = 35
count(q04dat_1new %>% filter(str_detect(hire_date, "-04-")))
#April = 50
count(q04dat_1new %>% filter(str_detect(hire_date, "-05-")))
#May = 54
count(q04dat_1new %>% filter(str_detect(hire_date, "-06-")))
#Jun = 46
count(q04dat_1new %>% filter(str_detect(hire_date, "-07-")))
#July = 75
count(q04dat_1new %>% filter(str_detect(hire_date, "-08-")))
#Aug = 85
count(q04dat_1new %>% filter(str_detect(hire_date, "-09-")))
#Sep = 83
count(q04dat_1new %>% filter(str_detect(hire_date, "-10-")))
#Oct = 29
count(q04dat_1new %>% filter(str_detect(hire_date, "-11-")))
#Nov 23
count(q04dat_1new %>% filter(str_detect(hire_date, "-12-")))
#Dec = 20
total <- 31+27+35+50+54+46+75+85+83+29+23+20
total #558 this is how I check that I have included everyone on the dataset

#entering raw number instead of knitting everything into objects
mydf4_1 <-data.frame(
  Hire_Month = c("Jan", "Feb", "Mar", "April", "May", "Jun", "July", "Aug", "Sep", "Oct", "Nov", "Dec"),
  Head_Count = c(31, 27, 35, 50, 54, 46, 75, 85, 83, 29, 23, 20),
  Percentage = c((31*100/558), (27*100/558), (35*100/558), 
                 (50*100/558), (54*100/558), (46*100/558), (75*100/558), 
                 (85*100/558), (83*100/558), (29*100/558), (23*100/558), (20*100/558))
)
mydf4_1

#----
#Calculating for each hire uear cohort the probability of first promotion within 180 days
count(q04dat %>% filter(str_detect(hire_date, "1988")))
#384
count(q04dat %>% filter(str_detect(hire_date, "1989")))
#326
count(q04dat %>% filter(str_detect(hire_date, "1990")))
#212
count(q04dat %>% filter(str_detect(hire_date, "1991")))
#151
count(q04dat %>% filter(str_detect(hire_date, "1992")))
#56

date <- as.POSIXct(q04dat$hire_date, format = "%Y-%m-%d")
numdate <- as.numeric(date)
numdate
q04dat$numdate <- numdate


dateprom <- as.POSIXct(q04dat$promo1_date, format = "%Y-%m-%d")
numdateprom <- as.numeric(dateprom)
q04dat$numdateprom <- numdateprom

q04dat$promo1time <- q04dat$numdateprom - q04dat$numdate
q04dat$promo1time_day <- q04dat$promo1time / 86400
str(q04dat)

dat180hire <- q04dat %>% filter(promo1time_day <= 180)

count(dat180hire %>% filter(str_detect(hire_date, "1988")))
#77
count(dat180hire %>% filter(str_detect(hire_date, "1989")))
#71
count(dat180hire %>% filter(str_detect(hire_date, "1990")))
#36
count(dat180hire %>% filter(str_detect(hire_date, "1991")))
#25
count(dat180hire %>% filter(str_detect(hire_date, "1992")))
#14

#probabilility
prob1988 <- (count(dat180hire %>% filter(str_detect(hire_date, "1988"))))/(count(q04dat %>% filter(str_detect(hire_date, "1988"))))
prob1989 <- (count(dat180hire %>% filter(str_detect(hire_date, "1989"))))/count(q04dat %>% filter(str_detect(hire_date, "1989")))
prob1990 <- (count(dat180hire %>% filter(str_detect(hire_date, "1990"))))/count(q04dat %>% filter(str_detect(hire_date, "1990")))
prob1991 <- (count(dat180hire %>% filter(str_detect(hire_date, "1991"))))/count(q04dat %>% filter(str_detect(hire_date, "1991")))
prob1992 <- (count(dat180hire %>% filter(str_detect(hire_date, "1992"))))/count(q04dat %>% filter(str_detect(hire_date, "1992")))

View(dat180hire)
View(q04dat)

mydf5 <- data.frame(
  Cohort_year = c("1988", "1989", "1990", "1991", "1992"),
  Probability = c(0.20, 0.22, 0.17, 0.17, 0.25)
)
mydf5

#----
#Calculating for each hire uear cohort the probability of getting a SECOND promotion within 180 days of the first
datpromotion1 <- q04dat %>% drop_na(numdateprom)
count(datpromotion1)

numdateprom2 <- as.POSIXct(datpromotion1$promo2_date, format = "%Y-%m-%d")
numdate2 <- as.numeric(numdateprom2)
numdate2
datpromotion1$numdateprom2 <- numdate2


datpromotion1$promo2time <- datpromotion1$numdateprom2 - datpromotion1$numdateprom
datpromotion1$promo2time_day <- datpromotion1$promo2time / 86400
str(datpromotion1)

dat180hire2 <- datpromotion1 %>% filter(promo2time_day <= 180)

#cohort
#count(datpromotion1 %>% filter(str_detect(hire_date, "1988")))
#count(datpromotion1 %>% filter(str_detect(hire_date, "1989")))
#count(datpromotion1 %>% filter(str_detect(hire_date, "1990")))
#count(datpromotion1 %>% filter(str_detect(hire_date, "1991")))
#count(datpromotion1 %>% filter(str_detect(hire_date, "1992")))

#probability
prob1988b <- (count(dat180hire2 %>% filter(str_detect(hire_date, "1988"))))/(count(datpromotion1 %>% filter(str_detect(hire_date, "1988"))))
prob1989b <- (count(dat180hire2 %>% filter(str_detect(hire_date, "1989"))))/(count(datpromotion1 %>% filter(str_detect(hire_date, "1989"))))
prob1990b <- (count(dat180hire2 %>% filter(str_detect(hire_date, "1990"))))/(count(datpromotion1 %>% filter(str_detect(hire_date, "1990"))))
prob1991b <- (count(dat180hire2 %>% filter(str_detect(hire_date, "1991"))))/(count(datpromotion1 %>% filter(str_detect(hire_date, "1991"))))
prob1992b <- (count(dat180hire2 %>% filter(str_detect(hire_date, "1992"))))/(count(datpromotion1 %>% filter(str_detect(hire_date, "1992"))))


mydf5_1 <- data.frame(
  Cohort_year = c("1988", "1989", "1990", "1991", "1992"),
  Probability = c(0.09, 0.05, 0.09, 0.14, 0.06)
)
mydf5_1

#----
#Computing age-specific mortality rates (ASMRs) and proportion of person-years lived for each age group.
Magedat <- q06dat$deaths/q06dat$exposure
Propdat <- (q06dat$exposure)/(sum(q06dat$exposure))
q06dat$Mort <- Magedat
q06dat$Prop <- Propdat
ageg <- q06dat$age

mydf6 <- data.frame(
  Age_Group = ageg,
  Mortality_Rate = Magedat,
  Proportion = Propdat
)
mydf6

#----
#Crude death rate as a function of the ASMRs and age structure
CDR <- sum(Magedat*Propdat)
CDR