# Shell Scripting

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
