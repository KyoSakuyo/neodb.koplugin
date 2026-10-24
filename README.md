# NeoDB for KOReader

Link the book you are reading to its entry on a NeoDB server, then keep your status, progress, rating, notes and highlights up to date without leaving the book.

## What is NeoDB

[NeoDB](https://neodb.net) is a free and open source catalogue of books, films and more, similar to Goodreads or StoryGraph. The difference is that there is no single NeoDB owned by a single company: many servers run it, and they talk to each other over open protocols such as ActivityPub and ATProto. You may use it to share your reading with friends on Mastodon and Bluesky, or keep a completely private reading journal.

## Screenshots

| Link to a book | Rate and comment | Sync options |
|:---:|:---:|:---:|
| ![Linking a book to NeoDB](screenshots/link.png) | ![Rating a book and writing a comment](screenshots/mark.png) | ![Choosing what this book syncs](screenshots/options.png) |

## Install

The interface follows KOReader's language setting: Simplified Chinese is fully
translated, and English uses the original labels. Generated note titles and the
quote introduction follow the same language; your book metadata and note text
are never translated. Restart KOReader after changing its interface language.

**From a plugin store**, which handles updates afterwards: search for **NeoDB** in [Storefront](https://github.com/ultimatejimmy/storefront.koplugin) or [AppStore](https://github.com/omer-faruq/appstore.koplugin).

**Manually**: download `neodb.koplugin.zip` from [the latest release](https://github.com/neodb-social/neodb.koplugin/releases/latest) and unzip it into KOReader's `plugins` folder. The zip already holds a correctly named folder, so there is nothing to rename.

| Device | Folder |
| --- | --- |
| Kobo | `.adds/koreader/plugins/` |
| Kindle | `koreader/plugins/` |
| Android | `koreader/plugins/` under internal storage |
| Desktop | `koreader/plugins/` next to the program |

Restart KOReader after install. The plugin appears under **☰ → Tools → NeoDB**.

To see which version you have, tap **☰ → Tools → NeoDB → Settings → About this plugin**. A copy built from the source rather than installed from a release reports `dev`.

## Signing in NeoDB

Tap **☰ → Tools → NeoDB → Sign in to NeoDB…** and pick one of these.

- **Scan a QR code** is the easiest. Scan it, sign in on your phone, then tap **Done** on the reader.
- **Enter a server address myself** involves nobody but your server. Approve the plugin in a browser and type the short code back, or paste a token you made at `https://your-server/developer/`.
- **Read a token from a file** avoids typing. Save the token as the first line of `neodb_token.txt` in your KOReader folder, then pick this option.

## Linking a book

Once signed in, the first time you open a book, the plugin offers to match an entry in the server catalogue. You can also match it yourself from either **NeoDB → Find this book on NeoDB…**, which searches by ISBN / title + author; or from **Link by URL…**, which takes a link from NeoDB, Goodreads, Google Books, Open Library or Douban.

After linking, you may choose whether to send progress and highlights automatically. Your choice are kept per book and can be changed later under **Settings for this book**.

## What you can do once linked

Most features are under the **☰ → Tools → NeoDB** menu:

- **Read Status**: set to Want to read, Reading, Finished, Dropped.
- **Update progress** sends where you are now.
- **Rate and comment**, from half a star to five, with an optional comment.
- **Add note**, with your position attached if you want.
- **Post something…** writes a post with no book attached.
- **Settings for this book** holds that book's own switches.

Choose **添加笔记&分享** to save a note on that passage in KOReader and share it
to NeoDB together. The quote button cycles through four modes:

- **引用：正文下方 / Quote: below note** (default): append the quote when posting.
- **引用：正文上方 / Quote: above note**: prepend the quote when posting.
- **引用：无 / Quote: none**: post only your note, without a quote or introduction.
- **引用：自定义 / Quote: custom**: put the quote and a blank line directly in the
  editor before your notes, so you can freely edit the whole post. Nothing is
  automatically added when posting.

The automatic modes keep the editor and local note free of the added quote.
Custom mode saves the entire edited body locally when local saving is on,
including any quote you leave in it. Switching modes preserves separate plain
and custom drafts. None and custom require a non-empty body. Set the initial
choices under **NeoDB → Settings → Selection sharing defaults**. Changes made
in a composer apply only to that post. Cancelling creates no new highlight;
offline sharing saves the local note immediately and queues the post.
The **保存到本地：开 / 关** control below the editor defaults to on unless changed
in settings. Turn it off
to share without creating or editing local highlights or notes. With it on, an
empty note body saves a highlight only; with it off, a bare quote can still be
shared. The old **Share on NeoDB** selection-menu entry is replaced by this option.
The **Selection sharing defaults** submenu contains the quote mode, attaching
reading progress, local saving, visibility, block quote formatting and
crossposting. Existing visibility, formatting and crossposting preferences are
preserved and still apply to the other NeoDB actions that already use them.
**Highlight & share** respects the progress, visibility, formatting and
crossposting settings, and always saves the highlight and shares the quote.

The optional NeoDB title has its own single-line field above the note body in
the same window. The body scrolls and resizes when the keyboard opens or closes.
The title starts as **📖 读书笔记｜《书名》· 章名 · 48%**, using the current
book, chapter and live reading percentage. It can be edited or cleared; an
unavailable chapter is omitted.

**高亮&分享** saves the selection as a highlight and shares it immediately,
without opening a composer or picker. The post uses the same generated title
and contains only **引文如下：👇** followed by the quote, with no note text.
Offline posts wait in the upload queue. Sign in and link the book beforehand;
if either is missing, the highlight is still saved and a brief notification
explains why it could not be shared.

To update reading progress once an hour, turn on **Settings for this book → Update reading progress automatically**.

To upload highlights automatically, turn on  
**Settings for this book → Upload new highlights and notes automatically**.

To upload highlights manually, use **NeoDB → Upload all highlights and notes…**.

To upload highlights for many books at once, use **☰ → Tools → Export highlights**.

to have one-gesture access, bind **NeoDB: book actions** in **Settings → Taps and gestures → Gesture manager**.

## Working offline

Anything you do offline is queued. It goes out the next time you open a book, and you can send it yourself at any moment from **NeoDB → Uploads**, which also shows what is waiting. An upload that fails is tried three more times over about two minutes, then left for the next occasion.

To have the queue send itself instead, turn on **Settings → Upload automatically when connected**. It is off until you ask for it. With it on, anything waiting goes out quietly whenever the device goes online, whatever put it online: turn Wi-Fi on for some other reason and your backlog leaves behind it, with nothing to open and nothing to tap.

This never turns Wi-Fi on by itself, never interrupts you, and never sits there checking. KOReader tells the plugin when the device connects, so a reader who stays offline for a week pays no battery for it.


## Things to know

- Most settings explain themselves if you long-press them.
- **Your access token is stored in plain text** on the device. Anybody with the device, or with a backup of it, can read it. If you lose the device, cancel the token on your NeoDB server.
- Your device model may be sent to your server, so posts may show something like "from Kobo". Nothing else identifying is sent.
- [dev_notes.md](dev_notes.md) covers the rest: exactly how each feature behaves, its limits, and everything needed to work on the plugin.
