/**
 * MathTutor 12 – app.js
 * Vanilla JS, module pattern, khởi tạo trong DOMContentLoaded.
 * Mọi chuỗi từ server/AI chèn vào DOM qua textContent hoặc escapeHtml().
 */
(function () {
  'use strict';

  /* ── Utility ── */
  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  function qs(sel, ctx) { return (ctx || document).querySelector(sel); }
  function qsa(sel, ctx) { return (ctx || document).querySelectorAll(sel); }

  /* ── 7.9 KaTeX render ── */
  function renderMath(el) {
    if (!window.renderMathInElement || !el) return;
    renderMathInElement(el, {
      delimiters: [
        { left: '$$', right: '$$', display: true },
        { left: '$',  right: '$',  display: false }
      ],
      throwOnError: false
    });
  }

  /* ── CSRF + fetch có timeout (mọi lời gọi POST/PUT/DELETE tới server) ── */
  function csrfToken() {
    var meta = qs('meta[name="csrf-token"]');
    return meta ? meta.getAttribute('content') : '';
  }

  /**
   * fetch tự gắn header X-CSRF-TOKEN cho request ghi và hủy sau timeoutMs (mặc định 100 giây,
   * trùng timeout bất đồng bộ phía server).
   */
  function csrfFetch(url, options) {
    options = options || {};
    var headers = new Headers(options.headers || {});
    var method = (options.method || 'GET').toUpperCase();
    if (method !== 'GET' && method !== 'HEAD') headers.set('X-CSRF-TOKEN', csrfToken());
    var controller = new AbortController();
    var timer = setTimeout(function () { controller.abort(); }, options.timeoutMs || 100000);
    var init = Object.assign({}, options, { headers: headers, signal: controller.signal });
    delete init.timeoutMs;
    return fetch(url, init).finally(function () { clearTimeout(timer); });
  }

  /** Bật/tắt trạng thái đang xử lý của một nút (spinner + khóa nút chống gửi trùng). */
  function setLoading(button, loading) {
    if (!button) return;
    if (loading) {
      button.dataset.label = button.dataset.label || button.innerHTML;
      button.disabled = true;
      button.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Đang xử lý...';
    } else {
      button.disabled = false;
      if (button.dataset.label) button.innerHTML = button.dataset.label;
    }
  }

  /** Thông báo nhỏ góc phải màn hình (type: success | danger | warning | info). */
  function showToast(message, type) {
    var box = qs('#toastBox');
    if (!box) {
      box = document.createElement('div');
      box.id = 'toastBox';
      box.className = 'position-fixed top-0 end-0 p-3';
      box.style.zIndex = 1080;
      document.body.appendChild(box);
    }
    var el = document.createElement('div');
    el.className = 'alert alert-' + (type || 'info') + ' shadow-sm mb-2';
    el.textContent = message;
    box.appendChild(el);
    setTimeout(function () { el.remove(); }, 4000);
  }

  window.csrfFetch = csrfFetch;
  window.renderMath = renderMath;
  window.setLoading = setLoading;
  window.showToast = showToast;

  /* ── 7.1 Form validate + chống gửi trùng ── */
  function initFormValidation() {
    qsa('form.needs-validation').forEach(function (form) {
      form.addEventListener('submit', function (e) {
        if (!form.checkValidity()) {
          e.preventDefault();
          e.stopPropagation();
        } else {
          var btn = form.querySelector('[type="submit"]');
          if (btn) {
            btn.disabled = true;
            btn.dataset.label = btn.dataset.label || btn.textContent;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Đang xử lý...';
          }
        }
        form.classList.add('was-validated');
      });
    });

    // Khôi phục nút khi bấm Back (pageshow)
    window.addEventListener('pageshow', function (e) {
      if (e.persisted) {
        qsa('[type="submit"]').forEach(function (btn) {
          btn.disabled = false;
          if (btn.dataset.label) btn.textContent = btn.dataset.label;
        });
      }
    });
  }

  /* ── 7.2 Hiện/ẩn mật khẩu ── */
  function initPasswordToggle() {
    qsa('[data-toggle-password]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var input = qs(btn.dataset.togglePassword);
        if (!input) return;
        var show = input.type === 'password';
        input.type = show ? 'text' : 'password';
        var icon = btn.querySelector('i');
        if (icon) icon.className = show ? 'bi bi-eye-slash' : 'bi bi-eye';
        btn.setAttribute('aria-label', show ? 'Ẩn mật khẩu' : 'Hiện mật khẩu');
      });
    });
  }

  /* ── 7.3 Confirm-modal xóa ── */
  function initConfirmModal() {
    var modal = qs('#confirmModal');
    if (!modal) return;
    var msgEl = modal.querySelector('#confirmMessage');
    var okBtn = modal.querySelector('#confirmOkBtn');
    var bsModal = new bootstrap.Modal(modal);
    var targetForm = null;

    qsa('[data-confirm]').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        if (msgEl) msgEl.textContent = btn.dataset.confirmMessage || 'Bạn có chắc muốn thực hiện?';
        targetForm = btn.dataset.form ? qs(btn.dataset.form) : btn.closest('form');
        bsModal.show();
      });
    });

    if (okBtn) {
      okBtn.addEventListener('click', function () {
        if (targetForm) targetForm.submit();
        bsModal.hide();
      });
    }
  }

  /* ── 7.4 Tự mở modal ── */
  function initAutoOpenModal() {
    // Mở modal có data-open-on-load="true"
    qsa('[data-open-on-load="true"]').forEach(function (el) {
      var m = bootstrap.Modal.getOrCreateInstance(el);
      m.show();
    });
    // Mở #addUserModal khi URL có ?add=1
    if (window.location.search.indexOf('add=1') !== -1) {
      var addModal = qs('#addUserModal');
      if (addModal) bootstrap.Modal.getOrCreateInstance(addModal).show();
    }
  }

  /* ── 7.10 MCQ/ESSAY switch ── */
  function initQuestionTypeSwitch() {
    var radios = qsa('[name="type"]');
    var mcqBlock = qs('#mcqBlock');
    if (!radios.length || !mcqBlock) return;

    function toggle() {
      var selected = qs('[name="type"]:checked');
      var isMcq = selected && selected.value === 'MCQ';
      mcqBlock.style.display = isMcq ? '' : 'none';
      var mcqPreview = qs('#mcqPreview');
      if (mcqPreview) mcqPreview.style.display = isMcq ? '' : 'none';
      qsa('#mcqBlock input, #mcqBlock select', document).forEach(function (el) {
        el.disabled = !isMcq;
        if (!isMcq) el.removeAttribute('required');
      });
    }

    radios.forEach(function (r) { r.addEventListener('change', toggle); });
    toggle();
  }

  /* ── 7.11 Đếm câu AI đã chọn ── */
  function initAiPreviewCounter() {
    var form = qs('#aiPreviewForm');
    if (!form) return;
    var counter = qs('#aiSelectedCount');
    var saveBtn = qs('#aiSaveBtn');

    function update() {
      var checked = qsa('input[name="idx"]:checked', form).length;
      if (counter) counter.textContent = checked;
      if (saveBtn) saveBtn.disabled = checked === 0;
    }

    form.addEventListener('change', update);
    update();
  }

  /* ── Sidebar mobile toggle ── */
  function initSidebarToggle() {
    var toggleBtn = qs('#sidebarToggle');
    var sidebar   = qs('.app-sidebar');
    var overlay   = qs('.sidebar-overlay');
    if (!toggleBtn || !sidebar) return;

    function close() { sidebar.classList.remove('show'); if (overlay) overlay.classList.remove('show'); }

    toggleBtn.addEventListener('click', function () {
      sidebar.classList.toggle('show');
      if (overlay) overlay.classList.toggle('show');
    });

    if (overlay) overlay.addEventListener('click', close);
  }

  /* ── KaTeX auto-render toàn trang ── */
  function initKaTeX() {
    renderMath(document.body);
  }

  /* ── Edit user modal (fill data-*) ── */
  function initEditUserModal() {
    var modal = qs('#editUserModal');
    if (!modal) return;

    qsa('[data-bs-target="#editUserModal"]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        ['userId', 'fullName', 'email', 'phone'].forEach(function (field) {
          var el = modal.querySelector('[name="' + field + '"]');
          if (el && btn.dataset[field] !== undefined) el.value = btn.dataset[field];
        });
      });
    });
  }

  /* ── Reset password modal ── */
  function initResetPwdModal() {
    var modal = qs('#resetPwdModal');
    if (!modal) return;

    qsa('[data-bs-target="#resetPwdModal"]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var el = modal.querySelector('[name="userId"]');
        if (el && btn.dataset.userId) el.value = btn.dataset.userId;
        var nameEl = modal.querySelector('#resetPwdUserName');
        if (nameEl && btn.dataset.fullName) nameEl.textContent = btn.dataset.fullName;
      });
    });

    var newPw    = modal.querySelector('[name="newPassword"]');
    var confirmPw = modal.querySelector('[name="confirmPassword"]');
    if (newPw && confirmPw) {
      function checkMatch() {
        if (confirmPw.value && newPw.value !== confirmPw.value) {
          confirmPw.setCustomValidity('Mật khẩu xác nhận không khớp.');
        } else {
          confirmPw.setCustomValidity('');
        }
      }
      newPw.addEventListener('input', checkMatch);
      confirmPw.addEventListener('input', checkMatch);
    }
  }

  /* ── Topic modal (add / edit) ── */
  function initTopicModal() {
    var modal = qs('#topicModal');
    if (!modal) return;

    qsa('[data-action="edit-topic"]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var idEl   = modal.querySelector('[name="topicId"]');
        var nameEl = modal.querySelector('[name="topicName"]');
        var descEl = modal.querySelector('[name="description"]');
        var actEl  = modal.querySelector('[name="action"]');
        var titleEl = modal.querySelector('.modal-title');

        if (idEl)   idEl.value   = btn.dataset.topicId   || '';
        if (nameEl) nameEl.value = btn.dataset.topicName  || '';
        if (descEl) descEl.value = btn.dataset.description || '';
        if (actEl)  actEl.value  = 'update';
        if (titleEl) titleEl.textContent = 'Sửa chủ đề';
      });
    });

    // Reset khi mở để thêm mới
    var addBtn = qs('[data-action="add-topic"]');
    if (addBtn) {
      addBtn.addEventListener('click', function () {
        var f = modal.querySelector('form');
        if (f) f.reset();
        var idEl  = modal.querySelector('[name="topicId"]');
        var actEl = modal.querySelector('[name="action"]');
        var titleEl = modal.querySelector('.modal-title');
        if (idEl)   idEl.value  = '';
        if (actEl)  actEl.value = 'create';
        if (titleEl) titleEl.textContent = 'Thêm chủ đề';
      });
    }
  }

  /* ── KaTeX preview cho textarea ── */
  /* ── HTML đơn giản an toàn (khớp HtmlSanitizer.toSafeHtml phía server) ── */
  var SAFE_TAGS = 'p|br|b|i|u|strong|em|sub|sup|ul|ol|li|div|span|h[1-6]|table|thead|tbody|tr|th|td|img';
  var SAFE_TAG_SET = SAFE_TAGS.replace('h[1-6]', 'h1|h2|h3|h4|h5|h6').toUpperCase().split('|');
  var STRAY_LT = new RegExp('<(?!/?(' + SAFE_TAGS + ')\\b)', 'gi');

  /**
   * Trả về chuỗi HTML an toàn để gán innerHTML: chỉ giữ thẻ định dạng cơ bản, bỏ MỌI thuộc tính,
   * thẻ khác (script, ...) chuyển thành văn bản thuần; <img> chỉ giữ khi src là /static/img/.... DOMParser tạo tài liệu "chết"
   * nên không chạy script / không tải ảnh trong lúc phân tích. Công thức $a<b$ được giữ nguyên.
   */
  function toSafeHtml(raw) {
    if (raw == null || raw === '') return '';
    var doc = new DOMParser().parseFromString(
      '<body>' + String(raw).replace(STRAY_LT, '&lt;') + '</body>', 'text/html');
    (function clean(node) {
      Array.prototype.slice.call(node.childNodes).forEach(function (child) {
        if (child.nodeType === 3) return;
        if (child.nodeType !== 1) { node.removeChild(child); return; }
        if (SAFE_TAG_SET.indexOf(child.tagName) === -1) {
          child.replaceWith(document.createTextNode(child.textContent));
          return;
        }
        var src = child.tagName === 'IMG' ? child.getAttribute('src') : null;
        Array.prototype.slice.call(child.attributes).forEach(function (a) {
          child.removeAttribute(a.name);
        });
        if (child.tagName === 'IMG') {
          // chỉ cho ảnh nội bộ /static/img/... (khớp HtmlSanitizer phía server), nguồn khác bị bỏ
          if (src && /^\/static\/img\/[A-Za-z0-9_.\/-]+$/.test(src) && src.indexOf('..') === -1) {
            var ctxMeta = qs('meta[name="ctx"]');
            child.setAttribute('src', (ctxMeta ? ctxMeta.getAttribute('content') : '') + src);
            child.setAttribute('class', 'img-fluid sgk-figure');
          } else {
            child.remove();
          }
          return;
        }
        clean(child);
      });
    })(doc.body);
    return doc.body.innerHTML;
  }
  window.EduRich = { toSafeHtml: toSafeHtml };

  function initLatexPreview() {
    qsa('[data-latex-preview]').forEach(function (textarea) {
      var target = qs(textarea.dataset.latexPreview);
      if (!target) return;
      var placeholder = target.innerHTML;
      function update() {
        if (!textarea.value.trim()) { target.innerHTML = placeholder; return; }
        target.innerHTML = toSafeHtml(textarea.value);
        renderMath(target);
      }
      var timer;
      textarea.addEventListener('input', function () {
        clearTimeout(timer);
        timer = setTimeout(update, 300);
      });
      update(); // trang sửa: nội dung có sẵn được preview ngay, không chờ nhập
      // KaTeX nạp bằng defer: render lại công thức khi mọi script đã sẵn sàng
      window.addEventListener('load', function () {
        if (textarea.value.trim()) renderMath(target);
      });
    });
  }

  /* ── init ── */
  document.addEventListener('DOMContentLoaded', function () {
    initFormValidation();
    initPasswordToggle();
    initConfirmModal();
    initAutoOpenModal();
    initKaTeX();
    initQuestionTypeSwitch();
    initAiPreviewCounter();
    initSidebarToggle();
    initEditUserModal();
    initResetPwdModal();
    initTopicModal();
    initLatexPreview();
  });

})();
