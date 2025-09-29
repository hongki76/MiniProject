// /javascript/purchase-list.js
// - listPurchase.jsp 전용
// - pageNavigator.jsp가 호출하는 fncGetList(page)를 전역에서 제공
(function (global, $) {
  "use strict";

  function submitPage(page) {
    var $form = $("#detailForm");
    if ($form.length === 0) return;

    // currentPage hidden 보장
    var $cp = $form.find("input[name='currentPage']");
    if ($cp.length === 0) {
      $cp = $('<input type="hidden" name="currentPage" />').appendTo($form);
    }
    $cp.val(page);

    $form.trigger("submit");
  }

  // pageNavigator.jsp가 호출하는 이름 유지
  global.fncGetList = function (page) {
    submitPage(page);
  };

  // (선택) data-page를 쓰는 페이징 링크를 지원하고 싶다면 활성화
  $(function () {
    $(document).on("click", "[data-page]", function (e) {
      var page = $(this).data("page");
      if (typeof page === "number" || /^[0-9]+$/.test(page)) {
        e.preventDefault();
        submitPage(page);
      }
    });
  });
  
  // 상태 텍스트만 <span class="state-label">로 감싸 주황색 적용
  $(function () {
    $("tr.ct_list_pop td").each(function () {
      const text = $(this).text().trim();

      // "현재 ... 상태입니다." 패턴만 처리 (마침표 유무/공백 허용)
      const m = text.match(/^현재\s*(.+?)\s*상태입니다\.?$/);
      if (!m) return;

      const state = m[1]; // 상태만 추출
      // 기존 텍스트를 안전하게 재구성
      $(this).html(
        `현재 <span class="state-label">${$("<div>").text(state).html()}</span> 상태입니다.`
      );
    });

    // 스타일 적용 (CSS 파일로 빼도 OK)
    $(".state-label").css("color", "orange");
  });


})(window, window.jQuery);
