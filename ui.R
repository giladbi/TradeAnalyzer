pageWithSidebar(
    headerPanel("Trade Evaluator"),
    sidebarPanel(
        numericInput('fastSMA', 'Fast SMA', 9, min = 2, max = 250, step = 1),
        numericInput('slowSMA', 'Fast SMA', 9, min = 3, max = 250, step = 1),
        dateInput('startQuery', "Start Date:"),
        dateInput('endQuery', "End Date:")
    ),
    mainPanel(
        h4('Fast SMA:'),
        verbatimTextOutput("oidfsma"),
        h4('Slow SMA:'),
        verbatimTextOutput("oidssma"),
        h4('Query Start Date:'),
        verbatimTextOutput("oidsdate"),
        h4('Query End Date:'),
        verbatimTextOutput("oidedate")
    )
)