*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.FileSystem
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open browser and navigate to page
    ${Orders}=    Get orders
    FOR    ${row}    IN    @{Orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Wait Until Keyword Succeeds    10    2 sec    Submit the order
        ${pdf_path}=    Store the receipt as a PDF file    ${row}[Order number]
        ${ss_path}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${ss_path}    ${pdf_path}
        Go to order another robot
    END
    Create a ZIP file of the receipts
    [Teardown]    Log out and close the browser


*** Keywords ***
Open browser and navigate to page
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}
    ${Orders}=    Read table from CSV
    ...    C:${/}Users${/}alani01${/}Robocorp Courses${/}Course 2${/}orders.csv
    ...    header=${True}
    RETURN    ${Orders}

Close the annoying modal
    Click Button    //button[@class='btn btn-dark' and contains(text(),'OK')]

Fill the form
    [Arguments]    ${row}
    Wait Until Element Is Visible    //select[@id='head']
    Select From List By Value    //select[@id='head']    ${row}[Head]
    Click Element    //input[@id='id-body-${row}[Body]']
    Input Text    //input[@placeholder='Enter the part number for the legs']    4
    Input Text    //input[@id='address']    ${row}[Address]

Preview the robot
    Wait and Click Button    //button[@id='preview']

Submit the order
    Click Button    //button[@id='order']
    TRY
        Wait Until Element Is Visible    //div[@id='order-completion']
    EXCEPT
        Click Button    //button[@id='order']
    END

Store the receipt as a PDF file
    [Arguments]    ${row}
    ${pdf_path}=    Set Variable    C:${/}Users${/}alani01${/}Robocorp Courses${/}Course 2${/}receipts${/}${row}.pdf
    ${HTML}=    RPA.Browser.Selenium.Get Element Attribute    //div[@id='receipt']    outerHTML
    Html To Pdf    ${HTML}    ${pdf_path}
    RETURN    ${pdf_path}

Take a screenshot of the robot
    [Arguments]    ${row}
    ${ss_path}=    Set Variable
    ...    C:${/}Users${/}alani01${/}Robocorp Courses${/}Course 2${/}screenshots${/}${row}_ss.png
    ${screenshot}=    Screenshot    //div[@id='robot-preview-image']    ${ss_path}
    RETURN    ${ss_path}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf_path}
    ${pdf_files}=    Create List    ${screenshot}:align=center
    Open Pdf    ${pdf_path}
    Add Files To Pdf    ${pdf_files}    ${pdf_path}    append=True
    Close Pdf

Go to order another robot
    Click Button    //button[@id='order-another']

Create a ZIP file of the receipts
    Archive Folder With Zip    C:${/}Users${/}alani01${/}Robocorp Courses${/}Course 2${/}receipts    Robots_Order.zip

Log out and close the browser
    ${modal_visible}=    Is Element Visible    //button[@class='btn btn-dark' and contains(text(),'OK')]
    IF    ${modal_visible} == True
        Click Button    //button[@class='btn btn-dark' and contains(text(),'OK')]
    ELSE
        Close Browser
    END
