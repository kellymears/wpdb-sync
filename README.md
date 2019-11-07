# WPDB Sync

## Install

Clone to `bin`, alias it, whatever you want. Doesn't need to be in your sites/web dir. Just terminal accessible.

## Examples

Create a new site like so:

```
./bin/wpdb-sync new site.com /Users/username/sites/site.com http://site.vagrant https://staging.site.com https://site.com
```

Now you can run commands like:

```
./bin/wpdb-sync site.com development staging`
```

## Signature

```
wpdb-sync new [host] [site_root] [development] [staging] [production]
```

```
wpdb-sync [host] [pull] [push]
```

