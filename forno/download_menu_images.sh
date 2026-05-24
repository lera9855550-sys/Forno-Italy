#!/usr/bin/env bash
# ============================================================================
# FORNO — download all menu photos from pollinations.ai into ./assets/menu/
# ============================================================================
#
# Usage:
#   chmod +x download_menu_images.sh
#   ./download_menu_images.sh
#
# This produces:   ./assets/menu/m1.jpg ... m31.jpg
# Place the `assets/` folder next to index.html and you're done.
#
# Re-runs are idempotent: existing files are skipped unless you pass --force.
# ============================================================================

set -euo pipefail

OUT_DIR="assets/menu"
FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

mkdir -p "$OUT_DIR"

# Unified style suffix appended to every prompt — same as in index.html
STYLE="professional food photography, rustic italian trattoria, dark wood table, warm cinematic lighting, overhead close-up, shallow depth of field, editorial style, appetizing, vibrant natural colors"

# URL-encode a string using python3 (POSIX-safe; works on macOS + Linux)
urlencode() {
  python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$1"
}

# fetch <id> <prompt>
fetch() {
  local id="$1"
  local prompt="$2"
  local out="$OUT_DIR/${id}.jpg"

  if [[ -f "$out" && "$FORCE" != "true" ]]; then
    echo "  ✓ $id  (cached)"
    return 0
  fi

  local seed="${id//[!0-9]/}"
  local full="$prompt, $STYLE"
  local encoded
  encoded=$(urlencode "$full")
  local url="https://image.pollinations.ai/prompt/${encoded}?width=800&height=800&model=flux&seed=${seed}&nologo=true&nofeed=true"

  printf "  → %-3s  " "$id"
  # Retry up to 3 times with backoff — first generation can take 15-30s and
  # occasionally times out
  local try
  for try in 1 2 3; do
    if curl -fsSL --max-time 120 -o "$out.tmp" "$url"; then
      # Verify it's actually a JPEG (pollinations returns text on failure)
      if file "$out.tmp" 2>/dev/null | grep -qiE 'jpeg|jpg|image'; then
        mv "$out.tmp" "$out"
        local size
        size=$(du -h "$out" | cut -f1)
        echo "ok ($size)"
        return 0
      fi
    fi
    rm -f "$out.tmp"
    if [[ $try -lt 3 ]]; then
      printf "retry %d… " "$try"
      sleep $((try * 2))
    fi
  done
  echo "FAILED"
  return 1
}

echo "Downloading 31 menu photos to $OUT_DIR/ …"
echo "(first run takes ~5-10 minutes; pollinations generates each on demand)"
echo

# ---------------- Pizze ----------------
fetch m1  "wood-fired neapolitan margherita pizza, charred crust, fresh basil leaves, melted mozzarella, red tomato sauce, drizzle of olive oil"
fetch m2  "classic margherita pizza with buffalo mozzarella di bufala, torn basil leaves, sea salt flakes, round whole pizza"
fetch m3  "gourmet truffle mushroom pizza with porcini and cremini mushrooms, melted taleggio cheese, fresh black truffle shavings on top"
fetch m4  "spicy diavola pizza with red nduja sausage, smoked mozzarella, drizzle of hot honey, chili flakes, wood-fired crust"
fetch m5  "pizza topped with fresh burrata cheese in center, slices of prosciutto di parma, fresh arugula, after baking"
fetch m6  "quattro formaggi four cheese pizza with melted mozzarella gorgonzola fontina and parmigiano, golden bubbly crust, no tomato sauce"
fetch m7  "pizza with green basil pesto base, grilled chicken pieces, sun-dried tomatoes, pine nuts scattered on top"
fetch m8  "carbonara pizza with crispy guanciale bacon, creamy pecorino sauce, runny egg yolk in the center, cracked black pepper"
fetch m9  "neapolitan pizza napoli with anchovy fillets, capers, black taggiasca olives, dried oregano, tomato sauce, no cheese"
fetch m10 "pizza with bright green pistachio cream base, folded slices of pink mortadella, white stracciatella cheese dollops, crushed pistachios"
fetch m11 "thin crust pizza topped after baking with raw prosciutto di parma slices, fresh wild arugula leaves, shaved parmigiano flakes, lemon wedge"

# ---------------- Antipasti ----------------
fetch m12 "fresh burrata cheese ball cut open with creamy interior on plate, topped with crushed bronte pistachios, drizzle of honey, olive oil"
fetch m13 "bruschetta on charred sourdough toast, smoked ricotta spread, diced heirloom tomatoes, fresh basil leaves, served on wooden board"
fetch m14 "crispy golden fried polenta cubes squares on plate, drizzle of gorgonzola cheese sauce fonduta, crushed walnuts on top"
fetch m15 "italian crostini on toasted ciabatta slices, whipped ricotta cheese spread, prosciutto folded on top, drizzle of fig jam"
fetch m16 "rustic country bread toast topped with creamy burrata cheese, black truffle shavings, drizzle of truffle honey, micro herbs garnish"
fetch m17 "thick italian focaccia bread with dimples, topped with slow roasted cherry tomatoes, fresh rosemary sprigs, sea salt flakes"
fetch m18 "crispy breaded zucchini fries sticks with golden parmesan crust, small bowl of lemon aioli dipping sauce, lemon wedge"
fetch m19 "whipped fluffy ricotta cheese in bowl, drizzle of golden chestnut honey, toasted hazelnuts, flaky sea salt, with bread on side"
fetch m20 "sicilian arancini, crispy golden fried saffron risotto balls cut open showing meat ragu filling, small bowl of basil aioli dip"
fetch m21 "roman style charred grilled artichokes carciofi alla romana, lemon wedges, shaved parmigiano cheese, drizzle of olive oil, served on plate"
fetch m22 "fresh burrata cheese ball cut open creamy center, cherry tomato confit, green basil oil drizzle, sourdough bread on side"
fetch m23 "italian charcuterie plate with prosciutto di parma slices, fresh cantaloupe melon wedges, fig jam, focaccia bread"

# ---------------- Pasta ----------------
fetch m24 "creamy tagliatelle pasta with fresh black truffle shavings on top, parmigiano cheese, twirled in white pasta bowl"
fetch m25 "authentic spaghetti carbonara pasta with crispy guanciale, pecorino cheese, runny egg yolk, cracked black pepper, no cream"
fetch m26 "homemade italian lasagna slice showing layers of pasta sheets, beef ragu sauce, bechamel cream, melted parmigiano on top, golden crust"
fetch m27 "fresh handmade ricotta ravioli pasta on plate, golden brown butter sauce, crispy fried sage leaves, lemon zest sprinkled"

# ---------------- Dolci ----------------
fetch m28 "classic italian tiramisu dessert square in glass dish, layers of mascarpone cream and espresso-soaked savoiardi ladyfingers, dusted with cocoa powder"
fetch m29 "scoop of green bronte pistachio gelato ice cream in small bowl, crushed pistachios, drizzle of olive oil, flaky sea salt"

# ---------------- Bevande ----------------
fetch m30 "orange aperol spritz cocktail in wine glass with ice cubes, orange wheel slice garnish, bubbles, on dark wood table"
fetch m31 "double espresso coffee in small white ceramic cup with golden crema on top, on saucer, italian bar style"

echo
echo "Done! All 31 photos saved in $OUT_DIR/"
echo "Re-run with './download_menu_images.sh --force' to regenerate everything."
