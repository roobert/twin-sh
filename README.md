# :magic_wand: This Week in NeoVIM - Contribution Wizard

![twin demo](https://user-images.githubusercontent.com/226654/212550237-8c8b6dc5-16c6-494c-911c-6e61fac12a14.gif)


## :rocket: Usage

```
bash <(curl -s https://raw.githubusercontent.com/roobert/twin-sh/main/twin.sh)
```

## :hammer_and_wrench: Description

This wizard does the following:
1. Creates a fork of `phaazon/this-week-in-neovim-contents`
2. Clones the repository
3. Asks what type of post you'd like to make [core-update, need-help, guide,
   new-plugin, new-project]
4. Asks for a name for your contribution depending on type
5. Creates a copy of the post-type template and updates the title, if required
6. Opens an editor for any adjustments to be made
7. Displays a preview of the post to be committed
8. Asks for confirmation before committing your post
9. Push the changes
10. Creates a PR against `phaazon/this-week-in-neovim-contents`

