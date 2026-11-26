// Supabase edge function "hit": receives one visit record from stats.js and stores it.
// The visitor's ip address is used only inside record_hit() to make a one-way code that changes every day; it is never stored.
import { createClient } from "jsr:@supabase/supabase-js@2";

const db = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const ALLOWED = /^https:\/\/(www\.)?claire-tian\.com$/;
const BOT = /bot|crawl|spider|slurp|headless|lighthouse|pagespeed|preview|facebookexternalhit|embedly|python|curl|wget|httpclient|monitor|uptime/i;

function device(ua: string) {
  if (/ipad|tablet|(android(?!.*mobile))/i.test(ua)) return "tablet";
  if (/mobi|iphone|android/i.test(ua)) return "phone";
  return "desktop";
}
function browser(ua: string) {
  if (/edg\//i.test(ua)) return "edge";
  if (/instagram/i.test(ua)) return "instagram app";
  if (/fban|fbav/i.test(ua)) return "facebook app";
  if (/opr\//i.test(ua)) return "opera";
  if (/samsungbrowser/i.test(ua)) return "samsung";
  if (/firefox|fxios/i.test(ua)) return "firefox";
  if (/chrome|crios/i.test(ua)) return "chrome";
  if (/safari/i.test(ua)) return "safari";
  return "other";
}
function os(ua: string) {
  if (/iphone|ipad|ipod/i.test(ua)) return "ios";
  if (/android/i.test(ua)) return "android";
  if (/windows/i.test(ua)) return "windows";
  if (/mac os x|macintosh/i.test(ua)) return "macos";
  if (/cros/i.test(ua)) return "chromeos";
  if (/linux/i.test(ua)) return "linux";
  return "other";
}

Deno.serve(async (req) => {
  const origin = req.headers.get("origin") ?? "";
  const cors = { "Access-Control-Allow-Origin": ALLOWED.test(origin) ? origin : "https://www.claire-tian.com" };
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: { ...cors, "Access-Control-Allow-Methods": "POST", "Access-Control-Allow-Headers": "content-type" } });
  if (req.method !== "POST" || !ALLOWED.test(origin)) return new Response(null, { status: 204, headers: cors });
  let p: Record<string, unknown>;
  try {
    const text = await req.text();
    if (text.length > 4000) return new Response(null, { status: 204, headers: cors });
    p = JSON.parse(text);
  } catch { return new Response(null, { status: 204, headers: cors }); }
  const ua = (req.headers.get("user-agent") ?? "").slice(0, 400);
  const ip = (req.headers.get("x-forwarded-for") ?? "").split(",")[0].trim();
  const { error } = await db.rpc("record_hit", {
    p, p_ip: ip, p_ua: ua, p_bot: BOT.test(ua) || !ua, p_device: device(ua), p_browser: browser(ua), p_os: os(ua),
  });
  if (error) console.error("record_hit", error.message);
  return new Response(null, { status: 204, headers: cors });
});
