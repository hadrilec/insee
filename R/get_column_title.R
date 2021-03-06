#' Get the title of dataset's columns
#'
#' @param dataset an INSEE's dataset, if NULL
#' @return a dataframe
#' @examples
#' \donttest{
#' column_titles_all_dataset = get_column_title()
#'
#' column_titles = get_column_title("CNA-2014-CONSO-MEN")
#' }
#' @export
get_column_title = function(dataset = NULL){

  if(!is.null(dataset)){
    dataset_dimension = get_dataset_dimension(dataset = dataset)
  }else{
    list_dataset = as.character(suppressMessages(get_dataset_list()$id))

    df_dataset_dimension = dplyr::bind_rows(
      lapply(1:length(list_dataset),
                      function(i){

                        dataset_dimension = get_dataset_dimension(dataset = list_dataset[i])

                        df = data.frame(dim = as.character(dataset_dimension),
                                        cl = attr(dataset_dimension, 'cl'),
                                          stringsAsFactors = FALSE)
                        return(df)
                      }
                        ))

    df_dataset_dimension = dplyr::distinct(.data = df_dataset_dimension)

    dataset_dimension = dplyr::pull(.data = df_dataset_dimension, .data$dim)
    attr(dataset_dimension, 'cl') = dplyr::pull(.data = df_dataset_dimension, .data$cl)
  }

  if(!is.null(dataset_dimension)){

    dimension_name_df = dplyr::bind_rows(
      lapply(1:length(dataset_dimension),
             function(i){
               df_dim = get_dimension_values(dimension = attr(dataset_dimension, "cl")[i],
                                             col_name = dataset_dimension[i],
                                             name = TRUE)
               return(df_dim)
               })
    )

    dimension_name_df[,"dimension"] = gsub("-", "_", dimension_name_df[,"dimension"])

    dimension_name_df = dplyr::bind_rows(dimension_name_df, add_type_qual_conf_rev_title())
    dimension_name_df = dplyr::arrange(.data = dimension_name_df, .data$dimension)
    dimension_name_df = dplyr::distinct(.data = dimension_name_df)

    dimension_name_df = tibble::as_tibble(dimension_name_df)

    return(dimension_name_df)
  }else{
    warning("This dataset might not exist, get datasets' list with get_dataset_list()")
    return(NULL)
  }
}
