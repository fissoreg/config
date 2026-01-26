# Vi mode
fish_vi_key_bindings

# Zoxide - smart cd that learns your habits
# Usage:
#   z <partial>  - jump to frecent directory matching partial
#   zi           - interactive selection with fzf
# Zoxide tracks every cd and ranks by frecency (frequency + recency)
# Works automatically in shell and Yazi (press 'z' in Yazi)
zoxide init fish | source
