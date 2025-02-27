
#------Importing files and words----

importing_words <- function(type_of_article1, type_of_article2, whole_label=TRUE, remove_papers=c()){
  all_titles <- list.files() #files_names are storied into this list
  papers_titles <- list() #empty list for the filtered titles
  articles <- list() # empty list where articls are going to be stored
  i=1
  start=1
  for (i in c(i:length(all_titles))){
    method <- substring(all_titles[i], 1, 4)
    if(whole_label==TRUE){
      method <- all_titles[i]
    }
    if(grepl(type_of_article1, method) | grepl(type_of_article2, method)){
      papers_titles <- append(papers_titles, all_titles[i])
    }
  }
  papers_titles <- as.character(papers_titles)
  papers_titles <- papers_titles[!papers_titles %in% remove_papers]
  npapers <- length(papers_titles)
  end <- npapers
  article_length <- c()
  
  for (i in c(start:end)){
    try({
      doc <- scan(papers_titles[i], what = "character", sep = "\n") #importing the .txt file
      doc <- paste(doc, collapse=" ") #separating each character by " "
      doc <- gsub("- ", "", doc)  # undo hyphenation
      doc <- gsub('\f', " ", doc) #form feed character
      doc <- gsub("[^A-Za-z[:space:]]", " ", doc) #removing all non-words and non-spaces
      doc <- gsub(" +", " ", doc) #removing all more than 1 spaces
      doc <- gsub('\n', " ", doc) #removing paragraph jump
      doc <- trimws(doc) #removing all the spaces at the beginning and end of the string
      doc <- tolower(doc) #converting to lowercase
      words <- strsplit(doc," ") #splitting the whole string into single characters
      
      articles[[i]] <- data.frame(table(words)) 
      wn <- nrow(articles[[i]]) # wn stands for words number in the article
      article_length <- c(article_length, wn) #vector with the length of each paper
      names(articles)[i] <- papers_titles[i] 
      print(i)
    })
  }
  
  return(list(
    article_length = article_length,
    articles_dfs = articles,
    papers_titles = papers_titles,
    npapers = npapers
  ))
}

#----creating abundance table----

abundance_dataframe <-function(articles, papers_titles, npapers, articles_length){
  # Check if the input is a list
  if (!is.list(articles)) {
    stop("Input must be a list. Provided input is not a list.", call. = FALSE)
  }
  
  # Check if every element of the list is a data frame
  if (!all(sapply(articles, is.data.frame))) {
    stop("All elements of the list must be data frames.", call. = FALSE)
  }
  
  words_as_index <- function(data_frame, i){
    df           <- as.data.frame(data_frame[[i]]$Freq)
    colnames(df) <- names(data_frame[i])
    rownames(df) <- data_frame[[i]]$words
    return(df)
  }
  
  i <- 1
  start <- 1
  end <- npapers
  
  #Applying the function
  words_frequencies = list()
  j = 0
  deleted_papers <- 0
  new_articles <- articles
  for (i in start:end){
    print(i)
    if(length(row.names(articles[[i]])!=0)){
      j = j + 1
      words_frequencies[[j]] <- words_as_index(articles,i)} 
    else{
      print (paste0("The ", as.character(i), "th list-entry is empty - following PDF seems not having been read rightly:  ", as.character(papers_titles[i]) ) )
      deleted_papers <- deleted_papers + 1
      new_articles <- new_articles[-i]
    }
  }
  npapers <- npapers - deleted_papers
  end <- npapers
  articles <- new_articles
  
  ##--CREATING SINGLE DATAFRAME WITH ALL THE ARTICLES' WORDS----
  
  for ( i in 1:(length(words_frequencies)-1) ){
    if (i == 1){
      df1 = words_frequencies[[i]]
      df2 = words_frequencies[[i+1]]}else{df2 = words_frequencies[[i+1]]}
    df1 <- merge(df1, df2, all=T,by="row.names",sort=F)
    # The merge function drops the row.names, and in turn adds a column named "row.names": Correct this!
    row.names(df1) <- df1[,1] #putting the words as the index (again)
    print(i)
    df1 <- df1[,-1]#removing the first column "row.names"
  }
  
  allwords <- df1
  rm(df1, df2)
  
  ##--CREATING ABUNDANCE TABLE----
  
  ###vector of unique words
  word_vector<-as.factor(sort(row.names(allwords))) #words sorted
  word_vector<- word_vector[which(nchar(as.character(word_vector))<20)] #all words less that 20 length
  word_vector<-as.factor(word_vector) #words as factor
  word_levels<-levels(word_vector) #words as levels
  
  ## abundance table
  word_df <- data.frame(words = word_levels)
  colnames(word_df)<-"words"
  
  #populating the table with all the words present in each article
  for (j in c(1:end)){
    article <-articles[[j]]
    article_filtered <-article[article$words %in% word_levels,]
    word_df <- merge(word_df, article_filtered, by="words",all.x=T)
    print(j)
  }
  
  word_df<-word_df[,2:(npapers+1)] #removing first column
  rownames(word_df) <- word_levels #putting the words as index
  
  #replacing NAs with 0 and renaming columns
  for (i in 1:npapers) word_df[is.na(word_df[,i]),i] <- 0
  colnames(word_df)<-names(articles)[c(1:npapers)]
  
  
  
  ## Correcting the frequencies of words by the total words in each article
  word_df <- sweep(word_df, 2, articles_length, "/")
  word_df <- word_df*1000
  
  return(word_df)
  
}

