# rain cloud plot

# define variables for plotting
ambition_coral <- "#E94B58"
ambition_charcole <- "#2C3C3B"

# define theme for plot
theme <- theme(
  plot.title = element_text(size=14, face="bold", hjust = 0.5),
  axis.title.y = element_text(size=10, face="bold"),
  legend.title = element_blank(),
  legend.position = "bottom"
) + theme_bw()

plot_raincloud <- function(data = df, xvar = x, yvar = y,
                           xlower = NULL,
                           xupper = NULL,
                           ylower = NULL,
                           yupper = NULL,
                           ybreaks = NULL,
                           yintercept = NULL,
                           title = "",
                           ylab = "",
                           xlab = ""){
  
  # create rain cloud plot, adapted from: https://z3tt.github.io/Rainclouds/
  plot <- 
    # define variables to plot based on input
    ggplot(data, aes(x = get(xvar), y = get(yvar))) +
    # create rain cloud
    ggdist::stat_halfeye(adjust = 1.5, width = .3, .width = 0, justification = -.3, point_colour = NA, fill = ambition_charcole) + 
    # create boxplot
    geom_boxplot(width = .1, outlier.shape = NA) + # do not show outlier in boxplot
    # add stat mean + se to boxplt
    stat_summary(fun="mean", geom = "point", col = ambition_coral) + 
    stat_summary(fun.data = mean_se, geom = "errorbar", width = .05, col = ambition_coral) +    
    # add rain
    ggdist::stat_dots(side = "left", dotsize = 0.3, justification = 1.1, binwidth = .1, col = ambition_charcole, fill = ambition_charcole) + 

    # determine titles
    ggtitle(paste0(title)) + xlab(paste0(xlab)) + ylab(paste0(ylab)) +
    theme 
  #+ theme(axis.title.x = element_blank(), axis.text.x = element_blank()) 
  
  # determine coord system + scales
  if (!is.null(ylower) | !is.null(yupper)) {
    plot <- plot + coord_cartesian(ylim = c(ylower, yupper))
    if (!is.null(ybreaks)) {
      plot <- plot + scale_y_continuous(breaks=seq(ylower, yupper, ybreaks))
    }
  }
  
  if (!is.null(xlower) | !is.null(xupper)) {
    plot <- plot + coord_cartesian(xlim = c(xlower, xupper))
  }
  
  # add horizontal line
  if (!is.null(yintercept)) {
    plot <- plot + geom_hline(yintercept = yintercept, linetype="dashed")
  }

  
  plot
}