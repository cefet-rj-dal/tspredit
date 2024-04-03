

# TSPredIT
# version 1.0.767

source("https://raw.githubusercontent.com/cefet-rj-dal/daltoolbox/main/jupyter.R")

#loading DAL Toolbox
load_library("daltoolbox")
load_library("tspredit")

#load required library
library(ggplot2)


i <- seq(0, 25, 0.25)
x <- cos(i)

plot_ts(x=i, y=x) + theme(text = element_text(size=16))

sw_size <- 10
ts <- ts_data(x, sw_size)
ts_head(ts, 3)



test_size <- 1
samp <- ts_sample(ts, test_size)
ts_head(samp$train, 3)
ts_head(samp$test)



tune <- ts_maintune(input_size=c(3:5), base_model = ts_elm(), preprocess = list(ts_norm_gminmax()))
ranges <- list(nhid = 1:5, actfun=c('sig', 'radbas', 'tribas', 'relu', 'purelin'))

io_train <- ts_projection(samp$train)

model <- fit(tune, x=io_train$input, y=io_train$output, ranges)

adjust <- predict(model, io_train$input)
ev_adjust <- evaluate(model, io_train$output, adjust)
print(head(ev_adjust$metrics))

steps_ahead <- 1
io_test <- ts_projection(samp$test)
prediction <- predict(model, x=io_test$input, steps_ahead=steps_ahead)
prediction <- as.vector(prediction)

output <- as.vector(io_test$output)
if (steps_ahead > 1)
  output <- output[1:steps_ahead]

print(sprintf("%.2f, %.2f", output, prediction))

yvalues <- c(io_train$output, io_test$output)
plot_ts_pred(y=yvalues, yadj=adjust, ypre=prediction) + theme(text = element_text(size=16))