#-----Getting the optimal frequency----

frequency_words <- function(word_df, top_words){
  top_words <- top_words/100
  rows_number <- nrow(word_df)
  top <- round(nrow(word_df)*top_words,0) #change here to get the percentage of top words with highest abundance
  freq <- 1
  # While loop
  while (rows_number>=top) {
    moritz<- word_df[apply(ifelse(word_df>0,1,0),1,sum)>freq,]
    rows_number <- nrow(moritz)
    # Increment the counter to avoid infinite loop
    freq <- freq + 1
  }
  freq <- freq -1 
  paste0("The higher frequency to get the", top_words*100, "is ", freq) 
  return(list(freq = freq,
              words_number = rows_number
  ))
}

#removing the articles grouped in very small branches
#abundancet <- abundancet[!row.names(abundancet) %in% remove_sites, ]

#----running DCA----
words_dca <- function(word_df, freq,sumrows=0, logscaling=TRUE){
  
  moritz<- word_df[apply(ifelse(word_df>0,1,0),1,sum)>freq,]
  abundance <- moritz
  abundancet <- t(abundance)
  abundancet <- abundancet[rowSums(abundancet)>0,]
  if(logscaling==TRUE){
    abundancet<- log(abundancet+1) 
  }
  #eliminating rows or articles with empty values
  abundancet <- abundancet[rowSums(abundancet) > sumrows, ]
  model<-decorana(abundancet,iweigh=0, ira=0)
  return(list(model = model,
              moritz = moritz,
              abundancet = abundancet))
}

#----cluster barplot ------

