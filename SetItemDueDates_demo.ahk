#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


if 1 = 
{
	msgbox, No data received
	ExitApp
}


UUID = %1%
ordernumber = %2%

ordernumber := SubStr(ordernumber, 3)

;msgbox, %UUID% - %ordernumber%

;clearing output log
FileDelete output.txt

;define api instance

host := 
security := 
user :=
Pass :=


FileReadLine, host, data.txt, 1
FileReadLine, security, data.txt, 2
FileReadLine, user, data.txt, 3
FileReadLine, pass, data.txt, 4


;get order ID
endpoint = %security%%host%/DataOrder30
	xml = 
	(
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:api="http://API.Integration/">
   <soap:Header/>
   <soap:Body>
      <api:getOrderID>
         <UUID>%UUID%</UUID>
         <displayNo>O-%ordernumber%</displayNo>
      </api:getOrderID>
   </soap:Body>
</soap:Envelope>
	)

response := SRWebService_SendRequest(xml, host, endpoint)
output := response.text
FileAppend, %UUID%`n, %A_ScriptDir%\output.txt

DocNode := response.selectSingleNode("//IntegerResult/data")
OrderID := DocNode.text


;get all item objects
endpoint = %security%%host%/DataItem30
	xml = 
	(
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:api="http://API.Integration/">
   <soap:Header/>
   <soap:Body>
      <api:getAllItemObjects>
         <UUID>%UUID%</UUID>
         <projectID>%OrderID%</projectID>
         <projectType>3</projectType>
      </api:getAllItemObjects>
   </soap:Body>
</soap:Envelope>
	)

response := SRWebService_SendRequest(xml, host, endpoint)
output := response.text
toparse := response.xml

;creating item list GUI
Gui, New,, Set Item Due Dates | Order Number: O-%ordernumber%

;Adding assorted batch buttons
Gui, Add, Button, , 1
Gui, Add, Button, ys, 2
Gui, Add, Button, ys, 3
Gui, Add, Button, ys, 4
Gui, Add, Button, ys, 5
Gui, Add, Button, ys, 6
Gui, Add, Button, ys, 7+

;datetime field stored as variable MyDateTime
Gui, Add, DateTime, ys w120 vMyDateTime, dd/MM/yyyy HH:mm

Gui, Add, Button, x+170 w100, Submit
Gui, Add, ListView, xs r20 w600, Batch|Item|Item Name|DueDate|itemID


; replacing closing data element with a single character to use in parsing loop
StringReplace, toparse, toparse, </data>, ¬, All

;parsing through each item from all items object result
Loop, Parse, toparse, ¬
{

	;clearing variables
	itemid1 :=
	desc1 :=
	due1 :=

	;collecting data from current item
	FoundPos := RegExMatch(A_LoopField, "<itemID>(.*?)</itemID>" , itemid, 1)
	FoundPos := RegExMatch(A_LoopField, "<briefDescription>(.*?)</briefDescription>" , desc, 1)
	FoundPos := RegExMatch(A_LoopField, "<deliveryDeadline>(................).*?</deliveryDeadline>" , due, 1)
	
	;adding item data to GUI list view, if an item is in the current parsed text.
	ifnotequal, itemid1,
	{
		LV_Add("", "0", A_Index, desc1, due1, itemid1)
	}
}

;setting column widths
LV_ModifyCol()
LV_ModifyCol(1, "40 Integer")  
LV_ModifyCol(2, "40 Integer")  
LV_ModifyCol(3, "370")  
LV_ModifyCol(4, "120")  
LV_ModifyCol(5, "0")  
LV_ModifyCol(3, "sort")

; Display the window and return. The script will be notified whenever the user double clicks a row.
Gui, Show
return


GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
;jump to finishing up, logging out of API 
goto finishup

;what happens when each button is pressed
Button1:
	buttonnumber := 1
	gosub, Buttonpressed
return

Button2:
	buttonnumber := 2
	gosub, Buttonpressed
return

Button3:
	buttonnumber := 3 
	gosub, Buttonpressed
return

Button4:
	buttonnumber := 4
	gosub, Buttonpressed
return

Button5:
	buttonnumber := 5
	gosub, Buttonpressed
return

Button6:
	buttonnumber := 6 
	gosub, Buttonpressed
return

Button7+:
	InputBox, buttonnumber, more than 7, Enter a number:, , 200, 120, , , , , 
	
	gosub, Buttonpressed
return

;action of button being pressed that wasn't submit
Buttonpressed:

;push data from GUI into code
gui, submit, nohide

;convert time into plunet compatblie format
FormatTime, itemduedate, %MyDateTime%, yyyy-MM-ddTHH:mm

;loop through all list view lines
Loop % LV_GetCount()
{
	
	;check if this row is select by getting the next selected row, by starting at the row before.
	RowNumber := LV_GetNext(A_index - 1)
	;mod row = current row number
	modrow:=A_Index
	
	;if current row is selected modify it's date 
	ifequal, A_index, %RowNumber%
	{
		LV_Modify(modrow, ,buttonnumber, ,,itemduedate )
	}
 
 }

 Return
 
 ;submit button pressed
 Buttonsubmit:
 ;sort by date order so that the last due date can be used later on.
 LV_ModifyCol(4, "sort")
 
 ;submit GUI and close
 gui, submit
 
 ;flag that dialog was submited.
 submitted:= "yes"
 ;warning for modifying items
 msgbox, kick everyone out of the project (including yourself) i.e., go to job list page.
 
 ;loop through each item and set its delivery date 
 Loop % LV_GetCount()
{
	LV_GetText(delivdate, A_index , 4)
	LV_GetText(itemID, A_index , 5)
	;msgbox, %itemID%-%delivdate%


;setDeliv Deadline
endpoint = %security%%host%/DataItem30
	xml = 
	(
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:api="http://API.Integration/">
   <soap:Header/>
   <soap:Body>
      <api:setDeliveryDeadline>
         <UUID>%UUID%</UUID>
         <deadline>%delivdate%:00</deadline>
         <comment>comment</comment>
		 <projectType>3</projectType>
         <itemID>%itemID%</itemID>
	 </api:setDeliveryDeadline>
   </soap:Body>
</soap:Envelope>
	)

setdelivagain:
response := SRWebService_SendRequest(xml, host, endpoint)
output := response.text
		FileAppend, setDeliveryDeadline%output%`n, %A_ScriptDir%\output.txt

