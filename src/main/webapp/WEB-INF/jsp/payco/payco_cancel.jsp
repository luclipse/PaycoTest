<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.luclipse.paycoTest.util.PaycoUtil"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="java.io.PrintWriter, java.util.*" %>
<%@ include file="common_include.jsp" %>
<%
/**-----------------------------------------------------------------------
 * 주문 취소 API(JSP)
 *------------------------------------------------------------------------
 * @Class payco_cancel.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since
 * @version
 * @Description 
 */ 
%>
<%
	ObjectMapper mapper = new ObjectMapper(); 	//jackson json object
	PaycoUtil util = new PaycoUtil(serverType);	//CommonUtil
	String strResult = "";				  	  	//반환값
	
	String cancelType 						= (String)request.getParameter("cancelType");						//취소 Type 받기 - ALL 또는 PART
	String orderNo							= (String)request.getParameter("orderNo");							//PAYCO에서 발급받은 주문번호
	String orderCertifyKey					= (String)request.getParameter("orderCertifyKey");					//PAYCO에서 발급받은 주문인증 key
	String cancelTotalAmt 					= (String)request.getParameter("cancelTotalAmt");					//총 취소 금액
	String totalCancelTaxfreeAmt			= (String)request.getParameter("totalCancelTaxfreeAmt");			//주문 총 면세금액
	String totalCancelTaxableAmt			= (String)request.getParameter("totalCancelTaxableAmt");			//주문 총 과세 공급가액
	String totalCancelVatAmt				= (String)request.getParameter("totalCancelVatAmt");				//주문 총 과세 부가세액
	String totalCancelPossibleAmt			= (String)request.getParameter("totalCancelPossibleAmt");			//총 취소가능금액
	String sellerOrderProductReferenceKey 	= (String)request.getParameter("sellerOrderProductReferenceKey");	//가맹점 주문 상품 연동 키(PART 취소 시)
	String cancelDetailContent 				= (String)request.getParameter("cancelDetailContent");				//취소 상세 사유
	String cancelAmt 						= (String)request.getParameter("cancelAmt");						//취소 상품 금액(PART 취소 시)
	String requestMemo						= (String)request.getParameter("requestMemo");						//취소처리 요청메모
	String sellerOrderReferenceKey			= (String)request.getParameter("sellerOrderReferenceKey");			//취소처리 요청메모
	
	/* orderNo 값이 없으면 로그를 기록한 뒤 JSON 형태로 오류를 돌려주고 API를 종료합니다. */
	if(orderNo == null ||orderNo.equals("")){
		
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
		
	/* cancelTotalAmt 값이 없으면 로그를 기록한 뒤 JSON 형태로 오류를 돌려주고 API를 종료합니다. */
	}else if(cancelTotalAmt == null || cancelTotalAmt.equals("")){
		
		Map<String,Object> noAmtMap = new HashMap<String,Object>();
		noAmtMap.put("result", "총 취소 금액이 전달되지 않았습니다.");
		noAmtMap.put("message", "cancelTotalAmt is Nothing.");
		noAmtMap.put("code", 9999);
		
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(mapper.writeValueAsString(noAmtMap));
		pw.flush();
		pw.close();
	}else if(orderCertifyKey == null || orderCertifyKey.equals("")){
		
		Map<String,Object> noCertifyKeyMap = new HashMap<String,Object>();
		noCertifyKeyMap.put("result", "주문인증 key가 전달되지 않았습니다.");
		noCertifyKeyMap.put("message", "CertifyKey is Nothing.");
		noCertifyKeyMap.put("code", 9999);
		
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(mapper.writeValueAsString(noCertifyKeyMap));
		pw.flush();
		pw.close();
	}
	
	List<Map<String,Object>> orderProducts = new ArrayList<Map<String,Object>>();
	
	/* 전체 취소 = "ALL", 부분취소 = "PART" */
	if(cancelType.equals("ALL")){
		/* 
		 * 주문상품 데이터 불러오기
		 * 파라메터로 값을 받을 경우 받은 값으로만 작업을 하면 됩니다.
		 * 주문 키값으로만 DB에서 취소 상품 데이터를 불러와야 한다면 이 부분에서 작업하세요.
		 */
		 
	}else if(cancelType.equals("PART")){
		/* 
		 * 주문상품 데이터 불러오기
		 * 파라메터로 값을 받을 경우 받은 값으로만 작업을 하면 됩니다.
		 * 주문 키값으로만 DB에서 취소 상품 데이터를 불러와야 한다면 이 부분에서 작업하세요.
		 */
		
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
		
		/* 부분 취소 할 상품정보 */
		Map<String,Object> orderProductsInfo = new HashMap<String,Object>();
		orderProductsInfo.put("sellerOrderProductReferenceKey", sellerOrderProductReferenceKey);	//[필수]취소상품 연동 키(파라메터로 넘겨 받은 값 - 필요시 DB에서 불러와 대입)	
		orderProductsInfo.put("cpId", cpId);														//[필수]상점 ID(common_include.jsp 에 설정)
		orderProductsInfo.put("productId", productId);												//[필수]상품 ID(common_include.jsp 에 설정)
		orderProductsInfo.put("productAmt", cancelAmt);												//[필수]취소상품 금액( 파라메터로 넘겨 받은 금액 - 필요시 DB에서 불러와 대입)
		orderProductsInfo.put("cancelDetailContent", cancelDetailContent);							//[선택]취소 상세 사유
		orderProducts.add(orderProductsInfo);
		
	/* 취소타입이 잘못되었음. ( ALL과 PART 가 아닐경우 ) */	
	}else{
		Map<String,Object> noCancelTypeMap = new HashMap<String,Object>();
		noCancelTypeMap.put("result", "CANCEL_TYPE_ERROR");
		noCancelTypeMap.put("message", "취소 요청 타입이 잘못되었습니다.");
		noCancelTypeMap.put("code", 9999);
		
		PrintWriter pw;
		pw = response.getWriter();
		response.setContentType("application/json; charset=utf-8");
		pw.print(mapper.writeValueAsString(noCancelTypeMap));
		pw.flush();
		pw.close();
	}
	
	/* 설정한 주문취소 정보로 Json String 을 작성합니다. */
	Map<String, Object> param = new HashMap<String, Object>();
	param.put("sellerKey", sellerKey);								//[필수]가맹점 코드
	param.put("sellerOrderReferenceKey", sellerOrderReferenceKey);	//[선택]가맹점 코드
	param.put("orderNo", orderNo);									//[필수]주문번호
	param.put("orderCertifyKey", orderCertifyKey);					//[필수]주문인증 key
	param.put("cancelTotalAmt", Integer.parseInt(cancelTotalAmt));  //[필수]취소할 총 금액(전체취소, 부분취소 전부다)
	
	if(orderProducts.size() != 0){
		param.put("orderProducts", orderProducts);					//[선택]취소할 상품 List(부분취소인 경우 사용, 입력하지 않는 경우 전체 취소)	
	}
	
	param.put("totalCancelTaxfreeAmt", totalCancelTaxfreeAmt);		//[선택]총 취소할 면세금액
	param.put("totalCancelTaxableAmt", totalCancelTaxableAmt);		//[선택]총 취소할 과세금액
	param.put("totalCancelVatAmt", totalCancelVatAmt);				//[선택]총 취소할 부가세
	param.put("requestMemo", requestMemo);							//[선택]취소처리 요청메모
	
	/* 부분취소 중복을 막기위해 totalCancelPossibleAmt 컬럼을 사용하는 예 
	 * 예를들어 고객이 10만원 주문을 하고 2만원을 부분취소 하고 싶은데 두번눌러서 4만원이 취소 되는 케이스
	 * 또는 어떠한 이유로 PAYCO 에서는 2만원 부분취소가 되었지만 가맹점 에서는 취소가 발생하지 않았을때 등의
	 * 예외상황이 발생했을때를 대비하여 totalCancelPossibleAmt 컬럼의 값을 설정하여 보내주시면 중복취소를 막을 수 있습니다.
	 * 고객이 10만원 결제금액 중 2만원 부분취소시도 -> PAYCO에는 2만원 취소성공, 그러나 어떠한 이유로 고객 화면에는 취소가 안되었음
	 * -> 고객이 다시 2만원 취소 -> 이때 가맹점 에서는 취소된상품이 하나도 없으므로 totalCancelPossibleAmt 값을 10만원으로 보냄 -> 
	 * 가맹점은 totalCancelPossibleAmt 값이 10만원이고 PAYCO 는 2만원을 제외한 8만원이 취소가능금액 이므로 취소가능금액이 일치하지않아 부분취소 불가.
	 */
	param.put("totalCancelPossibleAmt", totalCancelPossibleAmt);	//[선택]총 취소가능금액(현재기준) : 취소가능금액 검증
	
	/* 주문 결제 취소 API 호출 */
	strResult = util.payco_cancel(param,logYn,"N");
	
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
	
%>