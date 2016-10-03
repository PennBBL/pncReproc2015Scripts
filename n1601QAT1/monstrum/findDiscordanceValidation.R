# AFGR April 7th 2016

# This script is going to be used to do the same thing as find.Discordance.R
# but it will just work for the validation file sets

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


# Now load the data
df1 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/jablake_qa_logs/merged_edited.csv')
df2 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/kseelaus_qa_logs/merged_edited.csv')
df3 <- read.csv('/import/monstrum/Users/adrose/t1QA/data/lvilla_qa_logs/merged_edited.csv')


#### Merge the data - after changing column names - and fixing some other stuff
colnames(df1) <- c('num', 'bblid', 'scanid', 'ratingJB')
df1 <- df1[,1:4]
colnames(df2) <- c('num', 'bblid', 'scanid', 'ratingKS')
df2 <- df2[,1:4]
colnames(df3) <- c('num', 'bblid', 'scanid', 'ratingLV')
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
for(i in 1:916){
  tmp <- ident(just.ratings$ratingJB[i], just.ratings$ratingKS[i], just.ratings$ratingLV[i])
  if(tmp=='FALSE'){
    mis.match.row.index <- append(mis.match.row.index, i)  
  }
  if(tmp=='TRUE'){
    match.row.index <- append(match.row.index, i)
  }
}


# now go through and find all of the rating bins
# Start with 2 zeros and one 1
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

zeroZeroZeroIndex <- length(which(just.ratings$ratingJB==0 & just.ratings$ratingKS==0 & just.ratings$ratingLV==0)) 

oneOneOneIndex <- length(which(just.ratings$ratingJB==1 & just.ratings$ratingKS==1 & just.ratings$ratingLV==1))

twoTwoTwoIndex <- length(which(just.ratings$ratingJB==2 & just.ratings$ratingKS==2 & just.ratings$ratingLV==2))

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


#### Now write the csv to use for the qap val explore
averageRating <- just.ratings$ratingJB + just.ratings$ratingKS + just.ratings$ratingLV
averageRating <- round(averageRating/3, digits=2)
output <- cbind(just.ratings, averageRating)
write.csv(output, 'validationManualRatingData.csv', row.names=F, quote=F)
