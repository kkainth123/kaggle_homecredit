# Load Library & Functions ------------------------------------------------

library(sparklyr)
library(dplyr)

# load user-defined functions
fn_files = list.files("functions/", full.names = TRUE)
purrr::walk(fn_files, source)


# Initiate Spark Cluster --------------------------------------------------

# set up spark environment
spark_home_set()
Sys.setenv(HADOOP_CONF_DIR = '/etc/hadoop/conf')
Sys.setenv(YARN_CONF_DIR = '/etc/hadoop/conf')

# create connection to cluster
sc = spark_connect(master = "yarn-client")


# Load Data ---------------------------------------------------------------


flights_tbl <- copy_to(sc, nycflights13::flights, "flights")


data = load_credit_risk_data()




