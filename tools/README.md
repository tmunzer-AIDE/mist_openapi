# Tools Directory

This directory contains utility scripts for working with the Mist OpenAPI repository.

## Scripts

### api-doc-diff.sh

**Purpose**: Compare Mist API documentation files between two git tags from an external API repository.

**Description**: This script extracts documentation markdown files from two different git tags in a specified repository, saves them to a temporary directory, and opens VS Code for easy side-by-side comparison.

**Usage**:

Only contributors from Juniper/HPE will be able to run this.

```bash
./tools/api-doc-diff.sh <path> <from_tag> <to_tag>
```

**Arguments**:

- `path` - Path to the Mist API repository (must be a valid git repository).
- `from_tag` - Git tag to compare from (e.g., `v1.0.0`, `release-2023-01`).
- `to_tag` - Git tag to compare to (e.g., `v1.1.0`, `release-2023-02`).

**Example**:

```bash
./tools/api-doc-diff.sh /path/to/mist-api v1.0.0 v1.1.0
```

**What it does**:

1. Validates all input parameters and checks that the path is a valid git repository.
2. Verifies that both specified tags exist in the repository.
3. Creates a temporary directory structure: `/tmp/api-doc-diff/YYYYMMDD/`.
4. Extracts the following documentation files from both tags:
   - `docs/src/Home.md`
   - `docs/src/Overview.md`
   - `docs/src/Auth.md`
   - `docs/src/Site.md`
   - `docs/src/Org.md`
   - `docs/src/MSP.md`
5. Opens VS Code with the temporary directory containing both versions.
6. Prints the location of extracted files for reference.
7. Returns to the original working directory.

**Features**:

- ✅ Color-coded output (errors in red, warnings in yellow, success in green).
- ✅ Comprehensive error handling and validation.
- ✅ Graceful handling of missing files (creates `.missing` placeholder files with warnings).
- ✅ Progress indicators with checkmarks.
- ✅ Automatic directory creation and cleanup indicators.

**Output Location**:

Files are extracted to: `/tmp/api-doc-diff/YYYYMMDD/<tag_name>/`.

Where `YYYYMMDD` is the current date (e.g., `20251104`).

**Requirements**:

- Git must be installed and accessible in PATH.
- VS Code must be installed with the `code` command available.
- Read access to the target git repository.
- Write access to `/tmp` directory.

**Error Handling**:

- Missing parameters → displays usage help.
- Invalid path → exits with error message.
- Not a git repository → exits with error message.
- Non-existent tags → exits with error message.
- Missing files in a tag → warns but continues (useful for comparing different versions where files may have been added/removed).
