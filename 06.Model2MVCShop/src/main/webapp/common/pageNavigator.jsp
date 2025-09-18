<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!--
  요구사항: GET → POST
  구현: 모든 이동 링크가 javascript:fncGetList(n) 을 호출하여
       부모 페이지의 detailForm(POST) 제출을 이용하도록 구성
  전제: 포함하는 페이지에 fncGetList(currentPage) 함수와
       <form name="detailForm" method="post"> 가 존재
-->

<c:set var="curr" value="${resultPage.currentPage}" />
<c:set var="begin" value="${resultPage.beginUnitPage}" />
<c:set var="end" value="${resultPage.endUnitPage}" />
<c:set var="max" value="${resultPage.maxPage}" />
<c:set var="unit" value="${resultPage.pageUnit}" />

<style>
/* 간단한 스타일(선택) */
.pg a, .pg span { margin:0 4px; text-decoration:none; }
.pg .now { font-weight:bold; text-decoration:underline; }
.pg .disabled { color:#999; cursor:default; }
</style>

<div class="pg" style="display:inline-block;">
  <!-- 이전(◀) : 현재 유닛의 첫 페이지 > 1이면 표시 -->
  <c:choose>
    <c:when test="${curr > unit}">
      <a href="javascript:fncGetList('${curr-1}')">◀ 이전</a>
    </c:when>
    <c:otherwise>
      <span class="disabled">◀ 이전</span>
    </c:otherwise>
  </c:choose>

  <!-- 숫자 페이지 -->
  <c:forEach var="i" begin="${begin}" end="${end}" step="1">
    <c:choose>
      <c:when test="${i == curr}">
        <span class="now">${i}</span>
      </c:when>
      <c:otherwise>
        <a href="javascript:fncGetList('${i}')">${i}</a>
      </c:otherwise>
    </c:choose>
  </c:forEach>

  <!-- 이후(▶) : end < max 이면 표시 -->
  <c:choose>
    <c:when test="${end < max}">
      <a href="javascript:fncGetList('${end+1}')">이후 ▶</a>
    </c:when>
    <c:otherwise>
      <span class="disabled">이후 ▶</span>
    </c:otherwise>
  </c:choose>
</div>
