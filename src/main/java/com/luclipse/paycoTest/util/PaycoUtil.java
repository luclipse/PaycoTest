 package com.luclipse.paycoTest.util;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import javax.net.ssl.HttpsURLConnection;

/**-----------------------------------------------------------------------
 * 페이코 연동 유틸리티
 *------------------------------------------------------------------------
 * @Class PaycoUtil
 * @author PAYCO기술지원<dl_payco_ts@nhnent.com>
 * @version 1.0
 * @Description 
 */

public class PaycoUtil {


	private static final String FILE_PATH   		  = "C:/logs";
	private static final String PAY1_FILE_PATH    = "C:/logs/pay1";

	public static String SELLER_KEY 		= "SRT_TICKET";				// 가맹점 ID
	public static String CP_ID 				= "SRT_TICKET";				// 상점 ID
	public static String PRODUCT_ID			= "SRT_TICKET_EASYP";		// 상품 ID

	private String RESERVE_URI    			= "";  // 주문예약
	private String APPROVAL_URI				= "";  // 주문승인
	private String CANCEL_URI      			= "";  // 주문취소
	private String CANCEL_CHECK_URI   		= "";  // 취소가능여부
	private String UPDATE_STATUS_URI		= "";  // 주문 상태변경
	private String CANCEL_MILEAGE_URI		= "";  // 마일리지 취소
	private String CHECK_USABILITY_URI		= "";  // 연동 키 유효성 체크
	private String VARIFY_PAYMENT_URI		= "";  // 주문 상세 조회
	
	/* PAYCO 로그인 */
	private String AUTHORIZATION_URI		 = "";	// Payco 로그인 인증(샘플에서는 login.jsp 에서 submit)
	private String ACCESS_TOKEN_URI			 = "";	// AccessToken 발급 요청
	private String FRIENDS_TOKEN_URI		 = "";	// 회원정보 요청
	private String VERIFY_TOKEN_URI			 = "";	// AccessToken 유효 확인
	private String REMOVE_SERVICE_OFFER_URI = "";	// 개인정보 제공 동의 철회
	
	//생성자
	public PaycoUtil(String serverType){
		
		if(serverType.equals("DEV")){
			RESERVE_URI 			 = "https://alpha-api-bill.payco.com/outseller/order/reserve";
			APPROVAL_URI			 = "https://alpha-api-bill.payco.com/outseller/payment/approval";
			CANCEL_URI 				 = "https://alpha-api-bill.payco.com/outseller/order/cancel";
			CANCEL_CHECK_URI 		 = "https://alpha-api-bill.payco.com/outseller/order/cancel/checkAvailability";
			UPDATE_STATUS_URI 		 = "https://alpha-api-bill.payco.com/outseller/order/updateOrderProductStatus";
			CANCEL_MILEAGE_URI 		 = "https://alpha-api-bill.payco.com/outseller/order/cancel/partMileage";
			CHECK_USABILITY_URI 	 = "https://alpha-api-bill.payco.com/outseller/code/checkUsability";
			VARIFY_PAYMENT_URI  	 = "https://alpha-api-bill.payco.com/outseller/payment/approval/getDetailForVerify";
			
			AUTHORIZATION_URI		 = "https://alpha-id.payco.com/oauth2.0/authorize";
			ACCESS_TOKEN_URI		 = "https://demo-id.payco.com/oauth2.0/token";
			FRIENDS_TOKEN_URI 		 = "https://dev-apis.krp.toastoven.net/payco/friends/getMemberProfileByFriendsToken.json";
			VERIFY_TOKEN_URI 		 = "https://dev-apis.krp.toastoven.net/payco/friends/getIdNoByFriendsToken.json";
			REMOVE_SERVICE_OFFER_URI = "https://dev-apis.krp.toastoven.net/payco/friends/removeServiceOfferByIdNoAndConsumerKeyAndServiceProviderCode.json";
		
		} else if(serverType.equals("REAL")){
			RESERVE_URI 			 = "https://api-bill.payco.com/outseller/order/reserve";
			APPROVAL_URI			 = "https://api-bill.payco.com/outseller/payment/approval";
			CANCEL_URI 				 = "https://api-bill.payco.com/outseller/order/cancel";
			CANCEL_CHECK_URI 		 = "https://api-bill.payco.com/outseller/order/cancel/checkAvailability";
			UPDATE_STATUS_URI 		 = "https://api-bill.payco.com/outseller/order/updateOrderProductStatus";
			CANCEL_MILEAGE_URI 		 = "https://api-bill.payco.com/outseller/order/cancel/partMileage";
			CHECK_USABILITY_URI 	 = "https://api-bill.payco.com/outseller/code/checkUsability";
			VARIFY_PAYMENT_URI  	 = "https://api-bill.payco.com/outseller/payment/approval/getDetailForVerify";
			
			AUTHORIZATION_URI		 = "https://id.payco.com/oauth2.0/authorize";
			ACCESS_TOKEN_URI		 = "https://id.payco.com/oauth2.0/token";
			FRIENDS_TOKEN_URI		 = "https://apis3.krp.toastoven.net/payco/friends/getMemberProfileByFriendsToken.json";
			VERIFY_TOKEN_URI 		 = "https://apis3.krp.toastoven.net/payco/friends/getIdNoByFriendsToken.json";
			REMOVE_SERVICE_OFFER_URI = "https://apis3.krp.toastoven.net/payco/friends/removeServiceOfferByIdNoAndConsumerKeyAndServiceProviderCode.json";
		}
	}
	
