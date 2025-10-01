# ⚡️ The Ultimate Shell Scripting & CLI Toolkit

This guide compiles essential and advanced command-line utilities for efficient system administration, diagnostics, and development in Unix-like environments.

---

## 📜 I. Shell Scripting Fundamentals: Tips & Tricks

Mastering the terminal starts with Bash itself. These concepts are the foundation for automating tasks using the tools listed below.

 Shell scripting is very important to perform the automate the tasks 

1. **To check in which directory we are use.**
   ```bash
   pwd
2. **To check list of files.**
   ```bash
   ls
3. **To create a files like pdf,dock,txt,yaml,py,etc.**
   ```bash
   touch filename
   touch step_{1..100}.txt #To Create Multiple files at a time use.
   touch -d tomorrow 1 # To create a file for tomorrow
 4. **To create directories or folders**
    ```bash
    mkdir first
    mkdir first_{1..50} # To create mulitple folders or directories
5. **To create and write in files use**
   `vim` vim first.txt
   Now you have entered into file use `i` to write, after finishing writing click `esc`+`:wq!` to save the file
   ```bash
   vim first.txt 
6. **To go to another directory or folder**
    ```bash
    cd first
    cd first/second
7. **To go back to previous folder**
   ```bash
   cd ..
   #To go back multiple directories
   cd ../..
8. **Removes an empty directory**
   ```bash
   rmdir first
9. **Removes files or directories.**
    ```bash
    rm file.txt
    rm -r directory_name
 10. **Concatenates and displays the content of a file.**
     ```bash
     cat first.tx
 11. **Copies files or directories.**
     ```bash
     cp file1.txt file2.txt
     cp file1.txt /home/ubuntu/second # To move the file to another folder ore directory
12. **Moves or renames files or directories.**
    ```bash
    mv file1.txt /home/ubuntu/second
13. **Displays the manual for a command.**
    ```bash
    man ls
14. **To clear the terminal**
    ```bash
    clear
15. **To list the hidden files**
    ```bash
    ls -a
    ls -ltr



Mastering the terminal starts with Bash itself. These concepts are the foundation for automating tasks using the tools listed below.

### 1. Basics & Best Practices

| Concept | Explanation & Basic Usage | Tips & Tricks |
| :--- | :--- | :--- |
| **Shebang** | The first line of any script, telling the system which interpreter to use. | `#!/bin/bash` or `#!/usr/bin/env bash` (More portable) |
| **Variables** | Storing data. Assign with `=` (no spaces), access with `$`. | `NAME="Alice"` **Tip:** Use `${NAME}` to prevent ambiguity, e.g., `${NAME}s_file`. |
| **Quoting** | Controls how the shell interprets special characters. | `echo 'Hello $USER'` (Single quotes: literal string) vs. `echo "Hello $USER"` (Double quotes: allows variable expansion) |
| **Exit Codes** | Every command returns a code (0 for success, 1-255 for failure). | `command && echo "Success"` (Execute if previous command succeeds) |
| **Error Handling** | Make scripts robust by exiting on failure. | **`set -e`** (Exit immediately if a command exits with a non-zero status). **`set -u`** (Treat unset variables as an error). |

### 2. Control Structures (Loops & Conditionals)

| Structure | Explanation & Basic Usage | Advanced Scripting |
| :--- | :--- | :--- |
| **Conditionals** | Executing code based on a condition (`if / elif / else`). | Use **`[[ ... ]]`** for string and file testing, as it's safer than single brackets `[ ]`. |
| | `if [[ -f "$FILE" ]]; then echo "File exists"; fi` | **Arithmetic:** Use `(( A > 5 ))` for mathematical comparison without the `$` prefix. |
| **`for` Loop (List)** | Iterates over a list of items (e.g., files, words, numbers). | `for file in *.log; do echo "$file"; done` |
| | **Tip (IFS):** Modify **`IFS`** (Internal Field Separator) to correctly loop over lines, e.g., `IFS=$'\n'`. |
| **`while` Loop** | Repeats a block of code as long as a condition remains true. | `while read line; do echo "$line"; done < file.txt` |
| | **Advanced:** Use `while :` or `while true` for infinite loops (e.g., in service monitoring scripts). |
| **Functions** | Grouping commands into a reusable block. | `check_status() { command; return $?; }` |
| | **Tip:** Use **`local`** inside functions for temporary variables to avoid overwriting global variables. |

