  title: "ALY6070: Northeastern University Job Application: Teaching Assistant"
subtitle: "Week 2"
author: "Shamim Sherafati"
date: "2023-03-11"
output:
  html_document:
  df_print: paged
pdf_document: default
word_document: default
runtime: shiny

  ## Load libraries
  ```{r}
my_packages = c("plyr", "plotly", "ggplot2", "psych", "tidyr", "tidyverse","dplyr","lubridate","readr","caret","caTools","glmnet","shiny","shinyvalidate","shinyWidgets","shinythemes","tippy","shinyjs")
#install.packages(my_packages)
lapply(my_packages, require, character.only = T)
```

## Webpage design and Server setup
```{r}
ui <- fluidPage(theme = shinytheme("lumen"),
                useShinyjs(),
                tags$style(
                  HTML(
                    "
      body {
          background-image: url('https://images.credly.com/images/432ea12d-444b-42e7-a1d9-f5a3655fb948/blob.png');
          background-size: 45%;
          background-repeat: no-repeat;
          background-position: right;
      }
      "
                  )
                ),
                sidebarLayout(
                  sidebarPanel(
                    titlePanel("Northeastern University"), 
                    h3("Job Application: Teaching Assistant"),
                    
                    # Candidate Details
                    textInput("firstname", "First Name:",placeholder = "Enter Your First Name"),
                    
                    textInput("lastname", "Last Name:",placeholder = "Enter Your Last Name"),
                    
                    selectInput("gender", "Gender:", c("Male", "Female", "Other")),
                    
                    # Address
                    textInput("address", "Address:",placeholder = "Unit/Apt number, Street Details"),
                    tippy(
                      textInput("postalcode", "Postal code:",placeholder = "Eg: V5C1B5"), 
                      tooltip = "Eg: V5C1B5"),
                    
                    # Provinces in Canada
                    selectInput(inputId = "province", "Province/Territory:",
                                choices = c("NL","PE","NS","NB","QC","ON","MB","SK","AB","BC","YT","NT","NU")),
                    
                    # Email id
                    tippy(
                      textInput("email", "Email:",placeholder = "Enter email id"), 
                      tooltip = "Enter a valid Email ID"),
                    
                    # Phone number
                    div(
                      id = "phone-wrapper",
                      tags$input(
                        id = "phone", 
                        type = "number", 
                        min = 0, 
                        max = 9999999999, 
                        step = 1,
                        class = "form-control",
                        style = "width: 300px; height: 40px;", # add CSS styling to adjust size
                        oninput = "this.value = Math.max(0, Math.min(9999999999, this.value)).toString().slice(0,10)"
                      ),
                      tags$script(
                        "$('#phone').attr('placeholder', 'Enter phone number');"
                      )
                    ),
                    
                  ),
                  mainPanel(
                    
                    # Education
                    selectInput(inputId = "edu", label = "Education Level:",
                                choices = c("Bachelor's degree",
                                            "Master's Degree",
                                            "Doctoral degree",
                                            "Other")),
                    # Experience
                    verbatimTextOutput("value"),
                    numericInput("Exp","Teaching Experience:", value = NULL,min=2),
                    radioButtons("radio", "Working knowledge in R and/or Python language", choices = c("Yes", "No")),
                    
                    # Availability
                    selectInput(inputId = "Availability", "Availability:",
                                choices = c("Full Time",
                                            "Part Time",
                                            "Contractual",
                                            "Freelancer")),
                    
                    # Interview Availability
                    dateInput("date", "Choose Date For Interview:"),
                    
                    # Candidate Status
                    selectInput(inputId = "candidatestatus", "Status in Canada:",
                                choices = c("Citizen",
                                            "Permanent resident",
                                            "Work Permit" ,
                                            "Student")),
                    
                    #Salary
                    sliderInput("Salary", "Salary Expectation per hour:", min = 0, max = 200, value = 20),
                    
                    # Upload Resume
                    fileInput(inputId = "pdf", label = "Upload your resume", accept = "application/pdf"),
                    div(id = "upload-status"),
                    
                    # Status of the file upload
                    verbatimTextOutput(outputId = "file_status"),
                    
                    # Output text based on file upload
                    textOutput(outputId = "result"),
                    
                  ),
                ),
                
                # terms and condition 
                # checkboxInput("terms", "I agree to the terms and conditions."),
                checkboxInput("terms", HTML(paste("I agree to the ", 
                                                  a("terms and conditions", href = "https://github.com/abidikshit/R_Projects/blob/main/ALY6070/Week2/terms-and-conditions.html")))),
                
                
                actionButton("submit", "Submit"),
                textOutput("status")
                
)

# Define server logic required to draw a histogram ----
server <- function(input, output, session) {
  
  # Add a req() function to check if firstname and lastname are filled
  observeEvent(c(input$firstname, input$lastname), {
    if (is.null(input$firstname) || input$firstname == "" ||
        is.null(input$lastname) || input$lastname == "") {
      shinyjs::disable("submit") # disable the submit button if firstname or lastname is empty
    } else {
      shinyjs::enable("submit") # enable the submit button if firstname and lastname are not empty
    }
  })
  
  observeEvent(input$pdf, {
    req(input$pdf)
    status_message <- paste0("File '", input$pdf$name, "' uploaded successfully.")
    updateTextInput(session, "upload-status", label = NULL, value = status_message)
  })
  
  
  # Disable submit button initially
  shinyjs::disable("submit")
  
  # Define a reactive expression to track the submission status
  submission_status <- reactive({
    if (input$submit == 0) {
      return("")
    } else {
      return("Application submitted successfully!")
    }
  })
  
  # Print the submission status to the UI
  output$status <- renderText(submission_status())
  
  # Validate email input and enable/disable submit button accordingly
  observe({
    # Check that email input is not empty and is a valid email address
    email_valid <- !is.null(input$email) &&
      regexpr("[[:alnum:]]+@[[:alnum:]]+\\.[[:alpha:]]{2,4}", input$email) > 0
    # Enable/disable submit button based on email validity and agreement to terms
    if (email_valid && input$terms == TRUE) {
      shinyjs::enable("submit")
    } else {
      shinyjs::disable("submit")
    }
  })
}

observeEvent(input$submit, {
  # Store form data in a data frame
  form_data <- data.frame(
    First_Name= input$firstname,
    Last_Name= input$lastname,
    Gender = input$gender,
    Education_Level = input$edu,
    Address = input$address,
    Postal_code = input$postolcode,
    Province_Territory = input$province,
    Email = input$email,
    phone = input$phone,
    Teaching_Experience = input$Exp,
    Availability = input$Availability,
    Choose_Date_For_Interview = input$date,
    Status_in_Canada = input$candidatestatus,
    Salary_Expectation_per_hour = input$Salary
  )
  
  # Print the form data to the console
  print(form_data)
})

shinyApp(ui = ui, server = server)
