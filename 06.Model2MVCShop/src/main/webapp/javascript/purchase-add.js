// /javascript/purchase-add.js
// - addPurchaseView.jsp 전용: 제출/취소/달력 오픈 (검증은 CommonScript-jq.js의 FormValidation 사용)

(function (global, $) {
  "use strict";

  function submitForm() {
    var $form = $("#addPurchase");
    if ($form.length === 0) return;

    // 1) 공통 검증 호출: 각 필드의 required / fieldTitle / valCheck / format 등 속성 기반
    if (global.FormValidation && !global.FormValidation($form.get(0))) {
      return; // 포커스/알럿은 CommonScript-jq.js가 처리
    }

    // 2) 서버로 전송
    $form.trigger("submit");
  }

  function cancelForm() {
    if (global.history && typeof global.history.back === "function") {
      global.history.back();
    } else {
      global.location.href = "/product/getProductList";
    }
  }

  $(function () {

    // === 구매/취소 ===
    $(document).on("click", "#btnSubmit", function (e) {
      e.preventDefault();
      submitForm();
    });

    $(document).on("click", "#btnCancel", function (e) {
      e.preventDefault();
      cancelForm();
    });

    // === 달력 오픈: calendar.js 원형(show_calendar)과 호환 레이어 ===
    $(document).on("click", ".open-calendar", function (e) {
      e.preventDefault();

      var targetKey = $(this).data("target"); // 예: "dlvyDate"
      if (!targetKey) return;

      // 대상 input 찾기(id 우선 → name)
      var $input = $("#" + targetKey);
      if ($input.length === 0) $input = $("[name='" + targetKey + "']");
      if ($input.length === 0) return;

      // calendar.js가 기대하는 참조 문자열: document.formName.fieldName
      var $form = $("#addPurchase");
      var formName  = $form.attr("name") || "addPurchase";
      var fieldName = $input.attr("name") || targetKey;
      var ref = "document." + formName + "." + fieldName;

      // 현재 값 → 숫자만 → YYYYMMDD (8자리가 아니면 '' = 오늘 기준)
      var raw  = ($input.val() || "").toString().trim();
      var norm = raw.replace(/\D/g, "");
      if (norm.length !== 8) norm = "";

      if (typeof global.show_calendar === "function") {
        global.show_calendar(ref, norm);
      }
    });

  });
})(window, window.jQuery);
