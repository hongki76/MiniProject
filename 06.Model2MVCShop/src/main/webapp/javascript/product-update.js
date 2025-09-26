// /javascript/product-update.js
(function (global, $) {
  "use strict";

  /* ===== 공통 유틸 ===== */
  function fmtBytes(n) {
    if (n == null) return "0 B";
    var u = ["B","KB","MB","GB"], i = 0;
    while (n >= 1024 && i < u.length-1) { n /= 1024; i++; }
    return (Math.round(n*10)/10) + " " + u[i];
  }
  function isImage(f) { return /^image\//i.test(f.type); }

  function dtSupported() {
    try { return typeof DataTransfer !== "undefined" && new DataTransfer(); }
    catch (e) { return false; }
  }

  function rebuildFileList($input, keep) {
    var input = $input.get(0);
    if (!dtSupported()) { input.value = ""; return; }
    var dt = new DataTransfer();
    var fs = input.files;
    keep.forEach(function (i) { if (fs[i]) dt.items.add(fs[i]); });
    input.files = dt.files;
  }

  /* ===== 제출/취소 ===== */
  function doSubmit() {
    var $form = $("#detailForm");
    if (!$form.length) return;
    if (global.FormValidation && !global.FormValidation($form.get(0))) return;

    var price = $.trim($("#price").val() || "");
    if (!/^[0-9]+$/.test(price)) {
      alert("가격은 숫자만 입력하세요."); $("#price").focus(); return;
    }
    $("#btnUpdate").prop("disabled", true);
    $form.trigger("submit");
  }
  function goBack() {
    if (global.history && typeof global.history.back === "function") history.back();
    else location.href = (global.CONTEXT_PATH || "") + "/product/getProductList";
  }

  /* ===== 달력 ===== */
  function bindCalendarOpen() {
    $(document).on("click", ".open-calendar", function (e) {
      e.preventDefault();
      var targetKey = $(this).data("target");
      if (!targetKey) return;
      var $input = $("#" + targetKey);
      if (!$input.length) $input = $("[name='" + targetKey + "']");
      if (!$input.length) return;

      var formName = $(this).data("form") ||
                     $input.closest("form").attr("name") ||
                     $("#detailForm").attr("name") || "detailForm";
      var fieldToken = $input.attr("name") || targetKey;
      var ref = "document." + formName + "." + fieldToken;

      var raw = ($input.val() || "").trim();
      var norm = raw.replace(/\D/g, "");
      if (norm.length !== 8) norm = "";

      if (typeof global.show_calendar === "function") global.show_calendar(ref, norm);
    });
  }

  /* ===== 새 첨부(멀티) 미리보기 ===== */
  var $fileInput   = null;
  var $previewGrid = null;
  var $fileSummary = null;

  function renderList() {
    if (!$fileInput || !$fileInput.length) return;
    var files = $fileInput.get(0).files;
    if (!files || files.length === 0) {
      if ($fileSummary) $fileSummary.hide().empty();
      if ($previewGrid) $previewGrid.empty();
      return;
    }

    var total = 0, nonImage = false;
    Array.prototype.forEach.call(files, function (f) {
      total += f.size; if (!isImage(f)) nonImage = true;
    });

    $fileSummary
      .show()
      .html("선택 " + files.length + "개 · 총 " + fmtBytes(total) +
        (nonImage ? ' <span class="badge warn" style="margin-left:6px;">이미지 아닌 파일 포함</span>' : ""));

    $previewGrid.empty();

    Array.prototype.forEach.call(files, function (file, idx) {
      var $card = $('<div class="file-card"></div>');

      // 썸네일: URL.createObjectURL ↔ FileReader fallback
      if (isImage(file)) {
        var $img = $('<img class="thumb" alt="">').attr("alt", file.name);
        if (global.URL && typeof global.URL.createObjectURL === "function") {
          var url = URL.createObjectURL(file);
          $img.attr("src", url).on("load", function () {
            try { URL.revokeObjectURL(url); } catch (e) {}
          });
        } else {
          var reader = new FileReader();
          reader.onload = function (ev) { $img.attr("src", ev.target.result); };
          reader.readAsDataURL(file);
        }
        $card.append($img);
      } else {
        $card.append('<div class="thumb-placeholder">미리보기 없음</div>');
      }

      $card.append($('<div class="file-name"/>').text(file.name).attr("title", file.name));

      var $actions = $('<div class="file-actions"></div>');
      var $badge = $('<span class="badge"></span>').text("#" + (idx + 1));
      var $remove = $('<button type="button" class="btn-mini">제거</button>').on("click", function () {
        var keep = [];
        var len = $fileInput.get(0).files.length;
        for (var i=0; i<len; i++) if (i !== idx) keep.push(i);
        rebuildFileList($fileInput, keep);
        renderList();
      });
      $actions.append($badge, $remove);
      $card.append($actions);

      $previewGrid.append($card);
    });
  }

  function bindFiles() {
    // 위임 바인딩: 동적으로 교체돼도 동작
    $(document).on("change", "#productFile", function () {
      $fileInput   = $("#productFile");
      $previewGrid = $("#filePreview");
      $fileSummary = $("#fileSummary");
      renderList();
    });

    $(document).on("click", "#btnClearFiles", function () {
      $fileInput = $("#productFile");
      if (!$fileInput.length) return;
      var input = $fileInput.get(0);
      if (dtSupported()) {
        var dt = new DataTransfer();
        input.files = dt.files;
      } else {
        input.value = "";
      }
      $previewGrid = $("#filePreview");
      $fileSummary = $("#fileSummary");
      renderList();
    });
  }

  /* ===== 초기화 ===== */
  $(function () {
    console.log("[product-update] init");
    $(document).on("click", "#btnUpdate", function (e) { e.preventDefault(); doSubmit(); });
    $(document).on("click", "#btnCancel", function (e) { e.preventDefault(); goBack(); });
    bindCalendarOpen();
    bindFiles();
  });

})(window, window.jQuery);
