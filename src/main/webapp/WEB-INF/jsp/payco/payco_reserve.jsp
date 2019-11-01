<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
<%@ include file="common_include.jsp" %>
<%
/**-----------------------------------------------------------------------
 * 구매예약처리 페이지(JSP)
 *------------------------------------------------------------------------
 * @Class payco_reserve.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com> 
 * @since
 * @version
 * @Description 
 * 가맹점에서 전달한 파라미터를 받아 JSON 형태로 페이코API 와 통신한다.
 */    
%>
<% 
	
	ObjectMapper mapper = new ObjectMapper(); 		  //jackson json object
	PaycoUtil util = new PaycoUtil(serverType);

	/* 이전 페이지에서 전달받은 고객 주문번호 설정 */
	String customerOrderNumber = (String)request.getParameter("customerOrderNumber");
	
	/*======== 상품정보 변수 선언 ========*/
	int orderNumber, orderQuantity, productUnitPrice, productUnitPaymentPrice, productAmt, deliveryFeeAmt; 
	int productPaymentAmt, totalProductPaymentAmt, sortOrdering;
	int totalTaxfreeAmt, totalTaxableAmt, totalVatAmt, totalDeliveryAmt, unitTaxfreeAmt, unitTaxableAmt, unitVatAmt;
	String iOption;
	String productName;
	String productInfoUrl;
	String orderConfirmUrl;
	String orderConfirmMobileUrl;
	String productImageUrl;
	String sellerOrderProductReferenceKey;
	String taxationType;
	/*=====================================*/
	
	/*======== 변수 초기화 ========*/
	totalProductPaymentAmt = 0;	//주문 상품이 여러개일 경우 상품들의 총 금액을 저장할 변수
	orderNumber 	= 0;		//주문 상품이 여러개일 경우 순번을 매길 변수
	unitTaxfreeAmt  = 0;		//개별상품단위 면세금액
	unitTaxableAmt  = 0;		//개별상품단위 공급가액
	unitVatAmt      = 0;		//개별상품단위 부가세액
	totalTaxfreeAmt = 0;		//총 면세 금액
	totalTaxableAmt = 0;		//총 과세 공급가액
	totalVatAmt 	= 0;		//총 과세 부가세액
	/*=============================*/
	
	/*==== 상품정보 값 입력 ====*/
	orderNumber = orderNumber + 1; 										 // 상품에 순번을 정하기 위해 값을 증가합니다.
	orderQuantity = 1;													 //[필수]주문수량 (배송비 상품인 경우 1로 세팅)
	productUnitPrice = 79000;											 //상품 단가 ( 테스트용으로써 79000원으로 설정)
	productUnitPaymentPrice = 79000;					 		 		 //상품 결제 단가 ( 테스트용으로써 79000원으로 설정)
	productAmt = productUnitPrice;						 				 //[필수]상품 결제금액(상품단가 * 수량)
	productPaymentAmt = productUnitPaymentPrice * orderQuantity + 2500;	 //[필수]상품 결제금액(상품결제단가 * 수량, 배송비 설정시 상품가격에 포함시킴 ex) 2500원)
	iOption = "";											 		 	 //[선택]옵션(최대 100 자리)
	sortOrdering = orderNumber;											 //[필수]상품노출순서, 10자 이내
	productName = "꾸즈 여성 숄 자켓 (블랙/로즈베이지체크 택1)";					 //[필수]상품명, 4000자 이내
	orderConfirmUrl = "";							 					 //[선택]주문완료 후 주문상품을 확인할 수 있는 url, 4000자 이내
	orderConfirmMobileUrl = "";					 						 //[선택]주문완료 후 주문상품을 확인할 수 있는 모바일 url, 1000자 이내
	productImageUrl = "";	 											 //[선택]이미지URL(배송비 상품이 아닌 경우는 필수), 4000자 이내, productImageUrl에 적힌 이미지를 썸네일해서 PAYCO 주문창에 보여줍니다.
	sellerOrderProductReferenceKey = "2960903800";					  	 //[필수]가맹점에서 관리하는 상품키, 100자 이내.(외부가맹점에서 관리하는 주문상품 연동 키(sellerOrderProductReferenceKey)는 주문 별로 고유한 key이어야 합니다.)
																		 // 단 주문당 1건에 대한 상품을 보내는 경우는 연동키가 1개이므로 주문별 고유값을 고려하실 필요 없습니다.
	taxationType = "TAXATION";											 //[선택]과세타입(기본값 : 과세). DUTYFREE :면세, COMBINE : 결합상품, TAXATION : 과세
	
	
	//totalTaxfreeAmt(면세상품 총액) / totalTaxableAmt(과세상품 총액) / totalVatAmt(부가세 총액) => 일부 필요한 가맹점을위한 예제입니다.
	//과세상품일 경우
	if(taxationType.equals("TAXATION")){
		unitTaxfreeAmt = 0;
		unitTaxableAmt = Math.round((float)(productPaymentAmt / 1.1));
		unitVatAmt	   = Math.round((float)((productPaymentAmt / 1.1) * 0.1));
		
		if(unitTaxableAmt + unitVatAmt != productPaymentAmt){
			unitTaxableAmt = productPaymentAmt - unitVatAmt;
		}
	
	//면세상품일 경우
	}else if(taxationType.equals("DUTYFREE")){
		unitTaxfreeAmt = productPaymentAmt;
		unitTaxableAmt = 0;
		unitVatAmt	   = 0;
				
	//복합상품일 경우
	}else if(taxationType.equals("COMBINE")){
		unitTaxfreeAmt = 1000;
		unitTaxableAmt = Math.round((float)((productPaymentAmt - unitTaxfreeAmt) / 1.1));
		unitVatAmt	   = Math.round((float)(((productPaymentAmt - unitTaxfreeAmt) / 1.1) * 0.1));
		
		if(unitTaxableAmt + unitVatAmt != productPaymentAmt - unitTaxfreeAmt){
			unitTaxableAmt = (productPaymentAmt - unitTaxfreeAmt) - unitVatAmt;
		}
			
	}
	
	totalTaxfreeAmt = totalTaxfreeAmt + unitTaxfreeAmt;
	totalTaxableAmt = totalTaxableAmt + unitTaxableAmt;
	totalVatAmt		= totalVatAmt + unitVatAmt;
	
	//주문정보를 구성하기 위한 상품들 누적 결제 금액(상품결제금액)  
	totalProductPaymentAmt = totalProductPaymentAmt + productPaymentAmt; // 주문상품 총 금액
	
	
	//상품값으로 읽은 변수들로 Json String 을 작성합니다.
	List<Map<String,Object>> orderProducts = new ArrayList<Map<String,Object>>();
	
	Map<String,Object> productInfo = new HashMap<String,Object>(); 
	productInfo.put("cpId", cpId);														//[필수]상점ID
	productInfo.put("productId", productId);											//[필수]상품ID
	productInfo.put("productAmt", productAmt);											//[필수]상품금액(상품단가 * 수량)
	productInfo.put("productPaymentAmt", productPaymentAmt);							//[필수]상품결제금액(상품결제단가 * 수량)
	productInfo.put("orderQuantity", orderQuantity);									//[필수]주문수량(배송비 상품인 경우 1로 셋팅)
	productInfo.put("option", iOption);													//[선택]상품 옵션
	productInfo.put("sortOrdering", sortOrdering);										//[필수]상품 노출순서
	productInfo.put("productName", productName);										//[필수]상품명
	productInfo.put("orderConfirmUrl", orderConfirmUrl);								//[선택]주문완료 후 주문상품을 확인할 수 있는 URL
	productInfo.put("orderConfirmMobileUrl", orderConfirmMobileUrl); 					//[선택]주문완료 후 주문상품을 확인할 수 있는 모바일 URL
	productInfo.put("productImageUrl", productImageUrl);								//[선택]이미지 URL(배송비 상품이 아닌 경우는 필수)
	productInfo.put("sellerOrderProductReferenceKey", sellerOrderProductReferenceKey);	//[필수]외부가맹점에서 관리하는 주문상품 연동 키
	productInfo.put("taxationType", taxationType);										//[선택]과세타입(면세상품 : DUTYFREE, 과세상품 : TAXATION (기본), 결합상품 : COMBINE)
	orderProducts.add(productInfo);
	/*=====================================================================================================*/	
	
	
			
	/*======== 주문정보 변수 선언 ========*/
	int totalOrderAmt, totalPaymentAmt;
	String sellerOrderReferenceKey;
	String sellerOrderReferenceKeyType;
	String iCurrency;
	String orderSheetUiType;
	String orderTitle;
	String orderMethod;
	String returnUrl;
	String returnUrlParam;
	String nonBankbookDepositInformUrl;
	String orderChannel;
	String inAppYn;
	String individualCustomNoInputYn;
	String payMode;
	String serviceUrlParam;
	/*=====================================*/
			
	/*==== 주문정보 값 입력(가맹점 수정 가능 부분) ========================================================*/		
	sellerOrderReferenceKey 	= customerOrderNumber;						 //[필수]외부가맹점의 주문번호
	sellerOrderReferenceKeyType = "UNIQUE_KEY";							 	 //[선택]외부가맹점의 주문번호 타입(UNIQUE_KEY : 기본값, DUPLICATE_KEY : 중복가능한 키->외부가맹점의 주문번호가 중복 가능한 경우 사용)
	iCurrency 					= "KRW";									 //[선택]통화(default=KRW)
	totalPaymentAmt 			= totalProductPaymentAmt;			 		 //[필수]총 결재 할 금액
	orderTitle 					= "결제 테스트";			 	 			 	 //[선택]주문 타이틀
	returnUrl 					= domainName+"/payco_return.jsp"; 		 	 //[선택]주문완료 후 Redirect 되는 Url
	returnUrlParam 				= "{\"taxationType\":\""+taxationType+"\",\"totalTaxfreeAmt\":\""+totalTaxfreeAmt+"\",\"totalTaxableAmt\":\""+totalTaxableAmt+"\",\"totalVatAmt\":\""+totalVatAmt+"\"}";	//[선택]주문완료 후 Redirect 되는 URL과 함께 전달되어야 하는 파라미터(Json 형태의 String)
	serviceUrlParam = "{\"serviceParam_productId\":\"JSP_SAMPLE_EASYPAY_BACK\",\"taxationType\":\""+taxationType+"\",\"totalTaxfreeAmt\":\""+totalTaxfreeAmt+"\",\"totalTaxableAmt\":\""+totalTaxableAmt+"\",\"totalVatAmt\":\""+totalVatAmt+"\"}"; //[선택]주문완료 시 호출되는 API 와 함께 전달되어야 하는 파라미터(Json 형태의 String)(PAY1)
	nonBankbookDepositInformUrl = domainName+"/payco_without_bankbook.jsp";  //[선택]무통장입금완료통보 URL
	orderMethod					= "EASYPAY";								 //[필수]주문유형
	orderChannel 				= "PC";										 //[선택]주문채널 (default : PC/MOBILE)
	inAppYn 					= "N";										 //[선택]인앱결제 여부(Y/N) (default = N)
	individualCustomNoInputYn 	= "N";										 //[선택]개인통관고유번호 입력 여부 (Y/N) (default = N)
	orderSheetUiType 			= "GRAY";									 //[선택]주문서 UI 타입 선택(선택 가능값 : RED/GRAY)
	payMode						= "PAY2";									 //[선택]결제모드(PAY1 : 결제인증,승인통합 / PAY2 : 결제인증,승인분리)
																			 // payMode는 선택값이나 값을 넘기지 않으면 DEFALUT 값은 PAY1 으로 셋팅되어있습니다.
	
	//설정한 주문정보로 Json String 을 작성합니다.		
	Map<String,Object> orderInfo = new HashMap<String,Object>();
	orderInfo.put("sellerKey", sellerKey);										//[필수]가맹점 코드
	orderInfo.put("sellerOrderReferenceKey", sellerOrderReferenceKey); 			//[필수]외부가맹점 주문번호
	orderInfo.put("sellerOrderReferenceKeyType", sellerOrderReferenceKeyType);  //[선택]외부가맹점의 주문번호 타입
	orderInfo.put("currency", iCurrency);										//[선택]통화
	orderInfo.put("totalPaymentAmt", totalPaymentAmt);							//[필수]총 결제금액(면세금액,과세금액,부가세의 합) totalTaxfreeAmt + totalTaxableAmt + totalVatAmt
	orderInfo.put("totalTaxfreeAmt", totalTaxfreeAmt);							//[선택]면세금액(면세상품의 공급가액 합)
	orderInfo.put("totalTaxableAmt", totalTaxableAmt);							//[선택]과세금액(과세상품의 공급가액 합)
	orderInfo.put("totalVatAmt", totalVatAmt);									//[선택]부가세(과세상품의 부가세액 합)
	orderInfo.put("serviceUrlParam", serviceUrlParam);
	orderInfo.put("orderTitle", orderTitle); 									//[필수]주문 타이틀
	orderInfo.put("returnUrl", returnUrl);										//[필수]주문완료 후 Redirect 되는 URL
	orderInfo.put("returnUrlParam", returnUrlParam);							//[선택]주문완료 후 Redirect 되는 URL과 함께 전달되어야 하는 파라미터(Json 형태의 String)
	orderInfo.put("nonBankbookDepositInformUrl", nonBankbookDepositInformUrl); 	//[선택]무통장입금완료 통보 URL
	orderInfo.put("orderMethod", orderMethod);									//[필수]주문유형
	orderInfo.put("orderChannel", orderChannel);								//[선택]주문채널
	orderInfo.put("inAppYn", "N");												//[선택]인앱결제 여부
	orderInfo.put("individualCustomNoInputYn", individualCustomNoInputYn);		//[선택]개인통관 고유번호 입력 여부
	orderInfo.put("orderSheetUiType", orderSheetUiType);						//[선택]주문서 UI타입 선택
	orderInfo.put("payMode", payMode);											//[선택]결제모드(PAY1 : 결제인증,승인통합 / PAY2 : 결제인증,승인분리) DEFAULT : PAY1
	orderInfo.put("orderProducts", orderProducts); 								//[필수]주문상품 리스트
	
	
	/* 부가정보(extraData) - Json 형태의 String */
	Map<String,Object> extraData = new HashMap<String,Object>(); 
	//해당주문예약건 만료처리일자(해당일 이후에는 결제불가)
	extraData.put("payExpiryYmdt", "20191231180000");							//[선택]해당주문예약건 만료처리일자(14자리로 맞춰주세요)
																				//가맹점 상황에따라 필요한경우가 아니라면 해당 파라미터는 삭제하여 주세요.
	//가상계좌만료일시(YYYYMMDD or YYYYMMDDHHmmss형태로 넣는다)
	extraData.put("virtualAccountExpiryYmd", "20191231180000");					//[선택]가상계좌만료일시(Default 3일, YYYYMMDD일경우 그날 24시까지)
																				//가맹점 에서 무통장입금을 사용하지 않으시면 해당 파라미터는 삭제하여 주세요.
	//appUrl
	extraData.put("appUrl", "testapp://open");									//[IOS필수]IOS 인앱 결제시 ISP 모바일 등의 앱에서 결제를 처리한 뒤 복귀할 앱 URL
																				//AOS(안드로이드) 에서는 필수사항이 아니므로 삭제하여 주세요.
	
	//모바일 결제페이지에서 취소 버튼 클릭시 이동할 URL (결제창 이전 URL 등) 
	//1순위 : 주문예약 > extraData > cancelMobileUrl 값이 있을시 => cancelMobileUrl 이동
	//2순위 : 주문예약시 전달받은 returnUrl 이동 + 실패코드(오류코드:2222)
	//3순위 : 가맹점 URL로 이동(가맹점등록시 받은 사이트URL)
	//4순위 : 이전 페이지로 이동 => history.Back();
	extraData.put("cancelMobileUrl", "http://www.payco.com");					//[선택][모바일 일경우 필수]모바일 결제페이지에서 취소 버튼 클릭시 이동할 URL
	
	Map<String,Object> viewOptions = new HashMap<String,Object>();
	viewOptions.put("showMobileTopGnbYn", "N");									//[선택]모바일 상단 GNB 노출여부
	viewOptions.put("languageCode", "KR");										//[선택]주문서 언어 코드 (default KR) - EN/KR
	viewOptions.put("iframeYn", "N");											//[선택]Iframe 호출(모바일에서 접근하는경우 iframe 사용시 이값을 "Y"로 보내주셔야 합니다.)
																				// Iframe 사용시 연동가이드 내용중 [Iframe 적용가이드]를 참고하시길 바랍니다.
	extraData.put("viewOptions", viewOptions);									//[선택]화면 UI 옵션
																				
	orderInfo.put("extraData",  mapper.writeValueAsString(extraData));	//[선택]부가정보 - Json 형태의 String
		
	//주문예약 API 호출 함수
	String result = util.payco_reserve(orderInfo,logYn);
	
	try {
	    PrintWriter pw;
	    pw = response.getWriter();
	    response.setContentType("application/json; charset=utf-8");
	    pw.print(result);
	    pw.flush();
	    pw.close();
	    
	} catch (IOException e) {
		e.printStackTrace();
	}

%>