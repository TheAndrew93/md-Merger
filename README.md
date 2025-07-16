**TL;DR:** Markdown Merger is a native macOS app that lets you select or drag‑and‑drop multiple `.md` files to produce one combined Markdown document separated by `---`. This README covers installation, launching, operation, and error handling.

---

# Markdown Merger

## I. Overview

1. **Purpose**

   * Combine multiple Markdown files into a single document with uniform separators for streamlined editing and publishing.
2. **Key Features**

   * Native macOS file picker and drag‑and‑drop support
   * Automatic insertion of `---` between file contents
   * In‑app reordering of selected files
   * Overwrite protection and detailed error alerts
  
3. **Requirements**

   | Component            | Minimum Version          |
   | -------------------- | ------------------------ |
   | macOS                | 12.0 (Monterey) or later |
   | Swift                | 5.6                      |
   | Xcode (for building) | 14.0 or later            |

## II. Installation

1. **Build or Download**

   * If building from source, open the Xcode project and build the **Release** configuration.
   * Locate `MarkdownMerger.app` in `~/Library/Developer/Xcode/DerivedData/.../Release/`.
2. **Deploy**

   * Copy `MarkdownMerger.app` into `/Applications` (or `~/Applications`).
   * Ensure standard permissions:

     ```bash
     chmod +x /Applications/MarkdownMerger.app/Contents/MacOS/MarkdownMerger
     ```
3. **Dock Pinning**

   * Launch the app, then right‑click its Dock icon → **Options** → **Keep in Dock**.

## III. Usage

1. **Launching**

   * Double‑click the `MarkdownMerger.app` in Finder or open via Spotlight (`⌘Space`, type “Markdown Merger”).
2. **Selecting Files**

   * Click **Select Files…** to open the native file picker (filters to `.md`).
3. **Drag‑and‑Drop**

   * Drag one or more `.md` files from Finder onto the window; only valid `.md` are accepted.
4. **Reordering**

   * Drag rows in the file list to adjust merge order (implicit on macOS).
5. **Merging**

   * Click **Merge** once two or more files are listed.
   * A Save dialog appears with default name `Merged_<YYYYMMDD_HHMMSS>.md`.
6. **Saving Output**

   * Choose destination folder; if the file exists, confirm overwrite or rename.
7. **Completion**

   * On success, the app reveals the merged file in Finder and displays a “Merge successful” status.

## IV. Troubleshooting

| Scenario                        | Alert Message                 | Action                                      |
| ------------------------------- | ----------------------------- | ------------------------------------------- |
| File cannot be read             | `File Read Error: <filename>` | Verify file exists and you have read access |
| Destination file already exists | `File Already Exists`         | Click **Overwrite** or select a new name    |
| No valid Markdown selected      | `No Markdown files selected.` | Pick `.md` files explicitly                 |
| Dock icon not updating          | (old icon appears)            | Run `killall Dock` in Terminal              |

* **Permissions Issues**
  Grant full disk access under **System Settings → Privacy & Security → Full Disk Access** if your files reside in protected locations.


## V. License

Permission is granted to use, modify, and share this code for any purpose.
This software is provided "as is", without warranty of any kind. No support is offered.
