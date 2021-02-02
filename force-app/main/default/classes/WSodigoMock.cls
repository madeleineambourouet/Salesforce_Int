global class WSodigoMock {
	
	public static String SelectMock;

	global class CallBackWSmock implements WebServiceMock {
		global void doInvoke(
			Object stub,
			Object request,
			Map<String, Object> response,
			String endpoint,
			String soapAction,
			String requestName,
			String responseNS,
			String responseName,
			String responseType
		) {
			if (SelectMock == 'SaveCallBack2') {
	            WSodigo_Com20090921WebCallback.saveCallBack2Response_element response_x = new WSodigo_Com20090921WebCallback.saveCallBack2Response_element();
				WSodigo_WebCallBackWsBeanModel.SaveCallBackResponseBean responseBean = new WSodigo_WebCallBackWsBeanModel.SaveCallBackResponseBean();
				responseBean.callBackId = 1;
				responseBean.status = 1;
				response_x.return_x = responseBean;
						
				response.put('response_x', response_x);
				
			}
			else if (SelectMock == 'changeStatusCallBack') {
				WSodigo_Com20090921WebCallback.changeStatusCallBackResponse_element response_x = new WSodigo_Com20090921WebCallback.changeStatusCallBackResponse_element();
				WSodigo_WebCallBackWsBeanModel.changeStatusCallBackResponseBean responseBean = new WSodigo_WebCallBackWsBeanModel.changeStatusCallBackResponseBean();
				List<Integer> callBackIdErrorList = new List<Integer>();
				Integer callBackIdError = 1;
				callBackIdErrorList.add(callBackIdError);
				responseBean.callBackIdErrorList = callBackIdErrorList;
				responseBean.status = 0;
				response_x.return_x = responseBean;
						
				response.put('response_x', response_x);
				
			}

		}
	}
	
	
	
}