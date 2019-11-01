<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="common_include.jsp" %>
<%
	
	String orderNo 						  = request.getParameter("orderNo").toString();
	String sellerOrderProductReferenceKey = request.getParameter("sellerOrderProductReferenceKey").toString();
	String orderCertifyKey 				  = request.getParameter("orderCertifyKey").toString();
	String totalCancelTaxfreeAmt 		  = request.getParameter("totalCancelTaxfreeAmt").toString();
	String totalCancelTaxableAmt 		  = request.getParameter("totalCancelTaxableAmt").toString();
	String totalCancelVatAmt 			  = request.getParameter("totalCancelVatAmt").toString();
	String totalCancelPossibleAmt 		  = request.getParameter("totalCancelPossibleAmt").toString();
	String cancelTotalAmt 				  = request.getParameter("cancelTotalAmt").toString();
	String cancelDetailContent 			  = request.getParameter("cancelDetailContent").toString();
	String requestMemo 					  = request.getParameter("requestMemo").toString();
	String reserveOrderNo 				  = request.getParameter("reserveOrderNo").toString();
	String sellerOrderReferenceKey 		  = request.getParameter("sellerOrderReferenceKey").toString();

%>
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

function order_state_modify(){
    // 선택박스 필수 옵션을 체크 함
	if( $('#orderNo_modify').val() == "" ) {
        alert('주문번호를 입력해주세요.');
        return false;
	}

	if( $('#sellerOrderProductReferenceKey_modify').val() == "" ) {
        alert('주문상품연동키를 입력해주세요.');
        return false;
	}

	if( $('#orderProductStatus option:selected').val() == "" ) {
        alert('상태값을 선택해주세요.');
        return false;
    }

    // 선택박스 필수 옵션을 체크 함
    var Params = "orderNo=" 
			   + $('#orderNo_modify').val()
			   + "&sellerOrderProductReferenceKey="
			   + $('#sellerOrderProductReferenceKey_modify').val()
			   + "&orderProductStatus="
			   + $('#orderProductStatus option:selected').val();

	// localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류
    $.support.cors = true;

	/* + "&" + $('order_product_delivery_info').serialize() ); */
	$.ajax({
		type: "POST",
		url: "<%=domainName%>/payco_upstatus.do",
		data: Params,
		contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		dataType:"json",
		success:function(data){
			if(data.code == '0') {
				alert("변경되었습니다.");
			} else {
				alert("code:"+data.code+"\n"+"message:"+data.message);
			}
		},
        error: function(request,status,error) {
            //에러코드
            alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			return false;
        }
	});
}

function cancel_order_all_test(){
	// 선택박스 필수 옵션을 체크 함
	if( $('#orderNo_all').val() == "" ) 		{ alert( '주문 번호를 입력해주세요.' ); 		return false; }
	if( $('#orderCertifyKey_all').val() == "" )	{ alert( '주문 인증 Key를 입력해주세요.' ); 	return false; }
	if( $('#cancelTotalAmt_all').val() == "" ) 	{ alert( '취소할 총 금액을 입력해주세요.' ); 	return false; }

    // 선택박스 필수 옵션을 체크 함
    var Params = "cancelType=ALL"
			   + "&orderNo="
			   + $('#orderNo_all').val()
			   + "&orderCertifyKey="
	   		   + encodeURIComponent($('#orderCertifyKey_all').val())
			   + "&cancelTotalAmt="
			   + $('#cancelTotalAmt_all').val()
			   + "&totalCancelTaxfreeAmt="
			   + $('#totalCancelTaxfreeAmt_all').val()
			   + "&totalCancelTaxableAmt="
			   + $('#totalCancelTaxableAmt_all').val()
			   + "&totalCancelVatAmt="
			   + $('#totalCancelVatAmt_all').val()
			   + "&totalCancelPossibleAmt="
			   + $('#totalCancelPossibleAmt_all').val()
    		   + "&requestMemo="
	   		   + $('#requestMemo_all').val();     

	// localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류
    $.support.cors = true;
	
	/* + "&" + $('order_product_delivery_info').serialize() ); */
	$.ajax({
		type: "POST",
		url: "<%=domainName%>/payco_cancel.do",
		data: Params,
		contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		dataType:"json",
		success:function(data){
			if(data.code == '0') {
				alert("주문이 정상적으로 취소되었습니다.\n( 주문취소번호 : "+data.result.cancelTradeSeq+" )");
				$("#totalCancelPossibleAmt_all").val(data.result.remainCancelPossibleAmt);
			} else {
				alert("code:"+data.code+"\n"+"message:"+data.message);
			}
		},
        error: function(request,status,error) {
            //에러코드
            alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            return false;
        }
	});
}

