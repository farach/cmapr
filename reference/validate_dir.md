# Validate Directory Exists

Checks if a directory exists and aborts with a helpful error message if
not.

## Usage

``` r
validate_dir(path, label = "path")
```

## Arguments

- path:

  Character string specifying the directory path to validate.

- label:

  Character string used in the error message to describe the path.
  Default is "path".

## Value

Invisibly returns TRUE if the directory exists.