clusters_barplot <- function(abundancet, number_of_clusters, printclusters = TRUE){
  modelclust<-agnes(abundancet,method="ward")
  nk<-2 # initial number of clusters
  cutmodel_values <- list()
  for (i in c(2:20)){
    cutmodel <-cutree(modelclust,k=nk)
    elements_incluster <- table(cutmodel)
    
    cluster_below_number <- FALSE
    gus <- c()
    for (j in c(1:nk)){
      num_elements <- as.numeric(elements_incluster[j])
      gus <- c(gus, num_elements)
      if (num_elements < 1){
        cluster_below_number <- TRUE
        break
      }
    }
    
    if (cluster_below_number){
      break
    }
    cutmodel_values[[i]] <- gus
    if (printclusters == TRUE){
      print(elements_incluster)
    }
    
    nk <- nk + 1
  }
  nk <- nk -1 
  paste0("The maximum number of clusters is ", nk)
  #---ploting the cutmodel
  num_rows <- nk
  num_columns <- nk
  cutmodel_m<- matrix(NA, nrow = num_rows, ncol = num_columns)
  for (i in 2:num_rows) {
    # Fill the matrix row by row
    cutmodel_m[i, 1:length(cutmodel_values[[i]])] <- cutmodel_values[[i]]
  }
  cutmodel_m <- cutmodel_m[-1,]
  
  colores <- c("#FF0000","#008000","#800000","#0000FF","#808000","#FF00FF",
               "#800080","#008080","#000080","#FFA500","#A52A2A","#8B4513","#DC143C",
               "#DA70D6","#7FFF00","#D2691E","#00CED1","#9400D3","#FFD700","#ADFF2F","#FF69B4","#CD5C5C"
  )
  
  number_of_clusters <- number_of_clusters
  nk <- number_of_clusters - 1

  return(barplot(t(cutmodel_m[1:nk, 1:(nk+1)]), 
          beside = TRUE, 
          horiz = FALSE, 
          col = colores[1:(nk+1)], 
          legend.text = paste("Cluster", 1:(nk+1)), 
          args.legend = list(x = "topright", bty = "n", title = "Clusters"),
          ylab = "Number of papers",
          xlab = "Number of clusters",
          names.arg = paste((1:nk)+1),
          main = "Distribution of clusters",
          space = c(0, 0)))
}


#-----showing numbers in cluster and indicators-----
cluster_indicators <- function(abundancet,nk){
  modelclust<-agnes(abundancet,method="ward")
  cutmodel <-cutree(modelclust,k=nk)
  print(table(cutmodel))
  temp5<-indval(abundancet,cutmodel,numitr=1000)
  summary(temp5)
}


#----getting dataframe with cluster and abundance indicators----
abundance_indicators <- function(abundancet,nk){
  modelclust<-agnes(abundancet,method="ward")
  temp6 <- data.frame(number_of_clusters=integer(),
                      probabilities_sum = numeric(),
                      indicator_values_sum = numeric(),
                      significant_indicator_value_sum = numeric(),
                      number_of_significant_indicators = numeric())
  # Predefine cluster columns (e.g., cl_1, cl_2, ..., cl_max_clusters)
  for (j in 1:nk) {
    temp6[[paste0("cl_", j)]] <- numeric()
  }
  
  # Loop over cluster numbers and fill the dataframe
  for (i in 2:nk) {
    cutmodel <- cutree(modelclust, k = i)
    temp5 <- indval(abundancet, cutmodel, numitr = 1000, digits=6)
    
    # Calculate significant indices and distribution
    significant_indices <- which(temp5$pval <= 0.05)
    significant_distribution <- as.vector(table(temp5$maxcls[significant_indices]))
    
    # Create a new row with the standard columns
    new_row <- data.frame(
      number_of_clusters = i,
      probabilities_sum = sum(temp5$pval),
      indicator_values_sum = sum(temp5$indcls),
      significant_indicator_value_sum = sum(temp5$indcls[significant_indices]),
      number_of_significant_indicators = length(significant_indices)
    )
    
    # Add the significant distribution to the new row
    # Ensure all clusters are accounted for, even if some are missing
    for (j in 1:nk) {
      if (j <= length(significant_distribution)) {
        new_row[[paste0("cl_", j)]] <- significant_distribution[j]
      } else {
        # If a cluster is missing in the distribution, fill with NA
        new_row[[paste0("cl_", j)]] <- NA
      }
    }
    
    # Ensure both temp6 and new_row have the same columns
    missing_cols <- setdiff(names(temp6), names(new_row))
    for (col in missing_cols) {
      new_row[[col]] <- NA
    }
    
    # rbind the new row to temp6
    temp6 <- rbind(temp6, new_row)
  }
  return(temp6)
}


