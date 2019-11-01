<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
java.text.SimpleDateFormat dateformat = new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss");

/* 개발용 간편결제 */
String sellerKey 			= "S0FSJE";      	// 가맹점 코드 - 파트너센터에서 알려주는 값으로, 초기 연동 시 PAYCO에서 쇼핑몰에 값을 전달한다.
String cpId 				= "PARTNERTEST";	// 상점ID
String productId 			= "PROD_EASY";		// 상품ID
String deliveryId 			= "DELIVERY_PROD";	// 배송비상품ID
String deliveryReferenceKey = "DV0001";			// 가맹점에서 관리하는 배송비상품 연동 키
String serverType 			= "DEV";			// 서버유형. DEV:개발, REAL:운영
String logYn 				= "Y";				// 로그Y/N


//도메인명 or 서버IP  
String domainName = "http://127.0.0.1:8080/payco";

boolean isMobile;
String userAgent = request.getHeader("user-agent");
boolean mobile1 = userAgent.matches(".*(iPhone|iPod|Android|Windows CE|BlackBerry|Symbian|Windows Phone|webOS|Opera Mni|Opera Mobi|POLARIS|IEMobile|lgtelecom|nokia|SonyEricsson).*");
boolean mobile2 = userAgent.matches(".*(LG|SAMSUNG|Samsung).*");
if(mobile1||mobile2){
	isMobile = true;
}else{
	isMobile = false;
}
%>

<script>

</script>