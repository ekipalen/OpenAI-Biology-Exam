*** Settings ***
Documentation       Robot completes Finnish national upper secondary schools biology exam using OpenAI.
Library             RPA.Browser.Playwright
Library    RPA.Robocorp.Vault
Library    RPA.OpenAI
Library    String

*** Variables ***
${url}   https://yle.fi/aihe/abitreenit/harjoittele
${cookies}   //button[contains(text(),'Vain välttämättömät')]
${question_number}   1
${question_text}   2
&{results}   A=1   B=2   C=3   D=4   E=5

*** Tasks ***
Finnish national upper secondary schools exam
    Authorize to ChatGPT
    Open Browser and accept cookies
    Select and start the Exam
    WHILE    ${question_number} <= ${10}
        Answer the Question   ${question_number}
        ${question_number}  Evaluate    ${question_number}+1
    END
    Log To Console    ${results}[A]
    Sleep    25

*** Keywords ***
Authorize to ChatGPT
    ${secrets}   Get Secret   secret_name=OpenAI
    Authorize To OpenAI   api_key=${secrets}[key]

Open Browser and accept cookies
    Open Browser   ${url}  
    Click   ${cookies}

Select and start the Exam
    Select Options By    //select[@id="yo-select--aine"]    value     biologia
    Click   //span[contains(text(),'Biologia, syksy 2022')]

Answer the Question
    [Arguments]  ${question_number}
    Scroll To Element    (//button[starts-with(@aria-label, 'Tarkista')])[${question_number}]
    ${question}=   Get Text    (//p[contains(text(),'2 p')])[${question_text}]   
    ${answer_option_A}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[1]
    ${answer_option_B}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[3] 
    ${answer_option_C}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[5]
    ${answer_option_D}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[7]
    ${answer_option_E}   Get text   ((//*[@class="yo-multiple-choice-question__options"])[${question_number}]//span)[9]

    # commented out lines are for the text-davinci-003 which has lower performance than gtp-3.5-turbo. 
    #${resp}   Completion Create    
    #...    prompt=${question}. A=${answer_option_A}, B=${answer_option_B}, C=${answer_option_C}, D=${answer_option_D}, E=${answer_option_E}. Vastaa vain oikean vastauksen kirjaimella A, B, C, D tai E ilman mitään muuta tekstiä.
    #...    temperature=1.7

    #Click    (((//*[@class="yo-multiple-choice-question__options"])[${question_number}])[1]//*[@class="ChoiceContainerstyles__ChoiceButtonContainer-sc-11i5r05-0 kvKlsK"])[${results}[${resp}[0]]]

    # following 3 lines to use ChatGPT gpt-3.5-turbo which performs better. 
    ${resp}   ${conversation}   Chat Completion Create   
    ...    user_content=${question}. A=${answer_option_A}, B=${answer_option_B}, C=${answer_option_C}, D=${answer_option_D}, E=${answer_option_E}. Vastaa vain oikean vastauksen kirjaimella A, B, C, D tai E ilman mitään muuta tekstiä. Pelkkä yksi kirjain.
    ...    temperature=0.2
    ${resp}   Strip String    ${resp}
    Log To Console    ${resp}

    Click    (((//*[@class="yo-multiple-choice-question__options"])[${question_number}])[1]//*[@class="ChoiceContainerstyles__ChoiceButtonContainer-sc-11i5r05-0 kvKlsK"])[${results}[${resp}]]
    Click   (//button[starts-with(@aria-label, 'Tarkista')])[${question_number}]
    Sleep    1
    ${question_text}   Evaluate    ${question_text}+1

