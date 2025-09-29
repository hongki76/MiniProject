// /javascript/purchase-get.js
// - getPurchase.jsp 전용: 확인 버튼 처리(뒤로가기)

(function (global, $) {
  "use strict";

  $(function () {
    $(document).on("click", "#btnOk", function (e) {
      e.preventDefault();
      if (global.history && typeof global.history.back === "function") {
        global.history.back();
      } else {
        // 폴백: 목록으로
        global.location.href = "/purchase/getPurchaseList";
      }
    });
  });

})(window, window.jQuery);
