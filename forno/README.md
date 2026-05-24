# FORNO — local menu images

This folder contains everything for the FORNO restaurant site:

```
index.html                      ← the site itself, open in any browser
download_menu_images.sh         ← run once to fetch 31 dish photos locally
assets/menu/m1.jpg ... m31.jpg  ← created by the script
```

## How it works

Each dish on the menu has a detailed text prompt. By default the site loads
images from `assets/menu/<id>.jpg`. If the local file is missing, the `<img>`
tag's `onError` handler automatically swaps in a live pollinations.ai URL
generated from the same prompt + seed — so the same image appears either way.

This means **the site works immediately**, even before you run the download
script. The script is just for going fully offline / removing the third-party
dependency.

## Running the download

```bash
chmod +x download_menu_images.sh
./download_menu_images.sh
```

- Takes ~5–10 minutes the first time (pollinations generates each image on demand).
- Idempotent: re-running skips images that already exist.
- Pass `--force` to regenerate everything from scratch:
  ```bash
  ./download_menu_images.sh --force
  ```

## Requirements

- `bash`, `curl`, `python3`, `file` — all preinstalled on macOS and Linux.
- On Windows: use WSL or Git Bash.

## Deploying

Once `assets/menu/` is populated, the whole folder is self-contained — drop it
on Netlify / Vercel / GitHub Pages / S3 / a USB stick. No build step.

## Customizing prompts

Both the website (`index.html`) and the downloader (`download_menu_images.sh`)
keep their prompts in sync via the `MENU` array in HTML and the matching
`fetch m1 "..."` calls in the script. If you change a prompt in one place,
update the other.

The shared style suffix (`FOOD_STYLE` in HTML, `STYLE` in the script) controls
the look across all 31 photos. Tweak it to taste — e.g. swap "rustic italian
trattoria" for "modern minimalist plating" — and re-run with `--force`.
