// the crm (crm.html, also inside the mac app). reads and writes only through the crm_* database functions in
// crm/schema.sql, as the signed-in person; staff and admin only.
(() => {
  const $ = id => document.getElementById(id);
  const esc = s => String(s == null ? '' : s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const STAGES = ['new', 'talking', 'booked', 'client', 'past client', 'not a fit'];
  const PERMS = ['member', 'insider', 'staff', 'admin'];
  const say = (t, id = 'status') => { $(id).textContent = t || ''; };
  const inApp = !!(window.webkit && webkit.messageHandlers && webkit.messageHandlers.ctSave);
  const day = t => t ? new Date(t).toLocaleDateString(undefined, { year: '2-digit', month: 'short', day: 'numeric' }).toLowerCase() : '';
  const when = t => t ? new Date(t).toLocaleString(undefined, { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }).toLowerCase() : '';
  const ago = t => {
    if (!t) return '';
    const m = Math.round((Date.now() - new Date(t)) / 60000);
    return m < 60 ? m + 'm ago' : m < 1440 ? Math.round(m / 60) + 'h ago' : m < 60 * 24 * 60 ? Math.round(m / 1440) + 'd ago' : day(t);
  };

  let people = [], role = '', picked = null, email = '';

  STAGES.forEach(s => $('f-stage').insertAdjacentHTML('beforeend', `<option>${s}</option>`));
  PERMS.forEach(s => $('f-perm').insertAdjacentHTML('beforeend', `<option>${s}</option>`));

  // ---- signing in ---------------------------------------------------------------------------------
  const gate = (msg) => { $('app').hidden = true; $('gate').hidden = false; $('refresh').hidden = $('signout').hidden = true;
    $('me').textContent = ''; $('nums').textContent = ''; $('g-email').hidden = false; $('g-code').hidden = true; say(msg, 'g-status'); $('g-addr').focus(); };

  $('g-email').addEventListener('submit', async e => {
    e.preventDefault();
    email = $('g-addr').value.trim().toLowerCase();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email)) return say('that is not an email address.', 'g-status');
    say('sending...', 'g-status');
    try {
      // on the website the email's link also works; in the app only the code does
      await ctAuth.sendCode(email, location.protocol === 'https:' ? { redirect: location.origin + location.pathname, from: 'crm' } : { from: 'crm app' });
      $('g-email').hidden = true; $('g-code').hidden = false; say('code sent to ' + email + '.', 'g-status'); $('g-num').focus();
    } catch (er) { say(er.status === 429 ? 'too many tries. wait a minute.' : er.message, 'g-status'); }
  });
  $('g-code').addEventListener('submit', async e => {
    e.preventDefault();
    say('checking...', 'g-status');
    try { await ctAuth.verifyCode(email, $('g-num').value); $('g-num').value = ''; await start(); }
    catch (er) { say('that code is wrong or too old. send a new one.', 'g-status'); }
  });
  $('g-back').addEventListener('click', () => gate(''));
  $('signout').addEventListener('click', async () => { await ctAuth.signOut(); people = []; picked = null; gate('signed out.'); });
  $('refresh').addEventListener('click', () => load(true));

  // ---- loading ------------------------------------------------------------------------------------
  async function start() {
    try { await ctAuth.fromLink(); } catch (e) { return gate(e.message); }
    const s = await ctAuth.session();
    if (!s) return gate('');
    $('gate').hidden = true; $('app').hidden = false; $('refresh').hidden = $('signout').hidden = false;
    $('me').textContent = s.email || '';
    await load();
  }

  async function load(loud) {
    if (loud) say('loading...');
    try {
      const [sum, list] = await Promise.all([ctAuth.rpc('crm_summary'), ctAuth.rpc('crm_list')]);
      role = sum.role || '';
      people = list || [];
      $('nums').innerHTML = `<b>${sum.members}</b> members · <b>${sum.new_7d}</b> new this week · <b>${sum.active_7d}</b> active this week · <b>${sum.marketing}</b> opted in`;
      $('me').textContent = ($('me').textContent.split(' · ')[0]) + ' · ' + role;
      draw();
      if (picked) open(picked, true);
      say(loud ? 'up to date ' + when(new Date()) : '');
    } catch (e) {
      if (e.status === 401) return gate('signed out. sign in again.');
      if (e.code === '42501' || /no access/.test(e.message)) {
        $('app').hidden = true; $('gate').hidden = false; $('g-email').hidden = $('g-code').hidden = true;
        return say('this account has no crm access. an admin can give it staff access.', 'g-status');
      }
      say(e.message);
    }
  }

  // ---- the list -----------------------------------------------------------------------------------
  const shown = () => {
    const q = $('q').value.trim().toLowerCase(), st = $('f-stage').value, pm = $('f-perm').value, mk = $('f-mk').checked;
    return people.filter(p => (!st || p.stage === st) && (!pm || p.permission === pm) && (!mk || p.marketing) &&
      (!q || [p.email, p.name, (p.tags || []).join(' ')].join(' ').toLowerCase().includes(q)));
  };
  function draw() {
    const rows = shown();
    $('rows').tBodies[0].innerHTML = rows.map(p => `<tr data-id="${p.id}" class="${p.id === picked ? 'on' : ''}">
      <td class="email">${esc(p.email)}</td><td>${esc(p.name)}</td><td>${esc(p.stage)}</td><td>${esc(p.permission)}</td>
      <td>${p.marketing ? 'yes' : ''}</td><td class="r">${p.visits}</td><td class="r">${p.sign_ins}</td>
      <td>${ago(p.last_seen || p.last_sign_in)}</td><td>${day(p.joined)}</td></tr>`).join('');
    $('empty').hidden = rows.length > 0;
    $('empty').textContent = people.length ? 'no one matches.' : 'no one has joined yet.';
  }
  ['q', 'f-stage', 'f-perm', 'f-mk'].forEach(id => $(id).addEventListener('input', draw));
  $('rows').addEventListener('click', e => { const tr = e.target.closest('tr[data-id]'); if (tr) open(tr.dataset.id); });

  // ---- one person ---------------------------------------------------------------------------------
  async function open(id, quiet) {
    picked = id; draw();
    if (!quiet) $('detail').innerHTML = '<p class="muted pad">loading...</p>';
    let m;
    try { m = await ctAuth.rpc('crm_member', { p_id: id }); } catch (e) { $('detail').innerHTML = `<p class="pad">${esc(e.message)}</p>`; return; }
    if (!m) { $('detail').innerHTML = '<p class="muted pad">gone.</p>'; return; }
    const admin = role === 'admin';
    const opts = (list, v) => list.map(o => `<option${o === v ? ' selected' : ''}>${o}</option>`).join('');
    const consent = (m.consents || []).map(c => `<li><span>${when(c.at)}</span><span>${c.given ? 'opted in' : 'opted out'} (${esc(c.source)})${c.wording ? ': “' + esc(c.wording) + '”' : ''}</span></li>`).join('');
    $('detail').innerHTML = `
      <h2>${esc(m.email)}</h2>
      <div class="muted">joined ${day(m.joined)}${m.first_page ? ' from ' + esc(m.first_page) : ''} · ${m.sign_ins} sign-ins · last seen ${ago(m.last_seen || m.last_sign_in) || 'never'}</div>
      <div class="fields">
        <label for="d-name">name</label><input id="d-name" value="${esc(m.name)}" spellcheck="false">
        <label for="d-stage">stage</label><select id="d-stage">${opts(STAGES, m.stage)}</select>
        <label for="d-perm">access</label><select id="d-perm" ${admin ? '' : 'disabled title="admin only"'}>${opts(PERMS, m.permission)}</select>
        <label for="d-tags">tags</label><input id="d-tags" value="${esc((m.tags || []).join(', '))}" placeholder="wedding, film, nyc" spellcheck="false">
      </div>
      <div class="row"><button class="send" id="d-save" type="button">save</button><a class="text muted" href="mailto:${esc(m.email)}">email them</a><span id="d-status" class="muted"></span></div>

      <h3>marketing email: ${m.marketing ? 'yes, since ' + day(m.marketing_at) : 'no'}</h3>
      <ul class="log">${consent || '<li><span></span><span class="muted">never asked to be emailed.</span></li>'}</ul>

      <h3>notes</h3>
      <textarea id="d-note" placeholder="add a note"></textarea>
      <div class="row"><button class="send" id="d-add" type="button">add note</button></div>
      <ul class="log">${(m.notes || []).map(n => `<li><span>${when(n.at)}</span><span><span class="note-body">${esc(n.body)}</span> <span class="muted">· ${esc(n.author)}</span></span></li>`).join('')}</ul>

      <h3>pages seen while signed in (${(m.visits || []).length})</h3>
      <ul class="log">${(m.visits || []).map(v => `<li><span>${when(v.at)}</span><span>${esc(v.page)}${v.device ? ' · ' + esc(v.device) + ' ' + esc(v.browser || '') : ''}${v.from ? ' · from ' + esc(v.from) : ''}${v.seconds != null ? ' · ' + v.seconds + 's' : ''}</span></li>`).join('') || '<li><span></span><span class="muted">none yet.</span></li>'}</ul>

      <h3>history</h3>
      <ul class="log">${(m.events || []).map(e => `<li><span>${when(e.at)}</span><span>${esc(e.event)}${e.detail ? ' · ' + esc(e.detail) : ''}</span></li>`).join('')}</ul>`;

    $('d-save').addEventListener('click', async () => {
      const patch = { name: $('d-name').value, stage: $('d-stage').value,
        tags: $('d-tags').value.split(',').map(t => t.trim()).filter(Boolean) };
      if (admin && $('d-perm').value !== m.permission) patch.permission = $('d-perm').value;
      $('d-status').textContent = 'saving...';
      try { await ctAuth.rpc('crm_update', { p_id: id, p_patch: patch }); $('d-status').textContent = 'saved.'; await load(); }
      catch (e) { $('d-status').textContent = e.message; }
    });
    $('d-add').addEventListener('click', async () => {
      const body = $('d-note').value.trim();
      if (!body) return;
      try { await ctAuth.rpc('crm_add_note', { p_id: id, p_body: body }); await open(id, true); load(); }
      catch (e) { $('d-status').textContent = e.message; }
    });
  }

  // ---- export -------------------------------------------------------------------------------------
  const cell = v => { const s = Array.isArray(v) ? v.join('; ') : String(v == null ? '' : v); return /[",\n]/.test(s) ? '"' + s.replace(/"/g, '""') + '"' : s; };
  function save(name, text) {
    if (inApp) return webkit.messageHandlers.ctSave.postMessage({ name, text });   // the mac app shows a save dialog
    const a = document.createElement('a');
    a.href = URL.createObjectURL(new Blob([text], { type: 'text/csv' })); a.download = name; a.click();
    setTimeout(() => URL.revokeObjectURL(a.href), 1000);
  }
  const stamp = () => new Date().toISOString().slice(0, 10);
  $('csv').addEventListener('click', () => {
    const cols = ['email', 'name', 'stage', 'permission', 'tags', 'marketing', 'marketing_at', 'joined', 'first_page', 'sign_ins', 'last_sign_in', 'last_seen', 'visits', 'notes'];
    save(`claire-tian-members-${stamp()}.csv`, [cols.join(','), ...shown().map(p => cols.map(c => cell(p[c])).join(','))].join('\n') + '\n');
  });
  $('csv-mk').addEventListener('click', () => {
    const rows = people.filter(p => p.marketing);
    save(`claire-tian-opted-in-${stamp()}.csv`, ['email,name,opted_in_at', ...rows.map(p => [p.email, p.name, p.marketing_at].map(cell).join(','))].join('\n') + '\n');
  });

  addEventListener('focus', () => { if (!$('app').hidden) load(); });
  start();
})();
