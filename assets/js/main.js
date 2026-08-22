function announce(message) {
  const status = document.getElementById("site-status");
  if (status) status.textContent = message;
}

async function copyText(text) {
  if (navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(text);
    return;
  }

  const textArea = document.createElement("textarea");
  textArea.value = text;
  textArea.setAttribute("readonly", "");
  textArea.style.position = "fixed";
  textArea.style.opacity = "0";
  document.body.appendChild(textArea);
  textArea.select();
  const copied = document.execCommand("copy");
  textArea.remove();
  if (!copied) throw new Error("Copy command was rejected");
}

function setupCopyButtons() {
  document.querySelectorAll("[data-copy-ip]").forEach((button) => {
    const serverAddress = button.dataset.copyIp;
    if (!serverAddress) return;

    button.addEventListener("click", async () => {
      try {
        await copyText(serverAddress);
        button.classList.add("copied");
        announce(`Server address copied: ${serverAddress}`);
        window.setTimeout(() => button.classList.remove("copied"), 2000);
      } catch (error) {
        console.error("Failed to copy server address", error);
        announce(`Could not copy automatically. Server address: ${serverAddress}`);
      }
    });
  });
}

function setupMenu() {
  const menuButton = document.getElementById("hamburger");
  const menu = document.getElementById("mobileMenu");
  if (!menuButton || !menu) return;

  const menuItems = () =>
    Array.from(menu.querySelectorAll('a[href], button:not([disabled])'));

  function setMenuOpen(open, returnFocus = false) {
    menuButton.classList.toggle("active", open);
    menu.classList.toggle("active", open);
    document.body.classList.toggle("menu-open", open && window.innerWidth <= 768);
    menuButton.setAttribute("aria-expanded", String(open));
    menuButton.setAttribute(
      "aria-label",
      open ? menuButton.dataset.closeLabel : menuButton.dataset.openLabel,
    );
    menu.setAttribute("aria-hidden", String(!open));
    menu.toggleAttribute("inert", !open);

    if (open) menuItems()[0]?.focus();
    else if (returnFocus) menuButton.focus();
  }

  menuButton.addEventListener("click", () => {
    setMenuOpen(menuButton.getAttribute("aria-expanded") !== "true", true);
  });

  menu.addEventListener("click", (event) => {
    if (event.target === menu || event.target.closest("a")) setMenuOpen(false);
  });

  document.addEventListener("keydown", (event) => {
    if (menuButton.getAttribute("aria-expanded") !== "true") return;

    if (event.key === "Escape") {
      event.preventDefault();
      setMenuOpen(false, true);
      return;
    }

    if (event.key !== "Tab") return;
    const items = menuItems();
    const first = items[0];
    const last = items[items.length - 1];
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last?.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first?.focus();
    }
  });

  window.addEventListener("resize", () => {
    if (window.innerWidth > 768 && menuButton.getAttribute("aria-expanded") === "true") {
      setMenuOpen(false, true);
    } else if (menuButton.getAttribute("aria-expanded") === "true") {
      document.body.classList.toggle("menu-open", window.innerWidth <= 768);
    }
  });
}

function setupAnchorScrolling() {
  document.querySelectorAll('a[href^="#"]:not([href="#"])').forEach((anchor) => {
    anchor.addEventListener("click", (event) => {
      const target = document.getElementById(anchor.hash.slice(1));
      if (!target) return;
      event.preventDefault();
      const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
      target.scrollIntoView({ behavior: reduceMotion ? "auto" : "smooth", block: "start" });
      history.pushState(null, "", anchor.hash);
    });
  });
}

function setupLanguageSelect() {
  const select = document.querySelector("[data-language-select]");
  if (!select) return;

  select.addEventListener("change", () => {
    if (select.value) window.location.assign(select.value);
  });
}

function setupBackToTop() {
  const button = document.getElementById("backToTopBtn");
  if (!button) return;

  function toggleVisibility() {
    button.classList.toggle("is-visible", window.scrollY > 400);
  }

  button.addEventListener("click", () => {
    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    window.scrollTo({ top: 0, behavior: reduceMotion ? "auto" : "smooth" });
  });

  window.addEventListener("scroll", toggleVisibility);
  toggleVisibility();
}

document.addEventListener("DOMContentLoaded", () => {
  setupMenu();
  setupCopyButtons();
  setupAnchorScrolling();
  setupLanguageSelect();
  setupBackToTop();
});
