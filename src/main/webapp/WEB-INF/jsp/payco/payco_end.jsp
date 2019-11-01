<%--
  Created by IntelliJ IDEA.
  User: user
  Date: 2019-10-23
  Time: 오후 2:02
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="Content-Script-Type" content="text/javascript">
    <meta http-equiv="Cache-Control" content="no-cache">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge">
    <meta name="viewport" content="width=device-width,initial-scale=1.0,minimum-scale=0.5,maximum-scale=2.0,user-scalable=yes">
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
    <title></title>
    <script type="text/javascript">
        function fayco_end(){
            $('#input-reserveOrderNo',window. opener.document).val('<c:out value="${reserveOrderNo}"/>');
            $('#input-sellerOrderReferenceKey',window. opener.document).val('<c:out value="${sellerOrderReferenceKey}"/>');
            $('#input-mainPgCode',window. opener.document).val('<c:out value="${mainPgCode}"/>');
            $('#input-totalPaymentAmt',window. opener.document).val('<c:out value="${totalPaymentAmt}"/>');
            $('#input-totalRemoteAreaDeliveryFeeAmt',window. opener.document).val('<c:out value="${totalRemoteAreaDeliveryFeeAmt}"/>');
            $('#input-discountAmt',window. opener.document).val('<c:out value="${discountAmt}"/>');
            $('#input-pointAmt',window. opener.document).val('<c:out value="${pointAmt}"/>');
            $('#input-paymentCertifyToken',window. opener.document).val('<c:out value="${paymentCertifyToken}"/>');
            $('#input-bid',window. opener.document).val('<c:out value="${bid}"/>');
            window.opener.parent.payco_end();
            window.close();
        }
    </script>
    <body onLoad="fayco_end()"></body>
</html>
