# :magic_wand: This Week in NeoVIM - Contribution Wizard

![twin demo](https://user-images.githubusercontent.com/226654/212550615-d8b977f1-6cf8-44ab-a325-d67a1ecb96c6.gif)

## :rocket: Usage

```
bash <(curl -s https://raw.githubusercontent.com/roobert/twin-sh/main/twin.sh)
```

## :hammer_and_wrench: Description

This wizard does the following:
1. Creates a fork of `phaazon/this-week-in-neovim-contents`
2. Clones the repository
3. Asks what type of post you'd like to make from:
  * core-update
  * need-help
  * guide
  * new-plugin
  * update
4. Asks for a name for your contribution depending on type
5. Creates a copy of the post-type template and updates the title, if required
6. Open an editor for any adjustments to be made
7. Display a preview of the post to be committed
8. Ask for confirmation before committing your post
9. Push the changes
10. Create a PR against `phaazon/this-week-in-neovim-contents:<this-weeks-branch>`

## :heart: Todo

* Try to establish the number to use to prefix the post filename
* More testing