function cancel_order_part_test(){
	// 선택박스 필수 옵션을 체크 함
	if( $('#orderNo_part').val() == "" ) 						{	alert( '주문번호를 입력해주세요.' );     			return false;	}
	if( $('#orderCertifyKey_part').val() == "" ) 				{	alert( '주문 인증 Key를 입력해주세요.' );     		return false;	}
	if( $('#sellerOrderProductReferenceKey_part').val() == "" )	{   alert( '취소할 주문 상품 번호를 입력해주세요.' );	return false;	}
	if( $('#cancelTotalAmt_part').val() == "" ) 				{	alert( '취소할 총 금액을 입력해주세요.' );			return false;	}
	if( $('#cancelAmt_part').val() == "" ) 						{	alert( '취소상품 금액을 입력해주세요.' );			return false;	}
// 
    // 선택박스 필수 옵션을 체크 함
    var Params = "cancelType=PART" 
			   + "&orderNo="
			   + $('#orderNo_part').val()
			   + "&orderCertifyKey="
			   + encodeURIComponent($('#orderCertifyKey_part').val())
			   + "&cancelTotalAmt="
			   + $('#cancelTotalAmt_part').val()
			   + "&totalCancelTaxfreeAmt="
			   + $('#totalCancelTaxfreeAmt_part').val()
			   + "&totalCancelTaxableAmt="
			   + $('#totalCancelTaxableAmt_part').val()
			   + "&totalCancelVatAmt="
			   + $('#totalCancelVatAmt_part').val()
			   + "&totalCancelPossibleAmt="
			   + $('#totalCancelPossibleAmt_part').val()
			   + "&sellerOrderProductReferenceKey="
			   + $('#sellerOrderProductReferenceKey_part').val()
			   + "&cancelDetailContent="
			   + $('#cancelDetailContent_part').val()
			   + "&cancelAmt="
			   + $('#cancelAmt_part').val()
    		   + "&requestMemo="
	   		   + $('#requestMemo_part').val();

	// localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류
    $.support.cors = true;
	alert(Params);
	/* + "&" + $('order_product_delivery_info').serialize() ); */
	$.ajax({
		type: "POST",
		url: "<%=domainName%>/payco_cancel.jsp",
		data: Params,
		contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		dataType:"json",
		success:function(data){
			if(data.code == '0') {		
				alert("주문이 정상적으로 취소되었습니다.\n( 주문취소번호 : "+data.result.cancelTradeSeq+" / 취소상품금액 : "+data.result.totalCancelPaymentAmt+" )");
				$("#totalCancelPossibleAmt_part").val(data.result.remainCancelPossibleAmt);
			} else {
				alert("code:"+data.code+"\n"+"message:"+data.message);
			}
		},
        error: function(request,status,error) {
            //에러코드
            alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			return false;
        }
	});
}

function mileage_cancel_test(){
    // 선택박스 필수 옵션을 체크 함
	if( $('#orderNo_mile').val() == "" ) {
        alert('주문번호를 입력해주세요.');
        return false;
	}

	if( $('#cancelPaymentAmount_mile').val() == "" ) {
        alert('취소할 주문서의 총 취소 금액을 입력해주세요.\n(마일리지 적립율을 곱한 금액이 취소됩니다.)');
        return false;
	}

    // 선택박스 필수 옵션을 체크 함
    var Params = "orderNo="
			   + $('#orderNo_mile').val()
			   + "&cancelPaymentAmount="
			   + $('#cancelPaymentAmount_mile').val();


	// localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류
    $.support.cors = true;

	/* + "&" + $('order_product_delivery_info').serialize() ); */
	$.ajax({
		type: "POST",
		url: "<%=domainName%>/payco_mileage_cancel.jsp",
		data: Params,
		contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		dataType:"json",
		success:function(data){
			if(data.code == '0') {
					alert("주문이 정상적으로 취소되었습니다.\n( 취소 마일리지 : "+data.result.canceledMileageAcmAmount +", 잔여 마일리지 : "+data.result.remainingMileageAcmAmount+" )");
			} else {
				alert("code:"+data.code+"\n"+"message:"+data.message);
			}
		},
        error: function(request,status,error) {
            //에러코드
            alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			return false;
        }
	});
}

