(function () {
  // Mobile menu
  const menuBtn = document.getElementById("menuBtn");
  const mobileNav = document.getElementById("mobileNav");

  function setMenuOpen(open) {
    if (!menuBtn || !mobileNav) return;
    mobileNav.classList.toggle("open", open);
    if (open) {
      mobileNav.removeAttribute("hidden");
    } else {
      mobileNav.setAttribute("hidden", "");
    }
    menuBtn.setAttribute("aria-expanded", open ? "true" : "false");
    menuBtn.setAttribute("aria-label", open ? "Close menu" : "Open menu");
    document.body.classList.toggle("menu-open", open);
  }

  if (menuBtn && mobileNav) {
    // closed by default (hidden attribute in HTML)
    setMenuOpen(false);

    menuBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      const open = !mobileNav.classList.contains("open");
      setMenuOpen(open);
    });

    mobileNav.querySelectorAll("a").forEach((a) => {
      a.addEventListener("click", () => setMenuOpen(false));
    });

    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") setMenuOpen(false);
    });

    document.addEventListener("click", (e) => {
      if (!mobileNav.classList.contains("open")) return;
      if (mobileNav.contains(e.target) || menuBtn.contains(e.target)) return;
      setMenuOpen(false);
    });

    // Close hamburger when viewport grows to desktop nav
    const mql = window.matchMedia("(min-width: 1100px)");
    const onBp = () => {
      if (mql.matches) setMenuOpen(false);
    };
    if (mql.addEventListener) mql.addEventListener("change", onBp);
    else if (mql.addListener) mql.addListener(onBp);
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
      const text = (btn.getAttribute("data-copy") || "").replace(/\\n/g, "\n");
      await copyText(text);
      const prev = btn.textContent;
      btn.textContent = "Copied";
      window.setTimeout(() => {
        btn.textContent = prev;
      }, 1600);
    });
  });

  // Active nav highlight on scroll
  const navLinks = Array.from(document.querySelectorAll(".nav a[href^='#']"));
  const sections = navLinks
    .map((a) => {
      const id = a.getAttribute("href").slice(1);
      const el = document.getElementById(id);
      return el ? { id, el, a } : null;
    })
    .filter(Boolean);

  function setActiveNav() {
    const y = window.scrollY + 96;
    let current = sections[0];
    for (const s of sections) {
      if (s.el.offsetTop <= y) current = s;
    }
    navLinks.forEach((a) => a.classList.remove("nav-active"));
    if (current) current.a.classList.add("nav-active");
  }

  if (sections.length) {
    window.addEventListener("scroll", setActiveNav, { passive: true });
    setActiveNav();
  }

  // Terminal animation
  const body = document.getElementById("terminalBody");
  if (!body) return;

  const LINES = [
    {
      kind: "cmd",
      prompt: "termux $ ",
      text: "bash install.sh --full --de xfce --with-grok --with-x11 --with-aider",
    },
    { kind: "out", text: "[grokhunter] detecting Termux + aarch64 … ok" },
    { kind: "out", text: "[grokhunter] pulling Kali NetHunter rootfs (current) …" },
    { kind: "out", text: "[grokhunter] installing XFCE + desktop session …" },
    { kind: "out", text: "[grokhunter] ensure Grok Build ≥ 1.0.5 … grok 1.0.5 [stable]" },
    { kind: "out", text: "[grokhunter] NetHunter profile → channel=stable · grok-4.6" },
    { kind: "out", text: "[grokhunter] Aider via uv + Python 3.12 … aider 0.86.2" },
    { kind: "out", text: "[grokhunter] wiring Termux:X11 + nh-x11 … done" },
    {
      kind: "ok",
      text: "[grokhunter] ready — nethunter | nh-x11 | grok | grokhunter | aider-grok",
    },
    { kind: "cmd", prompt: "kali $ ", text: "grokhunter skills install" },
    { kind: "out", text: "[skills] 5 skills · 8 agents · 8 personas · 7 roles" },
    { kind: "cmd", prompt: "kali $ ", text: "grokhunter doctor" },
    {
      kind: "ok",
      text: "✓ grok 1.0.5  ✓ profile  ✓ skills-core 3/3  ✓ agents  ✓ personas  ✓ roles",
    },
  ];

  const reduce =
    window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  function escapeHtml(s) {
    return s
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
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
        window.setTimeout(tick, 22);
        return;
      }
      lineIdx += 1;
      charIdx = 0;
      window.setTimeout(tick, 180);
      return;
    }

    el.className = line.kind === "ok" ? "t-ok" : "t-out";
    el.textContent = line.text;
    lineIdx += 1;
    charIdx = 0;
    window.setTimeout(tick, 75);
  }

  window.setTimeout(tick, 400);
})();
