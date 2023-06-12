; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;gather and the informmation received form the button/protocol
datastring = %1%
datastring := StrReplace(datastring, "PlunetButton://" , "")
datastring := StrReplace(datastring, "/" , "")
datastring := StrReplace(datastring, "%7C" , "|")

;close the tab just opened by clicking the button
send ^w

;checking to make sure inforamtion was receivd 
if 1 = 
{
	InputBox, ordernumberandtool , , Enter order number: (e.g. O-28640|SetItemDueDates_demo) and tool seperated by "|", , 350, 350, , , , , O-30937|SetItemDueDates_demo
	datastring = %ordernumberandtool%
}
else
{
	ordernumberandtool := datastring
}

if 1 = 
{
	ExitApp
}

;msgbox % ordernumberandtool
;clearing output log
FileDelete output.txt

;define api instance

host := 
security := 
user :=
Pass :=

;pull config information from data.txt
FileReadLine, host, data.txt, 1
FileReadLine, security, data.txt, 2
FileReadLine, user, data.txt, 3
FileReadLine, pass, data.txt, 4

;collect currently active UUID
FileReadLine, uuidtocheck, uuid.txt, 1


;checkuuid
endpoint = %security%%host%/DataAdmin30
	xml = 
	(
		<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:api="http://API.Integration/">
		   <soap:Header/>
		   <soap:Body>
			  <api:getCompanyCodeList>
				 <UUID>%uuidtocheck%</UUID>
			  </api:getCompanyCodeList>
		   </soap:Body>
		</soap:Envelope>
	)

response := SRWebService_SendRequest(xml, host, endpoint)

DocNode := response.selectSingleNode("//CompanyCodeListResult/statusCode")
statcode := DocNode.text
;msgbox, % statcode



;end of checkuuid
;if uudi is invalid get a new one
if (statcode = -5)
{
;login
endpoint = %security%%host%/PlunetAPI
	xml = 
	(
		<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:api="http://API.Integration/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">
			<soapenv:Body>
				<api:login soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
					<arg0 xsi:type="xsd:string">%user%</arg0>
					<arg1 xsi:type="xsd:string">%pass%</arg1>
				</api:login>
			</soapenv:Body>
		</soapenv:Envelope>
	)

response := SRWebService_SendRequest(xml, host, endpoint)

;set UUID for future use to new UUID 
UUID := response.text
;report info to an output.txt file for logging errors
FileAppend, %UUID%`n, %A_ScriptDir%\output.txt

;update uuid file with new uuid
FileDelete, %A_ScriptDir%\uuid.txt
FileAppend, %UUID%`n, %A_ScriptDir%\uuid.txt

;end of login
}
else
{
	;set UUID for future use to UUID from stored file
	UUID:= uuidtocheck
}

;divide information sent into 2 parts order number and chosen command
Temparray := strsplit(ordernumberandtool, "|")

ordernumber := temparray[1]
command := temparray[2]


;run executable based on command giving UUID and ordernmber information
if command = SetItemDueDates_demo
{
	run "SetItemDueDates_demo.exe" "%UUID%" "%ordernumber%"
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



