// tmux-style prefix: opened by the leader key, runs the command bound to the
// next key, then closes. Esc or any unbound key closes without running.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, theme } from "herdr";

const BINDINGS = [
  ['"', "split down", "pane.split", { direction: "down" }],
  ["%", "split right", "pane.split", { direction: "right" }],
  ["h", "focus left", "pane.go", { direction: "left" }],
  ["j", "focus down", "pane.go", { direction: "down" }],
  ["k", "focus up", "pane.go", { direction: "up" }],
  ["l", "focus right", "pane.go", { direction: "right" }],
  ["H", "swap left", "pane.swap", { direction: "left" }],
  ["J", "swap down", "pane.swap", { direction: "down" }],
  ["K", "swap up", "pane.swap", { direction: "up" }],
  ["L", "swap right", "pane.swap", { direction: "right" }],
  ["z", "zoom pane", "pane.zoom", {}],
  ["x", "close pane", "pane.close", {}],
  ["c", "new tab", "tab.new", {}],
  ["n", "next tab", "tab.next", {}],
  ["p", "prev tab", "tab.prev", {}],
  ["s", "picker", "mod.open", { name: "tab-picker" }],
  ["t", "open folder", "mod.open", { name: "sessionizer" }],
  ["1-9", "tab N", null, null],
];

const DIGIT = /^[1-9]$/;

function commandFor(key) {
  if (DIGIT.test(key)) return ["tab.select", { index: Number(key) }];

  const binding = BINDINGS.find(([k, , command]) => k === key && command);
  if (!binding) return null;

  return [binding[2], binding[3]];
}

export default class Leader extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  press(e) {
    closeOverlay(props().overlay);

    const command = commandFor(e.key_char ?? e.key);
    if (!command) return;

    run(command[0], command[1]);
  }

  render(cx) {
    const t = theme();
    const row = ([key, label]) =>
      h_flex()
        .w(180)
        .gap(10)
        .child(div().w(28).font_semibold().text_color(t.accent).child(key))
        .child(div().text_color(t.muted).child(label));

    return v_flex()
      .id("leader")
      .track_focus(this.handle)
      .on_key_down((e, cx) => {
        this.press(e);
        cx.stop_propagation();
      })
      .size_full()
      .p(14)
      .gap(8)
      .rounded(8)
      .bg(t.popover)
      .text_size(12)
      .child(h_flex().items_center().child(div().flex_1().text_size(13).font_semibold().text_color(t.foreground).child("Leader")).child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(h_flex().flex_wrap().gap_y(4).gap_x(12).children(BINDINGS.map(row)));
  }
}
