<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="common_include.jsp" %>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
<meta http-equiv="X-UA-Compatible" content="IE=Edge">
<meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0">

<meta name="keyword" content="컨텐츠">

<title>간편결제(pay2) 테스트페이지</title>

<link href="../../../share/css/common.css" rel="stylesheet" type="text/css">

<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
<!--
<script src="/share/js/requirejs/require.js"></script>
<script src="/share/js/requirejs/require.config.js"></script>
-->
<script type="text/javascript" src="https://static-bill.nhnent.com/payco/checkout/js/payco.js" charset="UTF-8"></script>
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script type="text/javascript">

// 주문예약 validation check
function order_chk(){
	
	if($(".payco input:radio[name=sort]:checked").val() == null){
		alert("결제방식을 선택하세요.");		
		return;
	}else{
		if($(".payco input:radio[name=sort]:checked").val() == "payco"){
			callPaycoUrl();
			return;
		}else{
			alert($(".payco input:radio[name=sort]:checked").val());
			return;
		}	
	}
}


//외부가맹점의 주문 관리번호 얻기
function randomStr(){
	
	var randomStr = "";
	
	for(var i=0;i<10;i++){
		randomStr += Math.ceil(Math.random() * 9 + 1);
	}
	
	randomStr = "TEST" + randomStr;
	
	return randomStr;
}

// 주문예약
function callPaycoUrl(){
	
  	var customerOrderNumber = "pnr1234567890";
	var productName = "테스트ProductName";
	var productUnitPrice = "12345";
	var sellerOrderProductReferenceKey = "pnr1234567890";
	
	var Params = 	"customerOrderNumber=" + customerOrderNumber +
					"&productUnitPrice=" + productUnitPrice +
					"&productName=" + productName +
					"&sellerOrderProductReferenceKey=" + sellerOrderProductReferenceKey +
					"";


    // localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류 
    $.support.cors = true;

	/* + "&" + $('order_product_delivery_info').serialize() ); */
	$.ajax({
		type: "POST",
		url: "<%=domainName%>/payco_reserve_json.do",
		data: Params,		// JSON 으로 보낼때는 JSON.stringify(customerOrderNumber)
		contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		dataType:"json",
		success:function(data){
			    
			if(data.code == '0') {
				//console.log(data.result.reserveOrderNo);
				alert("주문예약 성공! \n결제를 진행해 주세요!");
				$('#order_num').val(data.result.reserveOrderNo);
				$('#order_url').val(data.result.orderSheetUrl);
				$('#order_sellerOrderReferenceKey').val(customerOrderNumber);
			}else{
				alert("code : " + data.code + "\n" + "message : " + data.message);
			}
		},
        error: function(request,status,error) {
            //에러코드
            alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			return false;
        }
	});
}

// 결제하기
function order(){
	
	var order_Url = $('#order_url').val(); 
	
	if(order_Url == ""){
		alert(" 주문예약이 되어있지 않습니다. \n 주문예약을 먼저 실행 해 주세요.");
		return;
	}
	
	if(<%=isMobile%>){
		location.href = order_Url;
	}else{
		window.open(order_Url, 'popupPayco', 'top=100, left=300, width=727px, height=512px, resizble=yes, scrollbars=yes'); 
	}
}


// 팝업차단시 차단메시지 안뜨고 열리게 하는 방법
function payco_direct_open(){

	var customerOrderNumber = "pnr1234567890"; 					// pnr 넘버 사용 예정
	var productName = "테스트ProductName";						// 상품명
	var productUnitPrice = "12345";								// 가격
	var sellerOrderProductReferenceKey = "pnr1234567890";		// pnr 넘버 사용 예정
	var payExpiryYmdt = '20191231180000';						// 결제만료시간

	var Params = 	 "customerOrderNumber=" + customerOrderNumber +
					"&productUnitPrice=" + productUnitPrice +
					"&productName=" + productName +
					"&sellerOrderProductReferenceKey=" + sellerOrderProductReferenceKey +
					"&payExpiryYmdt=" + payExpiryYmdt +
					"";

	window.open("<%=domainName%>/payco_popup.do?"+Params, 'popupPayco', 'top=100, left=300, width=727px, height=512px, resizble=no, scrollbars=yes');
}
function payco_end(){
	$('#btn_easyPay').html("결제완료");
	$('#btn_easyPay').attr("disabled", true);
}

</script>

