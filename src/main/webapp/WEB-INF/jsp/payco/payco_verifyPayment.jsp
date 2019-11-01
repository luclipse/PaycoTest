<%@page import="com.fasterxml.jackson.databind.JsonNode"%>
<%@page import="com.fasterxml.jackson.databind.node.ArrayNode"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="common_include.jsp" %>
<%@ page import="com.fasterxml.jackson.databind.annotation.JsonDeserialize"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.xml.ws.Response"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.luclipse.paycoTest.util.PaycoUtil" %>

<%
/**-----------------------------------------------------------------------
 * 결제상세 조회 페이지(JSP)
 *------------------------------------------------------------------------
 * @Class payco_verifyPayment.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since
 * @version
 * @Description 
 * 가맹점에서 전달한 파라미터를 받아 JSON 형태로 페이코API 와 통신한다.
 * 결제완료 callback 이 실패하거나 했을때 수동으로 조회할 수 있는 API 입니다. 
 */
%>
<%
	// 전달받은 파라미터 셋팅
	String reserveOrderNo 		   = request.getParameter("reserveOrderNo");  		  // PAYCO 주문예약번호
	String sellerOrderReferenceKey = request.getParameter("sellerOrderReferenceKey"); // 외부가맹점에서 발급하는 주문연동키
	
	ObjectMapper mapper = new ObjectMapper();   	 //jackson json object
	PaycoUtil    util   = new PaycoUtil(serverType); //CommonUtil

	// 결제상세 조회 필수값 셋팅 
	Map<String, Object> sendMap = new HashMap<String, Object>();
	sendMap.put("sellerKey", sellerKey);
	sendMap.put("reserveOrderNo", reserveOrderNo);
	sendMap.put("sellerOrderReferenceKey", sellerOrderReferenceKey);
	
	// 결제상세 조회 API 호출 
	String result = util.payco_verifyPayment(sendMap, logYn);
	
	Object obj = mapper.readValue(result, new TypeReference<HashMap<String, Object>>(){});
	String resultValue = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(obj);
	
	try {
	    PrintWriter pw;
	    pw = response.getWriter();
	    response.setContentType("application/json; charset=utf-8");
	    pw.print(resultValue);
	    pw.flush();
	    pw.close();
	    
	} catch (IOException e) {
		e.printStackTrace();
	}
%>	



