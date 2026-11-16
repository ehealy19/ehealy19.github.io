/* Lizzie Healy portfolio: small enhancements, no libraries.
   1. Contour-line background behind the home hero
   2. Subject filter chips on the Projects page
   3. Document viewer on project pages (PDF inline on desktop, button on phones;
      live sites load only when clicked) */
(function () {
  "use strict";
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ---------- 1. Contours ---------- */
  var cv = document.getElementById("contours");
  if (cv && cv.getContext) {
    var ctx = cv.getContext("2d"), w = 0, h = 0, t = 0;
    var mx = 0.72, my = 0.45, tx = mx, ty = my, visible = true;
    var size = function () {
      var r = cv.getBoundingClientRect(), d = Math.min(window.devicePixelRatio || 1, 2);
      w = r.width; h = r.height; cv.width = w * d; cv.height = h * d; ctx.setTransform(d, 0, 0, d, 0, 0);
    };
    var draw = function () {
      mx += (tx - mx) * 0.04; my += (ty - my) * 0.04;
      ctx.clearRect(0, 0, w, h);
      var cx = mx * w, cy = my * h, R = Math.max(w, h);
      for (var k = 1; k <= 22; k++) {
        var base = k * R / 26;
        ctx.beginPath();
        for (var a = 0; a <= 6.3; a += 0.06) {
          var n = Math.sin(a * 3 + t + k * 0.35) * 0.06 + Math.sin(a * 5 - t * 0.7 + k * 0.2) * 0.035 + Math.cos(a * 2 + k * 0.5) * 0.05;
          var r = base * (1 + n), x = cx + Math.cos(a) * r * 1.25, y = cy + Math.sin(a) * r * 0.8;
          if (a === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
        }
        ctx.closePath();
        ctx.strokeStyle = k % 5 === 0 ? "rgba(29,117,102,0.26)" : "rgba(42,91,140,0.11)";
        ctx.lineWidth = k % 5 === 0 ? 1.3 : 1;
        ctx.stroke();
      }
    };
    size(); draw();
    window.addEventListener("resize", function () { size(); draw(); });
    cv.parentElement.addEventListener("pointermove", function (e) {
      var r = cv.getBoundingClientRect();
      tx = 0.6 + 0.25 * ((e.clientX - r.left) / r.width);
      ty = 0.3 + 0.3 * ((e.clientY - r.top) / r.height);
    });
    if ("IntersectionObserver" in window) {
      new IntersectionObserver(function (es) { visible = es[0].isIntersecting; }).observe(cv);
    }
    if (!reduceMotion) {
      var loop = function () { if (visible && !document.hidden) { t += 0.004; draw(); } requestAnimationFrame(loop); };
      requestAnimationFrame(loop);
    }
  }

  /* ---------- 2. Filters ---------- */
  var bar = document.getElementById("lh-filters");
  if (bar) {
    var cards = Array.prototype.slice.call(document.querySelectorAll(".lh-card[data-subject]"));
    var countEl = document.getElementById("lh-count");
    var subjects = [
      ["all", "All", "var(--ink)"], ["Data Science", "Data Science", "var(--ds)"],
      ["Economics", "Economics", "var(--econ)"], ["Mathematics", "Mathematics", "var(--math)"],
      ["Computer Science", "Computer Science", "var(--cs)"]
    ];
    var current = "all";
    try { current = sessionStorage.getItem("lh-filter") || "all"; } catch (e) {}
    var render = function () {
      bar.innerHTML = "";
      subjects.forEach(function (s) {
        var n = s[0] === "all" ? cards.length : cards.filter(function (c) { return c.dataset.subject === s[0]; }).length;
        if (!n) return;
        var b = document.createElement("button");
        b.type = "button"; b.className = "lh-chip"; b.style.setProperty("--c", s[2]);
        b.setAttribute("aria-pressed", String(current === s[0]));
        b.innerHTML = '<span class="sw"></span>' + s[1] + '<span class="n">' + n + "</span>";
        b.addEventListener("click", function () {
          current = s[0];
          try { sessionStorage.setItem("lh-filter", current); } catch (e) {}
          render();
        });
        bar.appendChild(b);
      });
      var shown = 0;
      cards.forEach(function (c) { var on = current === "all" || c.dataset.subject === current; c.hidden = !on; if (on) shown++; });
      if (countEl) countEl.textContent = shown + " of " + cards.length + " shown";
    };
    render();
  }

  /* ---------- 3. Viewer ---------- */
  var canInlinePdf = function () {
    var ua = navigator.userAgent || "";
    var phoneOrTablet = /Android|iPhone|iPad|iPod/i.test(ua) || (navigator.maxTouchPoints > 1 && /Macintosh/.test(ua));
    return !phoneOrTablet && window.matchMedia("(min-width: 900px)").matches;
  };
  Array.prototype.forEach.call(document.querySelectorAll("[data-lh-viewer]"), function (viewer) {
    var tabs = viewer.querySelectorAll("button[data-src]");
    var stage = viewer.querySelector(".lh-stage");
    var openLink = viewer.querySelector("[data-open]");
    var thumb = viewer.getAttribute("data-thumb");
    var esc = function (s) { return String(s).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); };
    var frame = function (src, title) {
      stage.classList.add("has-frame");
      stage.innerHTML = '<iframe src="' + esc(src) + '" title="' + esc(title) + '" loading="lazy"></iframe>';
    };
    var poster = function (html) {
      stage.classList.remove("has-frame");
      stage.innerHTML = (thumb ? '<img src="' + esc(thumb) + '" alt="">' : "") + html;
    };
    var show = function (btn) {
      Array.prototype.forEach.call(tabs, function (b) { b.setAttribute("aria-pressed", String(b === btn)); });
      var src = btn.dataset.src, type = btn.dataset.type, label = btn.textContent;
      if (openLink) { openLink.href = src; }
      if (type === "pdf") {
        if (viewer.hasAttribute("data-check")) {
          // only embed if the file exists (e.g. the resume before it's uploaded)
          fetch(src, { method: "HEAD" }).then(function (r) {
            if (!r.ok) throw 0;
            if (canInlinePdf()) frame(src + "#view=FitH", label);
            else poster('<a class="lh-btn primary" href="' + esc(src) + '" target="_blank" rel="noopener">Open ' + esc(label.toLowerCase()) + ' (PDF)</a>');
          }).catch(function () { poster('<span class="note">Coming soon.</span>'); if (openLink) openLink.hidden = true; });
          return;
        }
        if (canInlinePdf()) frame(src + "#view=FitH", label);
        else poster('<a class="lh-btn primary" href="' + esc(src) + '" target="_blank" rel="noopener">Open ' + esc(label.toLowerCase()) + ' (PDF)</a>');
      } else {
        poster('<button type="button" class="lh-btn primary" data-load>Load live preview</button><span class="note">Or open the site in a new tab with the link above.</span>');
        stage.querySelector("[data-load]").addEventListener("click", function () { frame(src, label); });
      }
    };
    Array.prototype.forEach.call(tabs, function (b) { b.addEventListener("click", function () { show(b); }); });
    if (tabs.length) show(tabs[0]);
  });
})();
