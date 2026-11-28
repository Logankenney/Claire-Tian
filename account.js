// account.html: join or sign in with an email link or code, tick or untick marketing email, sign out, delete the account.
// talks to supabase through auth.js; the rules live in crm/schema.sql.
(() => {
  const $ = id => document.getElementById(id);
  const WORDING = $('mk-text').textContent.trim();
  const steps = ['out', 'code', 'in'];
  const show = step => steps.forEach(s => { $('step-' + s).hidden = s !== step; });
  const say = (id, t) => { $(id).textContent = t || ''; };
  const busy = (form, on) => form.querySelectorAll('button, input').forEach(el => { el.disabled = on; });
  const valid = e => /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(e);
  let email = '';

  async function signedIn() {
    const s = await ctAuth.session();
    if (!s) return false;
    try {
      const me = await ctAuth.rpc('my_account');
      if (!me) { ctAuth.forget(); return false; }
      $('who').textContent = me.email;
      $('mk-on').checked = !!me.marketing;
      // a tick given on the join form, if the account already existed, is saved now
      const pending = sessionStorage.getItem('ct-join-mk');
      if (pending === '1' && !me.marketing) {
        await ctAuth.rpc('set_marketing', { p_on: true, p_wording: WORDING, p_source: 'join' });
        $('mk-on').checked = true;
      }
      sessionStorage.removeItem('ct-join-mk');
      show('in');
      return true;
    } catch (e) {
      if (e.status === 401) { ctAuth.forget(); return false; }
      show('in'); say('in-status', e.message); return true;
    }
  }

  // step 1: email
  $('step-out').addEventListener('submit', async e => {
    e.preventDefault();
    email = $('email').value.trim().toLowerCase();
    if (!valid(email)) { say('out-status', 'that is not an email address.'); $('email').focus(); return; }
    const mk = $('mk').checked;
    try { sessionStorage.setItem('ct-join-mk', mk ? '1' : '0'); } catch (er) {}
    busy(e.target, true); say('out-status', 'sending...');
    try {
      await ctAuth.sendCode(email, { marketing: mk, wording: mk ? WORDING : '', from: document.referrer ? new URL(document.referrer).pathname : '',
                                     redirect: location.origin + location.pathname });
      $('sent-to').textContent = email;
      show('code'); say('out-status'); $('code').focus();
    } catch (er) {
      say('out-status', er.status === 429 ? 'too many tries. wait a minute and try again.' : er.message);
    } finally { busy(e.target, false); }
  });

  // step 2: the code (the link signs in on its own, below)
  $('step-code').addEventListener('submit', async e => {
    e.preventDefault();
    const code = $('code').value.replace(/\D/g, '');
    if (code.length < 6) { say('code-status', 'the code is the 6 numbers in the email.'); return; }
    busy(e.target, true); say('code-status', 'checking...');
    try { await ctAuth.verifyCode(email, code); say('code-status'); await signedIn(); }
    catch (er) { say('code-status', er.status === 403 || er.status === 400 ? 'that code is wrong or too old. send a new one.' : er.message); }
    finally { busy(e.target, false); }
  });
  $('again').addEventListener('click', () => { show('out'); $('email').focus(); });

  // signed in
  $('mk-on').addEventListener('change', async e => {
    const on = e.target.checked;
    say('in-status', 'saving...');
    try { await ctAuth.rpc('set_marketing', { p_on: on, p_wording: WORDING, p_source: 'account' }); say('in-status', on ? 'saved. you will get the odd email.' : 'saved. no more emails.'); }
    catch (er) { e.target.checked = !on; say('in-status', er.message); }
  });
  $('out').addEventListener('click', async () => { await ctAuth.signOut(); show('out'); say('out-status', 'signed out.'); });
  let sure = false;
  $('delete').addEventListener('click', async () => {
    if (!sure) { sure = true; $('delete').textContent = 'delete everything? click again'; setTimeout(() => { sure = false; $('delete').textContent = 'delete my account'; }, 6000); return; }
    say('in-status', 'deleting...');
    try { await ctAuth.rpc('delete_my_account'); ctAuth.forget(); show('out'); say('out-status', 'deleted. nothing about you is left in the account list.'); }
    catch (er) { say('in-status', er.message); }
  });

  (async () => {
    try { if (await ctAuth.fromLink()) { await signedIn(); return; } }
    catch (er) { show('out'); say('out-status', er.message.includes('expired') ? 'that link is too old. send a new one.' : er.message); return; }
    if (!(await signedIn())) show('out');
  })();
})();