function receipt_go(){
	
	if($("#orderNo_receipt").val() == null || $("#orderNo_receipt").val() == ""){
		alert("주문번호를 입력해주세요.");		
		return;
	}
	
	var orderurl = "https://alpha-bill.payco.com/outseller/receipt/"+$('#orderNo_receipt').val()+"?receiptKind="+$(".payco input:radio[name=receipt]:checked").val();
	alert(orderurl);
	window.open(orderurl, 'receipt_pop','scrollbars=yes');
}	


function verifyPayment() {
	// 선택박스 필수 옵션을 체크 함
	if( $('#verifyPayment_reserveOrderNo').val() == "" ) 			{	alert( 'PAYCO 주문예약번호를 입력해주세요.' );     				return false;	}
	if( $('#verifyPayment_sellerOrderReferenceKey').val() == "" )	{   alert( '외부가맹점에서 발급하는 주문연동키를 입력해주세요.' );	return false;	}

	// 전송 파라미터
	var Params = "reserveOrderNo="
		   		+ $('#verifyPayment_reserveOrderNo').val()
		   		+ "&sellerOrderReferenceKey="
		   		+ $('#verifyPayment_sellerOrderReferenceKey').val();

	// localhost 로 테스트 시 크로스 도메인 문제로 발생하는 오류
    $.support.cors = true;
	
    $.ajax({
		type: "POST",
		url: "<%=domainName%>/payco_verifyPayment.jsp",
		data: Params,
		contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		dataType:"json",
		success:function(data){
			$("#show_verifyPayment").html('<pre style="background-color: #f5deb3">' + JSON.stringify(data,null,'\t') + '</pre>');
		},
        error: function(request,status,error) {
            //에러코드
            alert("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
			return false;
        }
	});

}

// 취소금액 변경시 과세인풋값 셋팅
function inputChange(value, gubun){
	if(value == "" || value == 0){
		alert("취소 금액을 기입하여주세요.");
		if(gubun == "all"){
			$("#cancelTotalAmt_all").focus();
		}else if(gubun == "part"){
			$("#cancelTotalAmt_part").focus();
		}
		return;
	}
	if(gubun == 'all'){
		var cancelTaxableAmt = Math.floor((value / 1.1) + 1);
		var cancelVatAmt     = value - cancelTaxableAmt;
		$("#totalCancelTaxableAmt_all").val(cancelTaxableAmt);
		$("#totalCancelVatAmt_all").val(cancelVatAmt);	
		$("#totalCancelTaxfreeAmt_all").val(0);
	}else if(gubun == "part"){
		var cancelTaxableAmt = Math.floor((value / 1.1) + 1);
		var cancelVatAmt     = value - cancelTaxableAmt;
		$("#totalCancelTaxableAmt_part").val(cancelTaxableAmt);
		$("#totalCancelVatAmt_part").val(cancelVatAmt);
		$("#totalCancelTaxfreeAmt_part").val(0);
	}
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
				<li>
					<h3>간편결제(EASYPAY - PAY2)</h3>
				</li>
				<li>
					<div style="margin-top: 10px;">
						<span>
							<a href="index.jsp"><button id="order_modify_btn"  class="btn btn-default" type="button">INDEX 페이지로 이동</button></a>
						</span>	
					</div>
				</li>
			</ul>
		</div>
	</div>
</div>
	
<div id="container" class="clearfix">
	<div class="main_fix_wrap easyPay_wrap">
		<div class="detail_area">
			<div class="payco">
				<span class="glyphicon glyphicon-menu-down" aria-hidden="true">주문 상태 변경 테스트</span>
				<ul style="border-bottom:none;">
					<li style="margin:20px 0;">
						<em><span style="color: red;">[필수]</span> 주문번호(orderNo)</em>
						<input type="text" class="form-control input_text" name="orderNo_modify" id="orderNo_modify" value="<%=orderNo%>">
						<em><span style="color: red;">[필수]</span> 변경할 주문 상품 연동키(sellerOrderProductReferenceKey)</em>
						<input type="text" class="form-control input_text" name="sellerOrderProductReferenceKey_modify" id="sellerOrderProductReferenceKey_modify" value="<%=sellerOrderProductReferenceKey%>">
						<em><span style="color: red;">[필수]</span> 상태값(orderProductStatus)</em>
						<div class="input-group">
							<select id="orderProductStatus" name="orderProductStatus" class="fs12 gray_03" style="width: 220px">
									<option value="">선택하세요</option>
									<option value="PAYMENT_WAITNG">입금대기</option>
									<option value="PAYED">결제완료 (빌링 결제완료)</option>
									<option value="DELIVERY_READY">배송 준비 중 [deprecated]</option>
									<option value="DELIVERING">배송 중 [deprecated]</option>
									<option value="DELIVERY_COMPLETE">배송 완료 [deprecated]</option>
									<option value="DELIVERY_START">배송 시작(출고지시)</option>
									<option value="PURCHASE_DECISION">구매확정</option>
									<option value="CANCELED">취소</option>
							</select>
							<span class="input-group-btn">
							 <button id="order_modify_btn"  class="btn btn-default" type="button" onclick="order_state_modify();">GO</button>
							</span>
						</div>
					</li>
				</ul>
				<span class="glyphicon glyphicon-menu-down" aria-hidden="true">주문 취소 테스트 (전체)</span>
				<ul style="border-bottom:none;">
					<li style="margin:20px 0;">
						<em><span style="color: red;">[필수]</span> 주문번호(orderNo)</em>
						<input type="text" class="form-control input_text" name="orderNo_all" id="orderNo_all" value="<%=orderNo%>">
						<em><span style="color: red;">[필수]</span> PAYCO에서 발급하는 주문인증 Key(orderCertifyKey)</em>
						<input type="text" class="form-control input_text" name="orderCertifyKey_all" id="orderCertifyKey_all" value="<%=orderCertifyKey%>">
						<em>[선택] 총 취소할 면세금액(totalCancelTaxfreeAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelTaxfreeAmt_all" id="totalCancelTaxfreeAmt_all" value="<%=totalCancelTaxfreeAmt%>">
						<em>[선택] 총 취소할 과세금액(totalCancelTaxableAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelTaxableAmt_all" id="totalCancelTaxableAmt_all" value="<%=totalCancelTaxableAmt%>">
						<em>[선택] 총 취소할 부가세(totalCancelVatAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelVatAmt_all" id="totalCancelVatAmt_all" value="<%=totalCancelVatAmt%>">
						<em>[선택] 총 취소가능금액(totalCancelPossibleAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelPossibleAmt_all" id="totalCancelPossibleAmt_all" value="<%=totalCancelPossibleAmt%>">
						<em>[선택] 취소처리 요청메모(requestMemo)</em>
						<input type="text" class="form-control input_text" name="requestMemo_all" id="requestMemo_all" value="<%=requestMemo%>">
						<em><span style="color: red;">[필수]</span> 총 취소 금액(cancelTotalAmt)</em>
						<div class="input-group">
							<input type="text" class="form-control input_text" name="cancelTotalAmt_all" id="cancelTotalAmt_all" value="<%=cancelTotalAmt%>" onchange="inputChange(this.value, 'all');">
							<span class="input-group-btn">
								<button id="order_cancel_all__btn" class="btn btn-default" type="button" onclick="cancel_order_all_test();">GO</button>
							</span>
						</div>
					</li>
				</ul>
				<span class="glyphicon glyphicon-menu-down" aria-hidden="true">주문 취소 테스트 (부분 - 상품 1개만)</span>
				<ul style="border-bottom:none;">
					<li style="margin:20px 0;">
						<em><span style="color: red;">[필수]</span> 주문번호(orderNo)</em>
						<input type="text" class="form-control input_text" name="orderNo_part" id="orderNo_part" value="<%=orderNo%>">
						<em><span style="color: red;">[필수]</span> PAYCO에서 발급하는 주문인증 Key(orderCertifyKey)</em>
						<input type="text" class="form-control input_text" name="orderCertifyKey_part" id="orderCertifyKey_part" value="<%=orderCertifyKey%>">
						<em><span style="color: red;">[필수]</span> 취소할 주문 상품 연동키(sellerOrderProductReferenceKey)</em>
						<input type="text" class="form-control input_text" name="sellerOrderProductReferenceKey_part" id="sellerOrderProductReferenceKey_part" value="<%=sellerOrderProductReferenceKey%>">
						<em><span style="color: red;">[필수]</span> 취소할 총 금액(cancelTotalAmt)</em>
						<input type="text" class="form-control input_text" name="cancelTotalAmt_part" id="cancelTotalAmt_part" value="<%=cancelTotalAmt%>" onchange="inputChange(this.value, 'part');">
						<em>[선택] 총 취소할 면세금액(totalCancelTaxfreeAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelTaxfreeAmt_part" id="totalCancelTaxfreeAmt_part" value="<%=totalCancelTaxfreeAmt%>">
						<em>[선택] 총 취소할 과세금액(totalCancelTaxableAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelTaxableAmt_part" id="totalCancelTaxableAmt_part" value="<%=totalCancelTaxableAmt%>">
						<em>[선택] 총 취소할 부가세(totalCancelVatAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelVatAmt_part" id="totalCancelVatAmt_part" value="<%=totalCancelVatAmt%>">
						<em>[선택] 총 취소가능 금액(totalCancelPossibleAmt)</em>
						<input type="text" class="form-control input_text" name="totalCancelPossibleAmt_part" id="totalCancelPossibleAmt_part" value="<%=totalCancelPossibleAmt%>">
						<em>[선택] 취소 사유(cancelDetailContent)</em>
						<input type="text" class="form-control input_text" name="cancelDetailContent_part" id="cancelDetailContent_part" value="<%=cancelDetailContent%>">
						<em>[선택] 취소처리 요청메모(requestMemo)</em>
						<input type="text" class="form-control input_text" name="requestMemo_part" id="requestMemo_part" value="<%=requestMemo%>">
						<em><span style="color: red;">[필수]</span> 취소 할 주문상품 금액(productAmt)</em>
						<div class="input-group">
							<input type="text" class="form-control input_text" name="cancelAmt_part" id="cancelAmt_part" value="<%=cancelTotalAmt%>">
							<span class="input-group-btn">
								<button id="order_cancel_btn" class="btn btn-default" type="button" onclick="cancel_order_part_test();">GO</button>
							</span>
						</div>
					</li>
				</ul>
				<span class="glyphicon glyphicon-menu-down" aria-hidden="true">마일리지 적립 취소 테스트</span>
				<ul style="border-bottom:none;">
					<li style="margin:20px 0;">
						<em><span style="color: red;">[필수]</span> 주문번호(orderNo)</em>
						<input type="text" class="form-control input_text" name="orderNo_mile" id="orderNo_mile" value="<%=orderNo%>">
						<em><span style="color: red;">[필수]</span> 취소 총 금액(cancelPaymentAmount)</em>
						<div class="input-group">
							<input type="text" class="form-control input_text" name="cancelPaymentAmount_mile" id="cancelPaymentAmount_mile" value="<%=cancelTotalAmt%>">
							<span class="input-group-btn">
								<button id="order_cancel_btn" class="btn btn-default" type="button" onclick="mileage_cancel_test();">GO</button>
							</span>
						</div>
					</li>
				</ul>
				<span class="glyphicon glyphicon-menu-down" aria-hidden="true">영수증 확인</span>
				<ul style="border-bottom:none;">
					<li style="margin:20px 0;">
						<em><span style="color: red;">[필수]</span> 주문번호(orderNo)</em>
						<input type="text" class="form-control input_text" name="orderNo_receipt" id="orderNo_receipt" value="<%=orderNo%>">
						<em>결제수단</em>
						<div class="input-group">
							<span style= "margin-right: 3px;"><input type="radio"  value="cash" name="receipt"> <label for="pay01">현금영수증</label></span>
							<span style= "margin-right: 3px;"><input type="radio"  value="online" name="receipt"><label for="pay02">온라인영수증</label></span>	
							<span style= "margin-right: 3px;"><input type="radio"  value="card" name="receipt" checked><label for="pay03">신용카드매출전표</label></span>	
							<span class="input-group-btn">
								<button id="order_mile_cancel_btn" class="btn btn-default" type="button" onclick="receipt_go();">GO</button>
							</span>
						</div>
					</li>
				</ul>
				<span class="glyphicon glyphicon-menu-down" aria-hidden="true">결제 상세 조회</span>
				<ul style="border-bottom:none;">
					<li style="margin:20px 0;">
						<em><span style="color: red;">[필수]</span> 주문예약번호(reserveOrderNo)</em>
						<input type="text" class="form-control input_text" name="verifyPayment_reserveOrderNo" id="verifyPayment_reserveOrderNo" value="<%=reserveOrderNo%>">
						<em><span style="color: red;">[필수]</span> 가맹점에서 발급하는 주문 연동 Key(sellerOrderReferenceKey)</em>
						<div class="input-group">
							<input type="text" class="form-control input_text" name="verifyPayment_sellerOrderReferenceKey" id="verifyPayment_sellerOrderReferenceKey" value="<%=sellerOrderReferenceKey%>">
							<span class="input-group-btn">
								<button id="verifyPayment_btn" class="btn btn-default" type="button" onclick="verifyPayment();">GO</button>
							</span>
						</div>
					</li>
				<li><div id="show_verifyPayment" ></div></li>
				</ul>
			</div>
		</div>
	</div>
</div>
</body>
</html>
