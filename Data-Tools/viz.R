# clean start
rm(list = ls())
cat("\014")
setwd('/Users/hernandezj45/Desktop/Repositories/AutoQTL-Adventures/Data-Tools/')

# libraries we are using
library(ggplot2)
library(cowplot)
library(dplyr)
library(PupillometryR)

# experiment variables

NAMES = c('NSGA2','Lexicase','max_err','mean_ae','medi_ae')
SHAPE <- c(5,3,1,2,6,0,4,20,1)
cb_palette <- c('#332288','#88CCEE','#EE7733','#EE3377','#117733','#882255','#44AA99','#CCBB44', '#000000')
TSIZE <- 22

p_theme <- theme(
  plot.title = element_text( face = "bold", size = 20, hjust=0.5),
  panel.border = element_blank(),
  panel.grid.minor = element_blank(),
  legend.title=element_text(size=20),
  legend.text=element_text(size=20),
  axis.title = element_text(size=20),
  axis.text = element_text(size=19),
  legend.position="bottom",
  panel.background = element_rect(fill = "#f1f2f5",
                                  colour = "white",
                                  size = 0.5, linetype = "solid")
)

# get the data
data_dir <- './'
scores <- read.csv(paste(data_dir, 'scores.csv', sep = "", collapse = NULL), header = TRUE, stringsAsFactors = FALSE)
scores$Scheme <- factor(scores$Scheme, levels = NAMES)

# plot data 

fig = ggplot(scores, aes(x = Scheme, y = Score, color = Scheme, fill = Scheme, shape = Scheme)) +
  geom_flat_violin(position = position_nudge(x = 0.1, y = 0), scale = 'width', alpha = 0.2, width = 1.5) +
  geom_boxplot(color = 'black', width = .08, outlier.shape = NA, alpha = 0.0, size = 0.8, position = position_nudge(x = .15, y = 0)) +
  geom_point(position = position_jitter(width = .015, height = .0001), size = 2.0, alpha = 1.0) +
  scale_y_continuous(
    name=bquote('Holdout'~r^2),
    limits=c(.2, .24),
    breaks=c(0.2,0.21,0.22,0.23,0.24),

  ) +
  scale_x_discrete(
    name="Selection Scheme"
  )+
  scale_shape_manual(values=SHAPE)+
  scale_colour_manual(values = cb_palette, ) +
  scale_fill_manual(values = cb_palette) +
  ggtitle(bquote('Holdout'~r^2~'with Final Model'))+
  p_theme

# summary stats

scores %>%
  group_by(Scheme) %>%
  dplyr::summarise(
    count = n(),
    na_cnt = sum(is.na(Score)),
    min = min(Score, na.rm = TRUE),
    median = median(Score, na.rm = TRUE),
    mean = mean(Score, na.rm = TRUE),
    max = max(Score, na.rm = TRUE),
    IQR = IQR(Score, na.rm = TRUE)
  )

# kruskal-wallis test
kruskal.test(Score ~ Scheme, data = scores)

# did lexicase find better scores than nsga2
max_nsga = max(filter(scores, Scheme == 'NSGA2')$Score)
sum(filter(scores, Scheme == 'Lexicase')$Score >  max_nsga)


save_plot(
  paste(filename ="sample-data-comparison.pdf"),
  fig,
  base_width=10,
  base_height=5
)
