{ pkgs, ... }:

{
  enable = true;
  settings = {
    editor = {
      bufferline = "multiple";
      "color-modes" = true;
      cursorline = true;
      "line-number" = "relative";
      "completion-timeout" = 5;
      "true-color" = true;
      "cursor-shape" = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };
      "indent-guides" = {
        render = true;
      };
      statusline = {
        left = [ "mode" "file-name" "read-only-indicator" "file-modification-indicator" ];
        center = [ ];
        right = [ "diagnostics" "spinner" "selections" "register" "position" "file-encoding" ];
        mode = {
          normal = "π";
          insert = "ι";
          select = "ν";
        };
      };
      "file-picker" = {
        hidden = false;
      };
    };
    keys = {
      normal = {
        esc = [ "collapse_selection" "keep_primary_selection" ];
        tab = "goto_next_function";
        "S-tab" = "goto_prev_function";
        "C-y" = ":yank-diagnostic";
        "C-s" = ":w";
        X = "extend_line_above";
        "C-q" = ":q";
        "A-q" = ":q!";
        "C-w" = {
          c = ":bc";
        };
      };
      insert = {
        "C-c" = "yank_to_clipboard";
        "C-del" = [ "move_next_word_start" "delete_selection" ];
        "C-o" = [ "open_above" ];
        "C-p" = [ "paste_before" ];
        "C-s" = [ "normal_mode" ":w" ];
        "C-space" = [ "completion" ];
        "C-v" = [ "paste_clipboard_before" ];
        "C-u" = [ "undo" ];
        "A-u" = [ "redo" ];
        "A-c" = [ ":config-open" ];
        "C-e" = [ "move_next_word_start" ];
        "A-e" = [ "move_next_long_word_start" ];
        "C-y" = [ "yank" ];
        "C-w" = [ "move_next_word_end" "move_prev_word_end" "move_next_word_end" ];
        "A-w" = [ "move_next_long_word_end" "move_prev_long_word_start" "move_next_long_word_end" ];
        "C-left" = [ "move_prev_word_start" ];
        "C-right" = [ "move_next_word_end" ];
        "C-up" = [ "extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before" "move_line_up" ];
        "C-down" = [ "extend_to_line_bounds" "delete_selection" "paste_after" "move_line_down" ];
        up = "no_op";
        down = "no_op";
        left = "no_op";
        right = "no_op";
        pageup = "no_op";
        pagedown = "no_op";
        home = "no_op";
        end = "no_op";
      };
      select = {
        esc = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
      };
    };
  };
}
