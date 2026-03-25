# Git Commands Cheat Sheet

**A clean, guide to essential Git commands.**  
This README covers **everything from your original list** (all commands included with tiny accuracy fixes where needed), plus the important ones you were missing (`git init`, `git status`, `git clone`, `git push`, `git pull`, `git diff`, `git revert`, etc.).  

I checked **twice** for any new essential commands and added the most critical missing ones that every developer uses daily:  
- `git reflog` (lifesaver for recovering lost commits)  
- `git stash list` / `git stash pop` (already had basic stash — expanded for clarity)  
- A safer force-push option  

Everything is still organized, clean, and easy to copy-paste.

---

## 1. Setup & Configuration

| Command | Description |
|---------|-------------|
| `git config --global user.name "Your Name"` | Sets your name (appears in every commit) |
| `git config --global user.email "your@email.com"` | Sets your email (appears in every commit) |
| `git init` | **Initializes a new Git repository** in the current folder |

## 2. Staging Changes

| Command | Description |
|---------|-------------|
| `git add *` | Adds all files and folders (non-hidden) |
| `git add .` | Adds **all files, folders, and hidden files** |
| `git add filename` | Adds a specific file |
| `git status` | Shows what is staged, unstaged, or untracked |

## 3. Committing Changes

| Command | Description |
|---------|-------------|
| `git commit -m "Your commit message"` | Commits staged changes with a message |
| `git commit --amend --author "Name <my@email.com>"` | Changes author name & email **only for the latest commit** (editor opens — save & quit) |
| `git commit --amend -m "New commit message"` | Changes the commit message of the latest commit |
| `git commit --amend --no-edit` | Adds forgotten files to the latest commit (keeps same message) |

## 4. Viewing History & Changes

| Command | Description |
|---------|-------------|
| `git log --oneline` (or `git log --pretty=oneline`) | Compact list of commits (ID + message) |
| `git log -1` | Shows only the **latest** commit (change number for more) |
| `git log --follow -- filename` | Full history of a specific file (even after renames) |
| `git show commitid` | Shows **all changes** made in that commit |
| `git show commitid --name-only` | Shows **only the filenames** changed in that commit |
| `git show commitid --stat` | Shows stats (lines added/removed) for that commit |
| `git diff` | Shows unstaged changes |
| `git diff --staged` | Shows staged changes |

## 5. Undoing Changes

| Command | Description |
|---------|-------------|
| `git restore --staged filename` <br>or<br>`git rm --cached filename` | Unstages a file (removes it from staging area) |
| `git reset --hard HEAD~1` | **Deletes** the latest commit **and** all changes (change `~1` to `~n`) — **use with caution** |
| `git reset --soft HEAD~1` | Deletes the latest commit but **keeps changes staged** |
| `git revert commitid` | Creates a new commit that undoes the changes (safest way to undo) |

## 6. Branching & Merging

| Command | Description |
|---------|-------------|
| `git branch` | Lists all branches (current branch is highlighted) |
| `git branch branchname` | Creates a new branch |
| `git checkout -b branchname` | Creates **and switches** to a new branch |
| `git checkout branchname` | Switches to an existing branch |
| `git merge branchname` | Merges the specified branch into your current branch |
| `git branch -d branchname` | Deletes a branch **safely** (warns if commits are unmerged) |
| `git branch -D branchname` | Force-deletes a branch (no warning) |
| `git branch -m oldbranchname newbranchname` | Renames a branch |
| `git cherry-pick commitid` | Applies **only one specific commit** to your current branch |

## 7. Working with GitHub (Remote Repositories)

| Command | Description |
|---------|-------------|
| `git clone https://github.com/username/repo.git` | **Clones** a GitHub repository to your computer |
| `git remote add origin https://github.com/username/repo.git` | Connects your local repo to GitHub |
| `git remote -v` | Shows all connected remote repositories |
| `git push -u origin main` | **Pushes** your code to GitHub **and sets upstream** (use once) |
| `git push` | Pushes to GitHub (after upstream is set) |
| `git push origin branchname` | Pushes a specific branch |
| `git push --force-with-lease` | Safer force push (only if no one else pushed) |
| `git pull` | **Pulls** latest changes from GitHub and merges them |
| `git pull origin branchname` | Pulls from a specific branch |
| `git fetch` | Downloads changes from GitHub **without merging** (safe preview) |

## 8. Ignoring Files

Create a file named `.gitignore` in the root of your project:

```gitignore
# Example .gitignore content
node_modules/
*.log
.env
.DS_Store
```
## 9. Other Useful Commands

| Command | Description |
|--------|-------------|
| `git update-ref -d HEAD` | Deletes all commit history but keeps your files (very powerful — use carefully) |
| `git reflog` | Shows the full history of every action you did (even deleted commits). Life-saver when you mess up! |
| `git stash` | Temporarily saves uncommitted changes |
| `git stash list` | Lists all saved stashes |
| `git stash pop` | Restores the most recent stash |
| `git tag -a v1.0 -m "Version 1.0"` | Creates an annotated tag (great for releases) |
