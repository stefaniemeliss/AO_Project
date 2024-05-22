# load theme for all plots
devtools::source_url("https://github.com/stefaniemeliss/ambition_theme/blob/main/ambition_theme.R?raw=TRUE")


# rain cloud plot

# define variables for plotting
ambition_coral <- "#E94B58"
ambition_charcole <- "#2C3C3B"

dominant_col <- coral
nondominant_col <- navy

plot_raincloud <- function(data = df, xvar = x, yvar = y,
                           xlower = NULL,
                           xupper = NULL,
                           ylower = NULL,
                           yupper = NULL,
                           ybreaks = NULL,
                           yintercept = NULL,
                           title = "",
                           ylab = "",
                           xlab = "",
                           note = ""){
  
  # create rain cloud plot, adapted from: https://z3tt.github.io/Rainclouds/
  plot <- 
    # define variables to plot based on input
    ggplot(data, aes(x = get(xvar), y = get(yvar))) +
    # create rain cloud
    ggdist::stat_halfeye(adjust = 1.5, width = .3, .width = 0, justification = -.3, point_colour = NA, fill = nondominant_col) + 
    # create boxplot
    geom_boxplot(width = .1, outlier.shape = NA) + # do not show outlier in boxplot
    # add stat mean + se to boxplt
    stat_summary(fun="mean", geom = "point", col = dominant_col) + 
    stat_summary(fun.data = mean_se, geom = "errorbar", width = .05, col = dominant_col) +    
    # add rain
    ggdist::stat_dots(side = "left", dotsize = 0.3, justification = 1.1, binwidth = .1, col = nondominant_col, fill = nondominant_col) + 
    
    # determine titles
    ggtitle(paste0(title)) + xlab(paste0(xlab)) + ylab(paste0(ylab)) +
    labs(caption = note) +
    ambition_theme +
    theme(plot.caption = element_text(hjust=0))
  #+ theme(axis.title.x = element_blank(), axis.text.x = element_blank()) 
  
  # determine coord system + scales
  if (!is.null(ylower) | !is.null(yupper) | !is.null(xlower) | !is.null(xupper)) {
    
    if (!is.null(ylower) & is.null(xlower)) { # only modify y axis
      plot <- plot + coord_cartesian(ylim = c(ylower, yupper))
      
    } else if (!is.null(xlower) & is.null(ylower)) { # only modify x axis
      plot <- plot + coord_cartesian(xlim = c(xlower, xupper))
      
    } else if (!is.null(xlower) & !is.null(ylower)) { # modify both axes
      plot <- plot + coord_cartesian(xlim = c(xlower, xupper), ylim = c(ylower, yupper))
    }
  }
  
  if (!is.null(ybreaks)) {
    plot <- plot + scale_y_continuous(breaks=seq(ylower, yupper, ybreaks))
  }
  
  # add horizontal line
  if (!is.null(yintercept)) {
    plot <- plot + geom_hline(yintercept = yintercept, linetype="dashed")
  }
  
  
  print(plot)
}


table_desc <- function(data = df, group_var = "group", dep_var = "variable"){
  
  out <- rbind(
    psych::describe(data[, var]), # get descriptives whole sample
    do.call("rbind",psych::describeBy(data[, var], group = data[, grp])) # get descriptives per group
  )
  # edit output
  out$vars <- NULL
  rownames(out)[1] <- "all"
  # print output
  print(knitr::kable(out, caption = "Descriptives for whole sample and within each group"))
  cat('\n\n<!-- -->\n\n')
  
}