### 3. Installation & Usage of Third-Party Tools

Most of the advanced tools listed in sections below are installed using your distribution's package manager:

| OS/Distribution | Package Manager Command | Example |
| :--- | :--- | :--- |
| **Debian/Ubuntu** | `sudo apt install <tool-name>` | `sudo apt install ncdu duf fzf` |
| **RHEL/CentOS/Fedora** | `sudo dnf install <tool-name>` | `sudo dnf install ripgrep exa` |
| **Arch Linux** | `sudo pacman -S <tool-name>` | `sudo pacman -S glances fd` |
| **macOS (Homebrew)** | `brew install <tool-name>` | `brew install mosh progress` |

***Usage Tip:*** If a modern tool is a drop-in replacement (like `exa` for `ls`), consider creating an alias in your `~/.bashrc` or `~/.zshrc`:
     
     alias ls='exa'
     alias grep='rg'
     alias find='fd'


## I. System & Resource Monitoring

| Command | Purpose | Basic Usage & Tips |
| :--- | :--- | :--- |
| **`glances`** | **All-in-one System Monitoring.** A cross-platform tool providing a high-level view of CPU, memory, disk I/O, and network. | `glances` |
| **`iotop`** | Displays real-time disk **I/O usage** by process or thread. | `sudo iotop` (Press **'o'** to show only processes performing I/O) |
| **`dstat`** | Versatile tool to generate combined resource statistics, replacing `vmstat`, `iostat`, and `ifstat`. | `dstat -c -d -n` (CPU, disk, network stats) |
| **`watch -n`** | Executes a command repeatedly at a specified interval, displaying the output in full screen. | `watch -n 1 'lsof -i :80'` (Watch port 80 connections update every second) |
| **`progress`** | Displays the estimated progress of running core utilities (`cp`, `mv`, `dd`, `tar`, etc.). | Run a background copy (`cp large.zip /tmp/ &`), then run `progress` |
| **`systemd-analyze`** | Displays metrics on system boot-up time and service initialization. | `systemd-analyze blame` (Lists services by boot time) |
| **`procs`** | A modern, more informative and colorful replacement for the `ps` command. | `procs` (Includes a tree view option: `--tree`) |
| **`lazydocker`** | A simple terminal UI for managing Docker and Docker Compose environments. | `sudo lazydocker` (Requires Docker to be running) |
| **`lshw`** | **List Hardware.** Comprehensive hardware configuration tool. | `sudo lshw -C cpu` (View CPU details) / `lshw -C memory` (View RAM details) |

---

## II. File, Disk & Search Utilities

| Command | Purpose | Basic Usage & Tips |
| :--- | :--- | :--- |
| **`ncdu`** | **NCurses Disk Usage.** An interactive text-based interface to analyze disk space consumption. | `ncdu /path/to/check` (Use **'d'** to delete selected item) |
| **`duf`** | A user-friendly and colorful replacement for `df` to check disk usage and free space. | `duf` |
| **`rg`** | **Ripgrep.** A lightning-fast search tool that respects `.gitignore` and is built for codebases. | `rg 'function_name'` (Much faster than `grep -r`) |
| **`fd`** | A simple, fast, and user-friendly alternative to the `find` command. | `fd 'readme' -e md` (Find all markdown files with 'readme' in the name) |
| **`exa`** | A modern, feature-rich replacement for `ls` with better defaults and Git integration. | `exa -T` (Tree view) / `exa --icons` (Requires a patched font) |
| **`stat`** | Displays detailed file or file system status (timestamps, size, block count). | `stat filename` / `stat -f .` (Get filesystem info) |
| **`unp`** | A single utility to unpack archives of almost any format (zip, tar, rar, etc.). | `unp archive.zip` |
| **`vidir`** | **VI Directory Editor.** Opens a directory's contents in your `$EDITOR` for bulk renaming or deletion. | `vidir` |
| **`vipe`** | **VI Pipe Editor.** Allows you to edit data mid-pipeline before it's passed to the next command. | `ls -l | vipe | grep 'txt'` (Edit file list before filtering) |

