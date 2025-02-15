alleghenyTheme <- theme(text=element_text(size=12), panel.background = element_rect(fill = "white"), axis.text.x = element_text(angle = 90, hjust = 1, size=10), axis.text.y = element_text(size=10), panel.grid.major.x = element_blank(), panel.grid.major.y = element_line(color="gray90"))
acPalette <- c("#cc0033", "#ffcc00", "#423f40", "#aaaaaa", "#5FD855", "#5658A9", 
                        "#E04900", "#009661", "#4EC500", "#000000", "#c58000")
acChart <- function(p) {
    p <- p + alleghenyTheme +   scale_colour_manual(values=acPalette) + scale_fill_manual(values=acPalette)
    return(p)
}

acTable <- function(dt, caption) {
  if(missing(caption)) {
    caption <- "No caption provided"
  }
  dt %>%
    kable(caption=caption) %>%
    kable_styling(bootstrap_options = c("striped", "hover"))
}