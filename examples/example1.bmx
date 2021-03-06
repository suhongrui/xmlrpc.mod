'This example uses direct calls to the XMLRPC-EPI API
'to test the wrapped functions.
SuperStrict
Import htbaapub.xmlrpc

For Local a:Int = 0 To 10
	GCSuspend()
	'create a new request object
	Local request:Byte Ptr = XMLRPC_RequestNew()
	
	Local methodName:Byte Ptr = String("hello").ToCString()
	
	'Set the method name and tell it we are making a request
	XMLRPC_RequestSetMethodName(request, methodName)
	MemFree(methodName)
	XMLRPC_RequestSetRequestType(request, xmlrpc_request_call)
	
	'tell it to write out xml-rpc
	bmxXMLRPC_RequestSetOutputOptions(request, xmlrpc_version_1_0)
	
	'Create a parameter list vector
	Local xParamList:Byte Ptr = XMLRPC_CreateVector(Null, xmlrpc_vector_array)
	'Add our name as first param to the parameter list
	
	
	XMLRPC_VectorAppendString(xParamList, Null, "Htbaa")
	XMLRPC_VectorAppendBase64(xParamList, Null, "Some Base64 text")
	XMLRPC_VectorAppendBoolean(xParamList, Null, False)
	XMLRPC_VectorAppendBoolean(xParamList, Null, True)
	XMLRPC_VectorAppendDateTime(xParamList, Null, 1238998067)
	XMLRPC_VectorAppendDateTime_ISO8601(xParamList, Null, "2009-04-05T16:27:03")
	XMLRPC_VectorAppendDouble(xParamList, Null, 20.43)
	XMLRPC_VectorAppendInt(xParamList, Null, 19)
	
	XMLRPC_RequestSetData(request, xParamList)
	
	Try
		Local xmlMessage:Byte Ptr = XMLRPC_REQUEST_ToXML(request, Null)
		Print convertUTF8toISO8859(xmlMessage)
		XMLRPC_Free(xmlMessage)
	Catch ex:Object
		DebugLog "error!"
	End Try
	
	XMLRPC_RequestFree(request, 1)

	GCResume()
	GCCollect()
	
	Print "memory allocated: " + GCMemAlloced()
	
Next