// - listProduct.jsp 전용 스크립트
// - pageNavigator.jsp 호환 위해 전역 fncGetList 유지
(function (global, $) {
  "use strict";

  (function(){
    var $cond = $('#searchCondition');
    var $kw   = $('#searchKeyword');
    var $reg  = $('#regDateKeyword'); // 등록일 유지용 히든

    function applyPlaceholderAndValidation() {
      var v = String($cond.val());
      // 공통 초기화
      $kw.removeAttr('num').removeAttr('valCheck').removeAttr('maxLength').attr('placeholder','');

      if (v === '0') {                 // 상품명
        $kw.attr('placeholder','상품명 입력');
        // 날짜모드에서 벗어났을 때 입력칸은 비워서 날짜 값이 보이지 않게 (히든은 유지)
        if ($reg.val()) { $kw.val(''); }

      } else if (v === '1') {          // 상품가격
        $kw.attr('placeholder','가격(숫자)');
        $kw.attr('num','n');
        if ($reg.val()) { $kw.val(''); }

      } else if (v === '2') {          // 등록일
        $kw.attr('placeholder','YYYYMMDD');
        $kw.attr('valCheck','DATE').attr('maxLength','8');
      }
    }

    // 등록일 모드에서 입력 변화 → 히든에 정규화(숫자 8자리)로 저장
    $(document).on('input blur', '#searchKeyword', function(){
      if (String($cond.val()) !== '2') return;
      var digits = (this.value || '').replace(/\D/g,'');
      if (digits.length === 8) { $reg.val(digits); }
    });

    // 초기 세팅 & 조건 변경 시 갱신
    $(applyPlaceholderAndValidation);
	$cond.on('change', function () {
		$kw.val('');                 // ★ 비우기
		applyPlaceholderAndValidation();  // ★ placeholder/검증 속성 재적용
	});
  })();

  function submitList(page, order) {
    var $form = $("#detailForm");
    if ($form.length === 0) return;

    if (page !== undefined && page !== null && page !== "") {
      $("#currentPage").val(page);
    }
    if (order !== undefined && order !== null && order !== "") {
      $("#orderByPriceAsc").val(order); // 'ASC' or 'DESC'
    }

    if (global.FormValidation && !global.FormValidation($form.get(0))) {
      return;
    }
    $form.trigger("submit");
  }

  // === DOM Ready ===
  $(function () {
    $("#btnSearch").on("click", function () { submitList(1); });

    $(document).on("click", ".sort-price", function () {
      var order = $(this).data("order"); // 'ASC' / 'DESC'
      submitList($("#currentPage").val() || 1, order);
    });

    $("#detailForm input[name='searchKeyword']").on("keydown", function (e) {
      if (e.key === "Enter" || e.keyCode === 13) {
        e.preventDefault();
        submitList(1);
      }
    });

    $(document).on("click", "a[data-page]", function (e) {
      e.preventDefault();
      submitList($(this).data("page"));
    });
  });

  // === pageNavigator.jsp 호환 함수 ===
  global.fncGetList = function (currentPage, orderByPriceAsc) {
    submitList(currentPage, orderByPriceAsc);
    return false;
  };

})(window, window.jQuery);
