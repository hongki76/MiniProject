// /javascript/product-list.js
// - listProduct.jsp 전용 스크립트 (무한스크롤 + 자동완성 + Hover 미리보기)
// - 현재상태: proTranCode==0 → 판매중, 그 외(1/2/3) → 재고없음
(function (global, $) {
  "use strict";

  var CFG = global.__PRODUCT_LIST_CONFIG__ || {};
  var cPath = CFG.cPath || "";

  var $form = $("#detailForm");
  var $tbody = $("#productTbody");
  var $currentPageInput = $("#currentPage");
  var $orderByPriceAsc = $("#orderByPriceAsc");

  var $totalCountSpan = $("#totalCountSpan");
  var $currentPageSpan = $("#currentPageSpan");

  var ssrRowCount = $("#productTbody .ct_list_pop").length;

  var state = {
    currentPage: Number((CFG.currentPageSSR != null ? CFG.currentPageSSR : ($currentPageSpan.text() || 1))) || 1,
    pageSize: (CFG.pageSizeSSR != null ? CFG.pageSizeSSR : null),
    totalCount: Number((CFG.totalCountSSR != null ? CFG.totalCountSSR : ($totalCountSpan.text() || 0))) || 0,
    loadedCount: ssrRowCount || 0
  };

  var loading = false;
  var allLoaded = false;

  // 검색 입력 UX (자동완성용 placeholder/검증 설정)
  (function initSearchInputUX() {
    var $cond = $("#searchCondition");
    var $kw   = $("#searchKeyword");
    var $reg  = $("#regDateKeyword");

    function applyPlaceholderAndValidation() {
      var v = String($cond.val());
      $kw.removeAttr("num").removeAttr("valCheck").removeAttr("maxLength").attr("placeholder", "");

      if (v === "0") { $kw.attr("placeholder", "상품명 입력"); if ($reg.val()) $kw.val(""); }
      else if (v === "1") { $kw.attr("placeholder", "상품설명 입력"); if ($reg.val()) $kw.val(""); }
      else if (v === "2") { $kw.attr("placeholder", "YYYYMMDD"); $kw.attr("valCheck","DATE").attr("maxLength","8"); }
    }

    $(document).on("input blur", "#searchKeyword", function () {
      if (String($cond.val()) !== "2") return;
      var digits = (this.value || "").replace(/\D/g, "");
      if (digits.length === 8) $reg.val(digits);
    });

    $(applyPlaceholderAndValidation);
    $cond.on("change", function () { $kw.val(""); applyPlaceholderAndValidation(); });
  })();

  function n(v){ return Number(v||0); }
  function fmtPrice(v){ var num=n(v); return isNaN(num)?(v==null?"":String(v)):num.toLocaleString(); }
  function escapeHtml(s){ if(s==null)return ""; return String(s).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&#39;"); }
  function isAdmin(){ return (CFG.role || "") === "admin"; }
  function isLogin(){ return !!CFG.isLogin; }

  // 상태 배지
  function sellingBadge(code){
    var c = (code == null) ? "" : String(code);
    return (c === "0") ? '<span class="badge on">판매중</span>'
                       : '<span class="badge off">재고없음</span>';
  }

  // ===== 행 HTML (현재상태 / 작업 분리) =====
  function buildRow(product, rowNo) {
    // 작업 버튼: 관리자 & proTranCode == 1(구매완료) → 배송하기
    var actionHtml = "";
    if (isLogin() && isAdmin() && String(product.proTranCode) === "1") {
      actionHtml = '<a href="' + (cPath||"") +
                   '/purchase/updateTranCodeByProduct?prodNo=' + product.prodNo +
                   '&amp;tranStatusCode=2" class="a-like">배송하기</a>';
    }

    var html =
      '<tr class="ct_list_pop">' +
        '<td align="center">' + rowNo + '</td>' +
        '<td></td>' +
        '<td align="left">' +
          '<form action="' + (cPath||"") + '/product/getProduct" method="post" style="display:inline;">' +
            '<input type="hidden" name="prodNo" value="' + product.prodNo + '"/>' +
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
        // 현재상태
        '<td align="center">' + sellingBadge(product.proTranCode) + '</td>' +
        '<td></td>' +
        // 작업
        '<td align="center">' + (actionHtml || '') + '</td>' +
      '</tr>' +
      '<tr><td colspan="11" bgcolor="D6D7D6" height="1"></td></tr>';

    return html;
  }

  // ===== AJAX 로딩 =====
  function buildPayload(nextPage) {
    return {
      currentPage: nextPage,
      pageSize: state.pageSize || undefined,
      orderByPriceAsc: $orderByPriceAsc.val(),
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

    $.ajax({
      url: (cPath || "") + "/product/json/getProductList",
      method: "POST",
      contentType: "application/json; charset=UTF-8",
      dataType: "json",
      data: JSON.stringify(buildPayload(nextPage))
    }).done(function (res) {
      var list = res && res.list ? res.list : [];
      var page = res && res.resultPage ? res.resultPage : {};

      if (!state.pageSize && page.pageSize) state.pageSize = page.pageSize;
      if (page.totalCount != null) state.totalCount = page.totalCount;

      var baseNo = state.totalCount - ((nextPage - 1) * (state.pageSize || list.length));

      var html = "";
      list.forEach(function (p, i) { html += buildRow(p, baseNo - i); });

      if (html) {
        $tbody.append(html);
        state.loadedCount += list.length;
        state.currentPage = nextPage;

        $currentPageInput.val(state.currentPage);
        if ($currentPageSpan.length) $currentPageSpan.text(state.currentPage);
        if ($totalCountSpan.length)  $totalCountSpan.text(state.totalCount);
      }

      if (!list.length || (state.loadedCount >= state.totalCount)) {
        allLoaded = true;
      }

      if (typeof onDone === "function") onDone();
    }).always(function () { loading = false; });
  }

  // 스크롤 로딩
  function nearBottom() {
    var scrollTop = global.scrollY || document.documentElement.scrollTop;
    var viewport  = global.innerHeight || document.documentElement.clientHeight;
    var full      = document.documentElement.scrollHeight;
    return (scrollTop + viewport + 200 >= full);
  }
  var scrollTick = false;
  function onScroll() {
    if (scrollTick) return;
    scrollTick = true;
    requestAnimationFrame(function () {
      scrollTick = false;
      if (nearBottom()) fetchPage(state.currentPage + 1);
    });
  }

  function resetAndReload() {
    $tbody.empty();
    state.currentPage = 0;
    state.loadedCount = 0;
    allLoaded = false;
    fetchPage(1);
    if ($currentPageSpan.length) $currentPageSpan.text(1);
  }

  function submitList(page, order) {
    if (order !== undefined && order !== null && order !== "") {
      $orderByPriceAsc.val(order);
    }
    if (global.FormValidation && !global.FormValidation($form.get(0))) return;
    resetAndReload();
  }

  // ===== 자동완성 =====
  (function autoCompleteModule() {
    var $kw   = $("#searchKeyword");
    var $cond = $("#searchCondition");

    var menu = null, items = [], activeIndex = -1, lastReq = 0;
    var DEBOUNCE_MS = 120, timer = null;

    function ensureMenu() {
      if (menu && menu.length) return menu;
      menu = $('<div class="ac-menu" style="display:none; position:absolute; z-index:1000; min-width:200px; max-height:240px; overflow-y:auto; border:1px solid #ccc; background:#fff; box-shadow:0 2px 6px rgba(0,0,0,.08);"></div>');
      var $wrap = $(".ac-wrap");
      if ($wrap.length) { $wrap.css("position","relative").append(menu); }
      else {
        var $p = $kw.parent();
        if ($p.css("position")==="static") $p.css("position","relative");
        $p.append(menu);
      }
      return menu;
    }

    function hideMenu(){ if(menu){ menu.hide(); } items=[]; activeIndex=-1; }

    function renderMenu(list){
      ensureMenu().empty();
      if (!list || !list.length) { hideMenu(); return; }
      items = list.slice(0);
      activeIndex = -1;

      list.forEach(function (text, idx) {
        var $it = $('<div class="ac-item" style="padding:8px 10px; cursor:pointer;"></div>').text(text);
        // mousedown: blur 전에 값 확정
        $it.on('mousedown', function(e){ e.preventDefault(); applyChoice(idx); });
        $it.on('mouseenter', function(){
          menu.children().removeClass('active');
          $(this).addClass('active');
          activeIndex = idx;
        });
        menu.append($it);
      });

      ensureMenu().css({ minWidth: $kw.outerWidth()+"px" }).show();
    }

    function moveActive(delta){
      if (!items.length) return;
      activeIndex = (activeIndex + delta + items.length) % items.length;
      menu.children().removeClass('active')
          .eq(activeIndex).addClass('active').css('background','#f0f6ff');
    }

    function applyChoice(i){
      if (i < 0 || i >= items.length) return;
      $kw.val(items[i]).trigger('input'); // 등록일 모드면 히든값 갱신 로직과 연계
      hideMenu();
    }

    function debounce(fn, wait){
      return function(){
        clearTimeout(timer);
        var ctx=this, args=arguments;
        timer=setTimeout(function(){ fn.apply(ctx,args); }, wait);
      };
    }

    // 자동완성 호출부
    var requestSuggestDebounced = debounce(function(){
      var cond = String($cond.val() || "0"); // 0:상품명, 1:상품설명, 2:등록일
      var kw   = String($kw.val() || "").trim();

      // 상품설명(cond==="1")은 자동완성 비활성화
      if (cond === "1") { hideMenu(); return; }

      if (cond === "2") { // 등록일: 숫자 prefix 필요
        if (kw.replace(/\D/g,"").length < 1) { hideMenu(); return; }
      } else {            // 상품명
        if (kw.length < 1) { hideMenu(); return; }
      }

      var reqId = ++lastReq;

      $.ajax({
        url: (cPath || "") + "/product/json/autoComplete",
        method: "POST",
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        data: JSON.stringify({
          searchCondition: cond,
          keyword: (cond === "2" ? kw.replace(/\D/g,"") : kw),
          limit: 10
        })
      }).done(function(list){
        if (reqId !== lastReq) return; // 응답 역전 방지
        renderMenu(Array.isArray(list) ? list : []);
      }).fail(function(){
        hideMenu();
      });
    }, DEBOUNCE_MS);

    // 이벤트 바인딩
    $kw.on("input focus", requestSuggestDebounced);

    $kw.on("keydown", function (e) {
      if (!menu || menu.is(":hidden")) return;
      switch (e.key) {
        case "ArrowDown": e.preventDefault(); moveActive(1);  break;
        case "ArrowUp":   e.preventDefault(); moveActive(-1); break;
        case "Enter":
          if (activeIndex >= 0) { e.preventDefault(); applyChoice(activeIndex); }
          break;
        case "Escape": hideMenu(); break;
      }
    });

    $kw.on("blur", function(){ setTimeout(hideMenu, 120); });

    // 모드 변경 시 메뉴 닫기
    $("#searchCondition").on("change", function () { hideMenu(); });
  })();

  // ===== Hover 미리보기 (기존 유지) =====
  (function hoverPreview(){
    var $layer = $('<div class="prod-hover-layer" role="dialog" aria-hidden="true"></div>').appendTo(document.body);
    var cache = {}, showTimer=null, hideTimer=null, $currentTarget=null;
    var DELAY_SHOW=160, DELAY_HIDE=180;

    function formatYMD(v){
      if(v==null) return '';
      var s=String(v).trim();
      if(/^\d{13}$/.test(s)){ var d=new Date(Number(s)); if(!isNaN(d.getTime())) return [d.getFullYear(),String(d.getMonth()+1).padStart(2,'0'),String(d.getDate()).padStart(2,'0')].join('-'); }
      if(/^\d{10}$/.test(s)){ var d2=new Date(Number(s)*1000); if(!isNaN(d2.getTime())) return [d2.getFullYear(),String(d2.getMonth()+1).padStart(2,'0'),String(d2.getDate()).padStart(2,'0')].join('-'); }
      if(/^\d{8}$/.test(s)) return s.slice(0,4)+'-'+s.slice(4,6)+'-'+s.slice(6,8);
      return s;
    }
    function fmtPriceLocal(v){ var n=Number(v||0); return isNaN(n)?'':n.toLocaleString(); }
    function buildLayerHtml(p){
      var html='';
      html+='<div class="ttl">'+escapeHtml(p.prodName||'')+'</div>';
      html+='<div class="row">상품번호 : '+(p.prodNo!=null?p.prodNo:'')+'</div>';
      html+='<div class="row price">가격 : '+fmtPriceLocal(p.price)+' 원</div>';
      if(p.regDate)  html+='<div class="row">등록일 : '+formatYMD(p.regDate)+'</div>';
      if(p.manuDate) html+='<div class="row">제조일 : '+formatYMD(p.manuDate)+'</div>';
      if(p.proTranCode!=null) html+='<div class="row">상태 : '+(String(p.proTranCode)==='0'?'판매중':'재고없음')+'</div>';
      if(p.prodDetail) html+='<div class="row">설명 : '+escapeHtml(String(p.prodDetail)).slice(0,180)+'</div>';
      html+='<div class="act"><form action="'+(cPath||"")+'/product/getProduct" method="post" style="display:inline;"><input type="hidden" name="prodNo" value="'+p.prodNo+'"/><button type="submit" class="btn-like">상세보기</button></form></div>';
      return html;
    }
    function placeLayerNear($a){
      var r=$a[0].getBoundingClientRect();
      var sx=window.pageXOffset||document.documentElement.scrollLeft;
      var sy=window.pageYOffset||document.documentElement.scrollTop;
      $layer.css({top:(r.bottom+sy+6)+'px', left:(r.left+sx)+'px'});
    }
    function doShow($a, prodNo){
      if($currentTarget && $currentTarget[0]===$a[0] && $layer.is(':visible')) return;
      var onData=function(p){ $layer.html(buildLayerHtml(p)).show().attr('aria-hidden','false'); placeLayerNear($a); $currentTarget=$a; };
      if(cache[prodNo]){ onData(cache[prodNo]); return; }
      $.getJSON((cPath||'')+'/product/json/getProduct/'+encodeURIComponent(prodNo), function(p){
        if(p && typeof p==='object'){ cache[prodNo]=p; onData(p); }
      });
    }
    function scheduleShow($a){
      clearTimeout(showTimer); clearTimeout(hideTimer);
      var prodNo=$a.data('prodno'); if(!prodNo) return;
      showTimer=setTimeout(function(){ doShow($a, prodNo); }, DELAY_SHOW);
    }
    function scheduleHide(){ clearTimeout(showTimer); clearTimeout(hideTimer); hideTimer=setTimeout(hideNow, DELAY_HIDE); }
    function hideNow(){ $layer.hide().attr('aria-hidden','true'); $currentTarget=null; }

    $(document).on('mouseenter', '.prod-link', function(){ scheduleShow($(this)); });
    $(document).on('mouseleave', '.prod-link', function(){ scheduleHide(); });
    $layer.on('mouseenter', function(){ clearTimeout(hideTimer); });
    $layer.on('mouseleave', function(){ scheduleHide(); });
    $(window).on('scroll resize', function(){ if($layer.is(':visible')) hideNow(); });
  })();

  // 이벤트 바인딩
  $(function () {
    $form.on("submit", function (e) { e.preventDefault(); return false; });
    $("#btnSearch").on("click", function () { submitList(1); });
    $(document).on("click", ".sort-price", function () { submitList(state.currentPage || 1, $(this).data("order")); });
    $("#detailForm input[name='searchKeyword']").on("keydown", function (e) {
      if (e.key === "Enter" || e.keyCode === 13) { e.preventDefault(); submitList(1); }
    });
    $(global).on("scroll", onScroll);
  });

  // pageNavigator.jsp 호환
  global.fncGetList = function (currentPage, orderByPriceAsc) {
    if (orderByPriceAsc != null && orderByPriceAsc !== "") {
      $orderByPriceAsc.val(orderByPriceAsc);
    }
    submitList(currentPage || 1);
    return false;
  };

})(window, window.jQuery);
