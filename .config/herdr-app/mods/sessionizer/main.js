// Go to a folder's space, like tmux-sessionizer: lists the same folders
// (tmux-sessionizer.sh --list), filters as you type, and on Enter selects the
// space already in that folder or starts a new one there.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, props, closeOverlay, theme, exec, home, spaces } from "herdr";

const LIST_SCRIPT = ".config/scripts/tmux-sessionizer.sh";
const VISIBLE_ROWS = 10;

function fuzzy(text, query) {
  let at = 0;
  for (const ch of query) {
    at = text.indexOf(ch, at);
    if (at < 0) return false;
    at++;
  }
  return true;
}

function basename(path) {
  return path.slice(path.lastIndexOf("/") + 1);
}

export default class Sessionizer extends View {
  init(_props, cx) {
    this.dirs = [];
    this.filter = "";
    this.at = 0;
    this.handle = cx.focus_handle();

    this.input = InputState.new({ placeholder: "Find a folder…" });
    this.input.on("change", (_e, cx) => {
      this.filter = this.input.value();
      this.at = 0;
      cx.notify();
    });
    this.input.on("submit", () => this.open(this.matches()[this.at]));
    this.input.focus();

    cx.spawn(async (cx) => {
      const r = await exec(`${home()}/${LIST_SCRIPT}`, ["--list"]);
      if (r.code === 0) this.dirs = r.stdout.split("\n").filter(Boolean);
      cx.notify();
    });
  }

  matches() {
    const q = this.filter.toLowerCase().replace(/\s+/g, "");
    if (!q) return this.dirs;

    const hits = this.dirs.filter((d) => fuzzy(d.toLowerCase(), q));
    const byName = (d) => (basename(d).toLowerCase().includes(q) ? 0 : 1);
    return hits.sort((a, b) => byName(a) - byName(b));
  }

  open(dir) {
    closeOverlay(props().overlay);
    if (!dir) return;

    const existing = spaces().find((s) => !s.machine && s.folder === dir);
    if (existing) return run("space.select", { id: existing.id });

    run("space.new", { folder: dir });
  }

  render(cx) {
    const t = theme();
    const matches = this.matches();
    const start = Math.max(0, this.at - VISIBLE_ROWS + 1);
    const shown = matches.slice(start, start + VISIBLE_ROWS);
    const tilde = (d) => (d.startsWith(home()) ? "~" + d.slice(home().length) : d);

    const row = (dir, i) => {
      const selected = start + i === this.at;
      return h_flex()
        .h(28)
        .px(10)
        .gap(10)
        .items_center()
        .rounded(6)
        .when(selected, (el) => el.bg(t.selected))
        .child(div().w(160).font_semibold().text_color(selected ? t.accent : t.foreground).child(basename(dir)))
        .child(div().flex_1().text_color(t.muted).child(tilde(dir)));
    };

    return v_flex()
      .id("sessionizer")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (e.key === "escape") return closeOverlay(props().overlay);

        const n = matches.length;
        if (!n) return;

        const down = e.key === "down" || (e.modifiers.control && (e.key === "n" || e.key === "j"));
        const up = e.key === "up" || (e.modifiers.control && (e.key === "p" || e.key === "k"));
        if (down) this.at = (this.at + 1) % n;
        else if (up) this.at = (this.at + n - 1) % n;
        else return;

        cx.stop_propagation();
        cx.notify();
      })
      .size_full()
      .p(14)
      .gap(10)
      .bg(t.popover)
      .text_size(12)
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().text_color(t.foreground).child("Open folder")).child(div().text_size(11).text_color(t.dim).child(`${matches.length} · Esc`)))
      .child(
        h_flex().h(36).flex_none().px(10).items_center().rounded(8).border_1().border_color(t.accent).bg(t.background)
          .child(Input.new(this.input).flex_1().h_full().text_size(12.8).text_color(t.foreground)),
      )
      .child(v_flex().gap(2).children(shown.map(row)));
  }
}
