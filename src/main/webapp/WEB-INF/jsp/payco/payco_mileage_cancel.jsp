<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="java.io.PrintWriter" %>
<%@ include file="common_include.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="com.luclipse.paycoTest.util.PaycoUtil" %>
<%
/**-----------------------------------------------------------------------
 * 마일리지 취소(JSP)
 *------------------------------------------------------------------------
 * @Class payco_mileage_cancel.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since 
 * @version
 * @Description 
 * 가맹점과 페이코에서 50:50으로 지불하는 형태임. 가맹점에서 마일리지를 사용할 경우에만 적립취소처리를 한다.
 * return : JSON
 */
%>
<%	
	/* 마일리지 취소를 위한 값을 설정합니다 */
	String orderNo 			   = request.getParameter("orderNo");  				   // 주문번호
	String cancelPaymentAmount = request.getParameter("cancelPaymentAmount"); // 마일리지 취소할 주문서의 원 금액
	String outStr = "";
	
	ObjectMapper mapper = new ObjectMapper();   	 //jackson json object
	PaycoUtil util 		= new PaycoUtil(serverType); //CommonUtil
	
	try{
		/* 설정한 주문정보 변수들로 Json String 을 작성합니다. */
		Map<String, Object> jsonObject = new HashMap<String, Object>();
		jsonObject.put("sellerKey", sellerKey);						//[필수]가맹점 코드	
		jsonObject.put("orderNo", orderNo);							//[필수]주문번호
		jsonObject.put("cancelPaymentAmount", cancelPaymentAmount); //[필수]마일리지 취소할 주문서의 원 금액
		
		/* 주문 상품 상태 변경 API 호출 */
		outStr = util.payco_cancelmileage(jsonObject, logYn);
		
	}catch(Exception e){
		outStr = "{ \"message\" : \"마일리지 취소중 에러가 발생했습니다.\", \"code\" : 9999 }";
	}
	
	try{
		/* 결과반환 */
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(outStr);
		pw.flush();
		pw.close();
		
	}catch(Exception e){
		e.printStackTrace();
	}
%>