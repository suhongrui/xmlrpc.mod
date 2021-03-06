Rem
	Copyright (c) 2010 Christiaan Kras
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
End Rem

Rem
	bbdoc: XML-RPC Client
End Rem
Type TXMLRPC_Client
	Field transport:TXMLRPC_Transport_Interface

	Rem
		bbdoc: Change this to alter the output format.
		about: Accepted values are: xmlrpc_version_none, xmlrpc_version_1_0, xmlrpc_version_simple, xmlrpc_version_danda and xmlrpc_version_soap_1_1.
	End Rem
	Field outputVersion:Int = xmlrpc_version_1_0

	Rem
		bbdoc: This field will hold the XML message used to send the request
	End Rem
	Field xmlRequest:String
	
	Rem
		bbdoc: This field will hold the XML message returned from the XML-RPC server
	End Rem
	Field xmlResponse:String
	
	Rem
		bbdoc: Create a TXMLRPC_Client object
	End Rem
	Method Create:TXMLRPC_Client(outputVersion:Int = xmlrpc_version_1_0)
		Self.outputVersion = outputVersion
		Return Self
	End Method
	
	Rem
		bbdoc: Set a transport interface
	End Rem
	Method SetTransport(transport:TXMLRPC_Transport_Interface)
		Self.transport = transport
	End Method

	Rem
		bbdoc: Send a request to the XML-RPC server
		about: command will hold the function name you want to call. Additional parameters can be passed by passing an TXMLRPC_Call_Parameters object. This method will return a TXMLRPC_Response_Data object containing the returned values from the XML-RPC Server
	End Rem
	Method Call:TXMLRPC_Response_Data(command:String, data:TXMLRPC_Call_Parameters = Null)
		If Not Self.transport
			Throw New TXMLRPC_Exception.Create("No transport object has been assigned yet!")
		End If
		
		Local request:Byte Ptr = XMLRPC_RequestNew()

		'tell it to write out in the specified format
		bmxXMLRPC_RequestSetOutputOptions(request, Self.outputVersion)

		Local methodName:Byte Ptr = command.ToCString()
		'Set the method name and tell it we are making a request
		XMLRPC_RequestSetMethodName(request, methodName)
		XMLRPC_RequestSetRequestType(request, xmlrpc_request_call)
		
		MemFree(methodName)
		
		'If data has been given, then add it to the request
		If data <> Null And XMLRPC_VectorSize(data.vector) > 0
			XMLRPC_RequestSetData(request, data.vector)
		End If

		'Generate XML Message
		Local xmlMessage:Byte Ptr = XMLRPC_REQUEST_ToXML(request, Null)

		Self.xmlRequest = convertUTF8toISO8859(xmlMessage)
		XMLRPC_Free(xmlMessage)
		'And pass our XML message to the transport layer
		Self.xmlResponse = Self.transport.DoRequest(Self.xmlRequest)

		'Find first occurance of the xml start tag
		Local startPos:Int = Self.xmlResponse.Find("<?xml")
		'Strip out HTTP headers
		Self.xmlResponse = Self.xmlResponse[startPos..]
		
		Local responseData:TXMLRPC_Response_Data
		Local output:Byte Ptr = XMLRPC_RequestGetOutputOptions(request)
		responseData = New TXMLRPC_Response_Data.Create(Self.xmlResponse, output)
		
		'Free Request Object
		XMLRPC_RequestFree(request, 1)
		
		Return responseData
	End Method
End Type
