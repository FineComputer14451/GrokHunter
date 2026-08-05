(function () {
  // Mobile menu
  const menuBtn = document.getElementById("menuBtn");
  const mobileNav = document.getElementById("mobileNav");
  if (menuBtn && mobileNav) {
    menuBtn.addEventListener("click", () => {
      const open = mobileNav.classList.toggle("open");
      menuBtn.setAttribute("aria-expanded", open ? "true" : "false");
      menuBtn.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    });
    mobileNav.querySelectorAll("a").forEach((a) => {
      a.addEventListener("click", () => {
        mobileNav.classList.remove("open");
        menuBtn.setAttribute("aria-expanded", "false");
      });
    });
  }

  async function copyText(text) {
    try {
      await navigator.clipboard.writeText(text);
      return true;
    } catch {
      const ta = document.createElement("textarea");
      ta.value = text;
      ta.style.position = "fixed";
      ta.style.left = "-9999px";
      document.body.appendChild(ta);
      ta.select();
      document.execCommand("copy");
      document.body.removeChild(ta);
      return true;
    }
  }

  document.querySelectorAll("[data-copy]").forEach((btn) => {
    btn.addEventListener("click", async () => {
      // getAttribute already returns decoded attribute text
      const text = (btn.getAttribute("data-copy") || "").replace(/\\n/g, "\n");
      await copyText(text);
      const prev = btn.textContent;
      btn.textContent = "Copied";
      window.setTimeout(() => {
        btn.textContent = prev;
      }, 1600);
    });
  });

  // Terminal animation
  const body = document.getElementById("terminalBody");
  if (!body) return;

  const LINES = [
    {
      kind: "cmd",
      prompt: "termux $ ",
      text: "bash install.sh --full --de xfce --with-grok --with-x11",
    },
    { kind: "out", text: "[grokhunter] detecting Termux + aarch64 … ok" },
    { kind: "out", text: "[grokhunter] pulling Kali NetHunter rootfs (current) …" },
    { kind: "out", text: "[grokhunter] installing XFCE + Chromium …" },
    { kind: "out", text: "[grokhunter] installing Grok Build CLI … done" },
    { kind: "out", text: "[grokhunter] wiring Termux:X11 + nh-x11 … done" },
    {
      kind: "ok",
      text: "[grokhunter] ready — run: nethunter | nh-x11 | grok | grokhunter",
    },
    { kind: "cmd", prompt: "kali $ ", text: "grokhunter doctor" },
    { kind: "ok", text: "✓ grok binary  ✓ PATH  ✓ secrets  ✓ NetHunter rootfs" },
  ];

  const reduce =
    window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function escapeHtml(s) {
    return s
      .replace(/&/g, "&")
      .replace(/</g, "<")
      .replace(/>/g, ">");
  }

  function renderAll() {
    body.innerHTML = "";
    LINES.forEach((line) => {
      const div = document.createElement("div");
      if (line.kind === "cmd") {
        div.innerHTML =
          '<span class="t-prompt">' +
          escapeHtml(line.prompt) +
          '</span><span class="t-cmd">' +
          escapeHtml(line.text) +
          "</span>";
      } else {
        div.className = line.kind === "ok" ? "t-ok" : "t-out";
        div.textContent = line.text;
      }
      body.appendChild(div);
    });
    const end = document.createElement("div");
    end.className = "t-prompt";
    end.innerHTML = 'kali $ <span class="cursor">▌</span>';
    body.appendChild(end);
  }

  if (reduce) {
    renderAll();
    return;
  }

  let lineIdx = 0;
  let charIdx = 0;
  const lineEls = [];

  function ensureLineEl(i) {
    if (lineEls[i]) return lineEls[i];
    const div = document.createElement("div");
    body.appendChild(div);
    lineEls[i] = div;
    return div;
  }

  function tick() {
    const line = LINES[lineIdx];
    if (!line) {
      const end = document.createElement("div");
      end.className = "t-prompt";
      end.innerHTML = 'kali $ <span class="cursor">▌</span>';
      body.appendChild(end);
      return;
    }

    const el = ensureLineEl(lineIdx);

    if (line.kind === "cmd") {
      if (charIdx <= line.text.length) {
        const shown = line.text.slice(0, charIdx);
        const typing = charIdx < line.text.length;
        el.innerHTML =
          '<span class="t-prompt">' +
          escapeHtml(line.prompt) +
          '</span><span class="t-cmd">' +
          escapeHtml(shown) +
          "</span>" +
          (typing ? '<span class="cursor">▌</span>' : "");
        charIdx += 1;
        window.setTimeout(tick, 26);
        return;
      }
      lineIdx += 1;
      charIdx = 0;
      window.setTimeout(tick, 200);
      return;
    }

    el.className = line.kind === "ok" ? "t-ok" : "t-out";
    el.textContent = line.text;
    lineIdx += 1;
    charIdx = 0;
    window.setTimeout(tick, 85);
  }

  window.setTimeout(tick, 400);
})();
