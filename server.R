

shinyServer(
    function(input, output) {
        output$oidstock <- renderPrint({input$ticker})
        output$oidfsma <- renderPrint({input$fastSMA})
        output$oidssma <- renderPrint({input$slowSMA})
        output$oidsdate <- renderPrint({input$startQuery})
        output$oidedate <- renderPrint({input$endQuery})
    }
)