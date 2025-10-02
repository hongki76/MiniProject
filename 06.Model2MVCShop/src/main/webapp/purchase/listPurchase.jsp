<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"  %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- type 파라미터 기본값: all --%>
<c:set var="type" value="${empty param.type ? 'all' : param.type}" />
<c:choose>
  <c:when test="${type == 'cancel'}">
    <c:set var="pageTitle" value="주문 취소 목록" />
    <c:set var="headerTitle" value="주문 취소 목록" />
    <c:set var="stateClass" value="color:#d14343;font-weight:600;" />
  </c:when>
  <c:when test="${type == 'return'}">
    <c:set var="pageTitle" value="반품 목록" />
    <c:set var="headerTitle" value="반품 목록" />
    <c:set var="stateClass" value="color:#1e66d0;font-weight:600;" />
  </c:when>
  <c:otherwise>
    <c:set var="pageTitle" value="구매 목록조회" />
    <c:set var="headerTitle" value="구매 목록조회" />
    <c:set var="stateClass" value="color:orange;" />
  </c:otherwise>
</c:choose>

<html>
<head>
  <title>${pageTitle}</title>
  <link rel="stylesheet" href="/css/admin.css" type="text/css">
  <style>
    .infinite-loader { text-align:center; padding:16px; color:#888; }
    .empty-row { padding:16px; color:#666; }

    /* 행 높이 확장 (기존 스타일 유지) */
    .ct_list_pop td { padding:80px 2px; line-height:1.6; vertical-align:middle; }

    .btn { display:inline-block; padding:8px 12px; border:1px solid #d0d0d0; border-radius:6px; background:#fff; cursor:pointer; }
    .btn[disabled] { opacity:.5; cursor:default; }

    thead tr + tr td[bgcolor], tbody tr + tr td[bgcolor] { height:1px; padding:0; }

    @media (max-width: 768px) { .ct_list_pop td { padding:10px 8px; line-height:1.5; } }

    /* Hover 레이어 (공통) */
    .purchase-hover-layer{
      position:absolute; z-index:3000; min-width:280px; max-width:420px;
      background:#fff; border:1px solid #d9d9d9; box-shadow:0 8px 24px rgba(0,0,0,.12);
      border-radius:8px; padding:12px 14px; display:none; pointer-events:auto;
    }
    .purchase-hover-layer .ttl{ font-weight:600; margin-bottom:6px; }
    .purchase-hover-layer .row{ font-size:13px; line-height:1.4; margin:2px 0; }
    .purchase-hover-layer .price{ font-weight:600; }
    .purchase-hover-layer .act{ margin-top:8px; text-align:right; }
    .purchase-hover-layer .btn-like{ cursor:pointer; text-decoration:underline; color:#0066cc; background:none; border:none; padding:0; font:inherit; }
  </style>
</head>

<body bgcolor="#ffffff" text="#000000">
<div style="width:98%; margin-left:10px;">

  <%-- 페이지 분기값 전달용(스크립트가 읽음) --%>
  <div id="pageData" data-type="${type}" style="display:none;"></div>

  <!-- 헤더 -->
  <table width="100%" height="37" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="15" height="37"><img src="/images/ct_ttl_img01.gif" width="15" height="37" /></td>
      <td background="/images/ct_ttl_img02.gif" width="100%" style="padding-left:10px;">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="93%" class="ct_ttl01">${headerTitle}</td>
          </tr>
        </table>
      </td>
      <td width="12" height="37"><img src="/images/ct_ttl_img03.gif" width="12" height="37" /></td>
    </tr>
  </table>

  <!-- 요약 영역 -->
  <div id="summary" style="margin:10px 0;">전체 <span id="totalCount">0</span> 건</div>

  <!-- 목록 테이블 -->
  <table id="purchaseTable" width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
    <thead>
      <tr>
        <td class="ct_list_b" width="100">No</td>
        <td class="ct_line02"></td>
        <td class="ct_list_b" width="150">상품명</td>
        <td class="ct_line02"></td>
        <td class="ct_list_b">
          <c:choose>
            <c:when test="${type == 'cancel'}">취소 사유/상세</c:when>
            <c:when test="${type == 'return'}">반품 사유/상세</c:when>
            <c:otherwise>상세정보</c:otherwise>
          </c:choose>
        </td>
        <td class="ct_line02"></td>
        <td class="ct_list_b" width="100">가격</td>
        <td class="ct_line02"></td>
        <td class="ct_list_b" width="200">
          <c:choose>
            <c:when test="${type == 'cancel'}">취소 현황</c:when>
            <c:when test="${type == 'return'}">반품 현황</c:when>
            <c:otherwise>배송현황</c:otherwise>
          </c:choose>
        </td>
        <td class="ct_line02"></td>
        <td class="ct_list_b" width="200">작업</td>
      </tr>
      <tr><td colspan="11" bgcolor="808285" height="1"></td></tr>
    </thead>
    <tbody id="purchaseBody" class="ct_list_pop">
      <!-- AJAX로 행을 추가합니다 -->
    </tbody>
  </table>

  <!-- 무한 스크롤 로더 & 센티넬 -->
  <div id="infiniteLoader" class="infinite-loader">불러오는 중...</div>
  <div id="sentinel" style="height:1px;"></div>
</div>

<!-- 스크립트 -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="/javascript/purchase-list.js"></script>

</body>
</html>
