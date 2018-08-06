# Load Library & Functions ------------------------------------------------

library(sparklyr)
library(dplyr)

# load user-defined functions
fn_files = list.files("functions/", full.names = TRUE)
purrr::walk(fn_files, source)


# Data Loading ---------------------------------------------------------------

data_list = load_credit_risk_data()


# Data Preparation -----------------------------------------------------------

# preprocessing features and create new features
full_data = data_list$training %>%
  dplyr::bind_rows(data_list$testing)

# impute missing values
dummy_vars = caret::dummyVars(~ ., data = full_data[, -TARGET])
dummy_full_data = stats::predict(dummy_vars, full_data[, -TARGET])
pre_process = caret::preProcess(
  dummy_full_data,
  method = "knnImpute",
  pcaComp = 10,
  na.remove = TRUE,
  k = 5,
  knnSummary = mean,
  outcome = NULL,
  fudge = .2,
  numUnique = 3,
  verbose = TRUE)
imputed_data = stats::predict(pre_process, dummy_full_data)

# replace all columns in original data

# convert all character features to categorical
full_data = full_data %>%
  dplyr::mutate_if(is.character, as.factor)




# Data Splitting -------------------------------------------------------------

# create 80/20 split
train_index = caret::createDataPartition(
  full_data$SK_ID_CURR,
  times = 1,
  p = 0.8,
  list = FALSE)

training = full_data[ train_index,]
testing  = full_data[ -train_index,]


# Configure Parallel Processing -------------------------------------------

n_cores = parallel::detectCores() - 1 # leave 1 core for OS
cluster = doParallel::makeCluster(n_cores, type = "FORK")
doParallel::registerDoParallel(cluster) # so caret knows to train in parallel



# Configure Train Control Object ------------------------------------------

# set parameters that control how model is created.
train_control = caret::trainControl(
  method = "repeatedcv",
  number = 10, # perform 10-fold cross validation
  repeats = 3, # repeat it 3 times
  search = "grid" # use grid search for optimal model hyperparamter values
  )

# grid search of hyperparameters for xgboost
tune_grid = expand.grid(
  eta = c(0.05, 0.075, 0.1),
  nrounds = c(50, 75, 100),
  max_depth = 6:8,
  min_child_weight = c(2.0, 2.25, 2.5),
  colsample_bytree = c(0.3, 0.4, 0.5),
  gamma = 0,
  subsample = 1)



# Data Training/Testing ---------------------------------------------------

start_time = Sys.time()

# creating training model using the train_control object
fit = caret::train(
  TARGET ~ .,
  data = training,
  method = "xgbTree",
  trControl = train_control,
  tuneGrid = tune_grid,
  na.action = na.pass)

Sys.time() - start_time

# shutdown cluster
parallel::stopCluster(cluster)
foreach::registerDoSEQ() # tells R to return back to single-treaded processing


# Model Evaluation --------------------------------------------------------

# model tuning











