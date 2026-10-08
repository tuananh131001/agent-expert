---
name: podcast-to-article
description: Turn a podcast episode into a readable long-form article exported as PDF and EPUB. Given a Spotify, Apple Podcasts, RSS, or direct audio link, it finds the public audio through the show's RSS feed, transcribes it locally with Whisper, writes an article that follows the episode's structure, and exports it. Use this whenever the user shares a podcast or episode link and wants it as text, transcribed, written up, turned into an article, blog post, ebook, PDF, or EPUB, or wants to "read instead of listen", even if they don't say "article".
---

# Podcast → Article (PDF + EPUB)

The pipeline has four stages: **find audio → transcribe → write the article → export**. Stages 1, 2 and 4 are scripted. Stage 3 is the real work.

All scripts are in `scripts/` next to this file. Put downloads and intermediate files in the session scratchpad (or another temp directory) and the final article files where the user wants them, defaulting to the current working directory.

## 1. Find the public audio

```bash
python3 scripts/find_audio.py "<episode url>"            # Spotify / Apple / RSS / .mp3
python3 scripts/find_audio.py "<rss feed url>" --title "episode title words"
```

It prints JSON with `show`, `title`, `pub_date`, `audio_url`, and the episode `description`. Spotify's stream is DRM-protected, so for a Spotify link the script reads the episode and show names from the page, looks up the show's RSS feed through the iTunes Search API, and matches the episode by title. Check that the returned title really is the episode the user meant before spending time on transcription.

If the show has no public feed (Spotify exclusives, paywalled shows), tell the user. Don't try to circumvent DRM. They can provide an audio file they have access to instead.

The episode description often includes chapter timestamps and correct spellings of guest names. Keep it handy for stage 3.

## 2. Transcribe locally

```bash
scripts/transcribe.sh "<audio_url or local file>" "<scratch work dir>" [base.en|small.en|medium.en]
```

Run it in the background, since it takes minutes. It creates a cached venv with `faster-whisper` on first use, decodes the audio with ffmpeg, and writes `transcript.txt` with `[h:mm:ss]` timestamps line by line. You can `tail` the file to measure progress and estimate time remaining. On a 2-core CPU, `base.en` runs at roughly 7× real time, so an 80-minute episode takes about 11 minutes. Use `small.en` when accuracy matters more than speed or the machine is faster. If the user asks how long it will take, measure from the progress (latest timestamp ÷ elapsed time) instead of guessing.

Speech recognition mangles proper nouns, for example "a Mill Taurus" for Émile Torres or "Yacowski" for Yudkowsky. Fix names using the episode description, show notes, and your own knowledge. If you can't confidently identify a name, describe the person ("a critic of the movement") rather than printing a guess.

## 3. Write the article

Read the whole transcript, not just the beginning, because long files need several reads. Then write the article in HTML, starting from `assets/article-template.html`. It includes print-ready CSS, a `masthead` header block (which export strips from the EPUB so the title isn't duplicated), and optional components for definition lists, callout boxes and pull quotes.

**Write it in your own words.** Podcast episodes are copyrighted works. A verbatim transcript, or a transcript lightly reshaped into paragraphs, is a reproduction of that work, even when the user asks to "keep the same content and just change the format." What you can deliver, and what most readers actually want, is an editorial adaptation:

- Follow the episode's order and cover every substantive segment, argument, example, and story. The reader should come away knowing everything the episode said.
- Paraphrase in clear prose. Use direct quotes only for short, striking lines (a sentence or less), and not many of them.
- Don't save or present the raw transcript as a deliverable. It's a working file.
- Leave out ads, sponsor reads, and newsletter plugs.

Tell the user briefly up front that the article will be an adaptation in your own words, so the result isn't a surprise.

**Structure.** Write a headline and a dek (a one- to two-sentence summary under the title). Open with the host's framing, then use one `<h2>` section per topic shift (chapter timestamps help here). Cast the speakers in the third person ("Newport asks…", "Torres argues…"). Turn back-and-forth dialogue into narrative that keeps who said what. Use a definition list when the episode defines several terms, and a callout box for the central thesis. End with any closing reflections from the host and a short "further reading" box if guests recommended their work.

**Attribution.** Podcasts are full of opinions and claims about real people and organizations. Present those as the speakers' claims ("Torres says…", "according to…"), not as established fact, especially accusations. Keep the closing `.note` disclaimer from the template.

Name the file after the episode in kebab-case, e.g. `stark-warning-former-ai-doomer.html`.

## 4. Export to PDF and EPUB

```bash
scripts/export.sh path/to/article.html "Adapted from <Show Name>"
```

This produces `article.pdf` using headless Chromium via `agent-browser` and `article.epub` using pandoc, with a table of contents split at `<h2>`. Then render page 1 of the PDF to an image (`pdftoppm -png -r 50 -f 1 -l 1`) and look at it to catch layout problems before reporting back.

## Report back

Give the paths to the PDF and EPUB (the HTML source sits next to them), the episode identified, and the transcription model used. Note anything uncertain, such as names you couldn't resolve or a low-accuracy model, plus any claims you made sure to attribute. Keep it short.