	ObjectMapper mapper = new ObjectMapper();
	java.text.SimpleDateFormat dateformat = new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss");
	
	/**
	 * 주문예약
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	
	public String payco_reserve(Map<String, Object> map, String logYn){ 
		
	    String returnStr = "";
	    
	    try {
	    	
	    	returnStr = getSSLConnection( RESERVE_URI, mapper.writeValueAsString(map));
	    	
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문예약요청] " +"[callUrl :" + RESERVE_URI +" ] " + mapper.writeValueAsString(map), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문예약결과] " + returnStr, logYn);
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 결제승인
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_approval(Map<String, Object> map, String logYn){
		
	    String returnStr = "";
	    
	    try {
	    	
	    	returnStr = getSSLConnection( APPROVAL_URI, mapper.writeValueAsString(map));
	    	
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문결제 승인요청] " +"[callUrl :" + APPROVAL_URI +" ] " + mapper.writeValueAsString(map), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문결제 승인결과] " + returnStr, logYn);
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 주문취소
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_cancel(Map<String, Object> map, String logYn, String networkCancel){
		String returnStr = "";
		
		try {
	    	returnStr = getSSLConnection( CANCEL_URI, mapper.writeValueAsString(map));
	    	
	    	if(networkCancel.equals("Y")){
	    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][망 취소 요청] " +"[callUrl :" + CANCEL_URI +" ] " + mapper.writeValueAsString(map), logYn);
	    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][망 취소 결과] " + returnStr, logYn);
	    	}else{
	    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문취소요청] " +"[callUrl :" + CANCEL_URI +" ] " + mapper.writeValueAsString(map), logYn);
	    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문취소결과] " + returnStr, logYn);
	    	}
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
		
		return returnStr;
	}
	
	
	/**
	 * 주문취소검사
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_cancel_check(Map<String, Object> map, String logYn){
		String returnStr = "";
		
		try {
	    	returnStr = getSSLConnection( CANCEL_CHECK_URI, mapper.writeValueAsString(map));
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문취소검사요청] " +"[callUrl :" + CANCEL_CHECK_URI +" ] " + mapper.writeValueAsString(map), logYn);
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문취소검사결과] " +"[callUrl :" + CANCEL_CHECK_URI +" ] " + returnStr, logYn);
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
		
		return returnStr;
	}
	
	
	/**
	 * 주문상태 변경
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_upstatus(Map<String, Object> map, String logYn){
		String returnStr = "";
		
		try {
			returnStr = getSSLConnection( UPDATE_STATUS_URI, mapper.writeValueAsString(map));
			makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문상태변경요청] " +"[callUrl :" + UPDATE_STATUS_URI +" ] " + mapper.writeValueAsString(map), logYn);
			makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][주문상태변경결과] " +"[callUrl :" + UPDATE_STATUS_URI +" ] " + returnStr, logYn);
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
		
		return returnStr;
	}
	
	/**
	 * 마일리지 적립취소
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_cancelmileage(Map<String, Object> map, String logYn){
		String returnStr = "";
		
		try {
	    	returnStr = getSSLConnection( CANCEL_MILEAGE_URI, mapper.writeValueAsString(map));
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][마일리지적립취소요청] " +"[callUrl :" + CANCEL_MILEAGE_URI +" ] " + mapper.writeValueAsString(map), logYn);
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][마일리지적립취소결과] " +"[callUrl :" + CANCEL_MILEAGE_URI +" ] " + returnStr, logYn);
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
		
		return returnStr;
	}
	
	/**
	 * 가맹점별 연동키 유효성 체크
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_keycheck(Map<String, Object> map, String logYn){
		String returnStr = "";
		
		try {
	    	returnStr = getSSLConnection( CHECK_USABILITY_URI, mapper.writeValueAsString(map));
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][가맹점별연동키유효성체크요청] " +"[callUrl :" + CHECK_USABILITY_URI +" ] " + mapper.writeValueAsString(map), logYn);
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][가맹점별연동키유효성체크결과] " +"[callUrl :" + CHECK_USABILITY_URI +" ] " + returnStr, logYn);
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
		
		return returnStr;
	}
	
	/**
	 * 결제상세 조회(검증용)
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_verifyPayment(Map<String, Object> map, String logYn){
		
	    String returnStr = "";
	    
	    try {
	    	returnStr = getSSLConnection( VARIFY_PAYMENT_URI, mapper.writeValueAsString(map));
    		
	    	makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][결제상세 조회 요청] " +"[callUrl :" + VARIFY_PAYMENT_URI +" ] " + mapper.writeValueAsString(map), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][결제상세 조회 결과] " + returnStr, logYn);
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 소셜로그인 access_token 발급
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_getAccessToken(String params, String logYn){ 
		
	    String returnStr = "";
	    
	    try {
	    	
	    	returnStr = getSSLConnection_AccessToken( ACCESS_TOKEN_URI, params);
	    	
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][access_token 발급] " +"[callUrl :" + ACCESS_TOKEN_URI +" ] " + mapper.writeValueAsString(params), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][access_token 발급 결과] " + returnStr, logYn);
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 소셜로그인 회원정보 요청
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_getProfile(Map<String, Object> map, String logYn){ 
		
	    String returnStr = "";
	    
	    try {
	    	String client_id = (String)map.get("client_id");
	    	String access_token = (String)map.get("access_token");
	    	returnStr = getSSLConnection_Header( FRIENDS_TOKEN_URI, mapper.writeValueAsString(map), client_id, access_token);
	    	
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][회원정보 요청] " +"[callUrl :" + FRIENDS_TOKEN_URI +" ] " + mapper.writeValueAsString(map), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][회원정보 요청 결과] " + returnStr, logYn);
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 소셜로그인 access_token 유효 검사
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_verifyToken(Map<String, Object> map, String logYn){ 
		
	    String returnStr = "";
	    
	    try {
	    	String client_id = (String)map.get("client_id");
	    	String access_token = (String)map.get("access_token");
	    	returnStr = getSSLConnection_Header( VERIFY_TOKEN_URI, mapper.writeValueAsString(map), client_id, access_token);
	    	
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][access_token 유효 검사 요청] " +"[callUrl :" + VERIFY_TOKEN_URI +" ] " + mapper.writeValueAsString(map), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][access_token 유효 검사 결과] " + returnStr, logYn);
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 소셜로그인 access_token 재발급
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_getAccessTokenByRefresh(String params, String logYn){ 
		
	    String returnStr = "";
	    
	    try {
	    	returnStr = getSSLConnection_AccessToken( ACCESS_TOKEN_URI, params);
	    	
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][access_token 재발급 요청] " +"[callUrl :" + ACCESS_TOKEN_URI +" ] " + params, logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][access_token 재발급 결과] " + returnStr, logYn);
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/**
	 * 소셜로그인 개인정보 제공 동의 철회 요청
	 * @param map
	 * @param logYn : Y/N
	 * @return
	 */
	public String payco_removeServiceOffer(Map<String, Object> map, String client_id, String access_token, String logYn){ 
		
	    String returnStr = "";
	    
	    try {
	    	
	    	returnStr = getSSLConnection_Header( REMOVE_SERVICE_OFFER_URI, mapper.writeValueAsString(map), client_id, access_token);
	    	
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][개인정보 제공 동의 철회 요청] " +"[callUrl :" + REMOVE_SERVICE_OFFER_URI +" ] " + mapper.writeValueAsString(map), logYn);
    		makeServiceCheckApiLogFile("[" +dateformat.format(new java.util.Date()) + "][개인정보 제공 동의 철회 요청 결과] " + returnStr, logYn);
	    	
	    } catch (Exception e){
	    	e.printStackTrace();
	    	returnStr = "{\"code\":\"9999\",\"message\":\""+e.getMessage()+"\"}";
	    }
	    return returnStr;
	}
	
	
	/* connection */
	
	public String getSSLConnection(String apiUrl, String arrayObj) throws Exception{
		
		URL url 			   = new URL(apiUrl); 	// 요청을 보낸 URL
		String sendData 	   = arrayObj;
		HttpsURLConnection con = null;
		StringBuffer buf 	   = new StringBuffer();
		String returnStr 	   = "";
		
		try {
			con = (HttpsURLConnection)url.openConnection();
			
			con.setConnectTimeout(30000);		//서버통신 timeout 설정. 페이코 권장 30초
			con.setReadTimeout(30000);			//스트림읽기 timeout 설정. 페이코 권장 30초
			
			con.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
			con.setDoOutput(true);
		    con.setRequestMethod("POST");
		    con.connect();
		    
		    // 송신할 데이터 전송.
		    DataOutputStream dos = new DataOutputStream(con.getOutputStream());
		    dos.write(sendData.getBytes("UTF-8"));
		    dos.flush();
		    dos.close();
		    int resCode = con.getResponseCode();
		    
		    String headerType = con.getContentType();
		    
		    if (resCode == HttpsURLConnection.HTTP_OK) {
		    	BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
				int c;
			    
			    while ((c = br.read()) != -1) {
			    	buf.append((char)c);
			    }
			    returnStr = buf.toString();
			    br.close();
		    } else {
		    	returnStr = "{ \"code\" : 9999, \"message\" : \"Connection Error\" }";
		    }
		    
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			con.disconnect();
		}
		System.out.println("returnStr : " + returnStr);
		return returnStr;
	}
	
	/* AccessToken 발급, 재발급 */
	public String getSSLConnection_AccessToken(String apiUrl, String params) throws Exception{
		
		URL url 			   = new URL(apiUrl); 	// 요청을 보낸 URL
		String sendData 	   = params;
		HttpsURLConnection con = null;
		StringBuffer buf 	   = new StringBuffer();
		String returnStr 	   = "";
		
		try {
			con = (HttpsURLConnection)url.openConnection();
			con.setConnectTimeout(30000);		//서버통신 timeout 설정. 페이코 권장 30초
			con.setReadTimeout(30000);			//스트림읽기 timeout 설정. 페이코 권장 30초
			
			con.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
			con.setDoOutput(true); 
		    con.setRequestMethod("POST");
		    con.connect();
		    
		    // 송신할 데이터 전송.
		    DataOutputStream dos = new DataOutputStream(con.getOutputStream());
		    dos.write(sendData.getBytes("UTF-8"));
		    dos.flush();
		    dos.close();
		    int resCode = con.getResponseCode();
		    if (resCode == HttpsURLConnection.HTTP_OK) {
		    	BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
				int c;
			    
			    while ((c = br.read()) != -1) {
			    	buf.append((char)c);
			    }
			    returnStr = buf.toString();
			    br.close();
		    } else {
		    	returnStr = "{ \"code\" : 9999, \"message\" : \"Connection Error\" }";
		    }
		    
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			con.disconnect();
		}
		
		return returnStr;
	}
	
	/* 헤더정보 필요한 connection */
	public String getSSLConnection_Header(String apiUrl, String arrayObj, String client_id, String access_token) throws Exception{
	
		URL url 			   = new URL(apiUrl); 	// 요청을 보낸 URL
		String sendData 	   = arrayObj;
		HttpsURLConnection con = null;
		StringBuffer buf 	   = new StringBuffer();
		String returnStr 	   = "";
		
		try {
			con = (HttpsURLConnection)url.openConnection();
			con.setConnectTimeout(30000);		//서버통신 timeout 설정. 페이코 권장 30초
			con.setReadTimeout(30000);			//스트림읽기 timeout 설정. 페이코 권장 30초
			con.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
			con.setDoOutput(true);
		    con.setRequestMethod("POST");
		    con.setRequestProperty("client_id", client_id);
		    con.setRequestProperty("access_token", access_token);
		    con.connect();
		    
		    // 송신할 데이터 전송.
		    DataOutputStream dos = new DataOutputStream(con.getOutputStream());
		    dos.write(sendData.getBytes("UTF-8"));
		    dos.flush();
		    dos.close();
		    int resCode = con.getResponseCode();
		    if (resCode == HttpsURLConnection.HTTP_OK) {
		    	BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
				int c;
			    
			    while ((c = br.read()) != -1) {
			    	buf.append((char)c);
			    }
			    returnStr = buf.toString();
			    br.close();
		    } else {
		    	returnStr = "{ \"code\" : 9999, \"message\" : \"Connection Error\" }";
		    }
		    
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			con.disconnect();
		}
		
		return returnStr;
	}
	
	// 로그 파일 생성
	public static void makeServiceCheckApiLogFile(String logText, String logYn) {
		
		if(logYn.equals("Y")){
			String filePath   = FILE_PATH;
		  	java.text.SimpleDateFormat dateformat = new java.text.SimpleDateFormat("yyyyMMdd HH:mm:ss");
		  	String nowTotDate = dateformat.format(new java.util.Date());
		  	Integer nowdate = Integer.parseInt( nowTotDate.substring(0, 8) );
		   
			String fileName = "service_check_log_" + nowdate + ".txt"; //생성할 파일명
		  	String logPath = filePath + File.separator + fileName; 
		  
		  	File folder = new File(filePath); //로그저장폴더
		  	File f 		= new File(logPath);  //파일을 생성할 전체경로
		  
		  	try{
		  	
		  		if(folder.exists() == false) {
		   			folder.mkdirs();
				}

		   		if (f.exists() == false){
		    		f.createNewFile(); //파일생성
		   		}

		   		// 파일쓰기
		   		FileWriter fw = null;

		   		try {

		   			fw = new FileWriter(logPath, true); //파일쓰기객체생성
		   			fw.write(logText +"\n"); //파일에다 작성

		   		} catch(IOException e) {
		   			throw e;
		   		} finally {
		   			if(fw != null) fw.close(); //파일핸들 닫기
		   		}

		  	}catch (IOException e) { 
		  		e.printStackTrace();
		   		//System.out.println(e.toString()); //에러 발생시 메시지 출력
		  	}
		}else{
			return;
		}
	}
	
	// PAY1 Complete Page 파라미터 전달용 파일생성 
	public static void makeFile(String str, String fileName){
		
		String pay1FilePath = PAY1_FILE_PATH;
		String pay1FileName = fileName +  ".txt"; 	//생성할 파일명
		String fullPath = pay1FilePath + File.separator + pay1FileName;
		
		File folder		= new File(pay1FilePath); 	//로그저장폴더
	  	File f			= new File(fullPath);  		//파일을 생성할 전체경로
		
	  	try {
			if(folder.exists() == false){
				folder.mkdirs();			//폴더생성
			}
			
			if (f.exists() == false){
	    		f.createNewFile(); 			//파일생성
	   		}
			
			// 파일쓰기
	   		FileWriter fw = null;

	   		try {

	   			fw = new FileWriter(fullPath, true);	//파일쓰기객체생성
	   			fw.write(str); 						 	//파일에다 작성

	   		} catch(IOException e) {
	   			throw e;
	   		} finally {
	   			fw.flush();
	   			if(fw != null) fw.close(); //파일핸들 닫기
	   		}
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	  	
	}
	
		
}
