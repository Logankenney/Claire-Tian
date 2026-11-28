// sign-in for www.claire-tian.com and the claire tian crm app: supabase auth, email link or 6-digit code, no password.
// only the publishable key is here; what each person can read is decided by row level security (crm/schema.sql).
// the session is kept in the browser as "ct-auth" (docs/cookies-register.json), and only once someone signs in.
(() => {
  const URL_ = 'https://sunvqcispixmiapylcuo.supabase.co';
  const KEY = 'sb_publishable_o15AkR6_X24mPIasdY0xMw_JxSW6LS6';
  const SLOT = 'ct-auth';
  // the mac app hands in its own store (window.ctStore) so a sign-in survives restarts; the site uses localStorage
  const store = window.ctStore || {
    get: k => { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set: (k, v) => { try { localStorage.setItem(k, v); } catch (e) {} },
    del: k => { try { localStorage.removeItem(k); } catch (e) {} }
  };
  const now = () => Math.floor(Date.now() / 1000);

  async function call(path, { method = 'POST', body, token, prefer } = {}) {
    const h = { apikey: KEY, 'content-type': 'application/json' };
    if (token) h.authorization = 'Bearer ' + token;
    if (prefer) h.prefer = prefer;
    const r = await fetch(URL_ + path, { method, headers: h, body: body === undefined ? undefined : JSON.stringify(body) });
    const text = await r.text();
    let data = null; try { data = text ? JSON.parse(text) : null; } catch (e) { data = text; }
    if (!r.ok) {
      const msg = (data && (data.msg || data.message || data.error_description || data.error)) || ('error ' + r.status);
      const err = new Error(String(msg).toLowerCase()); err.status = r.status; err.code = data && (data.code || data.error_code); throw err;
    }
    return data;
  }

  const save = s => {
    const keep = { access_token: s.access_token, refresh_token: s.refresh_token,
      expires_at: s.expires_at ? +s.expires_at : now() + (+s.expires_in || 3600),
      email: (s.user && s.user.email) || s.email || '', id: (s.user && s.user.id) || s.id || '' };
    store.set(SLOT, JSON.stringify(keep));
    return keep;
  };
  const load = () => { try { return JSON.parse(store.get(SLOT) || 'null'); } catch (e) { return null; } };

  let refreshing = null;
  async function session() {
    const s = load();
    if (!s || !s.refresh_token) return null;
    if (s.expires_at - 90 > now()) return s;
    if (!refreshing) refreshing = call('/auth/v1/token?grant_type=refresh_token', { body: { refresh_token: s.refresh_token } })
      .then(save)
      .catch(e => { if (e.status && e.status < 500) store.del(SLOT); return null; })
      .finally(() => { refreshing = null; });
    return refreshing;
  }

  window.ctAuth = {
    // step 1: email the person a link and a code. "marketing" is the optional tick box; its wording is kept as consent.
    sendCode(email, { marketing = false, wording = '', from = '', redirect } = {}) {
      const q = redirect ? '?redirect_to=' + encodeURIComponent(redirect) : '';
      return call('/auth/v1/otp' + q, { body: { email, create_user: true, data: { marketing: !!marketing, marketing_text: wording, from } } });
    },
    // step 2a: the code from the email
    async verifyCode(email, code) {
      const s = await call('/auth/v1/verify', { body: { type: 'email', email, token: String(code).replace(/\D/g, '') } });
      return save(s);
    },
    // step 2b: the link from the email lands back on the page with the session in the address (#access_token=...)
    async fromLink() {
      const h = new URLSearchParams(location.hash.slice(1));
      if (!h.has('access_token') && !h.has('error_description') && !h.has('error')) return null;
      history.replaceState(null, '', location.pathname + location.search);
      if (!h.has('access_token')) throw new Error((h.get('error_description') || h.get('error') || 'the link did not work').replace(/\+/g, ' ').toLowerCase());
      const s = { access_token: h.get('access_token'), refresh_token: h.get('refresh_token'),
                  expires_at: h.get('expires_at'), expires_in: h.get('expires_in') };
      s.user = await call('/auth/v1/user', { method: 'GET', token: s.access_token });
      return save(s);
    },
    session,
    signedIn: () => !!load(),
    async signOut() {
      const s = load(); store.del(SLOT);
      if (s) try { await call('/auth/v1/logout', { token: s.access_token }); } catch (e) {}
    },
    forget: () => store.del(SLOT),
    // a database function (crm/schema.sql), called as the signed-in person
    async rpc(name, args = {}) {
      const s = await session();
      if (!s) { const e = new Error('not signed in'); e.status = 401; throw e; }
      return call('/rest/v1/rpc/' + name, { body: args, token: s.access_token });
    }
  };
})();

// the footer says "account" instead of "join" once someone is signed in
document.querySelectorAll('a.acct').forEach(a => { if (window.ctAuth && ctAuth.signedIn()) a.textContent = 'account'; });
