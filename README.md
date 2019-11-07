# WPDB Sync

## Install

Clone to `bin`, alias it, whatever you want. Doesn't need to be in your site dir.

Give permission to run as an executable: `chmod u+x` on the `wpdb-sync` file in the project root.

## Signature and Usage

First, add a site to the wpdb-sync config (`~/.config/wpdb-sync`) using `wpdb-sync new`. You can add as many sites as you like by running `wpdb-sync new` multiple times.

```shell
wpdb-sync new {host} {site_root} {development} {staging} {production}
```

Now, you can push and pull the database between environments:

```shell
wpdb-sync {host} {origin} {destination}
```

## Assumptions

- You already have `wp-cli` aliases set up and you use the following naming convention: `@development`, `@staging`, `@production`.
