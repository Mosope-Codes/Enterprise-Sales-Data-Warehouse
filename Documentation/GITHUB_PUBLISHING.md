# Publishing this repository

1. Extract/copy these files into your existing local `Enterprise-Sales-Data-Warehouse` repository folder. Do not overwrite your existing `.git` directory.
2. Review `git status` and inspect the staged file list.
3. Confirm no credentials, private connection strings, `.env` files or confidential data are included.
4. Stage and commit:

```bash
git add .
git status
git commit -m "Complete Enterprise Sales Data Warehouse project"
git push origin main
```

The SSIS package files in this public copy have local machine identifiers replaced and the Python task paths set to placeholders. Update those paths and SQL connection managers in Visual Studio before executing this copy. Your original local project files are not modified by this packaging step.
