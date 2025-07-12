# FileBrowser Lean

A lightweight and streamlined Docker image for [FileBrowser](https://filebrowser.org/), designed for minimal footprint and simplified deployment. This project builds the FileBrowser binary from source and packages it into a tiny busybox-based image.

## Why "Lean"?

*   **Minimal Image Size** 
*   **Simplified Configuration** 

## Comparison with Official `filebrowser/filebrowser` Docker Image

| Feature             | `filebrowser-lean` (This Project)                               | Official `filebrowser/filebrowser` Image                               |
| :------------------ | :-------------------------------------------------------------- | :----------------------------------------------------------------------- |
| **Base Image**      | `busybox:musl` (final stage)                                   | `alpine`                         |
| **Image Size**      | less than 20MB               | 50-60MB+           |
| **Configuration**   | No hard-coded user and healthcheck,<br>support passing --config arg for custom location  | Hard coded user, healthcheck and config file location           |

## Usage

Deployment is similar to filebrowser v2.33.0+. There is two differences:
- You don't have to change the permission of two mounted dirs. No more uid/gid mapping issues in rootless environment.
- You directly pass --config arg to container without overiding the whole entrypoint.

```bash
docker run -d \
  -p 8080:80 \
  -v /path/to/your/files:/srv \
  -v /path/to/your/config_and_db_dir:/config \
  --name filebrowser-lean \
  ghcr.io/outlook84/filebrowser-lean:latest
```

*   Replace `/path/to/your/files` with the absolute path to the directory you want FileBrowser to serve.
*   Replace `/path/to/your/config_and_db_dir` with an absolute path where you want the `settings.json` and `filebrowser.db` (new name for database) to persist. If `settings.json` is not present in this volume, a default one will be created.


### Migrating from Older Versions

If you are migrating from an official `filebrowser/filebrowser` image **older than v2.33.0**, you will need to follow these steps due to breaking changes in how configuration and database files are handled. 

Assume your original configuration file is `.filebrowser.json` and your database is `database.db`.

1.  **Prepare a New Configuration Directory**:
    Create a directory on your host machine to store the new configuration file and database. For example: `mkdir -p /path/to/your/config_and_db_dir`

2.  **Rename and Move Files**:
    -   Rename `.filebrowser.json` to `settings.json`.
    -   Rename `database.db` to `filebrowser.db`.
    -   Move both of these newly named files into the directory you just created (`/path/to/your/config_and_db_dir`).

4.  **Start with the New `docker run` Command above**


