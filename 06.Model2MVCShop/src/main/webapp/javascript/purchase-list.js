// /javascript/purchase-list.js
// - listPurchase.jsp 전용 (무한 스크롤 + 상태변경 AJAX + 상세 미리보기 Hover)
(function (global, $) {
  "use strict";

  var state = {
    currentPage: 1,
    pageSize: null,     // 서버 응답에서 세팅
    totalCount: 0,
    loading: false,
    done: false
  };

  var $tbody, $loader;

  // ========= 공통 유틸 =========
  function fmtPrice(n) {
    if (n == null) return "";
    var num = Number(n);
    if (isNaN(num)) return String(n);
    return num.toLocaleString();
  }
  function esc(s) { return $("<div/>").text(s == null ? "" : String(s)).html(); }
  function tranStateLabel(s) { return '<span class="state-label">' + esc(s || "") + "</span>"; }
  function resolveTranState(code) {
    switch (Number(code || 0)) {
      case 2: return "배송중";
      case 3: return "배송완료";
      default: return "구매완료";
    }
  }

  // ========= 행 빌드 =========
  function buildActions(tranNo, tranStateText) {
    var html = [];
    // 배송중일 때만 노출
    if (tranStateText === "배송중") {
      html.push(
        '<button type="button" class="btn js-arrived" data-tran-no="' +
          tranNo +
          '">물건도착</button>'
      );
    }
    return html.join(" ");
  }

  function buildRow(purchase, rowNo, tranStateText) {
    var prod = purchase && purchase.purchaseProd ? purchase.purchaseProd : {};
    var name = esc(prod.prodName);
    var detail = esc(prod.prodDetail || "");
    var price = fmtPrice(prod.price);

    return [
      '<tr class="ct_list_pop" data-tran-no="' + purchase.tranNo + '">',
      '  <td align="center">' + rowNo + "</td>",
      "  <td></td>",
      // ▼ 미리보기용 클래스/데이터 속성 부여 (purchase-link, data-tranno)
      '  <td align="left"><a href="/purchase/getPurchase?tranNo=' + purchase.tranNo + '"',
      '     class="purchase-link" data-tranno="' + purchase.tranNo + '">',
            name, '</a></td>',
      "  <td></td>",
      '  <td align="left">' + detail + "</td>",
      "  <td></td>",
      '  <td align="right">' + price + "</td>",
      "  <td></td>",
      '  <td align="center" class="td-state">현재 ' + tranStateLabel(tranStateText) + ' 상태입니다.</td>',
      "  <td></td>",
      '  <td align="center" class="td-actions">' + buildActions(purchase.tranNo, tranStateText) + "</td>",
      "</tr>",
      '<tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>',
    ].join("");
  }

  function renderEmpty() {
    $tbody.html(
      [
        "<tr>",
        '  <td colspan="11" align="center" class="ct_list_pop empty-row">표시할 구매내역이 없습니다.</td>',
        "</tr>",
        '<tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>',
      ].join("")
    );
  }

  function updateSummary() { $("#totalCount").text(state.totalCount || 0); }

  function computeRowNo(indexInPage) {
    // rowNo = totalCount - ((currentPage - 1) * pageSize) - index
    return state.totalCount - ((state.currentPage - 1) * state.pageSize) - indexInPage;
  }

  function loadNext() {
    if (state.loading || state.done) return;
    state.loading = true;
    $loader.show().text("불러오는 중...");

    var body = JSON.stringify({
      currentPage: state.currentPage,
      pageSize: state.pageSize || 0,
    });

    $.ajax({
      url: "/purchase/json/getPurchaseList",
      type: "POST",
      data: body,
      contentType: "application/json; charset=UTF-8",
      dataType: "json",
    })
      .done(function (res) {
        if (state.pageSize == null && res && res.search && res.search.pageSize) {
          state.pageSize = Number(res.search.pageSize) || 10;
        }
        if (res && typeof res.totalCount === "number") {
          state.totalCount = res.totalCount;
        }
        updateSummary();

        var list = (res && res.list) || [];
        var tranMap = (res && res.tranStateMap) || {};

        if (state.currentPage === 1 && list.length === 0) {
          renderEmpty();
          state.done = true;
          return;
        }

        for (var i = 0; i < list.length; i++) {
          var p = list[i];
          var rowNo = computeRowNo(i);
          var tranText = tranMap[p.tranNo];
          $tbody.append(buildRow(p, rowNo, tranText));
        }

        if (!state.pageSize || list.length < state.pageSize || $tbody.children("tr.ct_list_pop").length >= state.totalCount) {
          state.done = true;
          $loader.text("모든 항목을 불러왔습니다.");
        } else {
          state.currentPage += 1;
          $loader.hide();
        }
      })
      .fail(function () {
        $loader.text("불러오는 중 오류가 발생했습니다. 새로고침 해보세요.");
      })
      .always(function () {
        state.loading = false;
      });
  }

  function setupInfiniteScroll() {
    var sentinel = document.getElementById("sentinel");
    if (!("IntersectionObserver" in window) || !sentinel) {
      $(window).on("scroll", function () {
        if (state.loading || state.done) return;
        var nearBottom = window.innerHeight + window.scrollY >= document.body.offsetHeight - 300;
        if (nearBottom) loadNext();
      });
      return;
    }

    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) { if (entry.isIntersecting) loadNext(); });
      },
      { root: null, rootMargin: "0px", threshold: 0.1 }
    );

    io.observe(sentinel);
  }

  // ========= 상태 변경 AJAX =========
  function markArrived(tranNo, $btn) {
    if (!tranNo) return;
    $btn.prop("disabled", true).text("처리중...");

    $.ajax({
      url: "/purchase/json/updateTranCode",
      type: "POST",
      data: JSON.stringify({ tranNo: Number(tranNo), tranStatusCode: "3" }),
      contentType: "application/json; charset=UTF-8",
      dataType: "json",
    })
      .done(function (ok) {
        if (ok) {
          var $row = $btn.closest("tr.ct_list_pop");
          $row.find(".td-state").html("현재 " + tranStateLabel("배송완료") + " 상태입니다.");
          $row.find(".td-actions").empty();
        } else {
          alert("처리 결과를 확인할 수 없습니다.");
          $btn.prop("disabled", false).text("물건도착");
        }
      })
      .fail(function () {
        alert("상태 변경 중 오류가 발생했습니다.");
        $btn.prop("disabled", false).text("물건도착");
      });
  }

  // (옵션) 주문취소 AJAX
  function cancelPurchase(tranNo, $btn) {
    if (!tranNo) return;
    if (!confirm("이 주문을 취소하시겠습니까?")) return;
    $btn.prop("disabled", true).text("취소중...");

    $.ajax({
      url: "/purchase/json/cancelPurchase",
      type: "POST",
      data: { tranNo: tranNo },
      dataType: "json",
    })
      .done(function (res) {
        if (res && res.success) {
          var $row = $btn.closest("tr.ct_list_pop");
          var $sep = $row.next("tr");
          $row.remove();
          if ($sep.length) $sep.remove();
          alert(res.message || "주문이 취소되었습니다.");
        } else {
          alert((res && res.message) || "취소 처리에 실패했습니다.");
          $btn.prop("disabled", false).text("주문취소");
        }
      })
      .fail(function () {
        alert("취소 처리 중 오류가 발생했습니다.");
        $btn.prop("disabled", false).text("주문취소");
      });
  }

  // ========= 구매 상세 미리보기(Hover) =========
  (function purchaseHoverPreview(){
    var $layer = $('<div class="purchase-hover-layer" role="dialog" aria-hidden="true"></div>').appendTo(document.body);
    var cache = {};         // tranNo -> purchase json 캐시
    var showTimer = null;   // hover 지연
    var hideTimer = null;   // 레이어 자동 숨김 지연
    var DELAY_SHOW = 160;   // ms
    var DELAY_HIDE = 180;   // ms
    var $currentTarget = null;

    function formatYMD(v){
      if (v == null) return '';
      var s = String(v).trim();
      // 13자리 epoch millis
      if (/^\d{13}$/.test(s)) {
        var d = new Date(Number(s));
        if (!isNaN(d.getTime())) return [
          d.getFullYear(), String(d.getMonth()+1).padStart(2,'0'), String(d.getDate()).padStart(2,'0')
        ].join('-');
      }
      // 10자리 epoch seconds
      if (/^\d{10}$/.test(s)) {
        var d10 = new Date(Number(s)*1000);
        if (!isNaN(d10.getTime())) return [
          d10.getFullYear(), String(d10.getMonth()+1).padStart(2,'0'), String(d10.getDate()).padStart(2,'0')
        ].join('-');
      }
      // 8자리 yyyymmdd
      if (/^\d{8}$/.test(s)) return s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8);
      // fallback
      var d2 = new Date(s);
      if (!isNaN(d2.getTime())) {
        return [d2.getFullYear(), String(d2.getMonth()+1).padStart(2,'0'), String(d2.getDate()).padStart(2,'0')].join('-');
      }
      return s;
    }

    function buildLayerHtml(p){
      var prod = p && p.purchaseProd ? p.purchaseProd : {};
      var buyer = p && p.buyer ? p.buyer : {};
      var tranState = resolveTranState(p && p.tranCode);

      var html = '';
      html += '<div class="ttl">' + esc(prod.prodName || '상품명 없음') + '</div>';
      html += '<div class="row">거래번호 : ' + (p.tranNo != null ? p.tranNo : '') + '</div>';
      if (buyer.userId)   html += '<div class="row">구매자 : ' + esc(buyer.userId) + '</div>';
      if (prod.price != null) html += '<div class="row price">가격 : ' + fmtPrice(prod.price) + ' 원</div>';
      html += '<div class="row">상태 : ' + esc(tranState) + '</div>';
      if (p.orderDate) html += '<div class="row">주문일 : ' + formatYMD(p.orderDate) + '</div>';
      if (prod.prodDetail) html += '<div class="row">설명 : ' + esc(String(prod.prodDetail)).slice(0,180) + '</div>';
      html += '<div class="act">' +
                '<a href="/purchase/getPurchase?tranNo=' + p.tranNo + '" class="btn-like">상세보기</a>' +
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

    function doShow($anchor, tranNo){
      if ($currentTarget && $currentTarget[0] === $anchor[0] && $layer.is(':visible')) return;

      function onData(p){
        $layer.html(buildLayerHtml(p)).show().attr('aria-hidden','false');
        placeLayerNear($anchor);
        $currentTarget = $anchor;
      }

      if (cache[tranNo]){
        onData(cache[tranNo]);
        return;
      }

      $.ajax({
        url: '/purchase/json/getPurchase/' + encodeURIComponent(tranNo),
        method: 'GET',
        dataType: 'json'
      }).done(function(p){
        if (p && typeof p === 'object'){
          cache[tranNo] = p;
          onData(p);
        }
      });
    }

    function scheduleShow($anchor){
      clearTimeout(showTimer); clearTimeout(hideTimer);
      var tranNo = $anchor.data('tranno');
      if (!tranNo) return;
      showTimer = setTimeout(function(){ doShow($anchor, tranNo); }, DELAY_SHOW);
    }

    function scheduleHide(){
      clearTimeout(showTimer); clearTimeout(hideTimer);
      hideTimer = setTimeout(hideNow, DELAY_HIDE);
    }

    function hideNow(){
      $layer.hide().attr('aria-hidden','true');
      $currentTarget = null;
    }

    // 링크 hover 핸들
    $(document).on('mouseenter', '.purchase-link', function(){ scheduleShow($(this)); });
    $(document).on('mouseleave', '.purchase-link', function(){ scheduleHide(); });

    // 레이어 위에 마우스 올려도 유지
    $layer.on('mouseenter', function(){ clearTimeout(hideTimer); });
    $layer.on('mouseleave', function(){ scheduleHide(); });

    // 스크롤/리사이즈 시 자동 닫기
    $(window).on('scroll resize', function(){
      if ($layer.is(':visible')) hideNow();
    });
  })();

  // ========= 초기화 =========
  $(function () {
    $tbody = $("#purchaseBody");
    $loader = $("#infiniteLoader");

    // 첫 로드
    loadNext();
    setupInfiniteScroll();

    // 상태 변경(배송완료) 위임
    $(document).on("click", ".js-arrived", function () {
      var $btn = $(this);
      var tranNo = $btn.data("tran-no");
      markArrived(tranNo, $btn);
    });

    // (옵션) 주문취소 버튼 위임
    $(document).on("click", ".js-cancel", function () {
      var $btn = $(this);
      var tranNo = $btn.data("tran-no");
      cancelPurchase(tranNo, $btn);
    });
  });
})(window, window.jQuery);
