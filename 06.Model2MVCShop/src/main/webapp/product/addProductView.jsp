<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="cPath" value="${pageContext.request.contextPath}" />

<html>
<head>
  <title>상품등록</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <style>
    .a-like{ cursor:pointer; text-decoration:underline; color:#0066cc; background:none; border:none; padding:0; font:inherit; }
    .ct_comment{ font-size:11px; color:#666; margin-top:4px; }

    /* 파일 미리보기 그리드 */
    .file-preview {
      margin-top:10px;
      display:grid;
      grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
      gap:10px;
    }
    .file-card{
      border:1px solid #ddd;
      border-radius:8px;
      padding:8px;
      display:flex;
      flex-direction:column;
      gap:6px;
      background:#fafafa;
    }
    .file-thumb{
      width:100%;
      aspect-ratio: 4/3;
      object-fit:cover;
      border:1px solid #eee;
      border-radius:6px;
      background:#fff;
    }
    .file-meta{
      font-size:12px;
      line-height:1.4;
      color:#333;
      word-break:break-all;
    }
    .file-actions{
      display:flex; justify-content:space-between; align-items:center; gap:6px;
    }
    .btn-mini{
      font-size:12px; padding:4px 8px; border:1px solid #ddd; border-radius:6px; background:#fff; cursor:pointer;
    }
    .file-summary{
      margin-top:6px; font-size:12px; color:#333;
    }
    .badge{
      display:inline-block; padding:2px 6px; border-radius:999px; border:1px solid #ddd; font-size:11px; color:#555; background:#fff;
    }
    .badge.warn{ border-color:#e0b800; color:#8a6d00; background:#fff8dd; }
    .badge.err{ border-color:#e08989; color:#8a0000; background:#fff0f0; }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">

<form name="detailForm" id="detailForm"
      action="${cPath}/product/addProduct"
      method="post" enctype="multipart/form-data">

  <!-- 제목 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37"/></td>
      <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
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

  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:13px;">
    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 상품명 -->
    <tr>
      <td width="104" class="ct_write">
        상품명 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodName" class="ct_input_g"
               style="width: 250px; height: 19px"
               fieldTitle="상품명" required maxLength="20" />
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 상품상세정보 -->
    <tr>
      <td class="ct_write">
        상품상세정보 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="prodDetail" class="ct_input_g"
               style="width: 250px; height: 19px"
               fieldTitle="상품상세정보" required maxLength="100" minLength="6"/>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 제조일자 -->
    <tr>
      <td class="ct_write">
        제조일자 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="manuDate" id="manuDate" readonly="readonly" class="ct_input_g"
               style="width: 100px; height: 19px"
               fieldTitle="제조일자" required maxLength="10" minLength="8"/>
        &nbsp;
        <button type="button" class="a-like open-calendar" data-target="manuDate">
          <img src="../images/ct_icon_date.gif" width="15" height="15" alt="달력">
        </button>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 가격 -->
    <tr>
      <td class="ct_write">
        가격 <img src="/images/ct_icon_red.gif" width="3" height="3" align="absmiddle"/>
      </td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="text" name="price" class="ct_input_g"
               style="width: 100px; height: 19px"
               fieldTitle="가격" required maxLength="10" num="n" fromNum="0"/> 원
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>

    <!-- 첨부파일(멀티) + 미리보기/목록 -->
    <tr>
      <td class="ct_write">첨부파일</td>
      <td bgcolor="D6D6D6" width="1"></td>
      <td class="ct_write01">
        <input type="file"
               name="productFile"
               id="productFile"
               class="ct_input_g"
               style="width: 250px;"
               multiple="multiple" />
        <div class="ct_comment">
          ※ 여러 이미지를 한 번에 선택하려면 Ctrl 또는 Shift 키를 이용하세요.
        </div>

        <!-- 파일 요약/제한 안내 -->
        <div class="file-summary" id="fileSummary" style="display:none;"></div>

        <!-- 미리보기/목록 렌더 영역 -->
        <div class="file-preview" id="filePreview" aria-live="polite"></div>

        <!-- 빠른 작업 버튼 -->
        <div style="margin-top:6px; display:flex; gap:8px;">
          <button type="button" class="btn-mini" id="btnClearFiles">선택 파일 모두 지우기</button>
        </div>
      </td>
    </tr>

    <tr><td height="1" colspan="3" bgcolor="D6D6D6"></td></tr>
  </table>

  <!-- 버튼 -->
  <table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <tr>
      <td width="53%"></td>
      <td align="right">
        <table border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"/></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <button type="button" id="btnSubmit" class="a-like">등록</button>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"/></td>
            <td width="10"></td>
            <td width="17" height="23"><img src="/images/ct_btnbg01.gif" width="17" height="23"/></td>
            <td background="/images/ct_btnbg02.gif" class="ct_btn01" style="padding-top:3px;">
              <button type="button" id="btnReset" class="a-like">취소</button>
            </td>
            <td width="14" height="23"><img src="/images/ct_btnbg03.gif" width="14" height="23"/></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>

</form>

<!-- 스크립트 -->
<script src="/javascript/jquery-3.7.1.min.js"></script>
<script src="/javascript/CommonScript-jq.js"></script>
<script src="/javascript/calendar.js"></script>
<script src="/javascript/product-add.js"></script>
</body>
</html>
