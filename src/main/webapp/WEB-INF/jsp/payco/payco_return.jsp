<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.*" %>
<%@ page import="javax.xml.ws.Response"%>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.core.type.TypeReference" %>
<%@ page import="com.fasterxml.jackson.databind.node.ArrayNode"%>
<%@ page import="com.fasterxml.jackson.databind.JsonNode"%>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="com.luclipse.paycoTest.util.PaycoUtil" %>
<%@ page import="java.net.URLDecoder"%>
<%@ page import="java.net.URLEncoder"%>
<%@ include file="common_include.jsp" %>

<% 
/**-----------------------------------------------------------------------
 * 재고수량 및 금액 정합성 검사(ver. Pay2)
 *------------------------------------------------------------------------
 * @Class payco_return.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since 
 * @version
 * @Description 
 * - 구매예약페이지에서 재고수량 및 금액 정합성 검사를 하기위해 통신하는 API
 * - payco 결제 인증 후 호출되어 재고 및 금액 정합성 검사를 수행한다.
 * - 재고 및 금액에 이상이 없을 시 payco 결제승인 API 를 호출하여
 * - 응답에 따라 결제완료 여부를 판단한다.
 * param : response=JSON
 * return : 
 */
%>
<% 
	ObjectMapper mapper = new ObjectMapper();		  	//jackson json object
	PaycoUtil    util   = new PaycoUtil(serverType);	//CommonUtil	

	Boolean doCancel    = false;						// 승인 후 오류발생시 결제취소 여부
	Boolean doApproval  = true; 					  	// 요청금액과 결제 금액 일치여부(true : 일치)
	String	returnUrl	= "";
	
	/* 인증 데이타 변수선언 */
	String reserveOrderNo 	   	   = request.getParameter("reserveOrderNo");			//주문예약번호
	String sellerOrderReferenceKey = request.getParameter("sellerOrderReferenceKey");	//가맹점주문연동키
	String paymentCertifyToken 	   = request.getParameter("paymentCertifyToken");		//결제인증토큰(결제승인시필요)

	Map<String, Object> map = new HashMap<String, Object>(){};
	map.put("code", request.getParameter("code"));
	map.put("message", request.getParameter("message"));
	map.put("reserveOrderNo", request.getParameter("reserveOrderNo"));
	map.put("sellerOrderReferenceKey", request.getParameter("sellerOrderReferenceKey"));
	map.put("mainPgCode", request.getParameter("mainPgCode"));
	map.put("totalPaymentAmt", request.getParameter("totalPaymentAmt"));
	map.put("totalRemoteAreaDeliveryFeeAmt", request.getParameter("totalRemoteAreaDeliveryFeeAmt"));
	map.put("discountAmt", request.getParameter("discountAmt"));
	map.put("pointAmt", request.getParameter("pointAmt"));
	map.put("paymentCertifyToken", request.getParameter("paymentCertifyToken"));
	map.put("bid", request.getParameter("bid"));
	
	int totalPaymentAmt = 0;
	if(request.getParameter("totalPaymentAmt") == null){								//총 결제금액
		totalPaymentAmt = 0;
	}else{
		totalPaymentAmt = (int)Float.parseFloat(request.getParameter("totalPaymentAmt").toString()); 
	}
	
	String code      	   	       = request.getParameter("code");						//결과코드(성공 : 0)
	String message				   = request.getParameter("message");					//결과 메시지
	String cacelResulCode 		   = "";
	String cacelResultMsg 		   = "";
	
	/* 주문예약시 전달한 returnUrlParam */
	String taxationType = request.getParameter("taxationType");
	int taxfreeAmt 	= (int)Float.parseFloat(request.getParameter("totalTaxfreeAmt").toString());
	int taxableAmt 	= (int)Float.parseFloat(request.getParameter("totalTaxableAmt").toString());
	int vatAmt 	  	= (int)Float.parseFloat(request.getParameter("totalVatAmt").toString());
	System.out.println("taxationType : " + taxationType);
	
	/* 결제 인증 성공시 */
	if(code.equals("0")){ 
		/* 수신된 데이터 중 필요한 정보를 추출하여
		 * 총 결제금액과 요청금액이 일치하는지 확인하고,	
		 * 결제요청 상품의 재고파악을 실행하여 
		 * PAYCO 결제 승인 API 호출 여부를 판단한다.
		 */
		/*----------------------------------------------------------------
		.. 가맹점 처리 부분
		..
		-----------------------------------------------------------------*/
		
	  /*★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
		★★★★★★★★★★                                                      ★★★★★★★★★
		★★★★★★★★★★                    중요 사항                         ★★★★★★★★★
		★★★★★★★★★★                                                      ★★★★★★★★★
		★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
		
		 총 금액 결제된 금액을 주문금액과 비교.(반드시 필요한 검증 부분.)
		 주문금액을 변조하여 결제를 시도 했는지 확인함.(반드시 DB에서 읽어야 함.)
		 금액이 변조되었으면 반드시 승인을 취소해야 함.
		 
		★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★*/
		int myDBtotalValue = 81500;						// 가맹점 DB에서 읽은 주문요청 금액
		if(myDBtotalValue != totalPaymentAmt){			// 주문 요청금액과 인증정보로 넘어온 결제금액 비교
			doApproval = false;
			message   = "주문금액과 결제금액이 틀립니다.";
			returnUrl = "index.do";
		}
		
		/* 주문금액과 결제금액이 일치한다고 가정(doApproval = true) */
		if(doApproval){
			Map<String,Object> sendMap = new HashMap<String,Object>();
			sendMap.put("sellerKey", sellerKey);
			sendMap.put("reserveOrderNo", reserveOrderNo);
			sendMap.put("sellerOrderReferenceKey", sellerOrderReferenceKey);
			sendMap.put("paymentCertifyToken", paymentCertifyToken);
			sendMap.put("totalPaymentAmt", totalPaymentAmt);
			
			/* sendMap.put("totalTaxfreeAmt", taxfreeAmt);
			sendMap.put("totalTaxableAmt", taxableAmt);
			sendMap.put("totalVatAmt ", vatAmt);
			sendMap.put("totalServiceAmt ", 0); */
			 
			System.out.println("승인요청 : " + sendMap.toString());
			
			/* payco 결제승인 API 호출 */
			String result = util.payco_approval(sendMap,"Y");
			
			// jackson Tree 이용
			JsonNode node = mapper.readTree(result);
			
			if(node.path("code").toString().equals("0")){
				// 예시
				try{
					
					/* 결제승인 후 리턴된 데이터 중 필요한 정보를 추출하여
					 * 가맹점 에서 필요한 작업을 실시합니다.(예 주문서 작성 등..)
					 * 결제연동시 리턴되는 PAYCO주문번호(orderNo)와 주문인증키(orderCertifyKey)에 대해 
					 * 가맹점 DB 저장이 필요합니다.
					 */
					 
					// 승인 후 전달받은 데이터 저장 변수 
					String paymentTradeNo_card, paymentMethodCode_card, paymentMethodName_card, tradeYmdt_card,
						   cardCompanyName_card, cardCompanyCode_card, cardNo_card,
						   paymentTradeNo_point, paymentMethodCode_point, paymentMethodName_point, tradeYmdt_point,
						   orderProductNo, productPaymentAmt, sellerOrderProductReferenceKey = ""; 
					 
					
					// 주문완료 페이지 전달용 데이터 변수 
					String  orderNo, orderCertifyKey, totalCancelPossibleAmt, requestMemo, cancelTotalAmt, 
							cancelDetailContent, productAmt, cancelPaymentAmount;
							
					// 결제승인 후 리턴된 데이터 중 필요한 정보를 추출 예시
					orderNo 			  	= node.path("result").get("orderNo").textValue();
					reserveOrderNo			= node.path("result").get("reserveOrderNo").textValue();
					sellerOrderReferenceKey = node.path("result").get("sellerOrderReferenceKey").textValue();
					orderCertifyKey			= node.path("result").get("orderCertifyKey").textValue();
					totalPaymentAmt			= (int)Float.parseFloat(node.path("result").get("totalPaymentAmt").toString());
					
					// orderProducts 추출 예시
					ArrayNode orderProducts_arr = (ArrayNode)node.path("result").get("orderProducts");
					for(int i = 0; i < orderProducts_arr.size(); i++){
						orderProductNo 				   = orderProducts_arr.get(i).get("orderProductNo").textValue();
						sellerOrderProductReferenceKey = orderProducts_arr.get(i).get("sellerOrderProductReferenceKey").textValue();
						productPaymentAmt			   = orderProducts_arr.get(i).get("productPaymentAmt").toString();
						// .. 등등...
					}
					
					// paymentDetails 추출 예시
					ArrayNode paymentDetails_arr = (ArrayNode)node.path("result").get("paymentDetails");
					for(int j = 0; j < paymentDetails_arr.size(); j++){
						// paymentMethodCode : 31(신용카드)
						if(paymentDetails_arr.get(j).get("paymentMethodCode").textValue().equals("31")){
							paymentTradeNo_card		= paymentDetails_arr.get(j).get("paymentTradeNo").textValue();
							paymentMethodCode_card 	= paymentDetails_arr.get(j).get("paymentMethodCode").textValue();
							paymentMethodName_card 	= paymentDetails_arr.get(j).get("paymentMethodName").textValue();
							tradeYmdt_card		    = paymentDetails_arr.get(j).get("tradeYmdt").textValue();
							// 신용카드 상세정보(cardSettleInfo) 추출 예시
							cardCompanyName_card = paymentDetails_arr.get(j).get("cardSettleInfo").get("cardCompanyName").textValue();
							cardCompanyCode_card = paymentDetails_arr.get(j).get("cardSettleInfo").get("cardCompanyCode").textValue();
							cardNo_card 		 = paymentDetails_arr.get(j).get("cardSettleInfo").get("cardNo").textValue();
							String  cardAdmissionNo 		 = paymentDetails_arr.get(j).get("cardSettleInfo").get("cardAdmissionNo").textValue();
							System.out.println("cardCompanyName_card : " + cardCompanyName_card);
							System.out.println("cardCompanyCode_card : " + cardCompanyCode_card);
							System.out.println("cardNo_card : " + cardNo_card);
							System.out.println("cardAdmissionNo : " + cardAdmissionNo);
							
						// paymentMethodCode : 98(페이코 포인트)	
						}else if(paymentDetails_arr.get(j).get("paymentMethodCode").textValue().equals("98")){
							paymentTradeNo_point	= paymentDetails_arr.get(j).get("paymentTradeNo").textValue();
							paymentMethodCode_point = paymentDetails_arr.get(j).get("paymentMethodCode").textValue();
							paymentMethodName_point = paymentDetails_arr.get(j).get("paymentMethodName").textValue();
							tradeYmdt_point		 	= paymentDetails_arr.get(j).get("tradeYmdt").textValue();
							System.out.println("paymentTradeNo_point : " + paymentTradeNo_point);
							System.out.println("paymentMethodCode_point : " + paymentMethodCode_point);
							System.out.println("paymentMethodName_point : " + paymentMethodName_point);
							System.out.println("tradeYmdt_point : " + tradeYmdt_point);
						}else if(null != paymentDetails_arr.get(j).get("couponSettleInfo")){
							String discountAmt = paymentDetails_arr.get(j).get("couponSettleInfo").get("discountAmt").toString();
							String discountConditionAmt = paymentDetails_arr.get(j).get("couponSettleInfo").get("discountConditionAmt").toString();
							String encCouponId = paymentDetails_arr.get(j).get("couponSettleInfo").get("encCouponId").toString();
							String paymentMethodCode_coupon = paymentDetails_arr.get(j).get("paymentMethodCode").textValue();
							String paymentMethodName_coupon = paymentDetails_arr.get(j).get("paymentMethodName").textValue();
							
						}
						// .. 등등 ...
						
					}
					
					
					// complete 페이지로 보내는 정보(샘플용) - 가맹점에서는 DB로 데이터 처리하시기 바랍니다. 
					String paramStr = "?orderNo="+orderNo+"&sellerOrderProductReferenceKey="+sellerOrderProductReferenceKey+"&orderCertifyKey="+orderCertifyKey+
									  "&totalCancelTaxfreeAmt="+taxfreeAmt+"&totalCancelTaxableAmt="+taxableAmt+"&totalCancelVatAmt="+vatAmt+
									  "&totalCancelPossibleAmt="+totalPaymentAmt+"&cancelTotalAmt="+totalPaymentAmt+"&requestMemo=결제취소 테스트입니다."+
									  "&cancelDetailContent=결제취소 테스트입니다."+"&reserveOrderNo="+reserveOrderNo+"&sellerOrderReferenceKey="+sellerOrderReferenceKey;
					System.out.println(paramStr);
					message   = "주문이 정상적으로 완료되었습니다.";
					returnUrl = "payco_complete.do"+paramStr;
					
				}catch(Exception e){
					e.printStackTrace();
					message   = "정상 결제승인 완료 되었으나 가맹점 주문서 작성중 데이터처리 오류로 인하여 주문을 취소합니다.";
					returnUrl = "index.do";
					doCancel  = true;
				}
					
			}else{
				message   = node.path("message").textValue();
				returnUrl = "index.do";
			}
			
			if(doCancel){
				/*★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
				#  PAYCO 결제 승인이 완료되고 아래와 같은 상황이 발생하였을경우 예외 처리가 필요합니다.
				1. 가맹점 DB 처리중 오류 발생시
				2. 통신 장애로 인하여 결과를 리턴받지 못했을 경우
				
				위와 같은 상황이 발생하였을 경우 이미 승인 완료된 주문건에 대하여 주문 취소처리(전체취소)가 필요합니다.
				 - PAYCO에서는 주문승인(결제완료) 처리 되었으나 가맹점은 해당 주문서가 없는 경우가 발생
				 - PAYCO에서는 승인 완료된 상태이므로 주문 상세정보 API를 이용해 결제정보를 조회하여 취소요청 파라미터에 셋팅합니다.
				★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★*/
				
				// 결제상세 조회 필수값 셋팅 
				Map<String, Object> verifyPaymentMap = new HashMap<String, Object>();
				verifyPaymentMap.put("sellerKey", sellerKey);
				verifyPaymentMap.put("reserveOrderNo", reserveOrderNo);						// 주문예약번호
				verifyPaymentMap.put("sellerOrderReferenceKey", sellerOrderReferenceKey);	// 가맹점주문연동키
				
				// 결제상세 조회 API 호출
				String verifyPaymentResult = util.payco_verifyPayment(verifyPaymentMap, "Y");
				
				// jackson Tree 이용
				JsonNode verifyPayment_node = mapper.readTree(verifyPaymentResult);
				
				String cancel_orderNo		  = verifyPayment_node.path("result").get("orderNo").textValue(); 
				String cancel_orderCertifyKey = verifyPayment_node.path("result").get("orderCertifyKey").textValue();
				String cancel_cancelTotalAmt  = verifyPayment_node.path("result").get("totalPaymentAmt").toString();
				
				/* 설정한 주문취소 정보로 Json String 을 작성합니다. */
				Map<String, Object> param = new HashMap<String, Object>();
				param.put("sellerKey", sellerKey);										//[필수]가맹점 코드
				param.put("orderNo", cancel_orderNo);									//[필수]주문번호
				param.put("orderCertifyKey", cancel_orderCertifyKey);					//[필수]주문인증 key
				param.put("cancelTotalAmt", Integer.parseInt(cancel_cancelTotalAmt));  	//[필수]취소할 총 금액(전체취소, 부분취소 전부다)
				
				/* 주문 결제 취소 API 호출 */
				String cancelResult = util.payco_cancel(param,"Y","Y");
				
				JsonNode cancelNode = mapper.readTree(cancelResult);
				
				if(!cancelNode.path("code").toString().equals("0")){
					cacelResultMsg   = "망취소 실패사유 : " + cancelNode.path("message").textValue();
					returnUrl 		 = "index.do";
				}else{
					cacelResultMsg = "망취소 결과 : " + cancelNode.path("message").textValue();
					returnUrl 	   = "index.do";
				}
			}
		}
%>

<% 	
	// 사용자 취소(결제창 취소버튼 클릭시)
	}else if(code.equals("2222")){
		returnUrl = "index.do";
	}else{
		returnUrl = "index.do";
	} 
%>					
	<html>
		<head>
			<title>간편결제 PAY2</title>
		</head>
		<script type="text/javascript">
			alert("<%=message%> \n<%=cacelResultMsg%>");
			if(<%=isMobile%>){
				location.href = "<%=returnUrl%>";
			}else{
				opener.location.href = "<%=returnUrl%>";
				window.close();
			}
		</script>
		<body>			
		</body>
	</html>										


