return {
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "yamatsum/nvim-nonicons",
    lazy = true,
    config = function() 
      require("nvim-nonicons").setup {}
    end
  },
  -- { "mskelton/termicons.nvim", lazy = true },
}
