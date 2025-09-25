<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />

<html>
<head>
  <title>상품등록</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <style>
    .a-like{
      cursor:pointer; text-decoration:underline; color:#0066cc;
      background:none; border:none; padding:0; font:inherit;
    }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">

<form name="detailForm" id="detailForm"
      action="${cPath}/product/addProduct"
      method="post" enctype="multipart/form-data">

  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37"/></td>
      <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left: 10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">상품등록</td>
            <td width="20%" align="right">&nbsp;</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37"/></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 상품명 -->
    <tr>
      <td width="104" class="ct_write">
        상품명 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="105">
              <input type="text" name="prodName" class="ct_input_g"
                     style="width: 100px; height: 19px"
                     fieldTitle="상품명" required maxLength="20">
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 상품상세정보 -->
    <tr>
      <td width="104" class="ct_write">
        상품상세정보 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodDetail" class="ct_input_g"
               style="width: 100px; height: 19px"
               fieldTitle="상품상세정보" required maxLength="100" minLength="6"/>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 제조일자 -->
    <tr>
      <td width="104" class="ct_write">
        제조일자 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="manuDate" id="manuDate" readonly="readonly" class="ct_input_g"
               style="width: 100px; height: 19px"
               fieldTitle="제조일자" required maxLength="10" minLength="8"/>
        &nbsp;
        <!-- calendar.js의 show_calendar를 JS에서 바인딩하기 위해 data-target만 사용 -->
		<button type="button" class="a-like open-calendar" data-target="manuDate">
		  <img src="../images/ct_icon_date.gif" width="15" height="15" alt="달력">
		</button>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 가격 -->
    <tr>
      <td width="104" class="ct_write">
        가격 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="price" class="ct_input_g"
               style="width: 100px; height: 19px"
               fieldTitle="가격" required maxLength="10" num="n" fromNum="0">&nbsp;원
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 이미지 -->
    <tr>
      <td width="104" class="ct_write">상품이미지</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="file" name="uploadFile" class="ct_input_g" style="width: 200px;" maxLength="30"/>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- 버튼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top: 10px;">
    <tr>
      <td width="53%"></td>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"/></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <button type="button" id="btnSubmit" class="a-like">등록</button>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"/></td>
            <td width="10"></td>
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"/></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top: 3px;">
              <button type="button" id="btnReset" class="a-like">취소</button>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"/></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

</form>

<!-- 스크립트: 하단에서 외부 파일만 로드 -->
<script src="/javascript/jquery-3.7.1.min.js"></script>
<script src="/javascript/CommonScript-jq.js"></script> <!-- 공통 검증 사용 -->
<script src="/javascript/calendar.js"></script>        <!-- 기존 달력 스크립트 -->
<script src="/javascript/product-add.js"></script>     <!-- 신규: 본 페이지 전용 -->
</body>
</html>