#-------WordCloud-----
wordcloud <- function(abundancet, nk, model, wordnumber,cex=0.8,pvalue=0.05,abmean=0.01, xmin = 0, xmax = 0, ymin=0, ymax=0, xspace=0, yspace=0){
  
  modelclust<-agnes(abundancet,method="ward")
  cutmodel <-cutree(modelclust,k=nk)
  temp5<-indval(abundancet,cutmodel,numitr=1000)
  
  achsen<-model$cproj[,c(1:2)]
  cluster_dca<-cbind(round(temp5$indval,d=2),temp5$pval,names(temp5$pval),achsen)
  cluster_dcap<-cluster_dca[cluster_dca[nk+1]<pvalue,] #p-value less than ...
  final_cluster<-cluster_dcap[which(apply(cluster_dcap[,c(1:nk)],1,mean)>abmean),] #abmean means abudance indicators mean
  
  par(xpd=T)
  par(mar=c(2,2,0.1,0.1))
  plot(final_cluster$DCA1,final_cluster$DCA2,xlim=c(min(final_cluster$DCA1)+xmin,max(final_cluster$DCA1)+xmax),ylim=c(min(final_cluster$DCA2)+ymin,max(final_cluster$DCA2)+ymax),xlab="DCA1",ylab="DCA2",type="n")
  
  #wordnumber<-wordnumber
  
  subsets <- list()
  
  colores <- c("#FF0000","#008000","#800000","#0000FF","#808000","#FF00FF",
               "#800080","#008080","#000080","#FFA500","#A52A2A","#8B4513","#DC143C",
               "#DA70D6","#7FFF00","#D2691E","#00CED1","#9400D3","#FFD700","#ADFF2F","#FF69B4","#CD5C5C"
  )
  
  for (i in 1:nk){
    subsets[[i]] <- final_cluster[order(final_cluster[,i],decreasing=T)[c(1: wordnumber)],]
    #text(subsets[[i]]$DCA1[c(1:wordnumber)],subsets[[i]]$DCA2[c(1:wordnumber)],labels=rownames(subsets[[i]])[c(1:wordnumber)],col=colores[i] ,cex=0.8)
    subsets[[i]]$cluster <- i
  }
  
  
  for (i in 1:nk){
    xadj <- 0
    yadj <- 0
    for (j in 1:wordnumber){
      text(subsets[[i]]$DCA1[c(j)]-xadj,subsets[[i]]$DCA2[c(j)]-yadj, labels=rownames(subsets[[i]])[c(j)],col=colores[i],cex=cex)
      xadj <- xadj + xspace
      yadj <- yadj + yspace
    }
  }
  return(list(final_cluster=final_cluster, subsets=subsets))
}


#----Dendogram function----
wordendo <- function(abundancet,nk){
  
  modelclust<-agnes(abundancet,method="ward")
  
  colores <- c("#FF0000","#008000","#800000","#0000FF","#808000","#FF00FF",
               "#800080","#008080","#000080","#FFA500","#A52A2A","#8B4513","#DC143C",
               "#DA70D6","#7FFF00","#D2691E","#00CED1","#9400D3","#FFD700","#ADFF2F","#FF69B4","#CD5C5C"
  )
  
  dend <- as.dendrogram(modelclust)
  dend <- color_branches(dend, k = nk, col=colores, groupLabels=TRUE)
  # Plot the dendrogram with colored clusters
  plot(dend, main = paste0("Dendrogram with ", nk , " Clusters"))
  
  sub_dend <- get_subdendrograms(dend, k = nk) #getting the subdendrograms in a list
  #plot(sub_dend[[2]], main = paste0("Dendrogram ", nk)) #plotting individual dendograms
  
  clusters <- list() #the clusters
  site_names <- list() #the names of the papers or labels
  member_count <- list(list()) #the number of papers in each branch
  clusters_length <- c()
  for(i in 1:length(sub_dend)){
    clusters[[i]] <- sub_dend[[i]]
    site_names[[i]] <- labels(clusters[[i]])
    clusters_length <- c(clusters_length,length(site_names[[i]]))
    member_count[[i]] <- length(site_names[[i]])
    for(j in 1:2){
      member_count[[i]][[j]]<-length(labels(clusters[[i]][[j]]))
    }
  }
  return(list(dend=dend,
              sub_dend=sub_dend,
              clusters=clusters,
              site_names=site_names,
              clusters_length=clusters_length))
}


