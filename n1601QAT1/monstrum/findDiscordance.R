# AFGR December 9th 2015

# This script is going to be used to create a function which will return discordance for a 
# subject based on a inputted bblid, and the associated data frames
# I am not sure the best way to return or how to structure the output but I will find a way and # update this header later on

## Load Library(s)
library(irr)
library(polycor)
library(ggplot2)
## Declare function(s)
# Create a function which will take a list of inputs and return a bolean if they 
# are all equal or not
ident <- function(...){
    args <- c(...) 
    if( length( args ) > 2L ){
       #  recursively call ident()
       out <- c( identical( args[1] , args[2] ) , ident(args[-1]))
    }else{
        out <- identical( args[1] , args[2] )
    }    
    return( all( out ) )
}


# Create a function which will take a bblid and find if the row exists and then output if the
# rows are all equal
findDiscordance <- function(inputRow, dataFrame){
  # First find the mode of the row
  mode.value <- as.numeric(names(sort(-table(dataFrame[inputRow,])))[1])

  # Now find which columns do not equal the mode
  diff.cols <- which(dataFrame[inputRow,] != mode.value)
  
  # Now find the difference between the mode 
  cols.diff <- dataFrame[inputRow, diff.cols] - mode.value

  # Now attacht the difference to the column index
  diff.cols <- append(diff.cols, cols.diff)

  # Now return the diff.cols
  return(diff.cols)
} 



## Load the data here
#df1 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/#jablakeoutfile15_12_07_15_51_40_edited.csv')
#df1 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/jablakeoutfileWOComments.csv')

#df2 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/#lvillaoutfile15_12_07_16_37_38_edited.csv')
#df2 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/lvillaoutfileWOCOmments.csv')

#df3 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/#merged_edited.csv')

#df3 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/kseelasoutfileWOComments.csv')

#df4 <- read.csv('/import/monstrum2/Users/adrose/t1QA/data/expertTrainingCohort/allTrainingCohort.csv')

df1 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/jablake_qa_logs/mergedjablake.csv')
df2 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/kseelaus_qa_logs/merged_edited.csv')
df3 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/lvilla_qa_logs/merged_edited.csv')



# Clean the data down here
# Get rid of any duplicates, keep the first option every time and also clean out any NA's
df1 <- df1[ ! duplicated(df1$bblid),]
df1 <- na.omit(df1)
df2 <- df2[ ! duplicated(df2$bblid),]
df2 <- na.omit(df2)
df3 <- df3[ ! duplicated(df3$bblid),]
df3 <- na.omit(df3)


## Run the script down here
#Find the shortest csv and use that as the bblid index
find.min.index <- c(length(df1$bblid), length(df2$bblid), length(df3$bblid))
dfIndexToUse <- which.min(find.min.index)
dfIndexToUse <- get(paste('df', dfIndexToUse, sep=''))$bblid

# Now I need to go through each bblid and find the ratings 
# for the image and find if they all match
# If they don't match return the bblid to a vector
non.match.vector <- data.frame()
non.match.dataframe <- data.frame()
col.index.vector <- vector()
for(bblid.value in dfIndexToUse){
  # First find if all of the values match
  match.value <- ident(c(df1[grep(bblid.value, df1$bblid),4],df2[grep(bblid.value, df2$bblid),4],df3[grep(bblid.value, df3$bblid),4], df4[grep(bblid.value, df4$bblid),5]))
  # Now if the match value is not equal to TRUE then add the bblid to a vector
  if( match.value == 'FALSE'){
    non.match.vector <- append(non.match.vector, bblid.value) 
    # Now grab the individual ratings and put them into a row with the 
    # bblid to export to a dataframe  
    non.match.ratings <- c(df1[grep(bblid.value, df1$bblid),4],
                           df2[grep(bblid.value, df2$bblid),4],
                           df3[grep(bblid.value, df3$bblid),4])
    non.match.row <- append(bblid.value, non.match.ratings)
    non.match.dataframe <- rbind(non.match.dataframe, non.match.row)
    #col.index.vector <- rbind(col.index.vector, findDiscordance(grep(bblid.value, df1$bblid), tmp))
  }
}


# Now calculate the interrater reliability for non experts
tmp <- cbind(df1$rating[1:length(dfIndexToUse)], 
             df2$rating[1:length(dfIndexToUse)],
             df3$rating[1:length(dfIndexToUse)])
kappam.fleiss(tmp)


