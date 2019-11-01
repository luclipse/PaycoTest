<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.luclipse.paycoTest.util.PaycoUtil"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="java.io.PrintWriter, java.util.*" %>
<%@ include file="common_include.jsp" %>
<%
/**-----------------------------------------------------------------------
 * 주문취소가능 확인 API(JSP)
 *------------------------------------------------------------------------
 * @Class payco_cancel_check.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since 
 * @version
 * @Description 취소 처리 API를 호출하기 이전에 취소 처리를 진행할 수 있는지 확인하기 위해 사용한다.
 */
%>
<%
	ObjectMapper mapper = new ObjectMapper(); 	//jackson json object
	PaycoUtil util = new PaycoUtil(serverType);	//CommonUtil
	String strResult = "";				  	  	//반환값
	
	String cancelType 						= (String)request.getParameter("cancelType");						//취소 Type 받기 - ALL 또는 PART
	String orderNo							= (String)request.getParameter("orderNo");							//[필수]PAYCO에서 발급받은 주문번호
	String cancelTotalAmt 					= (String)request.getParameter("cancelTotalAmt");					//[필수]총 취소 금액
	String sellerOrderProductReferenceKey 	= (String)request.getParameter("sellerOrderProductReferenceKey");	//[필수]가맹점 주문 상품 연동 키(PART 취소 시)
	String cancelAmt 						= (String)request.getParameter("productAmt");						//[필수]취소 상품 금액(PART 취소 시)
	
	if(orderNo == null || orderNo.equals("")){
		Map<String,Object> noKeyMap = new HashMap<String,Object>();
		noKeyMap.put("result", "주문번호 값이 전달되지 않았습니다.");
		noKeyMap.put("message", "orderNo is Nothing.");
		noKeyMap.put("code", 9999);
		
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(mapper.writeValueAsString(noKeyMap));
		pw.flush();
		pw.close();
	}else if(cancelTotalAmt == null || cancelTotalAmt.equals("")){
		Map<String,Object> noAmtMap = new HashMap<String,Object>();
		noAmtMap.put("result", "총 취소금액이 전달되지 않았습니다.");
		noAmtMap.put("message", "cancelTotalAmt is Nothing.");
		noAmtMap.put("code", 9999);
		
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(mapper.writeValueAsString(noAmtMap));
		pw.flush();
		pw.close();
	}else{
		if(cancelType.equals("ALL")){
			Map<String, Object> cancelAllParam = new HashMap<String, Object>();
			cancelAllParam.put("sellerKey", sellerKey);								//[필수]가맹점 코드
			cancelAllParam.put("orderNo", orderNo);  								//[필수]PAYCO에서 발급받은 주문번호
			cancelAllParam.put("cancelTotalAmt", Integer.parseInt(cancelTotalAmt)); //[필수]취소할 총 금액
			
			/* 주문 결제 취소 가능 여부 API 호출 */
			strResult = util.payco_cancel_check(cancelAllParam,logYn);
			
		}else if(cancelType.equals("PART")){
			
			if(sellerOrderProductReferenceKey == null || sellerOrderProductReferenceKey.equals("")){
				Map<String,Object> noProductReferenceKey = new HashMap<String,Object>();
				noProductReferenceKey.put("result", "주문상품 연동키가 전달되지 않았습니다.");
				noProductReferenceKey.put("message", "sellerOrderProductReferenceKey is Nothing.");
				noProductReferenceKey.put("code", 9999);
				
				PrintWriter pw;
				pw = response.getWriter();
				response.setContentType("application/json; charset=utf-8");
				pw.print(mapper.writeValueAsString(noProductReferenceKey));
				pw.flush();
				pw.close(); 
			}else if(cancelAmt == null || cancelAmt.equals("")){
				Map<String,Object> noCancelAmt = new HashMap<String,Object>();
				noCancelAmt.put("result", "취소상품 금액이 전달되지 않았습니다.");
				noCancelAmt.put("message", "cancelAmt is Nothing.");
				noCancelAmt.put("code", 9999);
				
				PrintWriter pw;
				pw = response.getWriter();
				response.setContentType("application/json; charset=utf-8");
				pw.print(mapper.writeValueAsString(noCancelAmt));
				pw.flush();
				pw.close();
			}
			
			Map<String, Object> cancelPartParam = new HashMap<String, Object>();
			cancelPartParam.put("sellerKey", sellerKey);						     //[필수]가맹점 코드
			cancelPartParam.put("orderNo", orderNo);  								 //[필수]PAYCO에서 발급받은 주문번호
			cancelPartParam.put("cancelTotalAmt", Integer.parseInt(cancelTotalAmt)); //[필수]취소할 총 금액
			
			//Map<String, Object> orderProducts = new HashMap<String, Object>();
			
			List<Map<String,Object>> orderProducts = new ArrayList<Map<String,Object>>();
			
			Map<String, Object> orderProductInfo = new HashMap<String, Object>();
			orderProductInfo.put("sellerOrderProductReferenceKey", sellerOrderProductReferenceKey);	//[필수]취소상품 연동 키	
			orderProductInfo.put("cpId", cpId);														//[필수]상점 ID(common_include.jsp 에 설정)
			orderProductInfo.put("productId", productId);											//[필수]상품 ID(common_include.jsp 에 설정)
			orderProductInfo.put("productAmt", cancelAmt);											//[필수]취소상품 금액
			
			orderProducts.add(orderProductInfo);
			
			cancelPartParam.put("orderProducts", orderProducts);
			
			/* 주문 결제 취소 가능 여부 API 호출 */
			strResult = util.payco_cancel_check(cancelPartParam,logYn);
		}
		
		try{
			
			PrintWriter pw;
			pw = response.getWriter();
			response.setContentType("application/json; charset=utf-8");
			pw.print(strResult);
			pw.flush();
			pw.close();
		
		}catch(Exception e){
			e.printStackTrace();
		}
		
	}
	
%>


