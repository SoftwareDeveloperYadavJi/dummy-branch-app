# Setting up local domain (branchloans.com)

To access the application via `https://branchloans.com` on your local machine, you need to add an entry to your hosts file.

## Windows

1. Open Notepad as Administrator (Right-click → Run as administrator)
2. Open the file: `C:\Windows\System32\drivers\etc\hosts`
3. Add this line at the end:
   ```
   127.0.0.1    branchloans.com www.branchloans.com
   ```
4. Save the file

## macOS / Linux

1. Open terminal
2. Edit the hosts file:
   ```bash
   sudo nano /etc/hosts
   ```
3. Add this line:
   ```
   127.0.0.1    branchloans.com www.branchloans.com
   ```
4. Save and exit (Ctrl+X, then Y, then Enter)

## Verify

After adding the entry, verify it works:
```bash
ping branchloans.com
```

You should see responses from 127.0.0.1

**Note:** If you already have the site open in your browser, you may need to clear your browser cache or use an incognito/private window.