<style type="text/css">
	#sort {
		width:13px; 
		height:13px; 
		margin:0 0 2px; 
		padding:0; 
		border: 1px solid #FFF; 
		vertical-align:middle;
	}
</style>

</head>
<body>

<div id="header">
	<div class="gnb" id="gognb">
		<div class="wrap">
			<ul class="gognb" >
				<li><h3>간편결제(EASYPAY - PAY2)</h3></li>
			</ul>
		</div>
	</div>
</div>
	
<div id="container" class="clearfix">
	<div class="main_fix_wrap easyPay_wrap">
		<table style="display: none" cellspacing="0" cellpadding="0" class="tbl_std">
			<colgroup>
				<col width="9%">
				<col width="46%">
				<col width="10%">
				<col width="10%">
				<col width="10%">
				<col width="15%">
			</colgroup>
			<thead>
				<tr>
					<th colspan="2" class="fst left">상품정보</th>
					<th>수량</th>
					<th>상품금액</th>
					<th>적립금</th>
					<th>주문금액</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td class="fst">
						<img src="/share/img/nike.jpg" alt="" width="80" height="80">
					</td>
					<td class="left">
						<p>[GLOBE] TILT KIDS (NAVY/ORANGE)</p>
						<p>옵션 : 280</p>
					</td>
					<td>1</td>
					<td>
						<p>79,000 원</p>
					</td>
					<td class="bg_sum">0원</td>
					<td class="bg_sum txt_sum text_bold">79,000 원</td>
				</tr>
				<tr>
					<td class="fst left" colspan="4">
					</td>
					<td colspan="2" class="bg_total left">
						<ul class="total_wrap">
							<li><p>총상품금액</p><strong>79,000원</strong></li>
							<li><p>총적립금</p><strong>0원</strong></li>
							<li><p>배송비</p><strong>2,500원</strong></li>
							<li><p>결제금액</p><strong class="point">81,500원</strong></li>
						</ul>
					</td>
				</tr>
			</tbody>
		</table>

		<div style="height:30px;"></div>
		<table cellspacing="0" cellpadding="0" class="save_point_wrap">
			<colgroup>
				<col width="78%">
				<col width="22%">
			</colgroup>
			<tbody>
				<tr>
					<td>
						<!-- s:안내 -->
						<table cellspacing="0" cellpadding="0" class="save_point">
							<colgroup>
								<col width="20%">
								<col width="80%">
							</colgroup>
							<tbody>
								<tr>
									<th class="underline">결제방식</th>
									<td class="left underline"> 
										<div class="payco" style="text-align: left;">
										<span><input type="radio"  value="신용카드 결제" name="sort" id="sort1"><label for="sort1">신용카드 결제</label></span>
										<span style= "margin-left: 3px;"><input type="radio"  value="가상 계좌" name="sort" id="sort2"><label for="sort2">가상 계좌</label></span>
										<span style= "margin-left: 3px;"><input type="radio"  value="휴대폰 결제" name="sort" id="sort3"><label for="sort3">휴대폰 결제</label></span>
										<span style= "margin-left: 3px;"><input type="radio"  value="payco" name="sort" id="sort4" checked="checked"></span><span id="payco_btn_type_A1" style="padding-left: 3px;"></span>
									</div>
									</td>
								</tr>
	
								<!-- PAYCO 안내 -->
								<tr id="div_toastpay" class="pay_detail"
									style="height: 148px">
									<th>PAYCO</th>
									<td class="left">
										<ul>
											<li><font color="red"><strong>PAYCO 간편결제 안내</strong></font></li>
											<li>PAYCO는 온/오프라인 쇼핑은 물론 송금, 멤버십 적립까지 가능한 통합 서비스입니다.</li>
											<li>휴대폰과 카드 명의자가 동일해야 결제 가능하며, 결제금액 제한은 없습니다.</li>
											<li>- 지원카드: 모든 국내 신용/체크카드</li>
										</ul>
									</td>
								</tr>
							</tbody>
						</table>
					</td>
				</tr>
			</tbody>
		</table>
		<table align="center" style="margin-top:50px;" >
			<tr>
				<td style="padding:30px; border:solid 1px; display: none;" valign="Top">
					<div class="easyPay_div">주문예약, 결제하기 분리</div>
					<div class="easyPay_div"><button type="button" class="btn easyPay_btn"  onclick="order_chk();" >주문예약실행</button> </div>
					<div class="easyPay_div">
						<ul>
							<li style="margin:20px 0;">
								<em>가맹점 주문번호 </em>
								<input type="text" class="form-control input_text" name="order_sellerOrderReferenceKey" id="order_sellerOrderReferenceKey" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>예약주문번호 </em>
								<input type="text" class="form-control input_text" name="order_num" id="order_num" value=""  >
							</li>
							<li>
								<em>주문창URL </em>
								<input type="text" class="form-control input_text" name="order_url" id="order_url" value=""  >
							</li>
						</ul>
					</div>	
					<div class="easyPay_div"><button type="button" class="btn easyPay_btn"  onclick="order();" >결제하기( PC-팝업, MOBILE-리다이렉트 )</button> </div>
				</td>
				<td width="50" style="padding:10px; display: none;">
				</td>
				<td style="padding:30px; border:solid 1px;" valign="Top">
					<ul>
						<li style="margin:20px 0;">
							<em>customerOrderNumber</em>
							<input type="text" class="form-control input_text" name="input-customerOrderNumber" id="input-customerOrderNumber" value="pnr1234567890">
						</li>
						<li style="margin:20px 0;">
							<em>productName </em>
							<input type="text" class="form-control input_text" name="input-productName" id="input-productName" value="테스트ProductName">
						</li>
						<li style="margin:20px 0;">
							<em>productUnitPrice </em>
							<input type="text" class="form-control input_text" name="input-productUnitPrice" id="input-productUnitPrice" value="12345">
						</li>
						<li style="margin:20px 0;">
							<em>sellerOrderProductReferenceKey </em>
							<input type="text" class="form-control input_text" name="input-sellerOrderProductReferenceKey" id="input-sellerOrderProductReferenceKey" value="pnr1234567890">
						</li>
						<li style="margin:20px 0;">
							<em>payExpiryYmdt </em>
							<input type="text" class="form-control input_text" name="input-payExpiryYmdt" id="input-payExpiryYmdt" value="20191231180000">
						</li>
					</ul>
					<div class="easyPay_div" ><button type="button" class="btn easyPay_btn" id="btn_easyPay" onclick="payco_direct_open();">결제하기</button> </div>
				</td>
				<td style="padding:30px; border:solid 1px;" valign="Top">
					<div class="easyPay_div">
						<ul>
							<li style="margin:20px 0;">
								<em>reserveOrderNo</em>
								<input type="text" class="form-control input_text" name="input-reserveOrderNo" id="input-reserveOrderNo" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>sellerOrderReferenceKey </em>
								<input type="text" class="form-control input_text" name="input-sellerOrderReferenceKey" id="input-sellerOrderReferenceKey" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>mainPgCode </em>
								<input type="text" class="form-control input_text" name="input-mainPgCode" id="input-mainPgCode" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>totalPaymentAmt </em>
								<input type="text" class="form-control input_text" name="input-totalPaymentAmt" id="input-totalPaymentAmt" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>totalRemoteAreaDeliveryFeeAmt </em>
								<input type="text" class="form-control input_text" name="input-totalRemoteAreaDeliveryFeeAmt" id="input-totalRemoteAreaDeliveryFeeAmt" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>discountAmt </em>
								<input type="text" class="form-control input_text" name="input-discountAmt" id="input-discountAmt" value=""  >
							</li>
							<li>
								<em>pointAmt </em>
								<input type="text" class="form-control input_text" name="input-pointAmt" id="input-pointAmt" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>paymentCertifyToken </em>
								<input type="text" class="form-control input_text" name="input-paymentCertifyToken" id="input-paymentCertifyToken" value=""  >
							</li>
							<li style="margin:20px 0;">
								<em>bid</em>
								<input type="text" class="form-control input_text" name="input-bid" id="input-bid" value=""  >
							</li>
						</ul>
					</div>
				</td>
			</tr>
		</table>
	</div>
	<div style="height:100px"></div>
</div>
	
<script type="text/javascript">
	  Payco.Button.register({
		SELLER_KEY:'S0FSJE',
		ORDER_METHOD:"EASYPAY",
		/* ORDER_METHOD:"CHECKOUT", */
		BUTTON_TYPE:"A1",
		BUTTON_HANDLER:order,
		DISPLAY_PROMOTION:"Y",
		DISPLAY_ELEMENT_ID:"payco_btn_type_A1",
		"":""
	  });
	  
	  
</script>
</body>
</html>
