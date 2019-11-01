<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.luclipse.paycoTest.util.PaycoUtil" %>
<%@ page import="java.io.IOException" %>
<%@ include file="common_include.jsp" %>
<%
/**-----------------------------------------------------------------------
 * 상품상태변경처리 API(JSP)
 *------------------------------------------------------------------------
 * @Class payco_upstatus.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since 
 * @version
 * @Description 
 * 가맹점에서 송신한 매개변수를 전달받아 페이코API와 통신하여 상품상태를 변경처리한다.
 */
%>
<%
	
	ObjectMapper mapper = new ObjectMapper();   	 //jackson json object
	PaycoUtil util 		= new PaycoUtil(serverType); //CommonUtil
	
	String orderNo						  = (String)request.getParameter("orderNo");						//payco에서 발급받은 주문번호
	String sellerOrderProductReferenceKey = (String)request.getParameter("sellerOrderProductReferenceKey");	//외부가맹점에서 관리하는 주문상품키
	String orderProductStatus 			  = (String)request.getParameter("orderProductStatus");				//변경할 주문상태
	String returnStr = "";
	
	try{
		//json object 생성
		Map<String, Object> jsonMap = new HashMap<String, Object>();
		jsonMap.put("sellerKey", sellerKey);										   	//[필수]가맹점코드
		jsonMap.put("orderNo", orderNo);												//[필수]payco에서 발급받은 주문번호
		jsonMap.put("sellerOrderProductReferenceKey", sellerOrderProductReferenceKey);	//[필수]외부가맹점에서 관리하는 주문상품연동 키
		jsonMap.put("orderProductStatus", orderProductStatus);							//[필수]변경할 주문상품 상태
		
		// 주문 상품 상태 변경 API 호출
		returnStr = util.payco_upstatus(jsonMap, logYn);
		
	}catch(Exception e){
		e.printStackTrace();
		returnStr = "{\"code\":\"9999\", \"message\":\"상품상태변경중 알수없는 오류가 발생했습니다.\"}";
	}
	
	try{
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(returnStr);
		pw.flush();
		pw.close();
	}catch(IOException e){
		e.printStackTrace();
	}
	
%>
