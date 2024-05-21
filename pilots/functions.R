# load libraries
library(ggplot2)
library(extrafont)

# helper function to convert font size in pt to mm
devtools::source_url("https://github.com/zmorrissey/commonR/blob/master/R/pt_to_mm.R?raw=TRUE")

# rain cloud plot

# define variables for plotting
ambition_coral <- "#E94B58"
ambition_charcole <- "#2C3C3B"

# ambition colours
navy    = "#474C68"
cyan    = "#14B4E9"
coral   = "#E94B58"
teal    = "#00987C"
purple  = "#6D2160"
orange  = "#EC642D"
yellow  = "#FFCC00"
blue    = "#006FB7"
red     = "#BF1C1D"
white   = "#FFFFFF"
black   = "#000000"

# function to create colour tints
# source: https://rdrr.io/cran/MESS/src/R/colorfunctions.R
col.tint <- function(col, tint=.4) {
  
  if(missing(col))
    stop("a vector of colours is missing")
  
  if (tint<0 | tint>1)
    stop("shade must be between 0 and 1")
  
  mat <- t(col2rgb(col, alpha=TRUE)  +  c(rep(1-tint, 3), 0)*(255-col2rgb(col, alpha=TRUE)))
  rgb(mat, alpha=mat[,4], maxColorValue=255)
}

# generate tints #

# navy
navy40 <- col.tint(navy, tint = .4)
navy30 <- col.tint(navy, tint = .3)
navy20 <- col.tint(navy, tint = .2)
navy10 <- col.tint(navy, tint = .1)
palette_navy <- c(navy, navy40, navy30, navy20, navy10)

# black
black40 <- col.tint(black, tint = .4)
black30 <- col.tint(black, tint = .3)
black20 <- col.tint(black, tint = .2)
black10 <- col.tint(black, tint = .1)
palette_black <- c(black, black40, black30, black20, black10)

# define font sizesfor normal text and headings in pt
font_size = 12
head_size = font_size + 2

# define theme for plot
ambition_theme <- theme_bw(base_family = "Segoe UI") + 
  theme(
    text = element_text(family = "Segoe UI", size = font_size),
    title = element_text(face = "bold", size = font_size),
    plot.title = element_text(size = head_size, face = "bold"),
    plot.subtitle = element_text(size = font_size, face = "plain"),
    axis.title = element_text(size = font_size, face = "bold"),
    axis.text = element_text(size = font_size),
    legend.title = element_text(size = font_size, face = "bold"),
    legend.text = element_text(size = font_size),
    strip.text = element_text(size = font_size),
    plot.caption = element_text(size = font_size, face = "plain"),
    strip.background = element_rect(fill = black20),
    legend.position = "bottom"
  )


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
