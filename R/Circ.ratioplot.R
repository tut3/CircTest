## Give a circRNA count data, plot a certain row or plot all rows
#' @title Circ.ratioplot
#' 
#' @description
#' Plot the ratio of circRNAs to the total transcripts (circRNA plus liner RNA).
#' @param Circ CircRNACount file. A file of circRNA read count table. First three columns are circRNA coordinates, and followed by columns for circRNA read counts, each sample per column. 
#' @param Linear LinearCount file. A file of circRNA host gene expression count table. Same configuration as CircRNACount file.
#' @param plotrow The rownumber or rowname in the CircRNACount table corresponding the specific gene which you want to plot.
#' @param size the text size
#' @param ncol if groupindicator2 is provided, specify the panel layout.
#' @param CircCoordinates BED format circRNA coordinates file. 
#' @param groupindicator1 A vector of group indicators. For example, ages. 
#' @param groupindicator2 An other vector of group indicators. For example, tissues. This indicator will be used to segement plots out.
#' @param x x axis lable
#' @param y y axis lable
#' @param lab_legend legend title
#' @examples data(Coordinates)
#' data(Circ)
#' data(Linear)
#' @examples data(Coordinates)
#' data(Circ)
#' data(Linear)
#' Circ.ratioplot(Circ,Linear,Coordinates,plotrow=10,groupindicator1=c(rep('1days',6),rep('4days',6),rep('20days',6)),groupindicator2=rep(c(rep('Female',4),rep('Male',2)),3),lab_legend='Ages')
#' 
#' @export Circ.ratioplot
#' 
Circ.ratioplot <- function(Circ,Linear,CircCoordinates,plotrow='1',size=18,ncol=2,groupindicator1=NULL,groupindicator2=NULL,x='Conditions',y='circRNA/(circRNA+Linear)',lab_legend='groupindicator1'){
  require(ggplot2)
  #require(Rmisc)
  
  if( !is.null(groupindicator1) & length(groupindicator1) != ncol(Circ)-3 ){
    stop("If provided, the length of groupindicator1 should be equal to the number of samples.")
  }
  if( !is.null(groupindicator2) & length(groupindicator2) != ncol(Circ)-3 ){
    stop("If provided, the length of groupindicator2 should be equal to the number of samples.")
  }
  if(is.null(groupindicator1)){
    stop("At least one grouping should be provided through groupindicator1.")
  }
  if(!is.null(groupindicator2)){
    twolevel <- TRUE
  }else{
    twolevel <- FALSE
  }
  
  Circ <- data.frame(lapply(Circ, as.character), stringsAsFactors=FALSE)
  Linear <- data.frame(lapply(Linear, as.character), stringsAsFactors=FALSE)
  CircCoordinates <- data.frame(lapply(CircCoordinates, as.character), stringsAsFactors=FALSE)
  
  # Get gene name, if no annotation, output NA
  genename <- as.character(CircCoordinates[plotrow,4])
  if (genename == '.'){
    genename = NA
  }
  
  if(twolevel){
    plotdat <- summarySE( data.frame(Ratio=as.numeric(Circ[plotrow,-c(1:3)])/(as.numeric(Linear[plotrow,-c(1:3)])+as.numeric(Circ[plotrow,-c(1:3)])),
                                    groupindicator1,
                                    groupindicator2),
                         measurevar='Ratio',groupvars=c('groupindicator1','groupindicator2') )
  }else{
    plotdat <- summarySE( data.frame(Ratio=as.numeric(Circ[plotrow,-c(1:3)])/(as.numeric(Linear[plotrow,-c(1:3)])+as.numeric(Circ[plotrow,-c(1:3)])),
                                     groupindicator1),
                                     measurevar='Ratio',groupvars=c('groupindicator1') )
  }
  #View(plotdat)
  Q <- ggplot(plotdat, aes(x=groupindicator1, y=Ratio)) +
       theme(text=element_text(size=size))+
       theme_bw()+
       labs(list(title=paste(toString(Circ[plotrow,c(1:3)]),genename,sep=" "),x=x,y=y))+
       #ggtitle(toString(Circ[plotrow,c(1:3)]))+
       geom_errorbar(aes(ymin=Ratio-se, ymax=Ratio+se), width=.1 )+   # Width of the error bars
       geom_bar(stat="identity",aes(fill=groupindicator1))+
       scale_fill_discrete(name=lab_legend)
  if(twolevel){
    Q <- Q + facet_wrap( ~ groupindicator2,ncol=ncol )
  }

  print(Q)
}
