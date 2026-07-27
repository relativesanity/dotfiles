-- Emmet abbreviation expansion (div.card>ul>li*2 → markup) on <C-y>,
--
-- Pure vimscript, no node/LSP server: this config has no completion engine, so
-- an emmet *language server* would have nothing to surface its candidates in.
--
-- eruby needs no g:user_emmet_settings entry — emmet has no eruby lang module,
-- and its getFileType() falls back to html for anything it can't place, which is
-- exactly what .html.erb wants. Listing eruby in ft is what makes it load there.
return {
  "mattn/emmet-vim",
  ft = { "html", "eruby", "css", "scss", "javascriptreact", "typescriptreact" },
}
