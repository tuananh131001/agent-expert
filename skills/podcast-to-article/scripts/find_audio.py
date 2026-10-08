#!/usr/bin/env python3
"""Resolve a podcast episode link (Spotify, Apple Podcasts, RSS feed, or direct audio URL)
to its public audio file by way of the show's RSS feed.

Usage: find_audio.py <url> [--title "episode title hint"]
Prints JSON: {show, title, pub_date, audio_url, feed_url, description}
"""
import html
import json
import re
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

UA = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/124 Safari/537.36"}


def fetch(url):
    req = urllib.request.Request(url, headers=UA)
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode("utf-8", "replace")


def norm(s):
    return re.sub(r"[^a-z0-9]+", " ", html.unescape(s or "").lower()).strip()


def itunes(params):
    return json.loads(fetch("https://itunes.apple.com/" + params))["results"]


def spotify_meta(url):
    # A full browser UA gets the empty "Spotify – Web Player" shell; a bare UA gets server-rendered meta tags
    req = urllib.request.Request(url.split("?")[0], headers={"User-Agent": "Mozilla/5.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        page = r.read().decode("utf-8", "replace")
    og = re.search(r'<meta property="og:title" content="([^"]*)"', page)
    desc = re.search(r'<meta name="description" content="Listen to this episode from (.*?) on Spotify', page)
    if og and desc:
        return html.unescape(og.group(1)).strip(), html.unescape(desc.group(1)).strip()
    # Fallback: "<Episode> - <Show> | Podcast on Spotify"
    m = re.search(r"<title>(.*?)</title>", page, re.S)
    full = re.sub(r"\s*\|\s*Podcast on Spotify\s*$", "", html.unescape(m.group(1)) if m else "")
    title, _, show = full.rpartition(" - ")
    if not show:
        sys.exit("Could not read episode/show names from the Spotify page; pass the RSS feed URL with --title instead.")
    return title.strip(), show.strip()


def find_feed(show):
    for r in itunes("search?" + urllib.parse.urlencode({"term": show, "entity": "podcast", "limit": 5})):
        if r.get("feedUrl") and norm(r.get("collectionName")) == norm(show):
            return r["feedUrl"]
    res = itunes("search?" + urllib.parse.urlencode({"term": show, "entity": "podcast", "limit": 1}))
    return res[0]["feedUrl"] if res else None


def episodes(feed_url):
    root = ET.fromstring(fetch(feed_url).encode())
    chan = root.find("channel")
    show = chan.findtext("title")
    for it in chan.findall("item"):
        enc = it.find("enclosure")
        yield {
            "show": show,
            "title": it.findtext("title"),
            "pub_date": it.findtext("pubDate"),
            "audio_url": enc.get("url") if enc is not None else None,
            "feed_url": feed_url,
            "description": re.sub(r"<[^>]+>", " ", it.findtext("description") or "").strip()[:1500],
        }


def match(feed_url, title_hint):
    eps = list(episodes(feed_url))
    if not title_hint:
        return eps[0]  # newest episode
    hint = norm(title_hint)
    for e in eps:
        if norm(e["title"]) == hint:
            return e
    words = set(hint.split())
    best = max(eps, key=lambda e: len(words & set(norm(e["title"]).split())))
    return best


def main():
    args = sys.argv[1:]
    if not args:
        sys.exit(__doc__)
    url = args[0]
    title_hint = args[args.index("--title") + 1] if "--title" in args else None
    host = urllib.parse.urlparse(url).netloc

    if re.search(r"\.(mp3|m4a|aac|ogg|opus|wav)(\?|$)", url):
        out = {"show": None, "title": title_hint, "pub_date": None, "audio_url": url, "feed_url": None, "description": ""}
    elif "spotify.com" in host:
        title, show = spotify_meta(url)
        feed = find_feed(show)
        if not feed:
            sys.exit(f"No public RSS feed found for show {show!r} (it may be a Spotify exclusive).")
        out = match(feed, title_hint or title)
    elif "apple.com" in host:
        q = urllib.parse.parse_qs(urllib.parse.urlparse(url).query)
        show_id = re.search(r"id(\d+)", url).group(1)
        if "i" in q:
            for r in itunes(f"lookup?id={show_id}&entity=podcastEpisode&limit=200"):
                if str(r.get("trackId")) == q["i"][0] and r.get("episodeUrl"):
                    title_hint = title_hint or r.get("trackName")
                    break
        feed = itunes(f"lookup?id={show_id}")[0]["feedUrl"]
        out = match(feed, title_hint)
    else:  # assume an RSS feed URL
        out = match(url, title_hint)

    print(json.dumps(out, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
