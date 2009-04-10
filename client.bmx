Rem
	bbdoc:
End Rem
Type TXMLRPC_Client
	Rem
		bbdoc: URL of webservice
	End Rem
	Field transport:TXMLRPC_Transport_Interface
	Field outputVersion:Int = xmlrpc_version_1_0
	Field xmlRequest:String
	Field xmlResponse:String
	
	Rem
		bbdoc:
	End Rem
	Method Create:TXMLRPC_Client()
		Return Self
	End Method
	
	Rem
		bbdoc: Set a transport interface
	End Rem
	Method SetTransport(transport:TXMLRPC_Transport_Interface)
		Self.transport = transport
	End Method
	
	Rem
		bbdoc:
	End Rem
	Method Call:TXMLRPC_Response_Data(command:String, data:TXMLRPC_Call_Parameters = Null)
		If Not Self.transport
			Throw New TXMLRPC_Exception.Create("No transport object has been assigned yet!")
		End If
		
		Local request:Byte Ptr = XMLRPC_RequestNew()
		
		'Set the method name and tell it we are making a request
		XMLRPC_RequestSetMethodName(request, command.ToCString())
		XMLRPC_RequestSetRequestType(request, xmlrpc_request_call)
			
		'tell it to write out in the specified format, defaults to xmlrpc_version_1_0
		Local output:Byte Ptr = XMLRPC_Create_STRUCT_XMLRPC_REQUEST_OUTPUT_OPTIONS(Self.outputVersion)
		XMLRPC_RequestSetOutputOptions(request, output)

		'If data has been given, then add it to the request
		If data <> Null Or XMLRPC_VectorSize(data.vector) > 0 
			XMLRPC_RequestSetData(request, data.vector)
		End If

		'Generate XML Message
		Local xmlMessage:Byte Ptr = XMLRPC_REQUEST_ToXML(request, Null)
		
		Self.xmlRequest = convertUTF8toISO8859(xmlMessage)
		
		'And pass our XML message to the transport layer
		Self.xmlResponse = Self.transport.DoRequest(xmlMessage)
		
		'Find first occurance of the xml start tag
		Local startPos:Int = Self.xmlResponse.Find("<?xml")
		'Strip out HTTP headers
		Self.xmlResponse = Self.xmlResponse[startPos..]
		
		Local responseData:TXMLRPC_Response_Data = New TXMLRPC_Response_Data.Create(Self.xmlResponse, output)

		'Free Request object
		XMLRPC_RequestFree(request, 1)
		Return responseData
	End Method
End Type