# Now include the experts
expertsBblidIndex <- df4$bblid[match(df4$bblid, dfIndexToUse)]
expertsRatingIndex <- df4$DR.RATING[match(df4$bblid, dfIndexToUse)]
expertsRatingIndex <- expertsRatingIndex[!is.na(expertsBblidIndex)]
expertsRatingIndex <- expertsRatingIndex[!duplicated(experstBblidIndex)]
expertsRatingIndex <- expertsRatingIndex[!is.na(expertsRatingIndex)]
expertsBblidIndex <- expertsBblidIndex[!is.na(expertsBblidIndex)]
expertsBblidIndex <- expertsBblidIndex[!duplicated(experstBblidIndex)]
expertsBblidIndex <- expertsBblidIndex[!is.na(expertsBblidIndex)]


tmp1 <- cbind(df1$rating[1:length(dfIndexToUse)], 
              df2$rating[1:length(dfIndexToUse)],
              df3$rating[1:length(dfIndexToUse)],
              expertsRatingIndex)
kappam.fleiss(tmp1)
tmp2 <- cbind(expertsBblidIndex, tmp1)

# Check to make sure that all of the expert ratings are correctly attached
i <- 0
for(bblid.value in dfIndexToUse){
  match.value <- ident(c(as.numeric(df4[grep(bblid.value, df4$bblid),5]),as.numeric(tmp2[grep(bblid.value, tmp2[,1]),5])))
  print(match.value)
  i <- i + 1
  print(i)
}




### Load the all ratings down here and find % agreement 
allRatings <- read.csv("/import/monstrum2/Users/adrose/t1QA/data/concordanceAnalysis/consensusAllRatings.csv")


# Now make sure that all of the ratings matchup start with Kevin
for(bblid.value in dfIndexToUse){
  match.value <- ident(c(as.numeric(allRatings[grep(bblid.value, allRatings$bblid),3]), as.numeric(df3[grep(bblid.value, df3$bblid),4])))
  print(match.value)
}

# Now do Prayosha
for(bblid.value in dfIndexToUse){
  match.value <- ident(c(as.numeric(allRatings[grep(bblid.value, allRatings$bblid),4]), as.numeric(df2[grep(bblid.value, df2$bblid),4])))
  print(match.value)
}

# Now check Jason's
for(bblid.value in dfIndexToUse){
  match.value <- ident(c(as.numeric(allRatings[grep(bblid.value, allRatings$bblid),5]), as.numeric(df1[grep(bblid.value, df1$bblid),4])))
  print(match.value)
}

# Now do the experts
for(bblid.value in dfIndexToUse){
  match.value <- ident(c(as.numeric(allRatings[grep(bblid.value, allRatings$bblid),6]), as.numeric(df4[grep(bblid.value, df4$bblid),5])))
  print(match.value)
}


## Errything matches up, now lets grab the percantages
# Now find % of agreement
kAgree <- length(which(allRatings$ratingK==allRatings$ratingE))
lAgree <- length(which(allRatings$ratingL==allRatings$ratingE))
jAgree <- length(which(allRatings$ratingJ==allRatings$ratingE))


###################
###################
###################
###1601 Man Rate###
###WORK START######
####DOWN HERE######
###################

#### Load the data#
df1 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/jablake_qa_logs/go1/mergedjablake.csv')
df2 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/kseelaus_qa_logs/go1/merged_edited.csv')
#df3 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/lvilla_qa_logs/merged_edited.csv')
df3 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/lvilla_qa_logs/go1/merged_edited_afgr_consensus_edits.csv')

#### Merge the data - after changing column names - and fixing some other stuff
colnames(df1) <- c('num', 'bblid', 'scanid', 'ratingJB', 'ringingJB')
df1 <- df1[,1:4]
colnames(df2) <- c('num', 'bblid', 'scanid', 'ratingKS', 'ringingKS')
df2 <- df2[,1:4]
colnames(df3) <- c('bblid', 'scanid', 'ratingLV', 'ringingLV')
df3 <- df3[,1:4]
df1 <- df1[ ! duplicated(df1$bblid),]
df1 <- na.omit(df1)
df2 <- df2[ ! duplicated(df2$bblid),]
df2 <- na.omit(df2)
df3 <- df3[ ! duplicated(df3$bblid),]
df3 <- na.omit(df3)


## Now merge the data together
all.ratings <- merge(df1, df2, by='bblid')
all.ratings <- merge(all.ratings, df3, by='bblid')
just.ratings <- as.data.frame(cbind(all.ratings$bblid, all.ratings$ratingJB, all.ratings$ratingKS, all.ratings$ratingLV))
colnames(just.ratings) <- c('bblid', 'ratingJB', 'ratingKS', 'ratingLV')

##### First find the distribution for each possible rating spread

## First find all rows that are identical
mis.match.row.index <- vector()
match.row.index <- vector()
for(i in 1:1601){
  tmp <- ident(just.ratings$ratingJB[i], just.ratings$ratingKS[i], just.ratings$ratingLV[i])
  if(tmp=='FALSE'){
    mis.match.row.index <- append(mis.match.row.index, i)  
  }
  if(tmp=='TRUE'){
    match.row.index <- append(match.row.index, i)
  }
}


