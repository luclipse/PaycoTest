<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
 * 가맹점별 연동키 유효성 체크 페이지(JSP)
 *------------------------------------------------------------------------
 * @Class payco_key_check.jsp
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @since 
 * @version
 * @Description 
 * 해당 상품 정보가 사용이 가능한 코드인지 PAYCO에 조회한다.(usabilityYn = Y/N)
 * param : sellerKey=판매자키(페이코발급), codes=코드 값 리스트
 * return : {"result":[{"codeKind":"CP_ID","codeValue":"PARTNERTEST","usabilityYn":"Y"},{"codeKind":"PRODUCT_ID","codeValue":"PROD_CHK","usabilityYn":"Y"}],"code":0,"message":"success"}    
 */
%>
<%
	String result = "OK"; // 리턴값 초기설정 "OK", 유효성 체크결과 등록되어있지 않은 키일때 리턴값 : "ERROR"
	ObjectMapper mapper = new ObjectMapper();   	 //jackson json object
	PaycoUtil util 		= new PaycoUtil(serverType); //CommonUtil
	
	/*======== 가맹점별 연동키유효성체크 API start ========
	* 해당 예제는 common_include.jsp 파일에 설정된 
	* 상점ID(CP_ID)와 상품ID(PRODUCT_ID)를 사용함. 
	*/
	List<Map<String, Object>> array = new ArrayList<Map<String, Object>>();
	
	for(int i = 0; i < 2; i++){
		Map<String, Object> map = new HashMap<String, Object>();
		if(i == 0){
			map.put("codeKind", "CP_ID");			
			map.put("codeValue", cpId); // 사용가능
			//map.put("codeValue", 2);  // 사용불가
		}
		if(i == 1){
			map.put("codeKind", "PRODUCT_ID");
			map.put("codeValue", productId);
			map.put("upperCodeValue", cpId);
		}
		array.add(map);
	}
	
	Map<String, Object> keyCheck = new HashMap<String, Object>();
	keyCheck.put("sellerKey", sellerKey);
	keyCheck.put("codes", array);
	System.out.println(keyCheck.toString());
	//연동키 유효성체크 API 호출(include file httpConnection.jsp)
	String keyCheckStr = util.payco_keycheck(keyCheck,logYn);
	
	/* 리턴 받은 결과를 분석.  
	* CP_ID, PRODUCT_ID 사용 가능 여부 분석
	* 리턴 받은 값(response)을 JSON 형태로 변경
	* 데이터 확인에 필요한 값을 변수에 담아 처리합니다.
	*/ 	  
		  
	try {
		//연동키 유효성체크 리턴값을 제이슨맵으로 변환
		Map<String, Object> jObject  = mapper.readValue(keyCheckStr, new TypeReference<HashMap<String, Object>>(){});
		
		List<Map<String, Object>> jarray = (List<Map<String, Object>>)jObject.get("result");
		
		for(int k=0; k< jarray.size(); k++){
			Map<String, Object> retKey = (HashMap<String, Object>)jarray.get(k);
			//해당 상품 정보가 PAYCO에 등록되지 않은 상품이라면 사용할 수 없으므로 오류를 리턴
			if( retKey.get("usabilityYn").equals("N") ){
				//out.print("{\"code\":\"9999\",\"message\":\"가맹점 코드값 사용여부에서 에러가 발생했습니다.("+retKey.get("useImpossibleReason")+")\"}");
				result = "ERROR";
			}
		}
		
		 	PrintWriter pw;
		    pw = response.getWriter();
		    response.setContentType("text/html; charset=utf-8");
		    pw.print(result);
		    pw.flush();
		    pw.close();
			
	}catch(Exception e){
		out.print("{\"code\":\"9999\",\"message\":\"가맹점별 연동키유효성체크에서 에러가 발생했습니다.\"}");
		return;
	}
	/*======== 가맹점별 연동키유효성체크 API end ========*/
%>