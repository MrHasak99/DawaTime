(function () {
  "use strict";

  let currentThemeMode = "system";

  function createToggles() {
    const themeButton = document.createElement("button");
    themeButton.className = "dark-mode-toggle";
    themeButton.id = "theme-toggle";
    themeButton.title = "System Theme (Auto)";
    themeButton.setAttribute("data-tooltip", "System Theme");
    themeButton.innerHTML =
      '<span id="theme-icon"><div class="icon-auto"></div></span>';
    themeButton.onclick = toggleTheme;

    const langButton = document.createElement("button");
    langButton.className = "language-toggle";
    langButton.id = "language-toggle";
    langButton.title = "Switch Language";
    langButton.innerHTML = '<span id="language-icon">EN</span>';
    langButton.onclick = toggleLanguage;

    document.body.appendChild(themeButton);
    document.body.appendChild(langButton);
  }

  function updateThemeButton() {
    const button = document.getElementById("theme-toggle");
    const themeIcon = document.getElementById("theme-icon");

    if (!button || !themeIcon) return;

    if (currentThemeMode === "system") {
      button.title = "System Theme (Auto)";
      button.setAttribute("data-tooltip", "System Theme");
      themeIcon.innerHTML = '<div class="icon-auto"></div>';
    } else if (currentThemeMode === "light") {
      button.title = "Light Theme";
      button.setAttribute("data-tooltip", "Light Theme");
      themeIcon.innerHTML = '<div class="icon-light"></div>';
    } else {
      button.title = "Dark Theme";
      button.setAttribute("data-tooltip", "Dark Theme");
      themeIcon.innerHTML = '<div class="icon-dark"></div>';
    }
  }

  function toggleTheme() {
    const body = document.body;
    if (currentThemeMode === "system") {
      currentThemeMode = "light";
      body.removeAttribute("data-theme");
      localStorage.setItem("theme", "light");
    } else if (currentThemeMode === "light") {
      currentThemeMode = "dark";
      body.setAttribute("data-theme", "dark");
      localStorage.setItem("theme", "dark");
    } else {
      currentThemeMode = "system";
      applySystemTheme();
      localStorage.setItem("theme", "system");
    }
    updateThemeButton();
  }

  function applySystemTheme() {
    const body = document.body;
    const prefersDark = window.matchMedia(
      "(prefers-color-scheme: dark)",
    ).matches;

    if (prefersDark) {
      body.setAttribute("data-theme", "dark");
    } else {
      body.removeAttribute("data-theme");
    }
  }

  function setupSystemThemeListener() {
    const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
    mediaQuery.addListener((e) => {
      if (currentThemeMode === "system") {
        applySystemTheme();
      }
    });
  }

  function toggleLanguage() {
    const html = document.documentElement;
    const currentLang = html.getAttribute("lang") || "en";
    const newLang = currentLang === "en" ? "ar" : "en";
    const newDir = newLang === "ar" ? "rtl" : "ltr";

    document.body.classList.add("transitioning");

    html.setAttribute("lang", newLang);
    html.setAttribute("dir", newDir);

    const langIcon = document.getElementById("language-icon");
    if (langIcon) {
      langIcon.textContent = newLang === "ar" ? "EN" : "ع";
    }

    const enContent = document.querySelectorAll(".en-content, .en-btn");
    const arContent = document.querySelectorAll(".ar-content, .ar-btn");

    enContent.forEach((el) => {
      el.style.display = newLang === "en" ? "" : "none";
    });
    arContent.forEach((el) => {
      el.style.display = newLang === "ar" ? "" : "none";
    });

    const dataElements = document.querySelectorAll("[data-en][data-ar]");
    dataElements.forEach((element) => {
      const enText = element.getAttribute("data-en");
      const arText = element.getAttribute("data-ar");
      if (enText && arText) {
        const textToSet = newLang === "ar" ? arText : enText;
        element.textContent = textToSet;
      }
    });

    const translatableElements = document.querySelectorAll("[data-translate]");
    if (translatableElements.length > 0 && window.translations) {
      translatableElements.forEach((element) => {
        const key = element.getAttribute("data-translate");
        if (window.translations[newLang] && window.translations[newLang][key]) {
          element.textContent = window.translations[newLang][key];
        }
      });
    }

    if (document.body.style) {
      document.body.style.direction = newDir;
      if (newLang === "ar") {
        document.body.style.fontFamily =
          '"Noto Kufi Arabic", "Inter", Arial, sans-serif';
      } else {
        document.body.style.fontFamily = '"Nunito", "Inter", Arial, sans-serif';
      }
    }

    localStorage.setItem("language", newLang);

    setTimeout(() => {
      document.body.classList.remove("transitioning");
    }, 400);
  }

  function initTheme() {
    const savedTheme = localStorage.getItem("theme") || "system";
    currentThemeMode = savedTheme;

    if (savedTheme === "system") {
      applySystemTheme();
    } else if (savedTheme === "dark") {
      document.body.setAttribute("data-theme", "dark");
    } else {
      document.body.removeAttribute("data-theme");
    }

    updateThemeButton();
    setupSystemThemeListener();
  }

  function initLanguage() {
    const savedLang = localStorage.getItem("language") || "en";
    const html = document.documentElement;

    if (savedLang === "ar") {
      html.setAttribute("lang", "ar");
      html.setAttribute("dir", "rtl");

      const langIcon = document.getElementById("language-icon");
      if (langIcon) {
        langIcon.textContent = "EN";
      }

      document
        .querySelectorAll(".en-content, .en-btn")
        .forEach((el) => (el.style.display = "none"));
      document
        .querySelectorAll(".ar-content, .ar-btn")
        .forEach((el) => (el.style.display = ""));

      document.querySelectorAll("[data-en][data-ar]").forEach((element) => {
        const arText = element.getAttribute("data-ar");
        if (arText) {
          element.textContent = arText;
        }
      });

      if (document.body.style) {
        document.body.style.direction = "rtl";
        document.body.style.fontFamily =
          '"Noto Kufi Arabic", "Inter", Arial, sans-serif';
      }

      if (window.translations && window.translations.ar) {
        document.querySelectorAll("[data-translate]").forEach((element) => {
          const key = element.getAttribute("data-translate");
          if (window.translations.ar[key]) {
            element.textContent = window.translations.ar[key];
          }
        });
      }
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", function () {
      createToggles();
      initTheme();
      initLanguage();
    });
  } else {
    createToggles();
    initTheme();
    initLanguage();
  }
})();
