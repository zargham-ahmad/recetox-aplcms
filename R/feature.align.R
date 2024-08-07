#' @import foreach

create_empty_tibble <- function(number_of_samples, metadata_colnames, intensity_colnames, rt_colnames) {
    features <- new("list")
    features$metadata <- tibble::as_tibble(matrix(nrow = 0, ncol = length(metadata_colnames)), .name_repair = ~metadata_colnames)
    features$intensity <- tibble::as_tibble(matrix(nrow = 0, ncol = length(intensity_colnames)), .name_repair = ~intensity_colnames)
    features$rt <- tibble::as_tibble(matrix(nrow = 0, ncol = length(rt_colnames)), .name_repair = ~rt_colnames)
    return(features)
}

#' @export
create_output <- function(sample_grouped, sample_names) {
    number_of_samples <- length(sample_names)
    intensity_row <- rep(0, number_of_samples)
    rt_row <- rep(0, number_of_samples)
    sample_presence <- rep(0, number_of_samples)

    for (i in seq_along(intensity_row)) {
        filtered <- filter(sample_grouped, sample_id == sample_names[i])
        if (nrow(filtered) != 0) {
            sample_presence[i] <- 1
            intensity_row[i] <- sum(filtered$area)
            rt_row[i] <- median(filtered$rt)
        }
    }

    mz <- sample_grouped$mz
    rt <- sample_grouped$rt
    metadata_row <- c(mean(mz), min(mz), max(mz), mean(rt), min(rt), max(rt), nrow(sample_grouped), sample_presence)

    return(list(metadata_row = metadata_row, intensity_row = intensity_row, rt_row = rt_row))
}

#' @export
validate_contents <- function(samples, min_occurrence) {
    # validate whether data is still from at least 'min_occurrence' number of samples
    if (!is.null(nrow(samples))) {
        if (length(unique(samples$sample_id)) >= min_occurrence) {
            return(TRUE)
        }
        return(FALSE)
    }
    return(FALSE)
}

#' @export
find_optima <- function(data, bandwidth) {
    # Kernel Density Estimation
    den <- density(data, bw = bandwidth)
    # select statistically significant points
    turns <- find.turn.point(den$y)
    return(list(peaks = den$x[turns$pks], valleys = den$x[turns$vlys]))
}

#' @export
filter_based_on_density <- function(sample, turns, index, i) {
    # select data within lower and upper bound from density estimation
    lower_bound <- max(turns$valleys[turns$valleys < turns$peaks[i]])
    upper_bound <- min(turns$valleys[turns$valleys > turns$peaks[i]])
    selected <- which(sample[, index] > lower_bound & sample[, index] <= upper_bound)
    return(sample[selected, ])
}

#' @export
select_rt <- function(sample, rt_tol_relative, min_occurrence, sample_names) {
    turns <- find_optima(sample$rt, bandwidth = rt_tol_relative / 1.414)
    for (i in seq_along(turns$peaks)) {
        sample_grouped <- filter_based_on_density(sample, turns, 2, i)
        if (validate_contents(sample_grouped, min_occurrence)) {
            return(create_output(sample_grouped, sample_names))
        }
    }
}

#' @export
select_mz <- function(sample, mz_tol_relative, rt_tol_relative, min_occurrence, sample_names) {
    turns <- find_optima(sample$mz, bandwidth = mz_tol_relative * median(sample$mz))
    for (i in seq_along(turns$peaks)) {
        sample_grouped <- filter_based_on_density(sample, turns, 1, i)
        if (validate_contents(sample_grouped, min_occurrence)) {
            return(select_rt(sample_grouped, rt_tol_relative, min_occurrence, sample_names))
        }
    }
}

#' @export
create_rows <- function(features,
                        i,
                        sel.labels,
                        mz_tol_relative,
                        rt_tol_relative,
                        min_occurrence,
                        sample_names) {
    if (i %% 100 == 0) {
        gc()
    } # call Garbage Collection for performance improvement?

    sample <- dplyr::filter(features, cluster == sel.labels[i])
    if (nrow(sample) > 1) {
        if (validate_contents(sample, min_occurrence)) {
            return(select_mz(sample, mz_tol_relative, rt_tol_relative, min_occurrence, sample_names))
        }
    } else if (min_occurrence == 1) {
        return(create_output(sample_grouped, sample_names))
    }
    return(NULL)
}

#' @export
comb <- function(x, ...) {
    mapply(tibble::as_tibble, (mapply(rbind, x, ..., SIMPLIFY = FALSE)))
}

#' Align peaks from spectra into a feature table.
#'
#' @param features_table A list object. Each component is a matrix which is the output from compute_clusters().
#' @param min_occurrence  A feature has to show up in at least this number of profiles to be included in the final result.
#' @param sample_names list List of sample names.
#' @param mz_tol_relative The m/z tolerance level for peak alignment. The default is NA, which allows the
#'  program to search for the tolerance level based on the data. This value is expressed as the
#'  percentage of the m/z value. This value, multiplied by the m/z value, becomes the cutoff level.
#' @param rt_tol_relative The retention time tolerance level for peak alignment. The default is NA, which
#'  allows the program to search for the tolerance level based on the data.
#' @param cluster The number of CPU cores to be used
#' @return A tibble with three tables containing aligned metadata, intensities an RTs.
#'
#' @export
create_aligned_feature_table <- function(features_table,
                                         min_occurrence,
                                         sample_names,
                                         rt_tol_relative,
                                         mz_tol_relative,
                                         cluster = 4) {
    if (!is(cluster, "cluster")) {
        cluster <- parallel::makeCluster(cluster)
        on.exit(parallel::stopCluster(cluster))
        
        # NOTE: side effect (doParallel has no functionality to clean up)
        doParallel::registerDoParallel(cluster)
        register_functions_to_cluster(cluster)
    }



    number_of_samples <- length(sample_names)
    metadata_colnames <- c("id", "mz", "mzmin", "mzmax", "rt", "rtmin", "rtmax", "npeaks", sample_names)
    intensity_colnames <- c("id", sample_names)
    rt_colnames <- c("id", sample_names)

    aligned_features <- create_empty_tibble(number_of_samples, metadata_colnames, intensity_colnames, rt_colnames)

    # table with number of values per group
    groups_cardinality <- table(features_table$cluster)
    # count those with minimal occurrence
    sel.labels <- as.numeric(names(groups_cardinality)[groups_cardinality >= min_occurrence])

    # retention time alignment
    aligned_features <- foreach::foreach(
        i = seq_along(sel.labels), .combine = "comb", .multicombine = TRUE
    ) %dopar% {
        rows <- create_rows(
            features_table,
            i,
            sel.labels,
            mz_tol_relative,
            rt_tol_relative,
            min_occurrence,
            sample_names
        )

        if (!is.null(rows)) {
            rows$metadata_row <- c(i, rows$metadata_row)
            rows$intensity_row <- c(i, rows$intensity_row)
            rows$rt_row <- c(i, rows$rt_row)
        }

        list(metadata = rows$metadata_row, intensity = rows$intensity_row, rt = rows$rt_row)
    }

    colnames(aligned_features$metadata) <- metadata_colnames
    colnames(aligned_features$intensity) <- intensity_colnames
    colnames(aligned_features$rt) <- rt_colnames

    return(aligned_features)
}
