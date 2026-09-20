# QuizSphere · Socio Summer 3.0

Live event site and leaderboard for the **Socio Summer 3.0** quiz series at **IIT Bhubaneswar** (26 to 29 June 2026), organised by QuizSoc. Four days, four genres, one champion.

| Day | Quiz |
| --- | --- |
| 26 Jun | India |
| 27 Jun | Movies & TV Shows |
| 28 Jun | Sports |
| 29 Jun | Lines That Connect |

## Features

- **Launch countdown** until 25 June 2026, 10:00 AM IST, then the main site opens.
- **Schedule** that highlights the current day's quiz automatically (IST).
- **Leaderboards** for each quiz plus overall standings, with rank changes, player search and a pinned "my rank" bar.
- **Shareable results:** player achievement cards and podium images (PNG), per-quiz and overall PDF results, and CSV export.
- **Anonymous feedback form** for each quiz, unlocked on the evening of that quiz day.
- **Event extras:** announcements, quizmasters of the day, poster carousel, auto-generated storyline, champion reveal with confetti, and sound effects.
- **Hidden admin panel** for entering scores, players, announcements and posters.

## Tech

- One self-contained `index.html`: plain HTML, CSS and vanilla JavaScript. No framework, no build step.
- [Supabase](https://supabase.com) (REST API) as a simple key/value store for scores, players and feedback.
- [jsPDF](https://github.com/parallax/jsPDF) loaded from cdnjs for PDF export.

## Run it

Open `index.html` in a browser, or serve the folder locally:

```bash
python -m http.server 8000
```

Then visit `http://localhost:8000`. It can be hosted on any static host (Netlify, GitHub Pages, Vercel).

## Configuration

Settings are constants at the top of the `<script>` block in `index.html`:

| Constant | What it is |
| --- | --- |
| `SUPABASE_URL`, `SUPABASE_KEY` | Your Supabase project URL and its public `anon` key |
| `DB_TABLE` | Table name (`quizsphere`), with a unique text `key` column and a text `value` column |
| `ADMIN_SECRET` | Password for the admin panel (type `quizsoc` anywhere on the page to open the login) |
| `LAUNCH` | Date and time the countdown ends |

To reuse this for your own event, create your own Supabase project and table, then change these values along with the quiz names and dates in the `quizzes` list. A minimal table is `create table quizsphere (key text primary key, value text);`.

## Database security

This is a client-side app, so everything in `index.html`, including the Supabase URL, the public `anon` key and the admin password, is visible to anyone who opens the page. The admin password is a convenience lock, not real security.

Once an event is over, run [`supabase-rls.sql`](supabase-rls.sql) in the Supabase SQL Editor. It turns on Row Level Security so that:

- the public leaderboards, players, announcements and posters stay readable,
- nothing can be changed or deleted with the public key,
- participant feedback can no longer be read with the public key.

After that the site works as a read-only archive. The admin panel cannot save and the feedback form cannot submit, which is intended for a finished event. The file also has commented options to delete the feedback rows and to re-open the database for a new event.

If you run a live event with this app as built, the public key has to be able to write, so anyone who finds it could edit the data. For a real deployment, use your own Supabase project and consider moving admin logins to Supabase Auth.

## Credits

Built by Sriram G for QuizSoc, IIT Bhubaneswar.