;check if the project is locked. If it is ask the uesr to kick them out

ifequal, output, -45Data entry is locked by other user and can not be modified
{
	msgbox, someone is in the project!! Kick them out
	goto setdelivagain
}

;end of setDeliv Deadline


}

;setDeliv Deadline order based on the last item due date
endpoint = %security%%host%/DataOrder30
	xml = 
	(
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:api="http://API.Integration/">
   <soap:Header/>
   <soap:Body>
      <api:setDeliveryDeadline>
         <UUID>%UUID%</UUID>
         <deliveryDeadline>%delivdate%:00</deliveryDeadline>
         <orderID>%1%</orderID>
	 </api:setDeliveryDeadline>
   </soap:Body>
</soap:Envelope>
	)

response := SRWebService_SendRequest(xml, host, endpoint)
output := response.text
		FileAppend, setDeliveryDeadlineorder%output%`n, %A_ScriptDir%\output.txt

;end of setDeliv Deadline order



finishup:


ifequal, submitted, yes
{
	msgbox, Done!
}
exitapp

;Send the XML string request and returns an XML object of the SOAP Body
SRWebService_SendRequest(xml, host, endpoint)
{

	Response := []
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	WebRequest.Open("POST", endpoint)
	;WebRequest.Option(9) := TLSv1.2,SSLv3
	WebRequest.SetRequestHeader("Accept-Encoding", "gzip, deflate")
	WebRequest.SetRequestHeader("Content-Type", "application/soap+xml;charset=UTF-8")
	WebRequest.SetRequestHeader("Content-Length", StrLen(xml))
	WebRequest.SetRequestHeader("SOAPAction", endpoint)
	WebRequest.SetRequestHeader("Host", host)
	WebRequest.SetRequestHeader("Connection", "Keep-Alive")
	;WebRequest.SetTimeouts(180000,180000,180000,180000)

	try
		WebRequest.Send(xml)
	catch
		return 
	Response["Text"] := WebRequest.ResponseText
	WebRequest := ""
	
	;Put the XML content into an object
	doc := ComObjCreate("MSXML2.DOMDocument.6.0")
	doc.async := false
	doc.loadXML(Response["Text"])
	doc.setProperty("SelectionNamespaces", namespaces . " xmlns:S=""http://www.w3.org/2003/05/soap-envelope""")	
	body := doc.selectSingleNode("S:Envelope").selectSingleNode("S:Body")
	return body, XMLoutput
	
}



