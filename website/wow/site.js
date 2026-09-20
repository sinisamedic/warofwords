(() => {
  'use strict';
  const config = window.WOW_SITE || {};
  const safeHttps = value => { try { const u = new URL(value); return u.protocol === 'https:' ? u.href : null; } catch { return null; } };
  document.querySelectorAll('[data-social]').forEach(a => {
    const url = safeHttps(config[a.dataset.social + 'Url']);
    if (url) { a.href = url; a.querySelector('small').textContent = 'Follow us'; a.setAttribute('aria-label', a.dataset.social + ' — official profile'); a.rel = 'noopener noreferrer'; }
    else { const label = document.createElement('div'); for (const attr of a.attributes) if (!['href', 'aria-label'].includes(attr.name)) label.setAttribute(attr.name, attr.value); label.innerHTML = a.innerHTML; label.classList.add('unavailable'); label.querySelector('span:last-child').textContent = '—'; a.replaceWith(label); }
  });
  const store = safeHttps(config.playStoreUrl);
  if (store) {
    document.querySelectorAll('.release-link,.nav-cta').forEach(a => { a.href = store; a.textContent = 'Get it on Google Play ↗'; a.rel = 'noopener noreferrer'; });
    document.querySelectorAll('.release-status').forEach(el => el.textContent = 'Available on Android');
  }
  const motion = matchMedia('(prefers-reduced-motion: reduce)');
  let paused = motion.matches;
  function applyMotion() { document.documentElement.classList.toggle('motion-paused', paused); const b = document.querySelector('.motion-toggle'); if (b) { b.textContent = paused ? 'Enable motion' : 'Pause motion'; b.setAttribute('aria-pressed', String(paused)); } }
  applyMotion();
  motion.addEventListener('change', e => { paused = e.matches; applyMotion(); });
  document.querySelector('.motion-toggle')?.addEventListener('click', () => { paused = !paused; applyMotion(); });
  const embers = document.querySelector('.embers');
  if (embers) for (let i = 0; i < 18; i++) { const s = document.createElement('span'); s.style.cssText = `--x:${(i * 37) % 100}%;--delay:${-i * .8}s;--duration:${9 + (i % 5)}s`; embers.append(s); }
  const box = document.querySelector('.lightbox');
  if (box) {
    document.querySelectorAll('[data-full]').forEach(b => b.addEventListener('click', () => { box.querySelector('img').src = b.dataset.full; box.querySelector('img').alt = b.querySelector('img').alt; box.querySelector('p').textContent = b.dataset.caption; box.showModal(); }));
    box.querySelector('button').addEventListener('click', () => box.close());
    box.addEventListener('click', e => { if (e.target === box) { const r=box.getBoundingClientRect(); if(e.clientX < r.left || e.clientX > r.right || e.clientY < r.top || e.clientY > r.bottom) box.close(); } });
  }
  document.querySelectorAll('[data-email]').forEach(a => { const kind = a.dataset.email; const email = config[kind + 'Email']; if (config.contactsVerified && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email || '')) { a.href = 'mailto:' + email + (kind === 'privacy' ? '?subject=War%20of%20Words%20data%20request' : '?subject=War%20of%20Words%20support'); a.textContent = email; } else { a.removeAttribute('href'); a.textContent = (email || 'Contact') + ' — not yet verified'; } });
  if (config.contactsVerified) document.querySelectorAll('[data-contact-pending]').forEach(el => el.hidden = true);
})();
