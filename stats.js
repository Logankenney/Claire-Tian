// visitor log. counts visits so claire can see what people look at. no cookies. the server ("hit" function) keeps the
// visitor's ip address with each record (deleted after 400 days). browser storage: docs/cookies-register.json. see legal.html.
// visit any page with ?notrack to stop counting this browser (for logan and claire), ?track to start again.
// when the visitor has joined and is signed in (auth.js), each counted page view is also added to their account
// (link_visit, crm/schema.sql), so the crm shows what members look at. signed-out visitors are not linked to anyone.
(() => {
  const END = 'https://sunvqcispixmiapylcuo.supabase.co/functions/v1/hit';
  const q = new URLSearchParams(location.search);
  try {
    if (q.has('notrack')) localStorage.setItem('ct-notrack', '1');
    if (q.has('track')) localStorage.removeItem('ct-notrack');
    if (localStorage.getItem('ct-notrack')) return;
  } catch (e) {}
  if (navigator.globalPrivacyControl) return;   // browsers that send a "do not sell or share" signal are not counted
  if (!/claire-tian\.com$/.test(location.hostname)) return;

  const file = location.pathname.split('/').pop() || 'index.html';
  const page = document.title.startsWith('nothing') ? '404'
    : ({ 'index.html': 'home', 'recent.html': 'photo dump', 'contact.html': 'contact', 'photo.html': 'photo', 'privacy.html': 'privacy', 'legal.html': 'legal' }[file] || file);
  let ref = '';
  try { const r = new URL(document.referrer); if (r.hostname !== location.hostname) ref = r.hostname; } catch (e) {}
  const base = {
    page, path: page === 'photo' ? 'photo:' + (q.get('p') || '') : location.pathname,
    ref, us: q.get('utm_source') || '', um: q.get('utm_medium') || '', uc: q.get('utm_campaign') || '',
    sw: screen.width, sh: screen.height, lang: navigator.language || '',
    tz: (Intl.DateTimeFormat().resolvedOptions().timeZone) || '',
    sid: Math.random().toString(36).slice(2, 12)
  };
  const send = extra => {
    const body = JSON.stringify(Object.assign({}, base, extra));
    if (!(navigator.sendBeacon && navigator.sendBeacon(END, body))) fetch(END, { method: 'POST', body, keepalive: true, mode: 'no-cors' }).catch(() => {});
  };

  const t0 = Date.now();
  const view = () => {
    const nav = performance.getEntriesByType && performance.getEntriesByType('navigation')[0];
    send({ kind: 'view', load: nav ? Math.round(nav.loadEventEnd || nav.domContentLoadedEventEnd) : '' });
  };
  if (document.readyState === 'complete') setTimeout(view, 0); else addEventListener('load', () => setTimeout(view, 0));
  if (window.ctAuth && ctAuth.signedIn()) setTimeout(() => ctAuth.rpc('link_visit', { p_session: base.sid, p_page: page }).catch(() => {}), 1500);

  // how far the sideways strip was scrolled, in percent
  let scroll = 0;
  const strip = document.getElementById('work');
  if (strip) strip.addEventListener('scroll', () => {
    const max = strip.scrollWidth - strip.clientWidth;
    if (max > 0) scroll = Math.max(scroll, Math.round(100 * strip.scrollLeft / max));
  }, { passive: true });

  let left = false;
  const leave = () => { if (left) return; left = true; send({ kind: 'leave', sec: Math.round((Date.now() - t0) / 1000), scroll: strip ? scroll : '' }); };
  addEventListener('pagehide', leave);
  document.addEventListener('visibilitychange', () => { if (document.visibilityState === 'hidden') leave(); });

  document.addEventListener('click', e => {
    const a = e.target.closest && e.target.closest('a');
    if (!a) return;
    if (a.classList.contains('ig')) send({ kind: 'event', event: 'ig_click' });
    else if (/photo\.html\?p=/.test(a.getAttribute('href') || '')) send({ kind: 'event', event: 'photo_open', label: new URL(a.href).searchParams.get('p') });
  });
  const form = document.getElementById('idea');
  if (form) form.addEventListener('submit', () => { if (form.elements.idea.value.trim()) send({ kind: 'event', event: 'contact_send' }); });
})();
