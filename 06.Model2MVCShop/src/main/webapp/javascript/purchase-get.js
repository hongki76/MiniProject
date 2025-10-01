// /javascript/purchase-get.js
(function (global) {
  "use strict";

  var $ = global.jQuery;

  function onReady(fn) {
    if (document.readyState !== "loading") fn();
    else document.addEventListener("DOMContentLoaded", fn);
  }
  function detectBase() {
    if (global.APP_CONTEXT) return String(global.APP_CONTEXT);
    var scripts = document.getElementsByTagName("script");
    for (var i = 0; i < scripts.length; i++) {
      var src = scripts[i].getAttribute("src") || "";
      var marker = "/javascript/purchase-get.js";
      var pos = src.indexOf(marker);
      if (pos > -1) return src.slice(0, pos);
    }
    return "";
  }
  function getMeta(name) {
    var el = document.querySelector('meta[name="' + name + '"]');
    return el ? el.getAttribute("content") : "";
  }
  function getCsrf() {
    var token = getMeta("_csrf");
    var param = getMeta("_csrf_parameter") || "_csrf";
    return token ? { param: param, token: token } : null;
  }
  function postWithForm(action, data) {
    var form = document.createElement("form");
    form.method = "post";
    form.action = action;
    form.style.display = "none";
    if (data) {
      Object.keys(data).forEach(function (k) {
        var input = document.createElement("input");
        input.type = "hidden";
        input.name = k;
        input.value = data[k];
        form.appendChild(input);
      });
    }
    document.body.appendChild(form);
    form.submit();
  }

  function handleOk(base, e) {
    e.preventDefault();
    if (global.history && typeof global.history.back === "function") {
      global.history.back();
    } else {
      global.location.href = base + "/purchase/getPurchaseList";
    }
  }

  function handleCancel(base, csrf, e, target) {
    e.preventDefault();

    var tranNo =
      (target && target.getAttribute && target.getAttribute("data-tran-no")) ||
      ($ && $.fn && $.fn.data && $(target).data("tranNo"));

    if (!tranNo) {
      var el = target;
      while (el && el !== document && !tranNo) {
        tranNo = el.getAttribute && el.getAttribute("data-tran-no");
        el = el.parentNode;
      }
    }
    if (!tranNo) return;

    if (!global.confirm("이 주문을 취소하시겠습니까?")) return;

    var payload = { tranNo: tranNo };
    var c = getCsrf(); // 최신 값 다시 확인(선택)
    if (c) payload[c.param] = c.token;

    postWithForm(base + "/purchase/cancelPurchase", payload);
  }

  onReady(function () {
    var base = detectBase();

    if ($ && $.fn && $.fn.on) {
      // === jQuery가 있으면 jQuery만 바인딩하고 종료(중복 방지) ===
      $(document)
        .off("click.purchaseGetOk")
        .on("click.purchaseGetOk", "#btnOk", function (e) {
          // 다른 핸들러로 버블링되지 않게 즉시 중단
          e.stopImmediatePropagation();
          handleOk(base, e);
        });

      $(document)
        .off("click.purchaseGetCancel")
        .on("click.purchaseGetCancel", ".js-cancel-purchase", function (e) {
          e.stopImmediatePropagation(); // 중복 confirm 방지
          handleCancel(base, null, e, this);
        });

      return; // 네이티브 바인딩은 건너뜀(← 핵심)
    }

    // === jQuery가 전혀 없을 때만 네이티브 바인딩 ===
    document.addEventListener(
      "click",
      function (e) {
        var t = e.target;

        if (t && t.id === "btnOk") {
          handleOk(base, e);
          return;
        }
        var el = t;
        while (el && el !== document) {
          if (el.classList && el.classList.contains("js-cancel-purchase")) {
            handleCancel(base, null, e, el);
            return;
          }
          el = el.parentNode;
        }
      },
      false
    );
  });
})(window);
