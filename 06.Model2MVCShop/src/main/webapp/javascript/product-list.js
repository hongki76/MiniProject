// /javascript/product-list.js
// - listProduct.jsp 전용 스크립트 (무한스크롤 + 자동완성 + Hover 미리보기)
// - pageNavigator.jsp 호환 위해 전역 fncGetList는 초기화/재조회로 유지하되 실제 이동은 AJAX로 처리
(function (global, $) {
  "use strict";

  // =========================
  // 0) SSR 값/DOM 핸들들
  // =========================
  var CFG = global.__PRODUCT_LIST_CONFIG__ || {};
  var cPath = CFG.cPath || ""; // JSP에서 내려주면 사용

  var $form = $("#detailForm");
  var $tbody = $("#productTbody");
  var $currentPageInput = $("#currentPage");
  var $orderByPriceAsc = $("#orderByPriceAsc");

  var $totalCountSpan = $("#totalCountSpan");
  var $currentPageSpan = $("#currentPageSpan");

  // SSR 렌더된 1페이지 행수(제품행만)
  var ssrRowCount = $("#productTbody .ct_list_pop").length;

  // 상태
  var state = {
    // SSR에서 내려주는 값이 있으면 사용, 없으면 fallback
    currentPage: Number((CFG.currentPageSSR != null ? CFG.currentPageSSR : ($currentPageSpan.text() || 1))) || 1,
    pageSize: (CFG.pageSizeSSR != null ? CFG.pageSizeSSR : null),  // 첫 AJAX 응답으로 채움
    totalCount: Number((CFG.totalCountSSR != null ? CFG.totalCountSSR : ($totalCountSpan.text() || 0))) || 0,
    loadedCount: ssrRowCount || 0
  };

  var loading = false;
  var allLoaded = false;

  // =========================
  // 1) 검색 입력 UX (기존 유지)
  // =========================
  (function initSearchInputUX() {
    var $cond = $("#searchCondition");
    var $kw = $("#searchKeyword");
    var $reg = $("#regDateKeyword"); // 등록일 유지용 히든

    function applyPlaceholderAndValidation() {
      var v = String($cond.val());
      // 공통 초기화
      $kw.removeAttr("num").removeAttr("valCheck").removeAttr("maxLength").attr("placeholder", "");

      if (v === "0") { // 상품명
        $kw.attr("placeholder", "상품명 입력");
        // 날짜모드에서 벗어났을 때 입력칸은 비워서 날짜 값이 보이지 않게(히든은 유지)
        if ($reg.val()) { $kw.val(""); }

      } else if (v === "1") { // 상품가격
        $kw.attr("placeholder", "가격(숫자)");
        $kw.attr("num", "n");
        if ($reg.val()) { $kw.val(""); }

      } else if (v === "2") { // 등록일
        $kw.attr("placeholder", "YYYYMMDD");
        $kw.attr("valCheck", "DATE").attr("maxLength", "8");
      }
    }

    // 등록일 모드에서 입력 변화 → 히든에 정규화(숫자 8자리) 저장
    $(document).on("input blur", "#searchKeyword", function () {
      if (String($cond.val()) !== "2") return;
      var digits = (this.value || "").replace(/\D/g, "");
      if (digits.length === 8) { $reg.val(digits); }
    });

    $(applyPlaceholderAndValidation);
    $cond.on("change", function () {
      $kw.val(""); // ★ 비우기
      applyPlaceholderAndValidation(); // ★ placeholder/검증 속성 재적용
    });
  })();

  // =========================
  // 2) 유틸
  // =========================
  function n(v) { return Number(v || 0); }
  function fmtPrice(v) {
    var num = n(v);
    return isNaN(num) ? (v == null ? "" : String(v)) : num.toLocaleString();
  }
  function escapeHtml(s) {
    if (s == null) return "";
    return String(s)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }
  function isAdmin() {
    return (CFG.role || "") === "admin";
  }
  function isLogin() {
    return !!CFG.isLogin;
  }

  // =========================
  // 3) 행 HTML 빌드
  // =========================
  function buildRow(product, rowNo) {
    var actionHtml = "";
    if (isLogin() && isAdmin() && String(product.proTranCode) === "1") {
      actionHtml = '<a href="/purchase/updateTranCodeByProduct?prodNo='
        + product.prodNo + '&tranStatusCode=2" class="a-like">배송하기</a>';
    }

    var html =
      '<tr class="ct_list_pop">' +
        '<td align="center">' + rowNo + '</td>' +
        '<td></td>' +
        '<td align="left">' +
          '<form action="/product/getProduct" method="post" style="display:inline;">' +
            '<input type="hidden" name="prodNo" value="' + product.prodNo + '"/>' +
            // ▼ Hover 미리보기용 클래스/데이터 속성
            '<button type="submit" class="a-like prod-link" data-prodno="' + product.prodNo + '">' +
              escapeHtml(product.prodName) +
            '</button>' +
          '</form>' +
        '</td>' +
        '<td></td>' +
        '<td align="right">' + fmtPrice(product.price) + '</td>' +
        '<td></td>' +
        '<td align="center">' + (product.regDate || "") + '</td>' +
        '<td></td>' +
        '<td align="center">' + (product.proTranState || "") + (actionHtml ? " " + actionHtml : "") + "</td>" +
        "<td></td>" +
        "<td></td>" +
      "</tr>" +
      '<tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>';

    return html;
  }

  // =========================
  // 4) AJAX 로딩 (@RequestBody JSON)
  // =========================
  function buildPayload(nextPage) {
    return {
      currentPage: nextPage,
      pageSize: state.pageSize || undefined, // 서버 기본세팅을 따르되, 지정이 있으면 전달
      orderByPriceAsc: $orderByPriceAsc.val(), // "true"/"false" 문자열 그대로
      searchCondition: $("#searchCondition").val(),
      searchKeyword: $("#searchKeyword").val(),
      minPrice: $('input[name="minPrice"]').val(),
      maxPrice: $('input[name="maxPrice"]').val(),
      regDateKeyword: $("#regDateKeyword").val()
    };
  }

  function fetchPage(nextPage, onDone) {
    if (loading || allLoaded) return;
    loading = true;

    var payload = buildPayload(nextPage);

    $.ajax({
      url: (cPath || "") + "/product/json/getProductList",
      method: "POST",
      contentType: "application/json; charset=UTF-8",
      dataType: "json",
      data: JSON.stringify(payload)
    }).done(function (res) {
      var list = res && res.list ? res.list : [];
      var page = res && res.resultPage ? res.resultPage : {};

      // pageSize/totalCount 최신화
      if (!state.pageSize && page.pageSize) state.pageSize = page.pageSize;
      if (page.totalCount != null) state.totalCount = page.totalCount;

      // 화면상의 No 계산(총건수 기준 내림차순)
      var baseNo = state.totalCount - ((nextPage - 1) * (state.pageSize || list.length));

      var html = "";
      list.forEach(function (p, i) {
        html += buildRow(p, baseNo - i);
      });

      if (html) {
        $tbody.append(html);
        state.loadedCount += list.length;
        state.currentPage = nextPage;

        // 표시 갱신
        $currentPageInput.val(state.currentPage);
        if ($currentPageSpan.length) $currentPageSpan.text(state.currentPage);
        if ($totalCountSpan.length)  $totalCountSpan.text(state.totalCount);
      }

      // 마지막 페이지 판단
      if (!list.length || (state.loadedCount >= state.totalCount)) {
        allLoaded = true;
      }

      if (typeof onDone === "function") onDone();
    }).fail(function () {
      // 실패시: 사용자 알림은 생략(스크롤 시 재시도 가능)
    }).always(function () {
      loading = false;
    });
  }

  // =========================
  // 5) 스크롤 감지
  // =========================
  function nearBottom() {
    var scrollTop = global.scrollY || document.documentElement.scrollTop;
    var viewport = global.innerHeight || document.documentElement.clientHeight;
    var full = document.documentElement.scrollHeight;
    // 바닥 200px 근처에서 트리거
    return (scrollTop + viewport + 200 >= full);
  }

  var scrollTick = false;
  function onScroll() {
    if (scrollTick) return;
    scrollTick = true;
    requestAnimationFrame(function () {
      scrollTick = false;
      if (nearBottom()) {
        fetchPage(state.currentPage + 1);
      }
    });
  }

  // =========================
  // 6) 초기화/재조회
  // =========================
  function resetAndReload() {
    // 화면 초기화
    $tbody.empty();
    state.currentPage = 0;
    state.loadedCount = 0;
    allLoaded = false;

    // 1페이지부터 AJAX 로드
    fetchPage(1);
    if ($currentPageSpan.length) $currentPageSpan.text(1);
  }

  // =========================
  // 7) 기존 submit 기반 함수 → AJAX로 대체
  // =========================
  function submitList(page, order) {
    // 정렬 지정이 들어오면 히든값 반영
    if (order !== undefined && order !== null && order !== "") {
      $orderByPriceAsc.val(order); // 'ASC' or 'DESC' → 서버에서는 "true"/"false" 문자열 기대시 매퍼에서 해석
    }

    // 기존 FormValidation 연동(있으면)
    if (global.FormValidation && !global.FormValidation($form.get(0))) {
      return;
    }

    // AJAX 기반 재조회
    resetAndReload();
  }

  // =========================
  // 8) 자동완성 (AutoComplete)
  // =========================
  (function autoCompleteModule() {
    var $kw   = $("#searchKeyword");
    var $cond = $("#searchCondition");

    var menu = null;     // jQuery element for menu
    var items = [];      // 현재 표시 항목
    var activeIndex = -1;
    var DEBOUNCE_MS = 120;
    var lastReq = 0;

    function ensureMenu() {
      if (menu && menu.length) return menu;

      menu = $('<div class="ac-menu" style="display:none; position:absolute; z-index:1000; min-width:200px; max-height:240px; overflow-y:auto; border:1px solid #ccc; background:#fff; box-shadow:0 2px 6px rgba(0,0,0,.08);"></div>');

      // 우선순위: .ac-wrap → 입력창 부모
      var $wrap = $(".ac-wrap");
      if ($wrap.length) {
        $wrap.css("position", "relative").append(menu);
      } else {
        // 부모에 상대배치 보장
        var $p = $kw.parent();
        if ($p.css("position") === "static") $p.css("position", "relative");
        $p.append(menu);
      }
      return menu;
    }

    function hideMenu() {
      if (menu) { menu.hide(); }
      items = [];
      activeIndex = -1;
    }

    function renderMenu(list) {
      ensureMenu().empty();
      if (!list || !list.length) { hideMenu(); return; }

      items = list.slice(0);
      activeIndex = -1;

      list.forEach(function (text, idx) {
        var $it = $('<div class="ac-item" style="padding:8px 10px; cursor:pointer;"></div>').text(text);
        $it.on('mousedown', function (e) { // mousedown: blur 전에 값 확정
          e.preventDefault();
          applyChoice(idx);
        });
        $it.on('mouseenter', function(){ menu.children().removeClass('active'); $(this).addClass('active'); activeIndex = idx; });
        menu.append($it);
      });

      // 폭/위치 맞추기
      var w = $kw.outerWidth();
      ensureMenu().css({ minWidth: w + "px" }).show();
    }

    function moveActive(delta) {
      if (!items.length) return;
      activeIndex = (activeIndex + delta + items.length) % items.length;
      menu.children().removeClass('active').eq(activeIndex).addClass('active').css('background','#f0f6ff');
    }

    function applyChoice(i) {
      if (i < 0 || i >= items.length) return;
      $kw.val(items[i]).trigger('input'); // 등록일 모드면 히든값 갱신 로직과 연계
      hideMenu();
    }

    // 디바운스
    var timer = null;
    function debounce(fn, wait) {
      return function () {
        var ctx = this, args = arguments;
        clearTimeout(timer);
        timer = setTimeout(function () { fn.apply(ctx, args); }, wait);
      };
    }

    // AJAX 요청
    function requestSuggest() {
      var cond = String($cond.val() || "0"); // 0:상품명, 2:등록일
      var kw = String($kw.val() || "").trim();

      if (cond === "2") {
        // 등록일: 숫자만으로 prefix
        if (kw.replace(/\D/g, "").length < 1) { hideMenu(); return; }
      } else {
        // 상품명: 1글자 이상부터
        if (kw.length < 1) { hideMenu(); return; }
      }

      var reqId = ++lastReq;

      $.ajax({
        url: (cPath || "") + "/product/json/autoComplete",
        method: "POST",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        data: JSON.stringify({
          searchCondition: cond,                          // "0" | "2"
          keyword: cond === "2" ? kw.replace(/\D/g, "")  // 등록일은 숫자만
                                 : kw,
          limit: 10
        })
      }).done(function (list) {
        if (reqId !== lastReq) return; // 응답 역전 방지
        renderMenu(Array.isArray(list) ? list : []);
      }).fail(function () {
        hideMenu();
      });
    }

    var requestSuggestDebounced = debounce(requestSuggest, DEBOUNCE_MS);

    // 이벤트 바인딩
    $kw.on("input focus", requestSuggestDebounced);

    $kw.on("keydown", function (e) {
      if (!menu || menu.is(":hidden")) return;
      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          moveActive(1);
          break;
        case "ArrowUp":
          e.preventDefault();
          moveActive(-1);
          break;
        case "Enter":
          if (activeIndex >= 0) {
            e.preventDefault();
            applyChoice(activeIndex);
          }
          break;
        case "Escape":
          hideMenu();
          break;
      }
    });

    // 포커스 아웃 시 닫기
    $kw.on("blur", function () {
      setTimeout(hideMenu, 120); // 클릭 선택(mousedown) 고려
    });

    // 모드 바뀌면 초기화
    $("#searchCondition").on("change", function () {
      hideMenu();
    });
  })();

// =========================
// 9) Hover 레이어 (상품 상세 미리보기)
// =========================
(function hoverPreview(){
  var $layer = $('<div class="prod-hover-layer" role="dialog" aria-hidden="true" style="position:absolute; z-index:3000; min-width:280px; max-width:420px; background:#fff; border:1px solid #d9d9d9; box-shadow:0 8px 24px rgba(0,0,0,.12); border-radius:8px; padding:12px 14px; display:none; pointer-events:auto;"></div>').appendTo(document.body);
  var cache = {};         // prodNo -> product json 캐시
  var showTimer = null;   // hover 지연
  var hideTimer = null;   // 레이어 자동 숨김 지연
  var DELAY_SHOW = 160;   // ms
  var DELAY_HIDE = 180;   // ms
  var $currentTarget = null;

  // 날짜 → YYYY-MM-DD
  function formatYMD(v){
    if (v == null) return '';
    var s = String(v).trim();

    // 13자리 epoch millis
    if (/^\d{13}$/.test(s)) {
      var d = new Date(Number(s));
      if (!isNaN(d.getTime())) return [
        d.getFullYear(),
        String(d.getMonth()+1).padStart(2,'0'),
        String(d.getDate()).padStart(2,'0')
      ].join('-');
    }

    // 10자리 epoch (초 단위) 대응
    if (/^\d{10}$/.test(s)) {
      var d10 = new Date(Number(s)*1000);
      if (!isNaN(d10.getTime())) return [
        d10.getFullYear(),
        String(d10.getMonth()+1).padStart(2,'0'),
        String(d10.getDate()).padStart(2,'0')
      ].join('-');
    }

    // 8자리 yyyymmdd
    if (/^\d{8}$/.test(s)) {
      return s.slice(0,4) + '-' + s.slice(4,6) + '-' + s.slice(6,8);
    }

    // 6자리 yymmdd (00–69 → 20xx, 70–99 → 19xx)
    if (/^\d{6}$/.test(s)) {
      var yy = parseInt(s.slice(0,2),10);
      var yyyy = (yy <= 69 ? 2000 + yy : 1900 + yy);
      return yyyy + '-' + s.slice(2,4) + '-' + s.slice(4,6);
    }

    // 섞인 구분자들 → 숫자만 추출 후 처리
    var digits = s.replace(/\D/g,'');
    if (digits.length === 8) {
      return digits.slice(0,4)+'-'+digits.slice(4,6)+'-'+digits.slice(6,8);
    }
    if (digits.length === 6) {
      var yy2 = parseInt(digits.slice(0,2),10);
      var yyyy2 = (yy2 <= 69 ? 2000 + yy2 : 1900 + yy2);
      return yyyy2 + '-' + digits.slice(2,4) + '-' + digits.slice(4,6);
    }

    // 마지막 시도: Date 파서
    var d2 = new Date(s);
    if (!isNaN(d2.getTime())) {
      return [
        d2.getFullYear(),
        String(d2.getMonth()+1).padStart(2,'0'),
        String(d2.getDate()).padStart(2,'0')
      ].join('-');
    }

    return s; // 실패 시 원문
  }

  function fmtPriceLocal(v){
    var n = Number(v || 0);
    return isNaN(n) ? '' : n.toLocaleString();
  }

  function buildLayerHtml(p){
    var html = '';
    html += '<div class="ttl" style="font-weight:600; margin-bottom:6px;">' + escapeHtml(p.prodName || '') + '</div>';
    html += '<div class="row" style="font-size:13px; line-height:1.4; margin:2px 0;">상품번호 : ' + (p.prodNo != null ? p.prodNo : '') + '</div>';
    html += '<div class="row price" style="font-size:13px; line-height:1.4; margin:2px 0; font-weight:600;">가격 : ' + fmtPriceLocal(p.price) + ' 원</div>';
    if (p.regDate)  html += '<div class="row" style="font-size:13px; line-height:1.4; margin:2px 0;">등록일 : ' + formatYMD(p.regDate) + '</div>';
    if (p.manuDate) html += '<div class="row" style="font-size:13px; line-height:1.4; margin:2px 0;">제조일 : ' + formatYMD(p.manuDate) + '</div>';
    if (p.proTranState) html += '<div class="row" style="font-size:13px; line-height:1.4; margin:2px 0;">상태 : ' + escapeHtml(p.proTranState) + '</div>';
    if (p.prodDetail) html += '<div class="row" style="font-size:13px; line-height:1.4; margin:2px 0;">설명 : ' + escapeHtml(String(p.prodDetail)).slice(0,180) + '</div>';

    html += '<div class="act" style="margin-top:8px; text-align:right;">' +
              '<form action="/product/getProduct" method="post" style="display:inline;">' +
                '<input type="hidden" name="prodNo" value="' + p.prodNo + '"/>' +
                '<button type="submit" class="btn-like" style="cursor:pointer; text-decoration:underline; color:#0066cc; background:none; border:none; padding:0; font:inherit;">상세보기</button>' +
              '</form>' +
            '</div>';
    return html;
  }

  function placeLayerNear($anchor){
    var rect = $anchor[0].getBoundingClientRect();
    var scrollX = window.pageXOffset || document.documentElement.scrollLeft;
    var scrollY = window.pageYOffset || document.documentElement.scrollTop;

    var top  = rect.bottom + scrollY + 6; // 우하단 기본
    var left = rect.left   + scrollX;

    var vw = window.innerWidth;
    var vh = window.innerHeight;
    var lw = $layer.outerWidth();
    var lh = $layer.outerHeight();

    if (left + lw > scrollX + vw - 8) left = Math.max(8 + scrollX, rect.right + scrollX - lw);
    if (top  + lh > scrollY + vh - 8) top  = Math.max(8 + scrollY, rect.top   + scrollY - lh - 6);

    $layer.css({ top: top + 'px', left: left + 'px' });
  }

  function doShow($anchor, prodNo){
    if ($currentTarget && $currentTarget[0] === $anchor[0] && $layer.is(':visible')) return;

    var onData = function(p){
      $layer.html(buildLayerHtml(p)).show().attr('aria-hidden','false');
      placeLayerNear($anchor);
      $currentTarget = $anchor;
    };

    if (cache[prodNo]){
      onData(cache[prodNo]);
      return;
    }

    $.ajax({
      url: (cPath || '') + '/product/json/getProduct/' + encodeURIComponent(prodNo),
      method: 'GET',
      dataType: 'json'
    }).done(function(p){
      if (p && typeof p === 'object'){
        cache[prodNo] = p;
        onData(p);
      }
    });
  }

  function scheduleShow($anchor){
    clearTimeout(showTimer);
    clearTimeout(hideTimer);
    var prodNo = $anchor.data('prodno');
    if (!prodNo) return;
    showTimer = setTimeout(function(){ doShow($anchor, prodNo); }, DELAY_SHOW);
  }

  function scheduleHide(){
    clearTimeout(showTimer);
    clearTimeout(hideTimer);
    hideTimer = setTimeout(hideNow, DELAY_HIDE);
  }

  function hideNow(){
    $layer.hide().attr('aria-hidden','true');
    $currentTarget = null;
  }

  $(document).on('mouseenter', '.prod-link', function(){ scheduleShow($(this)); });
  $(document).on('mouseleave', '.prod-link', function(){ scheduleHide(); });

  $layer.on('mouseenter', function(){ clearTimeout(hideTimer); });
  $layer.on('mouseleave', function(){ scheduleHide(); });

  $(window).on('scroll resize', function(){
    if ($layer.is(':visible')) hideNow();
  });
})();


  // =========================
  // 10) 이벤트 바인딩
  // =========================
  $(function () {
    // 폼 submit 자체는 막음 (무한스크롤 환경에서는 페이지 전환 금지)
    $form.on("submit", function (e) {
      e.preventDefault();
      return false;
    });

    // 검색 버튼
    $("#btnSearch").on("click", function () { submitList(1); });

    // 정렬 버튼
    $(document).on("click", ".sort-price", function () {
      var order = $(this).data("order"); // 'ASC' / 'DESC'
      submitList(state.currentPage || 1, order);
    });

    // 엔터로 검색
    $("#detailForm input[name='searchKeyword']").on("keydown", function (e) {
      if (e.key === "Enter" || e.keyCode === 13) {
        e.preventDefault();
        submitList(1);
      }
    });

    // 스크롤
    $(global).on("scroll", onScroll);

    // 초기 상태: SSR로 1페이지가 이미 렌더링되어 있으므로 다음 스크롤부터 2페이지 호출
    // 단, 사용자가 정렬/검색을 누르면 resetAndReload()로 1페이지부터 다시 로드
  });

  // =========================
  // 11) pageNavigator.jsp 호환 함수
  // =========================
  global.fncGetList = function (currentPage, orderByPriceAsc) {
    if (orderByPriceAsc != null && orderByPriceAsc !== "") {
      $orderByPriceAsc.val(orderByPriceAsc);
    }
    submitList(currentPage || 1);
    return false;
  };

})(window, window.jQuery);
