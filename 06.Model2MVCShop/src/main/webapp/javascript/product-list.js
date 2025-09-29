// - listProduct.jsp 전용 스크립트
// - pageNavigator.jsp 호환 위해 전역 fncGetList 유지
(function (global, $) {
  "use strict";

  function submitList(page, order) {
    var $form = $("#detailForm");
    if ($form.length === 0) return;

    if (page !== undefined && page !== null && page !== "") {
      $("#currentPage").val(page);
    }
    if (order !== undefined && order !== null && order !== "") {
      $("#orderByPriceAsc").val(order); // 'ASC' or 'DESC'
    }

    // (선택) 공통 검증 사용 시
    if (global.FormValidation && !global.FormValidation($form.get(0))) {
      return;
    }

    $form.trigger("submit");
  }

  // === DOM Ready ===
  $(function () {
    // 검색 버튼 → 1페이지
    $("#btnSearch").on("click", function () {
      submitList(1);
    });

    // 가격 정렬 버튼(↑/↓)
    $(document).on("click", ".sort-price", function () {
      var order = $(this).data("order"); // 'ASC' / 'DESC'
      submitList($("#currentPage").val() || 1, order);
    });

    // Enter로 검색
    $("#detailForm input[name='searchKeyword']").on("keydown", function (e) {
      if (e.key === "Enter" || e.keyCode === 13) {
        e.preventDefault();
        submitList(1);
      }
    });

    // (선택) 페이지 네비 a[data-page] 지원
    $(document).on("click", "a[data-page]", function (e) {
      e.preventDefault();
      var p = $(this).data("page");
      submitList(p);
    });
  });

  // === pageNavigator.jsp 호환 함수 ===
  global.fncGetList = function (currentPage, orderByPriceAsc) {
    submitList(currentPage, orderByPriceAsc);
    return false;
  };

})(window, window.jQuery);
