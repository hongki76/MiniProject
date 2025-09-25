// /javascript/product-get.js
// - getProduct.jsp 전용: 뒤로가기, (선택) 구매 클릭 제어 등

(function (global, $) {
  "use strict";

  $(function () {
    // 뒤로가기 (history API)
    $(document).on("click", "#btnBack", function (e) {
      e.preventDefault();
      if (global.history && typeof global.history.back === "function") {
        global.history.back();
      } else {
        // 히스토리 없을 때 fallback: 목록으로
        var cpath = $("#btnBuy").data("cpath") || "";
        global.location.href = cpath + "/product/getProductList";
      }
    });

    // (선택) 구매 링크 클릭 시, 필요하면 확인/추가 파라미터 주입 등 처리 가능
    // 현재는 GET 그대로 두되, 예외 상황 대비해서 disabled class 클릭 방지
    $(document).on("click", ".txt-disabled", function (e) {
      e.preventDefault();
      return false;
    });

    // (옵션) GET → POST로 바꾸고 싶을 때 주석을 참고해 전환 가능
    // $(document).on("click", "#btnBuy[data-prodno]", function (e) {
    //   e.preventDefault();
    //   var prodNo = $(this).data("prodno");
    //   var cpath  = $(this).data("cpath") || "";
    //   // 동적 폼 POST
    //   var $f = $('<form>', { method: 'post', action: cpath + '/purchase/addPurchase' }).append(
    //     $('<input>', { type: 'hidden', name: 'prodNo', value: prodNo })
    //   );
    //   $('body').append($f);
    //   $f.trigger('submit');
    // });
  });

})(window, window.jQuery);
