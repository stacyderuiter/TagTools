##############################################################################
#  All code below this point is to make plots of the best.model predictions.
##############################################################################

#create plots of predictions for each covariate
#note: this makes ones plot with many panels;
#use par(mfrow=c(1,1)) to make one figure per variable.
# a colour brewer palette Set2 + grey:
colrs <-  c("#999999", "#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3" ,"#A6D854" ,"#FFD92F")
par(mfrow=c(2,2), mar=c(3,4,1,1), oma=c(0,3,0,0), las=1)
#list of variable names for titles in plots
vnames <- c("Deep Dive?" , "Group Size", "No. Groups", 
            "Spyhop", "Logging", "Spacing", "Synchrony",
            "Max Depth", "Calf Presence")
vnames <- c("Deep Dive?" , "Group Size", "Milling", 
            "Distance", "Spyhop", "Max Depth (bin)", "Breaching",
            "Spacing", "Synchrony", "Max Depth (bout)", "Line")
#in par:
# mfrow is number of rows,cols in multi-panel plot
# mar is margins around each individual panel
# oma is margins around entire plot area
# las is label direction: 0=parallel to axis, 1=horizontal, 2=perpendicular to axis, 3=always vertical
require(ggplot2)
theme_set(theme_bw(base_size = 22))

for (v in 1:n.coefs){
  
  #get the name of the variable
  coef <- best.coefs[v]
  #get the right dataset for this variable
  dat <- preddata[[v]]
  ci <- boot.CI95[[v]]
  #   dev.off()
  #   jpeg(filename=paste(coef, "_preds.jpg", sep=""),
  #        width=480, height=480, pointsize=22, res=300)
  if (is.factor(pwcalls[,coef])){#factor data
    if (exclude.coef==coef){
      ggplot(data=dat, aes_string(x=exclude.coef, y="resp", fill=exclude.coef)) + 
        geom_bar(position=position_dodge(), stat="identity") +
        geom_errorbar(aes(ymin=ci$lower, ymax=ci$upper),
                      width=.4,                    # Width of the error bars
                      position=position_dodge(.9)) +
        theme(legend.position = "bottom", legend.justification = 'centre') +
        #scale_fill_brewer(palette="Set2") + 
        xlab("") + ylab("") + ggtitle(vnames[v]) +
        scale_fill_brewer(palette="Set2", name="Deep?",
                          breaks=c("shallow", "deep"),
                          labels=c("No", "Yes"))
      #ggsave(filename = paste(coef, "_preds.jpg", sep=""),
      #       width = 4, height = 4,  dpi = 300)
    }else{
      ggplot(data=dat, aes_string(x=best.coefs[v], y="resp", fill=exclude.coef)) + 
        geom_bar(position=position_dodge(), stat="identity") +
        geom_errorbar(aes(ymin=ci$lower, ymax=ci$upper),
                      width=.4,                    # Width of the error bars
                      position=position_dodge(.9))  +
        theme(legend.position = "bottom", legend.justification = 'centre') +
        #scale_fill_brewer(palette="Set2") + 
        xlab("") + ylab("") + ggtitle(vnames[v]) +
        scale_fill_brewer(palette="Set2", name="Deep?",
                          breaks=c("shallow", "deep"),
                          labels=c("No", "Yes"))
      ggsave(filename = paste(coef, "_preds.jpg", sep=""),
             width = 4, height = 4,  dpi = 300)
    }
  }else{ #continuous data
    ggplot(data=dat, aes_string(x=best.coefs[v], y="resp", group=exclude.coef)) +
      geom_line(aes_string(colour = exclude.coef), size=1.5)+
      geom_ribbon(data=dat,aes_string(x=best.coefs[v], 
                                      ymin="ci$lower",ymax="ci$upper"),alpha=0.2) +
      theme(legend.position = "bottom", legend.justification = 'centre') +
      #scale_fill_brewer(palette="Set2") + 
      xlab("") + ylab("") + ggtitle(vnames[v]) + 
      scale_color_brewer(palette="Set2", name="Deep?",
                         breaks=c("shallow", "deep"),
                         labels=c("No", "Yes"))
    ggsave(filename = paste(coef, "_preds.jpg", sep=""),
           width = 4, height = 4,  dpi = 300)
  }
}
