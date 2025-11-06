#install.packages("tspredit")

# Loading the package
library(tspredit) 

# Load data and split axis/value
data(tsd)
x <- tsd$x
y <- tsd$y

library(ggplot2)
# Visualize the original series
plot_ts(x = x, y = y) + theme(text = element_text(size=16))

# ts_data without window (only t0)
data <- ts_data(y)
ts_head(data)
plot_ts(y=data[,1]) + theme(text = element_text(size=16))

# ts_data with window size 10 (t9..t0)
data10 <- ts_data(y, 10)
ts_head(data10)

# Select a row
r1 <- data10[12,]
r1

# Select a range of rows
r2 <- data10[12:13,]
r2

# Select a column
c1 <- data10[,1]
ts_head(c1)

# Select a range of columns
c2 <- data10[,1:2]
ts_head(c2)

# Select a range of rows and columns
rc1 <- data10[12:13,1:2]
rc1

# Select one row and a range of columns
rc2 <- data10[12,1:2]
rc2

# Select a range of rows and one column
rc3 <- data10[12:13,1]
rc3

# Select a single observation
rc4 <- data10[12,1]
rc4
