library(tm) # library for text mining
library(plyr) #Tools for Splitting, Applying and Combining Data
library(cluster) #library for cluster analysis
library(labdsv) #library for Ordination and Multivariate Analysis for Ecology
library(vegan) #another ordinations methods library
library(dendextend) #for better dendograms
library(plotrix)
library(openxlsx)

#You need to indicate the whole path of the package_draft file
source("/Users/jorgegustavorodriguezaboytes/Statstutorial/word_analysis/package_draft.R")

#set your working directory where the text files are
setwd("/Users/jorgegustavorodriguezaboytes/Statstutorial/word_analysis/data/final_sdgs_onlynouns")


#---FILES IMPORT AND CREATION OF DATAFRAMES ----

# some files are corrupted, other contain very few or a extreme high number of words, others are duplicates, or others may be irrelavant
# in any case, use the vector "remove_papers" to put the files names that you want to remove

remove_papers <- c()
# the function "importing words", imports all your files and creates a list of dataframes per file. Each dataframe contains the word and frequency of each word.
# this function requires the following inputs, "e" for empirical papers, "r" for reviews or "c" for conceptual papers. If you don't have this labeling system,
# which is highly recommended, you need to put "x" in both cases. The next argument is "remove_papers". The function works if this remove_papers is empty.

test <- importing_words("c", "r", whole_label=FALSE, remove_papers)

#it is important to check the distribution of number of words across all articles to identify the outliers.

# articles_length: saves the length of all dataframes or articles
# articles_dfs: retrieves the list of dataframes. You can retrieve an specific dataframe putting the index in articles_dfs[[index]]
# papers_titles: retrieves the list of the articles or files' names. You can retrieve the specific name or label by papers_titles[index]
# npapers: retrieves the number of articles of dataframes in the list

articles_length <- test$article_length 
articles_dfs <- test$articles_df 
papers_titles <- test$papers_titles 
npapers <- test$npapers 

hist(articles_length, col = "lightgreen", xlab = "word count", ylab = "frequency", main="")
boxplot(articles_length, xlab= "articles", ylab= "word count", pch = 19, col = "lightgreen", outcol = "red")


papers_to_remove <- papers_titles[which(articles_length < 167 | articles_length > 590)]
papers_to_remove <- papers_titles[which(articles_length < 164 | articles_length > 824)]
papers_to_remove <- append(papers_to_remove,papers_titles[which(articles_length > 867)])
papers_to_remove <- append(papers_to_remove,papers_titles[which(articles_length > 824)])

remove_papers <- papers_to_remove
#-----ABUNDANCE TABLE-----
# Just run the function. The variable "words_df" contains the raw abundance table, with the frequencies corrected by the length of the articles
words_df <- abundance_dataframe(articles_dfs, papers_titles, npapers, articles_length)

setwd("/Users/jorgegustavorodriguezaboytes/Statstutorial/word_analysis/")
write.xlsx(t(words_df), "doublecheckreview.xlsx", rowNames = T)

# getting optimal frequencies, selecting the most abundant words. For example, if you want to get the 20% most abundant words, you put the 20 as an arguments.
frequency_words(words_df, 20)

# As a result, you get 1) the mininum frequency to get the % most abundant articles and 2) the resulting number of words
# you can save it as a variable
optimal_frequency <- frequency_words(words_df, 30)

#---DCA MODEL----
# Now that you have decided on the

freq <- 15
#freq <- optimal_frequency$freq
sumrows <- 0 
dca <- words_dca(words_df, freq, sumrows=0, logscaling=TRUE) #this is the function to be run
abundancet <- dca$abundancet  #this is the final abundance table
model <- dca$model # this is the dca model
plot(model)



#sumrows: run it, ignore it or take faith in it. It is just to get rid of articles that possibly have all words with zero frequencies.
#logscaling: indicate if you want to apply logarithm scale to the frequencies

#----CLUSTERS BARPLOT AND INDICATORS----
# now with the DCA model, the next step is to apply the hiearchical clustering with the final abundance table (abundancet)
number_of_clusters <-8 #the maximum number of clusters you want to see. Recommended not put a high number
clusters_barplot(abundancet, number_of_clusters, printclusters=FALSE)

#cluster indicators---This function is to see only the abundance indicators in each cluster

nk <- 8
cluster_indicators(abundancet, nk)

# dataframe with abundance indicators (optional) - you get a dataframe with all the abundance indicators, from two to nk clusters.
temp6 <- abundance_indicators(abundancet,nk)

#---PRODUCING THE WORD CLOUD----
# nk: Indicate the number of clusters you want
# wordnumber: Indicate the number of words you want in each cluster
# cex: Indicate the size of words
# final_cluster: Indicate the number of words you want in each cluster
# subsets: the specific subsets
# adjust the parameters p-value (p-values of the words) and abmean (the mean of abudance indicators)

xmin = 0
xmax = 0 #adjusting the axis
ymin = 0
ymax = 0

nk <-nk 
wordnumber <- 5
cex <- 0.8
wordi <- wordcloud(abundancet,nk,model,wordnumber,cex, pvalue=0.05,abmean=0.01, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax) #run the word cloud
final_cluster <- wordi$final_cluster 
subsets <- wordi$subsets



# clustertable --- Getting the dataframe with all the article labels/titles in each cluster

grupos <- clusterstable(abundancet,subsets,nk=nk)
setwd("/Users/jorgegustavorodriguezaboytes/Statstutorial/word_analysis/")
write.xlsx(grupos, "cluster_words_sergey.xlsx", rowNames = FALSE)

#----DENDOGRAMS-----
# wordendogram: the dendogram with all clusters
# clusters: information about the clusters 
# subdends: a list with the specific cluster dendograms

wordendogram <- wordendo(abundancet,nk=nk)
clusters <- wordendogram$clusters
subdends <- wordendogram$sub_dend
dend <- wordendogram$dend

# navigating across branches in specific dendograms
plot(subdends[[2]])
plot(subdends[[2]][[1]])
plot(subdends[[8]][[2]][[1]][[1]][[1]])

#checking labels or titles
labels(clusters[[2]][[1]][[2]])
labels(clusters[[9]][[1]][[2]][[2]][[2]])
labels(clusters[[2]][[1]][[1]][[1]][[1]][[1]][[1]][[1]])

papers_to_remove <- append(papers_to_remove, "Luo2024.txt")

papers_to_remove <- append(papers_to_remove,labels(clusters[[9]][[1]][[2]]))

#----PRODUCING ELIPSIS PLOT----

#create a vector with the names of the clusters, the length of the vector must match the number of clusters.
group_labels <- c("healthcare", "vegetation", "forecasting", "water", "remote sensing", "clean energy", "industry", "education")
elipse <- elipse_plot(subsets,final_cluster,group_labels, with_labels=TRUE)