---

## III. Networking & Connectivity

| Command | Purpose | Basic Usage & Tips |
| :--- | :--- | :--- |
| **`mtr`** | **My Traceroute.** Combines `ping` and `traceroute` for continuous network diagnostics. | `mtr google.com` |
| **`mosh`** | **Mobile Shell.** A replacement for SSH that supports intermittent connectivity and roaming. | `mosh user@host` (Ideal for poor Wi-Fi or mobile connections) |
| **`dog`** | A modern, user-friendly replacement for `dig` for DNS lookups. | `dog example.com A` |
| **`termshark`** | A terminal UI for **tshark** (Wireshark's command-line tool) for packet analysis. | `sudo termshark -i eth0` |
| **`lsof -i`** | Lists open files and network connections, crucial for debugging port usage. | `lsof -i :80` (Shows all processes using port 80) |
| **`ipcalc`** | A simple utility to calculate various network parameters (netmask, broadcast, host range). | `ipcalc 192.168.1.5/24` |
| **`wormhole`** | **Magic Wormhole.** Securely transfers files between computers using a simple, human-speakable code. | `wormhole send filename` (Generates the code to share) |
| **`rsync`** | A fast, versatile file copying and synchronization utility, excellent for backups and remote transfers. | `rsync -avz source/ user@remote:destination/` |
| **`ping | ts`** | Pipes ping output to **`ts`** (from `moreutils`) to prepend a high-resolution timestamp. | `ping 8.8.8.8 -c 5 | ts '%H:%M:%.S'` (Essential for long-term monitoring) |
| **`ifdata`** | Prints network interface configuration data (IP, MAC, port speed). | `ifdata -p eth0` (Prints port speed) |

---

## IV. Productivity & Scripting Tools

| Command | Purpose | Basic Usage & Tips |
| :--- | :--- | :--- |
| **`fzf`** | **Fuzzy Finder.** A general-purpose command-line fuzzy finder for files, history, and more. | `history | fzf` (The killer combo for searching command history) |
| **`ranger`** | A VIM-like file manager with a multi-column view and image previews. | `ranger` |
| **`z`** | Jumps you to your most frequently/recently used directories with minimal input. | `z proj` (Jumps to the most frequent directory containing 'proj') |
| **`jq`** | A powerful, lightweight command-line **JSON processor** for parsing and manipulating API responses. | `curl ... | jq '.user.id'` |
| **`taskwarrior`** | A command-line to-do list and task management tool. | `task add "Review CLI toolkit README"` |
| **`asciinema`** | Records and plays back terminal sessions for easy sharing of tutorials and demos. | `asciinema rec my_demo.cast` (Stop with **`Ctrl+d`**) |
| **`errno`** | Looks up the meaning of system error numbers or names. | `errno EACCES` (Explains "Permission denied") |
| **`tldr`** | **"Too Long; Didn't Read."** Provides simplified, community-driven examples for complex commands. | `tldr tar` |
| **`fabric`** | A Python library and command-line tool for streamlining the use of SSH for deployment and administration. | `fab deploy` (Requires a `fabfile.py`) |
| **`agg`** / **`ai`** | *(Common placeholders for custom aggregation or AI scripts/aliases.)* | **Tips:** These often represent user-defined functions or tools like **`navi`** (cheatsheet) or **`shell-gpt`** (AI assistant). |
