import { apiInitializer } from "discourse/lib/api";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];
const INLINE_TL_PATTERN = /\[tl=([0-4])(?:\s+(text))?\]/gi;
const SKIP_SELECTOR =
  "code, pre, a, script, style, textarea, button, .trust-level-inline";

function trustLevelName(level) {
  return i18n(`trust_levels.names.${TRUST_LEVEL_KEYS[level]}`);
}

function buildInlineTrustLevel(level, showText) {
  const wrapper = document.createElement("span");
  wrapper.className = `trust-level-inline trust-level-inline--tl${level}`;
  wrapper.dataset.trustLevel = String(level);

  const badge = settings.theme_uploads?.[`badge_tl${level}`];

  if (badge) {
    const image = document.createElement("img");
    image.className = "trust-level-inline__icon";
    image.src = badge;
    image.alt = showText ? "" : `TL${level}`;
    image.loading = "lazy";
    wrapper.appendChild(image);
  }

  if (showText) {
    const label = document.createElement("span");
    label.className = "trust-level-inline__text";
    label.textContent = trustLevelName(level);
    wrapper.appendChild(label);
  } else if (!badge) {
    wrapper.textContent = `TL${level}`;
  }

  return wrapper;
}

function replaceInlineTrustLevels(element) {
  const walker = document.createTreeWalker(
    element,
    NodeFilter.SHOW_TEXT,
    {
      acceptNode(node) {
        if (!node.nodeValue?.includes("[tl=")) {
          return NodeFilter.FILTER_REJECT;
        }

        if (node.parentElement?.closest(SKIP_SELECTOR)) {
          return NodeFilter.FILTER_REJECT;
        }

        return NodeFilter.FILTER_ACCEPT;
      },
    }
  );

  const textNodes = [];
  while (walker.nextNode()) {
    textNodes.push(walker.currentNode);
  }

  for (const textNode of textNodes) {
    const source = textNode.nodeValue;
    const fragment = document.createDocumentFragment();
    let lastIndex = 0;
    let matched = false;

    INLINE_TL_PATTERN.lastIndex = 0;

    for (const match of source.matchAll(INLINE_TL_PATTERN)) {
      matched = true;

      if (match.index > lastIndex) {
        fragment.appendChild(
          document.createTextNode(source.slice(lastIndex, match.index))
        );
      }

      const level = Number(match[1]);
      fragment.appendChild(buildInlineTrustLevel(level, Boolean(match[2])));
      lastIndex = match.index + match[0].length;
    }

    if (!matched) {
      continue;
    }

    if (lastIndex < source.length) {
      fragment.appendChild(document.createTextNode(source.slice(lastIndex)));
    }

    textNode.replaceWith(fragment);
  }
}

function addNativeTitleTooltips(root = document) {
  const titles = [];

  if (root instanceof Element && root.matches(".user-title")) {
    titles.push(root);
  }

  if (root.querySelectorAll) {
    titles.push(...root.querySelectorAll(".user-title"));
  }

  for (const element of titles) {
    const existing = element.getAttribute("title")?.trim();
    const label = existing || element.textContent?.trim();

    if (!label) {
      continue;
    }

    element.title = label;
    if (!element.hasAttribute("aria-label")) {
      element.setAttribute("aria-label", label);
    }
  }
}

export default apiInitializer((api) => {
  if (settings.show_title_on_posts) {
    api.addTrackedPostProperties("trust_level");
    api.addTrackedPostProperties("title_badge");
  }

  api.decorateCookedElement(replaceInlineTrustLevels, {
    id: "trust-level-inline-icons",
  });

  addNativeTitleTooltips();

  const observer = new MutationObserver((mutations) => {
    for (const mutation of mutations) {
      for (const node of mutation.addedNodes) {
        if (node instanceof Element) {
          addNativeTitleTooltips(node);
        }
      }
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });
});
