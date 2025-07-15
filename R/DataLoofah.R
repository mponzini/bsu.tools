#' DataLoofah Shiny App for Investigators
#' @description Use function `DataLoofah()` to run the shiny app
#'
#'
#'
#' @import dplyr
#' @import tibble
#' @import ggplot2
#' @import arsenal
#' @import openxlsx
#' @import readxl
#' @import DT
#' @import svglite
#' @import slickR
#' @import haven
#' @import shiny
#' @importFrom methods Summary
#' @importFrom methods show
#' @importFrom utils read.csv
#'
#' @export

# options(shiny.maxRequestSize = 30*1024^2)
# runApp(paste0(getwd(),"/ShinyApp"))

DataLoofah <- function(...){
  ui <- navbarPage(
    "CTSC Data Loofah",

    tabPanel(
      "Introduction",

      fluidPage(
        fluidRow(
          h3("Purpose"),
          p('The purpose of this tool is to ',
            ' investigate the data and its quality prior to analysis. The ',
            'goal is to catch data issues such as numeric variables stored',
            ' as text (e.g. numbers with a white space at the end, commas',
            ', etc.),categorical variables that have inconsistent values ',
            '(e.g. "male" vs "Male" vs "m" vs "M"), numeric variables ',
            'with extreme or nonsensical values (e.g. BMI of 203.4), or ',
            'highlight the use of certain values that are often used to ',
            'code for missing values (e.g. -9, 888, 999). Note that some ',
            'categorical/factor variables may be stored as numeric ',
            'values. For the purposes of this tool they will be treated ',
            'as numeric values, but this is not a data quality issue as ',
            'they can easily be converted to factors in statistical ',
            'software prior to analysis. This tool is not meant to ',
            'create final summary statistics! Rather, this tool is to ',
            'help the user identify potential data errors that then ',
            'need to be corrected prior to conducting statistical analyses.'),
          h3("Instructions"),
          p("To upload your data go to the `Data Import` tab and click `Browse`",
            " to find your data file. If your data is stored in xls or xlsx you",
            " can select the sheet to upload from the `Sheet` dropdown.")
        )
      )
    ),

    tabPanel(
      "Data Import",
      sidebarLayout(
        sidebarPanel(
          fileInput(
            "upload", NULL, accept = c(".csv", ".xlsx", ".xls",
                                       ".sas7bdat", ".sav",
                                       ".dta")
          ),
          selectInput('sheet', "Choose Sheet",  NULL)
        ),
        mainPanel(
          fluidRow(
            column(
              11,
              shiny::dataTableOutput("info")
            )
          ),

          fluidRow(
            column(
              11,
              p(textOutput("dataInfo"))
            )
          )
        )
      )
    ),

    tabPanel(
      "Categorical Variables: Summary Table",
      fluidPage(

        fluidRow(
          column(
            12,
            shiny::dataTableOutput("chrTable")
          )

        ),

        fluidRow(
          column(
            11,
            p(textOutput("chrMessage"))
          )
        )
      )
    ),

    tabPanel(
      "Categorical Variables: Figures",
      fluidPage(
        slickROutput("ChrSlickR")
      )
    ),

    tabPanel(
      "Numeric Variables: Summary Table",
      fluidPage(
        fluidRow(

          column(
            12,
            shiny::dataTableOutput("numTable")
          )

        )
      )
    ),

    tabPanel(
      "Numeric Variables: Figures",
      fluidPage(
        slickROutput("NumSlickR")
      )
    )

  )

  server <- function(input, output, session) {
    ###################
    # data import tab #
    ###################
    sheetNames <- reactive({
      req(input$upload)
      ext <- tools::file_ext(input$upload$name)
      if(ext == 'xls' | ext == "xlsx"){
        readxl::excel_sheets(input$upload$datapath)
      } else {
        "No Sheets"
      }
    })

    observe({
      updateSelectInput(
        session, "sheet", choices = sheetNames()
      )
    })



    data <- reactive({
      if((!is.null(input$upload)) && (input$sheet != "")){
        ext <- tools::file_ext(input$upload$name)
        switch(
          ext,
          csv = read.csv(input$upload$datapath),
          xls = read_xls(input$upload$datapath, sheet = input$sheet),
          xlsx = read.xlsx(input$upload$datapath, sheet = input$sheet),
          sas7bdat = read_sas(input$upload$datapath),
          sav = read_spss(input$upload$datapath),
          dta = read_dta(input$upload$datapath),
          validate(paste0("Invalid file; Please upload a file of the following",
                          " types: .csv, .xls, .xlsx, .sas7bdat, .sav, .dta"))
        )
      } else {
        NULL
      }
    })

    data_info <- reactive({
      if((!is.null(data()))){
        text <- paste0("The data has ", nrow(data()), " rows and ", ncol(data()),
                       " columns. The variable types are displayed below.",
                       " Please review each variable and check that its class",
                       " (numeric or character) is as expected.")
      } else {
        text <- paste0("Import your data file.
                     Accepted file types are xls, xlsx",
                       ", csv, SAS (sas7bdat), Stata (dta), or SPSS (sav).")
      }
      text
    })

    output$dataInfo <- renderText(data_info())

    ####################################
    # Categorical Variables Table  tab #
    ####################################
    data_class <- reactive({
      if((!is.null(data()))){
        data.frame(
          "Variable" = colnames(data()),
          "Class" = sapply(1:ncol(data()), function(x){class(data()[[x]])})
        )
      }
    })


    output$info <- shiny::renderDataTable({
      DT::datatable(data_class())
    })

    chr_vars <- reactive({
      if((!is.null(data()))){
        data_class()[data_class()$Class == 'character' |
                       data_class()$Class == 'factor', ]$Variable
      }
    })

    data_chr <- reactive({
      if((!is.null(data()))){
        data() |>
          dplyr::select(any_of(chr_vars()))
      }
    })

    data_chr_distinct <- reactive({
      if((!is.null(data_chr()))){
        data_chr() |>
          summarise_all(n_distinct) |>
          t() |>
          as.data.frame() |>
          rownames_to_column(var = "Variable") |>
          rename("N_Distinct" = V1)
      }
    })

    data_chr_summarize <- reactive({
      if((!is.null(data_chr_distinct()))){
        data_chr_distinct() |>
          filter(N_Distinct <= 20)
      }
    })

    chr_vars_summ <- reactive({
      if((!is.null(data_chr_summarize()))){
        unlist(data_chr_summarize()$Variable)
      }
    })

    data_chr_summ <- reactive({
      if((!is.null(data_chr_summarize()))){
        data() |>
          dplyr::select(any_of(chr_vars_summ()))
      }
    })

    dat_chr_table <- reactive({
      if((!is.null(data_chr_summ())) && ncol(data_chr_summ()) > 0){
        tableby(~., data = data_chr_summ(), test = FALSE,
                cat.stats = c('countpct', 'Nmiss'))
      }
    })

    overall_label <- reactive({
      if((!is.null(data_chr_summ()))){
        paste0("Overall (N=", nrow(data()), ")")
      }
    })

    chr_table <- reactive({
      if((!is.null(data_chr_summ())) && ncol(data_chr_summ()) > 0){
        tmp <- summary(dat_chr_table())$object$Overall |>
          filter(Overall != "") |>
          rowwise() |>
          mutate(
            Test = case_when(
              label != "N-Miss" ~ paste0(Overall[1], " (", round(Overall[2], 2),
                                         "%)"),
              label == "N-Miss" ~ paste0(Overall[1])
            )
          ) |>
          ungroup() |>
          mutate("Variable" = "variable") |>
          rename("Category" = "label") |>
          dplyr::select(Variable, variable, Category, Test)

        colnames(tmp)[colnames(tmp) == "Test"] <- overall_label()
        tmp
      }
    })

    dat_chr_distinct_check <- reactive({
      if((!is.null(data_chr_distinct()))){
        data_chr_distinct() |>
          filter(N_Distinct > 20)
      }
    })

    chr_Message <- reactive({
      if((!is.null(dat_chr_distinct_check()))){
        chr_vars_check <- unlist(dat_chr_distinct_check()$Variable)
        if(length(chr_vars_check) > 0){
          text <- paste0(
            "The following variables are stored as a character/factor with more",
            " than 20 unique responses: ", paste(chr_vars_check, collapse = ", "),
            ". Consider checking if these are numeric values stored as text",
            " or character values with typos/spelling differences between similar",
            " responses (e.g. Male, male, m, M)."
          )
        } else if(length(chr_vars()) > 0 & length(chr_vars_check) == 0){
          text <- paste0(
            "There are no additional character variables to review."
          )
        } else if((!is.null(chr_vars())) && length(chr_vars()) == 0){
          text <-  paste0("There are no character variables.")
        }
        # text <- paste0("Length chr_vars_check = ", length(chr_vars_check),
        #                ". Length chr_vars = ", length(chr_vars()))
      } else{
        text <- paste0("")
      }
      text
    })

    output$chrTable <- shiny::renderDataTable({
      if((!is.null(chr_table()))){
        DT::datatable(
          chr_table(), rownames = FALSE,
          extensions = 'RowGroup',
          options=list(columnDefs = list(list(visible=FALSE,
                                              targets=c(0, 1))),
                       rowGroup = list(dataSrc = 1),
                       pageLength = 20)
        ) |>
          formatStyle(names(chr_table()), textAlign = 'center')
      }
    })

    output$chrMessage <- renderText(chr_Message())

    #####################################
    # Categorical Variables Figures tab #
    #####################################
    chr_plots <- reactive({
      if((!is.null(data_chr_summ())) && ncol(data_chr_summ()) > 0){
        tmp_chr_plots <- vector(mode = 'list', length = ncol(data_chr_summ()))

        withProgress(message = "Creating Figures", value = 0, {
          n_chr <- length(tmp_chr_plots)

          for(i in 1:n_chr){
            tmp_chr_plots[[i]] <- xmlSVG({
              show(ggplot(data_chr_summ(), aes(x = .data[[chr_vars_summ()[i]]])) +
                     geom_bar() +
                     theme_bw())
            }, standalone = TRUE)

            incProgress(1/n_chr, detail = paste("Figure", i))

            Sys.sleep(0.1)
          }
        })


        tmp_chr_plots
      }
    })

    cP1 <- htmlwidgets::JS("function(slick, index) {
    return '<a>'+(index+1)+'</a>';
    }")

    opts_dot_number1 <- settings(
      initialSlide = 0,
      slidesToShow = 1,
      slidesToScroll = 1,
      focusOnSelect = TRUE,
      dots = TRUE,
      customPaging = cP1
    )

    output$ChrSlickR <- renderSlickR({
      if((!is.null(chr_plots()))){
        slickR(chr_plots(), height = 550, width = "95%", slideId = 'chr') +
          settings(slidesToShow = 1, slidesToScroll = 1) +
          opts_dot_number1
      }

    })

    ###############################
    # Numeric Variables Table tab #
    ###############################
    num_vars <- reactive({
      if((!is.null(data()))){
        data_class()[data_class()$Class == 'numeric' |
                       data_class()$Class == 'integer', ]$Variable
      }
    })

    dat_num <- reactive({
      if((!is.null(data()))){
        data() |>
          dplyr::select(any_of(num_vars()))
      }
    })

    dat_num_table <- reactive({
      if((!is.null(dat_num())) && ncol(dat_num()) > 0){
        tableby(~., data = dat_num(), test = FALSE,
                numeric.stats = c('meansd', 'medianq1q3', 'range', 'Nmiss'))
      }
    })

    num_table <- reactive({
      if((!is.null(dat_num_table()))){
        tmp2 <- summary(dat_num_table())$object$Overall |>
          filter(Overall != "") |>
          rowwise() |>
          mutate(
            Test = case_when(
              label == "Mean (SD)" ~ paste0(format(round(Overall[1], 2), nsmall = 2),
                                            " (", format(round(Overall[2], 2),
                                                         nsmall = 2), ")"),
              label == "Median (Q1, Q3)" ~ paste0(format(round(unname(Overall[1]), 2),
                                                         nsmall = 2),
                                                  " (",
                                                  format(round(unname(Overall[2]), 2),
                                                         nsmall = 2),
                                                  ", ",
                                                  format(round(unname(Overall[3]), 2),
                                                         nsmall = 2),
                                                  ")"),
              label == "Range" ~ paste0(format(round(Overall[1], 2), nsmall = 2),
                                        " \U2012 ",
                                        format(round(Overall[2], 2), nsmall = 2)),
              label == "N-Miss" ~ paste0(Overall[1])
            )
          ) |>
          ungroup() |>
          mutate("Variable" = variable) |>
          rename("Summary" = "label") |>
          dplyr::select(Variable, variable, Summary, Test)

        colnames(tmp2)[colnames(tmp2) == 'Test'] <- overall_label()
        tmp2
      }
    })

    output$numTable <- shiny::renderDataTable({
      if((!is.null(num_table()))){
        DT::datatable(
          num_table(), rownames = FALSE,
          extensions = 'RowGroup',
          options=list(columnDefs = list(list(visible=FALSE,
                                              targets=c(0, 1))),
                       rowGroup = list(dataSrc = 1),
                       pageLength = 12)
        ) |>
          formatStyle(names(num_table()), textAlign = 'center')
      }
    })


    #################################
    # Numeric Variables Figures tab #
    #################################
    num_plots <- reactive({
      if((!is.null(dat_num())) && ncol(dat_num()) > 0){
        tmp_num_plots <- vector(mode = 'list', length = ncol(dat_num()))

        withProgress(message = "Creating Figures", value = 0, {
          n_num <- length(tmp_num_plots)

          for(i in 1:n_num){
            tmp_num_plots[[i]] <- xmlSVG({
              show(ggplot(dat_num(), aes(x = .data[[num_vars()[i]]])) +
                     geom_histogram() +
                     theme_bw())
            }, standalone = TRUE)

            incProgress(1/n_num, detail = paste("Figure", i))

            Sys.sleep(0.1)
          }

        })
        tmp_num_plots
      }
    })

    cP2 <- htmlwidgets::JS("function(slick, index) {
      return '<a>'+(index+1)+'</a>';
                             }")

    opts_dot_number2 <- settings(
      initialSlide = 0,
      slidesToShow = 1,
      slidesToScroll = 1,
      focusOnSelect = TRUE,
      dots = TRUE,
      customPaging = cP2
    )

    output$NumSlickR <- renderSlickR({
      if((!is.null(num_plots()))){
        slickR(num_plots(), height = 550, width = "95%", slideId = 'num') +
          settings(slidesToShow = 1, slidesToScroll = 1) +
          opts_dot_number2
      }
    })

  }

  shinyApp(ui, server, ...)
}
