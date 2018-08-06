load_credit_risk_data = function() {
  
  if (length(list.files("data")) == 0) {
    # download data using Kaggle API
    system("kaggle competitions download -c home-credit-default-risk -p data/")
    
    # unzip all files
    zip_files = list.files("data", full.names = TRUE)
    purrr::walk(zip_files, ~ unzip(.x, exdir = "data/"))
    
    # delete all zip files
    file.remove(zip_files)
  }
  
  if (sparklyr::connection_is_open(sc)) {
    message("Copying Credit Risk data to Spark Memory")
    
    bureau_tbl = sparklyr::spark_read_csv(sc, name = "bureau", path = "data/bureau.csv")
    bureau_balance_tbl = sparklyr::spark_read_csv(sc, name = "bureau_balance", path = "data/bureau_balance.csv")
    cc_balance_tbl = sparklyr::spark_read_csv(sc, name = "cc_balance", path = "data/cc_balance.csv")
    payments_tbl = sparklyr::spark_read_csv(sc, name = "payments", path = "data/payments.csv")
    pc_balance_tbl = sparklyr::spark_read_csv(sc, name = "pc_balance", path = "data/pc_balance.csv")
    prev_application_tbl = sparklyr::spark_read_csv(sc, name = "prev_application", path = "data/prev_application.csv")
    training_tbl = sparklyr::spark_read_csv(sc, name = "training", path = "data/training.csv")
    testing_tbl = sparklyr::spark_read_csv(sc, name = "testing", path = "data/testing.csv")
    
  } else {
    bureau = data.table::fread("data/bureau.csv")
    bureau_balance = data.table::fread("data/bureau_balance.csv")
    cc_balance = data.table::fread("data/credit_card_balance.csv")
    payments = data.table::fread("data/installments_payments.csv")
    pc_balance = data.table::fread("data/POS_CASH_balance.csv")
    prev_application = data.table::fread("data/previous_application.csv")
    training =  data.table::fread("data/application_train.csv")
    testing =  data.table::fread("data/application_test.csv")
    gc()
    
    list(
      bureau = bureau,
      bureau_balance = bureau_balance,
      cc_balance = cc_balance,
      payments = payments,
      pc_balance = pc_balance,
      prev_application = prev_application,
      training = training,
      testing = testing
    )
  }
}