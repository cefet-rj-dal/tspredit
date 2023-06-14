iris <- datasets::iris
head(iris)

#extracting the levels for the dataset
slevels <- levels(iris$Species)
slevels

# preparing dataset for random sampling
set.seed(1)
sr <- sample_random()
sr <- train_test(sr, iris)
iris_train <- sr$train
iris_test <- sr$test

tbl <- rbind(table(iris[,"Species"]),
             table(iris_train[,"Species"]),
             table(iris_test[,"Species"]))
rownames(tbl) <- c("dataset", "training", "test")
head(tbl)

#tune <- cla_tune(cla_knn("Species", slevels, k=3))
#ranges <- list(k=1:10)
#tune <- cla_tune(cla_mlp("Species", slevels, size=5, decay=0.54))
#ranges <- list(size=1:10, decay=seq(0, 1, 0.1))
#tune <- cla_tune(cla_rf("Species", slevels, mtry=3, ntree=5))
#ranges <- list(mtry=1:3, ntree=1:10)
tune <- cla_tune(cla_svm("Species", slevels))
ranges <- list(epsilon=seq(0,1,0.2), cost=seq(20,100,20), kernel = c("linear", "radial", "polynomial", "sigmoid"))

model <- fit(tune, iris_train, ranges)

train_prediction <- predict(model, iris_train)

iris_train_predictand <- adjustClassLabels(iris_train[,"Species"])
train_eval <- evaluate(model, iris_train_predictand, train_prediction)
print(train_eval$metrics)

# Test
test_prediction <- predict(model, iris_test)

iris_test_predictand <- adjustClassLabels(iris_test[,"Species"])
test_eval <- evaluate(model, iris_test_predictand, test_prediction)
print(test_eval$metrics)
