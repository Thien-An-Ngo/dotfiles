{ config, pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;

    # Managed by Nix — replaces TPM entirely
    plugins = with pkgs.tmuxPlugins; [
      sensible
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      yank
      vim-tmux-navigator
    ];

    extraConfig = ''
      # ── Fastfetch on new session ────────────────────────────────────
      set-hook -g after-new-session 'send-keys "fastfetch" Enter'

      # ── Core ───────────────────────────────────────────────────────
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g history-limit 50000
      set -g mouse on
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      set -g escape-time 10
      set -g focus-events on
      set -g set-clipboard on

      # ── Prefix: Ctrl+a ─────────────────────────────────────────────
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # ── Key bindings ───────────────────────────────────────────────
      bind r source-file ~/.tmux.conf \; display-message " Config reloaded!"

      # Splits (stay in current path)
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Pane navigation — vim-style
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Window switching
      bind -r n next-window
      bind -r p previous-window
      bind Tab last-window

      # Session tree
      bind s choose-tree -Zs

      # Kill without confirm
      bind x kill-pane
      bind X kill-window
      bind Q kill-session

      # Zoom
      bind z resize-pane -Z

      # Copy mode (vi keys)
      setw -g mode-keys vi
      bind Enter copy-mode
      bind -T copy-mode-vi v     send -X begin-selection
      bind -T copy-mode-vi y     send -X copy-pipe-and-cancel "clip.exe 2>/dev/null || xclip -sel clip 2>/dev/null || xsel --clipboard"
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi H     send -X start-of-line
      bind -T copy-mode-vi L     send -X end-of-line

      # Quick layouts
      bind M-1 select-layout even-horizontal
      bind M-2 select-layout even-vertical
      bind M-3 select-layout main-vertical
      bind M-4 select-layout tiled

      # Move windows
      bind -r < swap-window -d -t -1
      bind -r > swap-window -d -t +1

      # ── PASTEL POWERLINE THEME ─────────────────────────────────────
      # Palette matches starship.toml:
      #   #9A348E purple | #DA627D salmon | #FCA17D peach
      #   #86BBD8 steel  | #06969A teal   | #33658A navy

      # Pane borders
      set -g pane-border-style        "fg=#44475a"
      set -g pane-active-border-style "fg=#9A348E"

      # Messages
      set -g message-style         "fg=#f8f8f2,bg=#44475a,bold"
      set -g message-command-style "fg=#f8f8f2,bg=#44475a"

      # Copy-mode highlight
      setw -g mode-style "fg=#f8f8f2,bg=#9A348E,bold"

      # Status bar
      set -g status 2
      set -g status-interval 5
      set -g status-position bottom
      set -g status-justify left
      set -g status-left-length 60
      set -g status-right-length 120
      set -g status-style "bg=default"

      # LEFT: session pill (purple) + PREFIX indicator (peach)
      set -g status-left "#[fg=#9A348E,bg=default]#[fg=#f8f8f2]#[bg=#9A348E]#[bold] 󰌌 #S #{?client_prefix,#[fg=#9A348E]#[bg=#FCA17D]#[fg=#9A348E]#[bg=#FCA17D]#[bold] ⌨ PREFIX #[fg=#FCA17D]#[bg=default],#[fg=#9A348E]#[bg=default]}#[default] "

      # WINDOW TABS — inactive: muted rounded pill
      setw -g window-status-format "#[fg=#44475a,bg=default]#[fg=#6272a4,bg=#44475a] #I #[fg=#f8f8f2,bg=#44475a]#W #[fg=#44475a,bg=default]"

      # WINDOW TABS — active: salmon → peach rounded pill
      setw -g window-status-current-format "#[fg=#DA627D,bg=default]#[fg=#f8f8f2,bg=#DA627D,bold] #I #[fg=#DA627D,bg=#FCA17D]#[fg=#f8f8f2,bg=#FCA17D,bold] #W#{?window_zoomed_flag, 󰊓,} #[fg=#FCA17D,bg=default]"

      setw -g window-status-separator " "

      # TOP bar: empty spacer row
      set -g status-format[0] "#[bg=default,fg=default]"
      # BOTTOM bar: full powerline (tmux's default format[1])
      set -g status-format[1] "#[align=left range=left #{E:status-left-style}]#[push-default]#{T;=/#{status-left-length}:status-left}#[pop-default]#[norange default]#[list=on align=#{status-justify}]#[list=left-marker]<#[list=right-marker]>#[list=on]#{W:#[range=window|#{window_index} #{E:window-status-style}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-format}#[pop-default]#[norange default]#{?window_end_flag,,#{window-status-separator}},#[range=window|#{window_index} list=focus #{?#{!=:#{E:window-status-current-style},default},#{E:window-status-current-style},#{E:window-status-style}}#{?#{&&:#{window_last_flag},#{!=:#{E:window-status-last-style},default}}, #{E:window-status-last-style},}#{?#{&&:#{window_bell_flag},#{!=:#{E:window-status-bell-style},default}}, #{E:window-status-bell-style},#{?#{&&:#{||:#{window_activity_flag},#{window_silence_flag}},#{!=:#{E:window-status-activity-style},default}}, #{E:window-status-activity-style},}}]#[push-default]#{T:window-status-current-format}#[pop-default]#[norange list=on default]#{?window_end_flag,,#{window-status-separator}}}#[nolist align=right range=right #{E:status-right-style}]#[push-default]#{T;=/#{status-right-length}:status-right}#[pop-default]#[norange default]"

      # RIGHT: steel → teal → navy (mirrors starship language/docker/time segments)
      set -g status-right "#[fg=#86BBD8,bg=default]#[fg=#21222c,bg=#86BBD8] 󰥔 %H:%M #[fg=#86BBD8,bg=#06969A]#[fg=#f8f8f2,bg=#06969A] 󰃭 %d.%m.%y #[fg=#06969A,bg=#33658A]#[fg=#f8f8f2,bg=#33658A,bold]  #H #[fg=#33658A,bg=default]"
    '';
  };
}