#---Clusters dataframe (grupos)------
clusterstable <- function(abundancet,subsets,nk){
  
  
  modelclust<-agnes(abundancet,method="ward")
  cutmodel <-cutree(modelclust,k=nk)

  grupos <- data.frame(article= row.names(abundancet), Cluster = cutmodel)
  grupos$palabras <- NA
  for (i in 1:nrow(grupos)) {
    cluster_id <- grupos$Cluster[i]
    # Get the elements (names) for this specific cluster
    palabras_for_cluster <- row.names(subsets[[cluster_id]])
    # Concatenate the elements into a single string, or store as a list
    grupos$palabras[i] <- paste(palabras_for_cluster, collapse = ", ") # or `I(list(palabras_for_cluster))` if you want a list
  }
  return(grupos)
}




#----getting clusters in ellipsis using CLUSPLOT()----
elipse_plot <- function(subsets,final_cluster,group_labels,with_labels=FALSE){
  
  colores <- c("#FF0000","#008000","#800000","#0000FF","#808000","#FF00FF",
               "#800080","#008080","#000080","#FFA500","#A52A2A","#8B4513","#DC143C",
               "#DA70D6","#7FFF00","#D2691E","#00CED1","#9400D3","#FFD700","#ADFF2F","#FF69B4","#CD5C5C"
  )
  
  cc <- do.call(rbind, subsets) #concatenating all the dataframes in the subsets list
  cc2 <- cc[,c((ncol(cc)-2):ncol(cc))] #getting the columns 
  coordinates <- cc2[, c("DCA1", "DCA2")]
  clusteros <- cc2$cluster
  row.names(coordinates)<-row.names(cc2)
  
  par(xpd=T)
  par(mar=c(2,2,0.1,0.1))
  plot(final_cluster$DCA1,final_cluster$DCA2,xlim=c(min(final_cluster$DCA1)-0,max(final_cluster$DCA1)-0),ylim=c(min(final_cluster$DCA2)-0,max(final_cluster$DCA2)+0.5),xlab="DCA1",ylab="DCA2",type="n")
  
  ##---function to calculate the angle of ellipsis using covariance matrix---
  compute_angle <- function(cov_matrix) {
    eig <- eigen(cov_matrix)
    # Eigenvector corresponding to the largest eigenvalue
    max_eigenvector <- eig$vectors[, 1]
    # Calculate the angle in degrees
    angle <- atan2(max_eigenvector[2], max_eigenvector[1]) * 180 / pi
    return(angle)
  }
  
  for (i in unique(clusteros)) {
    # Get points belonging to the current cluster
    cluster_points <- coordinates[clusteros == i, ]
    cov_matrix <- cov(cluster_points[, c("DCA1", "DCA2")])
    angle <- compute_angle(cov_matrix)
    
    # Compute the mean (center) of the current cluster
    center_x <- mean(cluster_points$DCA1)
    center_y <- mean(cluster_points$DCA2)
    
    # Draw an ellipse around the cluster points with the desired color
    color_with_alpha <- rgb(t(col2rgb(colores[i])) / 255, alpha = 0.8)
    draw.ellipse(x = center_x, y = center_y, a = sd(cluster_points$DCA1)*2, b = sd(cluster_points$DCA2)*2,
                 border = colores[i],col=color_with_alpha, lwd = 1, angle=angle)  # Manually apply the custom color
    
    if (with_labels==TRUE){
    # Add highlighted text label
    label <- group_labels[i]
    
    # Calculate label position and dimensions
    text_x <- center_x + 0.10
    text_y <- center_y + 0.10
    label_width <- strwidth(label) * .5
    label_height <- strheight(label) * 1
    
    rect(text_x - label_width/2, text_y - label_height/2, text_x + label_width/2, text_y + label_height/2, 
         col = "white", lwd = 0.5)
    
    # Add the text label in the center of the rectangle
    text(text_x, text_y, label, col = colores[i], cex = 0.8, font = 2)
    }
  }
  
  return(list(cc=cc, 
              cc2=cc2,coordinates=coordinates,
              clusteros=clusteros, 
              cluster_points=cluster_points
              ))
}