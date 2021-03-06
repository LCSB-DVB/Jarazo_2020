create_plots = function(Table_all){ 
	###################################################
	## Violin with line through mnedian of timepoints #
	###################################################
	Table_all %>% 
	  dplyr::filter(Treatment=="Chloro") ->Table_all

	Table_all$Concentration[Table_all$Concentration==5]<-"50"
	Table_all$Concentration[Table_all$Concentration==0]<-"Un"
	Table_all$Concentration[Table_all$Concentration==1]<-"500"
	Table_all$Concentration[Table_all$Concentration==2]<-"1"
	Table_all$Concentration[Table_all$Concentration==3]<-"5"
	Table_all$Concentration[Table_all$Concentration==4]<-"10"


	Features = c("GFAPVolByTHVol","Tuj1VolByNucVol","THVolByTuj1Vol","THVolByNucVol","GFAPVolByNucVol")

	levels_x_axis = c("Un","500","1","5","10","50")
	Limit_y_axis = data.table(Features = Features, X1= c(0,0,0,0,0), X2= c(0.5,10,1,3,0.4))
	graph = list()
	for(feat in Features){
	  lmmin=Limit_y_axis[Features==feat,X1]
	  lmmax=Limit_y_axis[Features==feat,X2]
	  graph[[feat]]=ggplot(Table_all,aes_string(y=feat, x="Concentration", fill="Category")) + 
		geom_violin(aes(group=interaction(Category,Concentration)),alpha=0.4,position=position_dodge(width = 0.6),lwd=0.1) + 
		geom_boxplot(aes(group=interaction(Category,Concentration)), fill="white",position=position_dodge(width = 0.6),outlier.size = 0.1,lwd=0.1,width=0.3) +
		scale_fill_manual(values=c("cornflowerblue","firebrick1")) +
		stat_summary(fun.y=median, geom="line", aes(color=Category, group=factor(Category)), size=0.5, linetype="dashed")+
		scale_color_manual(values=c("cornflowerblue","firebrick1")) +
		scale_y_continuous (limits = c(lmmin,lmmax),breaks = breaks_extended(n = 4),expand = c(0,0)) +
		scale_x_discrete(limits = levels_x_axis) +
		theme_classic() +
		theme(plot.title= element_text(hjust=0.5, size=8),axis.text.x= element_text(size=5),axis.text.y= element_text(size=5),axis.title.x=element_blank(),axis.title.y=element_blank(),legend.position = "none") +
		ggtitle(feat)
	}

	#Get the legend as a separate plot
	legend_plot = ggplot(Table_all,aes(y=NucVol, x=Concentration, fill=Category)) + 
	  geom_violin(aes(group=interaction(Category,Concentration)),alpha=0.4,position=position_dodge(width = 6),lwd=0.1) + 
	  geom_boxplot(aes(group=interaction(Category,Concentration)), fill="white",position=position_dodge(width = 6),outlier.size = 0.3,lwd=0.3,width=0.8) +
	  scale_fill_manual(values=c("cornflowerblue","firebrick1")) +
	  stat_summary(fun.y=median, geom="line", aes(color=Category, group=factor(Category)), size=0.5, linetype="dashed")+
	  scale_color_manual(values=c("cornflowerblue","firebrick1")) +
	  theme(legend.background=element_rect(fill = "transparent", colour = NA)) 

	my_legend = get_legend(legend_plot)
  return(list(graphs=graph, legend=my_legend))
}