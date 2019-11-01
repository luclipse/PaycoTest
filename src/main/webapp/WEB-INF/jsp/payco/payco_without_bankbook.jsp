<%@page import="com.util.ResponseData"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLDecoder, java.net.URLEncoder" %>
<%
/**-----------------------------------------------------------------------
 * 무통장입금 완료통보수신 API(JSP)
 *------------------------------------------------------------------------
 * @Class payco_without_bankbook.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since
 * @version
 * @Description 
 * 무통장입금일 경우 입금완료 통보 URL을 설정하여 수신 받는다.
 * param : response=JSON
 * return : "OK","ERROR"
 */
%>
<%
	java.text.SimpleDateFormat dateformat = new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss");
	
	ObjectMapper mapper = new ObjectMapper(); //jackson json object
	String strResult 	= "";				  //반환값
	
	//페이코에서 송신하는 주문정보 JSON object
	String strResponse = request.getParameter("response") == null ? "" :(String)request.getParameter("response");
	System.out.println(strResponse);
	//POST 값 중 response 값이 없으면 에러를 표시하고 API를 종료합니다.
	if("".equals(strResponse)){
		strResult = "ERROR";
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("text/html; charset=utf-8");
		pw.print(strResult);
		pw.flush();
		pw.close();
		
		return;
	}
	
	StringBuffer sb = new StringBuffer();
	
	String sellerOrderReferenceKey 	  	= "";
	String reserveOrderNo 		   	  	= "";
	String orderNo 				   	  	= "";
	String memberName 			   	  	= "";
	int totalOrderAmt 			   	  	= 0;
	int totalDeliveryFeeAmt 	   	  	= 0;
	int totalRemoteAreaDeliveryFeeAmt	= 0;
	
	try{
	    
		strResponse = URLDecoder.decode(strResponse, "UTF-8");
		System.out.println(strResponse.toString());
		Map<String, Object> jObject = mapper.readValue(strResponse, new TypeReference<HashMap<String, Object>>(){});

		/*========== 수신 데이터를 사용하여 주문서를 조회합니다.(가맹점 처리) ==========*/
		sellerOrderReferenceKey = (String)jObject.get("sellerOrderReferenceKey"); //가맹점에서 발급하는 주문 연동 Key
		reserveOrderNo 			= (String)jObject.get("reserveOrderNo");		  //주문예약번호
		orderNo 				= (String)jObject.get("orderNo");				  //주문번호
		memberName 				= (String)jObject.get("memberName");			  //주문자명
		
		
		/*========== 지급이 완료 되었다고 받았으면 지급 완료 처리.(가맹점 처리) ==========*/
		String paymentCompletionYn = (String)jObject.get("paymentCompletionYn"); //지급완료 값 ( Y/N )
		if("Y".equals(paymentCompletionYn)){
			// 무통장 입금 확인 필드 업데이트(가맹점)
			// .....
			
			strResult = "OK";
		} else {
			/*
			*지급이 완료 되지 않았다고 받았으면 지급 되지 않았다고 처리
			*단, 지급되지 않은경우 이 API 가 호출되지 않으므로 필요는 없음.
			*혹시 모를 경우를 대비하여 처리
			*/
			strResult = "ERROR";
		}
	   	
	}catch(Exception e){
		e.printStackTrace();
		strResult = "ERROR";
		StackTraceElement[] elem = e.getStackTrace();
		for ( int i = 0; i < elem.length; i++ ){
			elem[i].toString();
			sb.append(elem[i].toString() + "\n");
		}
	}
	
	/* 상단 처리결과를 payco로 리턴한다.(성공:'OK', 실패:'ERROR') */
	PrintWriter pw;
	pw = response.getWriter();
	response.setContentType("text/html; charset=utf-8");
	pw.print(strResult);
	pw.flush();
	pw.close();
	
%>