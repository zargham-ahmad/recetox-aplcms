patrick::with_parameters_test_that(
  "test compute_clusters",
  {
    testdata <- file.path("..", "testdata")

    extracted <- lapply(files, function(x) {
      xx <- file.path(testdata, input, paste0(x, ".parquet"))
      tibble::as_tibble(arrow::read_parquet(xx))
    })

    actual <- compute_clusters(
      feature_tables = extracted,
      mz_tol_relative = NA,
      rt_tol_relative = NA,
      mz_max_diff = mz_max_diff,
      mz_tol_absolute = mz_tol_absolute,
      do.plot = FALSE,
      sample_names = files
    )

    expected <- lapply(files, function(x) {
      filepath <- file.path(testdata, "clusters", paste0(x, "_", input, "_clusters.parquet"))
      tibble::as_tibble(arrow::read_parquet(filepath))
    })


    for(i in seq_along(files)) {
      expect_equal(actual$feature_tables[[i]], expected[[i]])
    }

    expect_equal(actual$mz_tol_relative, expected_mz_tol_relative)
    expect_equal(actual$rt_tol_relative, expected_rt_tol_relative)

  },
  patrick::cases(
    RCX_shortened_extracted = list(
      files = c("RCX_06_shortened", "RCX_07_shortened", "RCX_08_shortened"),
      input = "extracted",
      mz_max_diff = 10 * 1e-05,
      mz_tol_absolute = 0.01,
      expected_mz_tol_relative = 6.85676325338646e-06,
      expected_rt_tol_relative = 3.61858118506494
    ),
    RCX_shortened_adjusted = list(
      files = c("RCX_06_shortened", "RCX_07_shortened", "RCX_08_shortened"),
      input = "adjusted",
      mz_max_diff = 10 * 1e-05,
      mz_tol_absolute = 0.01,
      expected_mz_tol_relative = 6.85676325338646e-06,
      expected_rt_tol_relative = 2.17918873407775
    )
  )
)

test_that("compute clusters simple", {
  testdata <- file.path("..", "testdata")
  files <- c("8_qc_no_dil_milliq", "21_qc_no_dil_milliq", "29_qc_no_dil_milliq")

  extracted <- lapply(files, function(x) {
    xx <- file.path(testdata, "extracted", paste0(x, ".mzml.parquet"))
    tibble::as_tibble(arrow::read_parquet(xx))
  })
  actual <- compute_clusters_simple(
    feature_tables = extracted,
    sample_names = files,
    mz_tol_ppm = 10,
    rt_tol = 2
  )

  actual <- actual[order(sapply(actual, function(x) x$sample_id[1]))]

  expected <- lapply(files, function(x) {
    file <- file.path(testdata, "clusters", paste0(x, ".parquet"))
    tibble::as_tibble(arrow::read_parquet(file))
  })

  expected <- expected[order(sapply(expected, function(x) x$sample_id[1]))]

  expect_equal(as.list(actual), expected, tolerance = 0.02)
})