## Not sure the best way to perform this so I am going to brute force it... =(
## I now need to go through all of the rows with discordance and faind the distribution of the votes, and bin each of those.
## Start with 2 zeros and one one.
tmp1 <- length(which(just.ratings$ratingJB==0 & just.ratings$ratingKS==0 & just.ratings$ratingLV==1))
tmp2 <- length(which(just.ratings$ratingJB==0 & just.ratings$ratingKS==1 & just.ratings$ratingLV==0))
tmp3 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==0 & just.ratings$ratingLV==0))
zeroZeroOneIndex <- tmp1 + tmp2 + tmp3

## Now do 1,1,0
tmp1 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==1 & just.ratings$ratingLV==0))
tmp2 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==0 & just.ratings$ratingLV==1))
tmp3 <- length(which(just.ratings$ratingJB==0 & just.ratings$ratingKS==1 & just.ratings$ratingLV==1))
oneOneZeroIndex <- tmp1 + tmp2 + tmp3

# Now do 112
tmp1 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==1 & just.ratings$ratingLV==2))
tmp2 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==2 & just.ratings$ratingLV==1))
tmp3 <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==1 & just.ratings$ratingLV==1))
oneOneTwoIndex <- tmp1 + tmp2 + tmp3

# Now do 2,2,1
tmp1 <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==2 & just.ratings$ratingLV==1))
tmp2 <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==1 & just.ratings$ratingLV==2))
tmp3 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==2 & just.ratings$ratingLV==2))
twoTwoOneIndex <- tmp1 + tmp2 + tmp3

# Now do 2,2,0
tmp1 <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==2 & just.ratings$ratingLV==0))
tmp2 <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==0 & just.ratings$ratingLV==2))
tmp3 <- length(which(just.ratings$ratingJB==0 & just.ratings$ratingKS==2 & just.ratings$ratingLV==2))
twoTwoZeroIndex <- tmp1 + tmp2 + tmp3


# Now do 0,1,2
tmp1 <- length(which(just.ratings$ratingJB[mis.match.row.index]==0 & just.ratings$ratingKS[mis.match.row.index]==1 & just.ratings$ratingLV[mis.match.row.index]==2))
tmp2 <- length(which(just.ratings$ratingJB[mis.match.row.index]==0 & just.ratings$ratingKS[mis.match.row.index]==2 & just.ratings$ratingLV[mis.match.row.index]==1))
tmp3 <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==2 & just.ratings$ratingLV==0))
tmp4 <- length(which(just.ratings$ratingJB[mis.match.row.index]==1 & just.ratings$ratingKS[mis.match.row.index]==0 & just.ratings$ratingLV[mis.match.row.index]==2))
tmp5 <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==1 & just.ratings$ratingLV==0))
tmp6 <- length(which(just.ratings$ratingJB[mis.match.row.index]==2 & just.ratings$ratingKS[mis.match.row.index]==0 & just.ratings$ratingLV[mis.match.row.index]==1))
zeroOneTwoIndex <- tmp1 + tmp2 + tmp3 + tmp4 + tmp5 + tmp6

zeroZeroZeroIndex <- 11
oneOneOneIndex <- 49
twoTwoTwoIndex <- 1280



#### Now graph all of these things
ratingDistributionToPlot <- as.data.frame(rbind(zeroZeroZeroIndex ,zeroZeroOneIndex, oneOneTwoIndex, oneOneOneIndex, zeroOneTwoIndex, twoTwoZeroIndex, twoTwoOneIndex,twoTwoTwoIndex))
foo <- c('zeroZeroZeroIndex' ,'zeroZeroOneIndex', 'oneOneTwoIndex', 'oneOneOneIndex', 'zeroOneTwoIndex', 'twoTwoZeroIndex', 'twoTwoOneIndex','twoTwoTwoIndex')
ratingDistributionToPlot <- cbind(ratingDistributionToPlot,foo)
ratingDistributionToPlot$foo <- factor(ratingDistributionToPlot$foo, levels=c('zeroZeroZeroIndex' ,'zeroZeroOneIndex', 'oneOneTwoIndex', 'oneOneOneIndex', 'zeroOneTwoIndex', 'twoTwoZeroIndex', 'twoTwoOneIndex','twoTwoTwoIndex'))

pdf('foo.pdf')
barPlot <- ggplot(ratingDistributionToPlot, aes(x=foo, y=V1, fill=V1)) + geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle=45,hjust=1)) +
  labs(title="Possible Vote Spreads", x="Spread Index", y="# of Votes With Spread")
barPlot
dev.off()


